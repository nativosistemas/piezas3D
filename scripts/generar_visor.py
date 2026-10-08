#!/usr/bin/env python3
"""Genera el visor 3D de armado de un diseño de varias piezas (fase 5).

    scripts/generar_visor.py <diseño> <carpeta_de_la_spec>
    scripts/generar_visor.py puntero_laser specs/002-puntero-laser-estelar
    scripts/generar_visor.py --comprobar puntero_laser specs/002-puntero-laser-estelar
    scripts/generar_visor.py --reexportar puntero_laser specs/002-puntero-laser-estelar

Normalmente no se llama a mano: lo llama scripts/generar_web.py cuando el diseño tiene ensamblaje.

Lee (fuentes únicas):
    src/<diseño>_ensamblaje.scad   tabla de pasos, colores, contexto y cada elemento (vía OpenSCAD,
                                   con la biblioteca src/armado_comun.scad)
    docs/<diseño>_guia.md          título y texto de cada paso
    scripts/plantilla_visor.html   la página
    scripts/vendor/three-0.160.0/  motor 3D, incrustado para funcionar sin internet

Escribe:
    <carpeta_de_la_spec>/web/armado_3d.html   un solo archivo, sin recursos externos

La página guarda una huella de las fuentes del ensamblaje: si no cambiaron, se reutilizan sus mallas
y no se ejecuta OpenSCAD. Con --comprobar no escribe nada y termina con 1 si el visor no está al día
(tampoco ejecuta OpenSCAD). Con --reexportar exporta todo aunque la huella coincida.
Contrato: specs/005-visor-armado-3d/contracts/scripts.md. Solo usa la biblioteca estándar de Python.
"""
import argparse
import base64
import concurrent.futures
import glob
import hashlib
import json
import os
import re
import struct
import subprocess
import sys
import tempfile

RAIZ = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
OPENSCAD = os.path.join(RAIZ, ".tools", "bin", "openscad")
PLANTILLA = os.path.join(RAIZ, "scripts", "plantilla_visor.html")
MOTOR = os.path.join(RAIZ, "scripts", "vendor", "three-0.160.0")
VERSION = 1             # formato de los datos incrustados
FN_VISOR = 32           # resolución de las curvas en el visor (las STL de impresión usan 64)
TAMANO_MAXIMO = 10e6    # bytes por diseño (FR-005)
RE_DATOS = re.compile(r'<script type="application/json" id="datos-visor">(.*?)</script>', re.S)


class Fallo(Exception):
    """Error con un mensaje para la persona; termina con código 1."""


def rel(ruta):
    return os.path.relpath(ruta, RAIZ)


# --- Fuentes ---
def huella(diseno):
    """SHA-256 de todo lo que determina las piezas y los pasos: los .scad del diseño, la biblioteca
    común, el perfil de la impresora y la resolución del visor."""
    rutas = sorted(glob.glob(os.path.join(RAIZ, "src", f"{diseno}_*.scad"))) + [
        os.path.join(RAIZ, "src", "armado_comun.scad"), os.path.join(RAIZ, "src", "perfil_impresora.scad")]
    h = hashlib.sha256(f"fn={FN_VISOR}\n".encode())
    for r in rutas:
        h.update(rel(r).encode() + b"\n")
        with open(r, "rb") as f:
            h.update(f.read())
    return "sha256:" + h.hexdigest()


def pasos_de_la_guia(diseno):
    """Título y texto de cada paso de "Instrucciones Paso a Paso" (lista numerada con título en negrita)."""
    ruta = os.path.join(RAIZ, "docs", f"{diseno}_guia.md")
    with open(ruta, encoding="utf-8") as f:
        guia = f.read()
    titulo = re.sub(r"^#\s+(Guía de Producción:\s*)?", "", guia.split("\n", 1)[0]).strip()
    m = re.search(r"^### Instrucciones Paso a Paso\s*$(.*?)(?=^##)", guia, re.M | re.S)
    if not m:
        raise Fallo(f"{rel(ruta)} no tiene la sección '### Instrucciones Paso a Paso'")
    pasos = []
    for item in re.finditer(r"^(\d+)\. \*\*(.+?)\*\*[ \t]*(.*?)(?=^\d+\. \*\*|\Z)", m.group(1), re.M | re.S):
        lineas, texto = item.group(3).split("\n"), []
        for linea in lineas:
            linea = linea.strip()
            if not linea:
                continue
            vineta = re.match(r"^[-*] +(.*)", linea)
            if vineta:
                texto.append("\n• " + vineta.group(1))
            elif texto and not texto[-1].endswith("\n"):
                texto[-1] += " " + linea
            else:
                texto.append(linea)
        pasos.append({"n": int(item.group(1)), "titulo": item.group(2).rstrip(".").strip(),
                      "texto": "".join(texto).strip()})
    if [p["n"] for p in pasos] != list(range(1, len(pasos) + 1)):
        raise Fallo(f"{rel(ruta)}: los pasos de armado no están numerados 1, 2, 3…")
    return titulo, pasos


# --- OpenSCAD ---
def openscad(ensamblaje, salida, *definiciones):
    args = [OPENSCAD]
    for d in definiciones:
        args += ["-D", d]
    r = subprocess.run(args + ["-o", salida, ensamblaje], capture_output=True, text=True)
    avisos = [l for l in r.stderr.splitlines() if l.startswith(("ERROR", "WARNING"))]
    return r.returncode == 0 and not avisos, "\n".join(avisos) or r.stderr[-500:]


def datos_del_ensamblaje(ensamblaje, carpeta):
    eco = os.path.join(carpeta, "pasos.echo")
    ok, error = openscad(ensamblaje, eco, "paso_armado=-1")
    if not ok:
        raise Fallo(f"{rel(ensamblaje)} falló con paso_armado=-1:\n{error}")
    with open(eco, encoding="utf-8") as f:
        texto = f.read()
    vector = lambda s: json.loads(re.sub(r"\bundef\b", "null", s.replace('\\"', '"')))
    m = re.search(r'^ECHO: "PASOS;(.*)"$', texto, re.M)
    if not m:
        raise Fallo(f"{rel(ensamblaje)} no entrega los datos de los pasos "
                    "(ver la skill disenio-multipieza: include <armado_comun.scad> y armado())")
    tabla = vector(m.group(1))
    colores = dict(re.findall(r'^ECHO: "COLOR;([^;]+);([^"]+)"$', texto, re.M))
    contextos = {int(n): vector(v) for n, v in re.findall(r'^ECHO: "CONTEXTO;(\d+);(.*)"$', texto, re.M)}
    pasos = [{"entradas": [{"e": en[0], "d": en[1], "r": en[2],
                            "o": en[3] if len(en) > 3 else None, "g": en[4] if len(en) > 4 else None}
                           for en in entradas],
              "contexto": contextos.get(n, [])}
             for n, entradas in enumerate(tabla, start=1)]
    return pasos, colores


def malla(ensamblaje, carpeta, nombre):
    """Exporta un elemento y devuelve las posiciones de sus triángulos en Float32, en base64."""
    stl = os.path.join(carpeta, f"{nombre}.stl")
    ok, error = openscad(ensamblaje, stl, f'solo_elemento="{nombre}"', f"$fn={FN_VISOR}")
    if not ok or not os.path.isfile(stl):
        return nombre, None, error
    with open(stl, encoding="utf-8") as f:
        coords = [float(v) for linea in f if linea.lstrip().startswith("vertex") for v in linea.split()[1:4]]
    if not coords:
        return nombre, None, "la malla está vacía"
    return nombre, base64.b64encode(struct.pack(f"<{len(coords)}f", *coords)).decode(), None


def exportar(ensamblaje):
    with tempfile.TemporaryDirectory(prefix="visor_") as carpeta:
        pasos, colores = datos_del_ensamblaje(ensamblaje, carpeta)
        nombres = sorted({en["e"] for p in pasos for en in p["entradas"]} | {e for p in pasos for e in p["contexto"]})
        donde = {}
        for n, p in enumerate(pasos, start=1):
            for e in [en["e"] for en in p["entradas"]] + p["contexto"]:
                donde.setdefault(e, n)
        elementos, errores = {}, []
        with concurrent.futures.ThreadPoolExecutor(max_workers=os.cpu_count() or 2) as hilos:
            for nombre, b64, error in hilos.map(lambda e: malla(ensamblaje, carpeta, e), nombres):
                if error:
                    errores.append(f"No se pudo exportar '{nombre}' (paso {donde[nombre]}): {error}")
                else:
                    elementos[nombre] = {"color": colores.get(nombre, ""), "malla": b64}
        if errores:
            raise Fallo("\n".join(errores))
    return pasos, elementos


# --- Página ---
def datos_de_pagina(ruta):
    if not os.path.isfile(ruta):
        return None
    with open(ruta, encoding="utf-8") as f:
        m = RE_DATOS.search(f.read())
    return json.loads(m.group(1)) if m else None


def armar_pagina(titulo, datos):
    with open(PLANTILLA, encoding="utf-8") as f:
        plantilla = f.read()
    modulo = lambda archivo: "data:text/javascript;base64," + base64.b64encode(
        open(os.path.join(MOTOR, archivo), "rb").read()).decode()
    mapa = {"imports": {"three": modulo("three.module.min.js"),
                        "three/addons/controls/OrbitControls.js": modulo("OrbitControls.js")}}
    json_datos = json.dumps(datos, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    return (plantilla
            .replace("{{titulo}}", f"Armado 3D: {titulo}".replace("&", "&amp;").replace("<", "&lt;"))
            .replace("/*IMPORTMAP*/", json.dumps(mapa, separators=(",", ":")))
            .replace("/*DATOS*/", json_datos.replace("</", "<\\/")))


def validar(datos, pagina):
    for p in datos["pasos"]:
        for e in [en["e"] for en in p["entradas"]] + p["contexto"]:
            el = datos["elementos"].get(e)
            if not el or not el["color"] or not el["malla"]:
                raise Fallo(f"El elemento '{e}' (paso {p['n']}) no tiene color o malla")
    tamano = len(pagina.encode("utf-8"))
    if tamano > TAMANO_MAXIMO:
        pesados = sorted(datos["elementos"].items(), key=lambda kv: -len(kv[1]["malla"]))[:5]
        raise Fallo(f"El visor pesa {tamano/1e6:.1f} MB (máx. {TAMANO_MAXIMO/1e6:.0f}). Más pesados: "
                    + ", ".join(f"{k} ({len(v['malla'])*3/4/1e6:.1f} MB)" for k, v in pesados))
    if re.search(r"""(?:src|href)\s*=\s*["']https?://""", pagina):
        raise Fallo("La página carga recursos de internet: el visor tiene que funcionar sin conexión")
    return tamano


def generar(diseno, carpeta_spec, reexportar=False):
    """Devuelve (ruta, página nueva, datos nuevos, datos de la página actual o None, si reutilizó mallas)."""
    ensamblaje = os.path.join(RAIZ, "src", f"{diseno}_ensamblaje.scad")
    if not os.path.isfile(ensamblaje):
        raise Fallo(f"No existe {rel(ensamblaje)}: el diseño no tiene visor 3D")
    ruta = os.path.join(RAIZ, carpeta_spec, "web", "armado_3d.html")
    titulo, guia = pasos_de_la_guia(diseno)
    actual = datos_de_pagina(ruta)
    firma = huella(diseno)
    reutiliza = (not reexportar and actual is not None and actual.get("version") == VERSION
                 and actual.get("huella") == firma)
    if reutiliza:
        pasos = [{"entradas": p["entradas"], "contexto": p["contexto"]} for p in actual["pasos"]]
        elementos = actual["elementos"]
    else:
        pasos, elementos = exportar(ensamblaje)
    if len(pasos) != len(guia):
        raise Fallo(f"La tabla de pasos de {rel(ensamblaje)} tiene {len(pasos)} pasos y la guía {len(guia)}")
    datos = {"version": VERSION, "diseno": diseno, "huella": firma, "fn": FN_VISOR,
             "pasos": [{**g, **p} for g, p in zip(guia, pasos)], "elementos": elementos}
    pagina = armar_pagina(titulo, datos)
    return ruta, pagina, datos, actual, reutiliza


def comprobar(diseno, carpeta_spec):
    ruta = os.path.join(RAIZ, carpeta_spec, "web", "armado_3d.html")
    ejecutar = f"Ejecutar: scripts/generar_web.py {diseno} {carpeta_spec}"
    actual = datos_de_pagina(ruta)
    if actual is None:
        raise Fallo(f"Falta el visor 3D: {rel(ruta)}. {ejecutar}")
    if actual.get("version") != VERSION or actual.get("huella") != huella(diseno):
        raise Fallo(f"Desactualizado: {rel(ruta)} (cambiaron las fuentes del ensamblaje). {ejecutar}")
    _, pagina, datos, _, _ = generar(diseno, carpeta_spec)
    with open(ruta, encoding="utf-8") as f:
        existente = f.read()
    if pagina != existente:
        textos = lambda d: [(p["n"], p["titulo"], p["texto"]) for p in d["pasos"]]
        motivo = "cambió la guía" if textos(datos) != textos(actual) else "cambió la plantilla o el motor 3D"
        raise Fallo(f"Desactualizado: {rel(ruta)} ({motivo}). {ejecutar}")
    validar(datos, pagina)


def ejecutar(diseno, carpeta_spec, comprobar_solo=False, reexportar=False):
    """Punto de entrada común (también lo usa generar_web.py). Devuelve el código de salida."""
    try:
        if comprobar_solo:
            comprobar(diseno, carpeta_spec)
            print("✓ El visor 3D está al día")
            return 0
        ruta, pagina, datos, _, reutiliza = generar(diseno, carpeta_spec, reexportar)
        tamano = validar(datos, pagina)
        os.makedirs(os.path.dirname(ruta), exist_ok=True)
        with open(ruta, "w", encoding="utf-8") as f:
            f.write(pagina)
        print(f"✓ Visor 3D: {rel(ruta)} ({tamano/1e6:.1f} MB, {len(datos['elementos'])} piezas, "
              f"{'mallas reutilizadas' if reutiliza else 'mallas exportadas'})")
        return 0
    except Fallo as error:
        sys.stdout.flush()
        print(f"✗ {error}", file=sys.stderr)
        return 1


def main():
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    p.add_argument("diseno", help="prefijo del diseño, p. ej. puntero_laser")
    p.add_argument("carpeta_spec", help="carpeta de Spec Kit, p. ej. specs/002-puntero-laser-estelar")
    p.add_argument("--comprobar", action="store_true", help="no escribir; fallar si el visor no está al día")
    p.add_argument("--reexportar", action="store_true", help="exportar todas las piezas aunque la huella coincida")
    a = p.parse_args()
    sys.exit(ejecutar(a.diseno, a.carpeta_spec, a.comprobar, a.reexportar))


if __name__ == "__main__":
    main()
