#!/usr/bin/env python3
"""Genera la web de armado de un diseño a partir de su guía y su lista de materiales (fase 5).

    scripts/generar_web.py <diseño> <carpeta_de_la_spec>
    scripts/generar_web.py puntero_laser specs/002-puntero-laser-estelar
    scripts/generar_web.py --comprobar puntero_laser specs/002-puntero-laser-estelar

Lee (fuentes únicas):
    docs/<diseño>_guia.md      texto de la guía de producción
    docs/<diseño>_bom.csv      componentes, cantidades y precios con fuente y fecha
    docs/tipo_cambio.csv       cotización del dólar con fuente y fecha
    docs/img/                  capturas de las piezas
    exports/<diseño>_*.stl     para contar las piezas impresas

Escribe:
    docs/<diseño>_guia.md      el bloque entre <!-- BOM:inicio --> y <!-- BOM:fin -->
    <carpeta_de_la_spec>/web/index.html

Con --comprobar no escribe nada y termina con 1 si la guía o la web no están al día.
Solo usa la biblioteca estándar de Python.
"""
import argparse
import csv
import glob
import html
import math
import os
import re
import sys
import unicodedata

RAIZ = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
COLUMNAS_BOM = ["categoria", "texto_cantidad", "descripcion", "cantidad", "unidad", "paquete",
                "opcional", "en_guia", "precio", "moneda", "tienda", "url", "fecha", "nota"]
MARCA_INICIO = "<!-- BOM:inicio"
MARCA_FIN = "<!-- BOM:fin"


# --- DATOS ---

def leer_csv(ruta):
    with open(ruta, newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f, delimiter=";"))


def leer_bom(ruta):
    filas = leer_csv(ruta)
    errores = []
    if filas and list(filas[0].keys()) != COLUMNAS_BOM:
        errores.append(f"columnas esperadas: {';'.join(COLUMNAS_BOM)}")
    for n, f in enumerate(filas, start=2):
        for campo in ("categoria", "descripcion", "cantidad", "unidad", "paquete"):
            if not f[campo]:
                errores.append(f"línea {n}: falta '{campo}'")
        if f["opcional"] not in ("si", "no") or f["en_guia"] not in ("si", "no"):
            errores.append(f"línea {n}: 'opcional' y 'en_guia' deben ser si o no")
        # Un precio sin fuente es un precio inventado: no se acepta
        if f["precio"]:
            for campo in ("moneda", "tienda", "url", "fecha"):
                if not f[campo]:
                    errores.append(f"línea {n}: el precio no tiene '{campo}'")
            if f["moneda"] not in ("ARS", "USD"):
                errores.append(f"línea {n}: moneda '{f['moneda']}' (usar ARS o USD)")
            if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", f["fecha"]):
                errores.append(f"línea {n}: fecha '{f['fecha']}' (usar AAAA-MM-DD)")
    if errores:
        sys.exit(f"Error en {os.path.relpath(ruta, RAIZ)}:\n  " + "\n  ".join(errores))
    return filas


def leer_tipo_cambio(ruta):
    filas = [f for f in leer_csv(ruta) if f["moneda"] == "USD"]
    if not filas:
        sys.exit(f"Error en {ruta}: no hay cotización del USD")
    return max(filas, key=lambda f: f["fecha"])  # la más reciente


def costos(fila, ars_por_usd):
    """Costo en ARS comprando paquetes completos y costo prorrateado por lo que se usa."""
    if not fila["precio"]:
        return None
    precio = float(fila["precio"]) * (ars_por_usd if fila["moneda"] == "USD" else 1)
    cantidad, paquete = float(fila["cantidad"]), float(fila["paquete"])
    paquetes = math.ceil(cantidad / paquete - 1e-9)
    return {"paquetes": paquetes, "compra": paquetes * precio, "prorrateado": cantidad / paquete * precio}


# --- BLOQUE DE MATERIALES DE LA GUÍA ---

def bom_markdown(filas):
    lineas, categoria = [], None
    for f in (f for f in filas if f["en_guia"] == "si"):
        if f["categoria"] != categoria:
            if categoria is not None:
                lineas.append("")
            categoria = f["categoria"]
            lineas += [f"**{categoria}**", ""]
        lineas.append("* " + " ".join(p for p in (f["texto_cantidad"], f["descripcion"]) if p))
    return lineas


def actualizar_guia(texto, filas, nombre_csv):
    lineas = texto.split("\n")
    ini = [i for i, l in enumerate(lineas) if l.startswith(MARCA_INICIO)]
    fin = [i for i, l in enumerate(lineas) if l.startswith(MARCA_FIN)]
    if len(ini) != 1 or len(fin) != 1 or ini[0] > fin[0]:
        sys.exit(f"La guía necesita una marca '{MARCA_INICIO} -->' y una '{MARCA_FIN} -->'")
    cabecera = f"{MARCA_INICIO} (generado desde docs/{nombre_csv} con scripts/generar_web.py: no editar a mano) -->"
    nuevas = lineas[:ini[0]] + [cabecera] + bom_markdown(filas) + lineas[fin[0]:]
    return "\n".join(nuevas)


# --- MARKDOWN → HTML (el subconjunto que usan las guías) ---

RE_LISTA = re.compile(r"^( *)([*-]|\d+\.) +")
RE_SEPARADOR_TABLA = re.compile(r"^\s*\|?[\s:|-]*-[\s:|-]*\|?\s*$")


class Markdown:
    def __init__(self, prefijo_img):
        self.prefijo_img = prefijo_img
        self.ids = {}
        self.titulos = []  # (nivel, id, texto)

    # Texto en línea
    def inline(self, t):
        guardado = []

        def guardar(h):
            guardado.append(h)
            return f"\x00{len(guardado) - 1}\x00"

        t = re.sub(r"`([^`]+)`", lambda m: guardar(f"<code>{html.escape(m.group(1))}</code>"), t)
        t = re.sub(r"\\([\\`*_\[\]()#+\-.!|])", lambda m: guardar(html.escape(m.group(1))), t)
        t = re.sub(r"!\[([^\]]*)\]\(([^)\s]+)\)",
                   lambda m: guardar(f'<img src="{html.escape(self.ruta(m.group(2)))}" '
                                     f'alt="{html.escape(m.group(1))}" loading="lazy">'), t)
        t = re.sub(r"\[([^\]]+)\]\(([^)\s]+)\)",
                   lambda m: guardar(f'<a href="{html.escape(self.ruta(m.group(2)))}">'
                                     f"{self.inline(m.group(1))}</a>"), t)
        t = html.escape(t, quote=False)
        t = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", t)
        t = re.sub(r"(?<![\w*])\*(?![\s*])(.+?)(?<![\s*])\*(?![\w*])", r"<em>\1</em>", t)
        return re.sub(r"\x00(\d+)\x00", lambda m: guardado[int(m.group(1))], t)

    def ruta(self, destino):
        if re.match(r"^[a-z]+:|^/|^#", destino):
            return destino
        return f"{self.prefijo_img}/{destino}"

    def id_titulo(self, texto):
        plano = re.sub(r"[`*\\]", "", texto)
        base = unicodedata.normalize("NFKD", plano).encode("ascii", "ignore").decode().lower()
        base = re.sub(r"[^a-z0-9]+", "-", base).strip("-") or "seccion"
        n = self.ids.get(base, 0)
        self.ids[base] = n + 1
        return base if n == 0 else f"{base}-{n + 1}"

    # Bloques
    @staticmethod
    def sangria(linea):
        return len(linea) - len(linea.lstrip(" "))

    @staticmethod
    def es_tabla(lineas, i):
        return (lineas[i].lstrip().startswith("|") and i + 1 < len(lineas)
                and RE_SEPARADOR_TABLA.match(lineas[i + 1]) is not None and "-" in lineas[i + 1])

    def es_inicio_bloque(self, lineas, i):
        s = lineas[i].strip()
        return bool(re.match(r"#{1,6} ", s) or s.startswith(("```", ">", "<!--"))
                    or RE_LISTA.match(lineas[i]) or self.es_tabla(lineas, i) or re.fullmatch(r"-{3,}", s))

    def bloques(self, lineas):
        salida, i, n = [], 0, len(lineas)
        while i < n:
            linea, s = lineas[i], lineas[i].strip()
            if not s:
                i += 1
            elif s.startswith("<!--"):
                while i < n and "-->" not in lineas[i]:
                    i += 1
                i += 1
            elif s.startswith("```"):
                sangria, codigo = self.sangria(linea), []
                i += 1
                while i < n and not lineas[i].strip().startswith("```"):
                    codigo.append(lineas[i][min(sangria, self.sangria(lineas[i])):])
                    i += 1
                i += 1
                salida.append(f"<pre><code>{html.escape(chr(10).join(codigo))}</code></pre>")
            elif m := re.match(r"(#{1,6}) +(.*)", s):
                nivel, texto = len(m.group(1)), m.group(2)
                ident = self.id_titulo(texto)
                self.titulos.append((nivel, ident, texto))
                salida.append(f'<h{nivel} id="{ident}">{self.inline(texto)}</h{nivel}>')
                i += 1
            elif re.fullmatch(r"-{3,}", s):
                salida.append("<hr>")
                i += 1
            elif self.es_tabla(lineas, i):
                filas = []
                while i < n and lineas[i].strip().startswith("|"):
                    if not RE_SEPARADOR_TABLA.match(lineas[i]):
                        filas.append(self.celdas(lineas[i]))
                    i += 1
                cab = "".join(f"<th>{self.inline(c)}</th>" for c in filas[0])
                cuerpo = "".join("<tr>" + "".join(f"<td>{self.inline(c)}</td>" for c in f) + "</tr>"
                                 for f in filas[1:])
                salida.append(f'<div class="tabla"><table><thead><tr>{cab}</tr></thead>'
                              f"<tbody>{cuerpo}</tbody></table></div>")
            elif s.startswith(">"):
                cita = []
                while i < n and lineas[i].strip().startswith(">"):
                    cita.append(re.sub(r"^\s*> ?", "", lineas[i]))
                    i += 1
                salida.append("<blockquote>" + "".join(self.bloques(cita)) + "</blockquote>")
            elif RE_LISTA.match(linea):
                html_lista, i = self.lista(lineas, i)
                salida.append(html_lista)
            else:
                parrafo = [s]
                i += 1
                while i < n and lineas[i].strip() and not self.es_inicio_bloque(lineas, i):
                    parrafo.append(lineas[i].strip())
                    i += 1
                salida.append(f"<p>{self.inline(' '.join(parrafo))}</p>")
        return salida

    @staticmethod
    def celdas(linea):
        linea = linea.strip()
        linea = linea[1:] if linea.startswith("|") else linea
        linea = linea[:-1] if linea.endswith("|") else linea
        return [c.strip() for c in re.split(r"(?<!\\)\|", linea)]

    def lista(self, lineas, i):
        m = RE_LISTA.match(lineas[i])
        base, ordenada = len(m.group(1)), m.group(2)[0].isdigit()
        inicio = int(m.group(2)[:-1]) if ordenada else 1
        n, items = len(lineas), []

        def mismo_nivel(j):
            m2 = RE_LISTA.match(lineas[j])
            return m2 and len(m2.group(1)) == base and m2.group(2)[0].isdigit() == ordenada

        def proxima_no_vacia(j):
            while j < n and not lineas[j].strip():
                j += 1
            return j

        while i < n:
            if not lineas[i].strip():
                j = proxima_no_vacia(i)
                if j < n and mismo_nivel(j):
                    i = j
                    continue
                break
            if not mismo_nivel(i):
                break
            m = RE_LISTA.match(lineas[i])
            columna, item, holgado = m.end(), [lineas[i][m.end():]], False
            i += 1
            while i < n:
                if not lineas[i].strip():
                    j = proxima_no_vacia(i)
                    if j < n and self.sangria(lineas[j]) > base and not mismo_nivel(j):
                        item += [""] * (j - i)
                        i, holgado = j, True
                        continue
                    break
                if self.sangria(lineas[i]) > base:
                    item.append(lineas[i][min(self.sangria(lineas[i]), columna):])
                    i += 1
                    continue
                break
            contenido = self.bloques(item)
            if not holgado and contenido and contenido[0].startswith("<p>"):
                contenido[0] = contenido[0][3:-4]
            items.append("<li>" + "".join(contenido) + "</li>")
        etiqueta = "ol" if ordenada else "ul"
        atributo = f' start="{inicio}"' if ordenada and inicio != 1 else ""
        return f"<{etiqueta}{atributo}>{''.join(items)}</{etiqueta}>", i

    def convertir(self, texto):
        return "\n".join(self.bloques(texto.split("\n")))


# --- FORMATO ---

def ars(v):
    return "$\u00a0" + f"{v:,.0f}".replace(",", ".")


def usd(v):
    return "US$\u00a0" + f"{v:,.2f}".replace(",", "_").replace(".", ",").replace("_", ".")


def numero(texto):
    v = float(texto)
    return f"{v:g}".replace(".", ",")


def precio_unitario(f):
    p = float(f["precio"])
    importe = ars(p) if f["moneda"] == "ARS" else usd(p)
    if f["unidad"] == "u" and float(f["paquete"]) == 1:
        return f"{importe} c/u"
    if f["unidad"] == "paquete":
        return f"{importe} el paquete"
    return f"{importe} cada {numero(f['paquete'])} {f['unidad']}"


# --- PÁGINA ---

def seccion_componentes(md, filas, tc):
    ars_por_usd = float(tc["valor_ars"])
    obligatorias = [f for f in filas if f["opcional"] == "no"]
    con_precio = [(f, costos(f, ars_por_usd)) for f in obligatorias if f["precio"]]
    sin_precio = [f for f in obligatorias if not f["precio"]]
    total_compra = sum(c["compra"] for _, c in con_precio)
    total_prorr = sum(c["prorrateado"] for _, c in con_precio)

    filas_html, categoria = [], None
    for f in filas:
        if f["categoria"] != categoria:
            categoria = f["categoria"]
            filas_html.append(f'<tr class="categoria"><th colspan="5">{html.escape(categoria)}</th></tr>')
        cantidad = f["texto_cantidad"].removesuffix(" ×").removesuffix(" de") or "1"
        descripcion = md.inline(f["descripcion"])
        if f["opcional"] == "si":
            descripcion += ' <span class="etiqueta">opcional</span>'
        if f["nota"]:
            descripcion += f'<small>{md.inline(f["nota"])}</small>'
        c = costos(f, ars_por_usd)
        if c:
            paquetes = f" ({c['paquetes']} paq.)" if f["unidad"] != "u" and c["paquetes"] > 1 else ""
            precio = (f"{precio_unitario(f)}{paquetes}<small>"
                      f'<a href="{html.escape(f["url"])}" rel="noopener" target="_blank">'
                      f"{html.escape(f['tienda'])}</a>, {f['fecha']}</small>")
            subtotal = f"{ars(c['compra'])}<small>{usd(c['compra'] / ars_por_usd)}</small>"
        else:
            precio, subtotal = '<span class="falta">sin precio verificado</span>', "—"
        filas_html.append(f'<tr><td class="num">{html.escape(cantidad)}</td><td>{descripcion}</td>'
                          f'<td>{precio}</td><td class="num">{subtotal}</td></tr>')

    faltan = "".join(f"<li>{md.inline(' '.join(p for p in (f['texto_cantidad'], f['descripcion']) if p))}</li>"
                     for f in sin_precio)
    fechas = sorted(f["fecha"] for f, _ in con_precio)
    resumen = f"""
<div class="precio">
  <div class="tarjeta destacada">
    <span class="rotulo">Componentes con precio verificado</span>
    <span class="importe">{ars(total_compra)}</span>
    <span class="importe-usd">{usd(total_compra / ars_por_usd)}</span>
    <span class="detalle">Comprando paquetes completos ({len(con_precio)} de {len(obligatorias)} componentes)</span>
  </div>
  <div class="tarjeta">
    <span class="rotulo">Solo lo que se usa</span>
    <span class="importe">{ars(total_prorr)}</span>
    <span class="importe-usd">{usd(total_prorr / ars_por_usd)}</span>
    <span class="detalle">Si ya tenés el rollo y el resto de los paquetes</span>
  </div>
</div>
<div class="aviso">
  <p><strong>El precio final todavía no está completo:</strong> faltan {len(sin_precio)} componentes
  sin precio verificado. No se cargan precios que no se hayan podido confirmar en una tienda.</p>
  <details><summary>Ver los {len(sin_precio)} componentes sin precio</summary><ul>{faltan}</ul></details>
</div>
<p class="fuente">Precios de tiendas argentinas, verificados entre {fechas[0]} y {fechas[-1]}.
Tipo de cambio: US$ 1 = {ars(ars_por_usd)} ({html.escape(tc['tipo'])},
<a href="{html.escape(tc['url'])}" rel="noopener" target="_blank">{html.escape(tc['fuente'])}</a>,
{tc['fecha']}). Los precios cambian: confirmalos antes de comprar.</p>"""
    tabla = (f'<div class="tabla"><table class="componentes"><thead><tr><th>Cant.</th><th>Componente</th>'
             f'<th>Precio y fuente</th><th>Subtotal</th></tr></thead><tbody>{"".join(filas_html)}'
             f"</tbody></table></div>")
    return resumen + tabla, total_compra, len(sin_precio)


def vistas_de_pasos(html_txt, diseno, docs, prefijo):
    """Agrega a cada paso de armado su vista explotada (docs/img/<diseño>_paso_NN.png, generada por
    scripts/capturas_armado.sh). Los pasos sin imagen quedan solo con texto."""
    apertura = '<ol class="pasos">'
    inicio = html_txt.find(apertura)
    if inicio < 0:
        return html_txt
    desde = inicio + len(apertura)
    profundidad, numero, inserciones = 0, 0, []
    for t in re.finditer(r"<(/?)(ol|ul|li)\b[^>]*>", html_txt[desde:]):
        cierre, etiqueta, pos = t.group(1) == "/", t.group(2), desde + t.start()
        if etiqueta in ("ol", "ul"):
            if cierre and profundidad == 0:
                break  # fin de la lista de pasos
            profundidad += -1 if cierre else 1
        elif profundidad == 0 and not cierre:
            numero += 1
        elif profundidad == 0 and cierre:
            nombre = f"{diseno}_paso_{numero:02d}.png"
            if os.path.isfile(os.path.join(docs, "img", nombre)):
                src = html.escape(f"{prefijo}/img/{nombre}")
                inserciones.append((pos, f'<figure class="vista-paso"><a href="{src}" target="_blank">'
                                         f'<img src="{src}" alt="Paso {numero}: cómo se colocan las piezas" '
                                         f'loading="lazy"></a></figure>'))
    if not inserciones:
        return html_txt
    for pos, texto in reversed(inserciones):
        html_txt = html_txt[:pos] + texto + html_txt[pos:]
    leyenda = ('<p class="leyenda">En cada imagen, las piezas de ese paso van en color y la flecha naranja '
               "muestra hacia dónde se mueven para colocarlas. Lo que ya está armado se ve transparente.</p>")
    return html_txt[:inicio] + leyenda + html_txt[inicio:]


def generar(diseno, carpeta_spec):
    docs = os.path.join(RAIZ, "docs")
    ruta_guia = os.path.join(docs, f"{diseno}_guia.md")
    ruta_bom = os.path.join(docs, f"{diseno}_bom.csv")
    salida = os.path.join(RAIZ, carpeta_spec, "web")
    for ruta in (ruta_guia, ruta_bom, os.path.join(docs, "tipo_cambio.csv")):
        if not os.path.isfile(ruta):
            sys.exit(f"No existe {os.path.relpath(ruta, RAIZ)}")
    if not os.path.isdir(os.path.join(RAIZ, carpeta_spec)):
        sys.exit(f"No existe la carpeta {carpeta_spec}")

    filas = leer_bom(ruta_bom)
    tc = leer_tipo_cambio(os.path.join(docs, "tipo_cambio.csv"))
    with open(ruta_guia, encoding="utf-8") as f:
        guia_actual = f.read()
    guia = actualizar_guia(guia_actual, filas, os.path.basename(ruta_bom))

    md = Markdown(os.path.relpath(docs, salida).replace(os.sep, "/"))
    lineas = guia.split("\n")
    titulo = re.sub(r"^#\s+(Guía de Producción:\s*)?", "", lineas[0]).strip()
    primera_h2 = next(i for i, l in enumerate(lineas) if l.startswith("## "))
    intro = lineas[1:primera_h2]

    # Bajada: primer párrafo; imagen principal: primera imagen de la introducción
    i = next(i for i, l in enumerate(intro) if l.strip())
    j = next((k for k in range(i, len(intro)) if not intro[k].strip()), len(intro))
    bajada = md.inline(" ".join(l.strip() for l in intro[i:j]))
    m_img = next((re.match(r"!\[([^\]]*)\]\(([^)]+)\)", l.strip()) for l in intro
                  if l.strip().startswith("![")), None)
    resto_intro = [l for k, l in enumerate(intro) if not (i <= k < j) and not l.strip().startswith("![")]

    # Cuerpo de la guía: el bloque de materiales se reemplaza por un enlace a la tabla con precios
    cuerpo = []
    dentro_bom = False
    for l in lineas[primera_h2:]:
        if l.startswith(MARCA_INICIO):
            dentro_bom = True
            cuerpo.append("La lista completa, con precios y dónde comprar, está en "
                          "[Lo que necesitás y cuánto cuesta](#componentes).")
        elif l.startswith(MARCA_FIN):
            dentro_bom = False
        elif not dentro_bom:
            cuerpo.append(l)
    html_cuerpo = md.convertir("\n".join(cuerpo))
    titulos_h2 = [(ident, texto) for nivel, ident, texto in md.titulos if nivel == 2]

    # Listas con estilo propio: primeros pasos, pasos de armado (con casillas) y consejos
    def clase_lista(html_txt, prefijo_id, clase):
        return re.sub(rf'(<h[23] id="{prefijo_id}[^"]*">.*?</h[23]>\s*(?:<p>.*?</p>\s*)*)<ol',
                      rf'\1<ol class="{clase}"', html_txt, count=1, flags=re.S)

    html_cuerpo = clase_lista(html_cuerpo, "primeros-pasos", "primeros")
    html_cuerpo = clase_lista(html_cuerpo, "instrucciones-paso-a-paso", "pasos")
    html_cuerpo = vistas_de_pasos(html_cuerpo, diseno, docs, md.prefijo_img)
    html_cuerpo = re.sub(r'(<h2 id="[^"]*consejos[^"]*">.*?</h2>\s*(?:<p>.*?</p>\s*)*)<ul',
                         r'\1<ul class="consejos"', html_cuerpo, count=1, flags=re.S)
    # Cada h2 abre una sección
    partes = re.split(r"(?=<h2 )", html_cuerpo)
    html_cuerpo = "".join(f"<section>{p}</section>" if p.startswith("<h2 ") else p for p in partes)

    html_componentes, total, faltan = seccion_componentes(md, filas, tc)
    ficha = md.convertir("\n".join(resto_intro))
    n_stl = len(glob.glob(os.path.join(RAIZ, "exports", f"{diseno}_*.stl")))
    filamento = next((f for f in filas if f["categoria"].lower() == "filamento"), None)

    datos = [f"<li><strong>{n_stl}</strong> archivos STL</li>"]
    if filamento:
        datos.append(f"<li><strong>≈ {numero(filamento['cantidad'])} {filamento['unidad']}</strong> "
                     f"de filamento</li>")
    datos.append(f"<li><strong>{sum(1 for f in filas if f['opcional'] == 'no')}"
                 f"</strong> componentes para comprar</li>")
    datos.append(f'<li><strong>{ars(total)}</strong> + {faltan} sin precio</li>')

    indice = ['<a href="#componentes">Lo que necesitás</a>'] + [
        f'<a href="#{ident}">{md.inline(re.sub(r"^[0-9.]+ ", "", texto))}</a>' for ident, texto in titulos_h2]
    imagen = (f'<img class="principal" src="{html.escape(md.ruta(m_img.group(2)))}" '
              f'alt="{html.escape(m_img.group(1))}">' if m_img else "")
    pagina = (PLANTILLA
              .replace("{{titulo}}", html.escape(titulo))
              .replace("{{bajada}}", bajada)
              .replace("{{imagen}}", imagen)
              .replace("{{datos}}", "".join(datos))
              .replace("{{indice}}", "".join(indice))
              .replace("{{componentes}}", html_componentes)
              .replace("{{cuerpo}}", html_cuerpo)
              .replace("{{ficha}}", ficha)
              .replace("{{clave}}", diseno)
              .replace("{{guia}}", f"docs/{diseno}_guia.md")
              .replace("{{bom}}", f"docs/{diseno}_bom.csv"))
    return guia_actual, guia, ruta_guia, os.path.join(salida, "index.html"), pagina


def main():
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    p.add_argument("diseno", help="prefijo del diseño, p. ej. puntero_laser")
    p.add_argument("carpeta_spec", help="carpeta de Spec Kit, p. ej. specs/002-puntero-laser-estelar")
    p.add_argument("--comprobar", action="store_true", help="no escribir; fallar si algo no está al día")
    a = p.parse_args()

    guia_actual, guia, ruta_guia, ruta_web, pagina = generar(a.diseno, a.carpeta_spec)
    web_actual = open(ruta_web, encoding="utf-8").read() if os.path.isfile(ruta_web) else None
    rel = lambda r: os.path.relpath(r, RAIZ)
    if a.comprobar:
        desactualizados = [rel(r) for r, viejo, nuevo in ((ruta_guia, guia_actual, guia),
                                                          (ruta_web, web_actual, pagina)) if viejo != nuevo]
        if desactualizados:
            sys.exit("Desactualizado: " + ", ".join(desactualizados)
                     + f". Ejecutar: scripts/generar_web.py {a.diseno} {a.carpeta_spec}")
        print("✓ La guía y la web están al día")
        return
    if guia != guia_actual:
        with open(ruta_guia, "w", encoding="utf-8") as f:
            f.write(guia)
        print(f"✓ Actualizado el bloque de materiales de {rel(ruta_guia)}")
    os.makedirs(os.path.dirname(ruta_web), exist_ok=True)
    with open(ruta_web, "w", encoding="utf-8") as f:
        f.write(pagina)
    print(f"✓ Web generada: {rel(ruta_web)}")


PLANTILLA = r"""<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{{titulo}}</title>
<style>
:root {
  --fondo: #f6f5f1; --superficie: #ffffff; --texto: #1d1f21; --suave: #5b6168; --borde: #dcdad3;
  --acento: #1f6f5c; --acento-suave: #e3f0ec; --aviso: #8a5a00; --aviso-fondo: #fff4dc;
  --codigo: #f0eee8; --sombra: 0 1px 2px rgba(0,0,0,.06);
}
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --fondo: #15171a; --superficie: #1d2024; --texto: #e7e6e2; --suave: #a3a8ae; --borde: #33373d;
    --acento: #5cc4a6; --acento-suave: #1d3330; --aviso: #f0c46a; --aviso-fondo: #33291a;
    --codigo: #24272c; --sombra: none;
  }
}
:root[data-theme="dark"] {
  --fondo: #15171a; --superficie: #1d2024; --texto: #e7e6e2; --suave: #a3a8ae; --borde: #33373d;
  --acento: #5cc4a6; --acento-suave: #1d3330; --aviso: #f0c46a; --aviso-fondo: #33291a;
  --codigo: #24272c; --sombra: none;
}
* { box-sizing: border-box; }
html { scroll-behavior: smooth; }
body { margin: 0; background: var(--fondo); color: var(--texto);
  font: 16px/1.6 system-ui, -apple-system, "Segoe UI", Roboto, sans-serif; }
main, header .contenido, nav .contenido, footer { max-width: 960px; margin: 0 auto; padding: 0 16px; }
header { background: var(--superficie); border-bottom: 1px solid var(--borde); padding: 32px 0 24px; }
h1 { font-size: clamp(1.7rem, 4vw, 2.4rem); line-height: 1.15; margin: 0 0 12px; }
.bajada { color: var(--suave); max-width: 70ch; margin: 0 0 20px; }
img { max-width: 100%; height: auto; }
img.principal { display: block; width: 100%; max-height: 420px; object-fit: contain;
  background: var(--codigo); border-radius: 12px; }
.datos { display: flex; flex-wrap: wrap; gap: 8px; list-style: none; padding: 0; margin: 20px 0 0; }
.datos li { background: var(--acento-suave); border-radius: 999px; padding: 4px 14px; font-size: .92rem; }
nav { position: sticky; top: 0; z-index: 2; background: var(--fondo); border-bottom: 1px solid var(--borde); }
nav .contenido { display: flex; gap: 6px 16px; flex-wrap: wrap; padding-top: 10px; padding-bottom: 10px;
  font-size: .9rem; }
nav a { color: var(--suave); text-decoration: none; white-space: nowrap; }
nav a:hover { color: var(--acento); }
section { background: var(--superficie); border: 1px solid var(--borde); border-radius: 12px;
  box-shadow: var(--sombra); padding: 8px 24px 24px; margin: 24px 0; }
h2 { font-size: 1.5rem; margin: 20px 0 12px; scroll-margin-top: 64px; }
h3 { font-size: 1.15rem; margin: 24px 0 8px; scroll-margin-top: 64px; }
a { color: var(--acento); }
code { background: var(--codigo); border-radius: 4px; padding: 1px 5px; font-size: .88em; }
pre { background: var(--codigo); border-radius: 8px; padding: 12px 14px; overflow-x: auto; font-size: .82rem;
  line-height: 1.35; }
pre code { background: none; padding: 0; }
blockquote { margin: 16px 0; padding: 4px 16px; background: var(--aviso-fondo);
  border-left: 4px solid var(--aviso); border-radius: 0 8px 8px 0; }
.tabla { overflow-x: auto; margin: 12px 0; }
table { border-collapse: collapse; width: 100%; font-size: .92rem; }
th, td { text-align: left; vertical-align: top; padding: 8px 10px; border-bottom: 1px solid var(--borde); }
thead th { font-size: .8rem; text-transform: uppercase; letter-spacing: .03em; color: var(--suave); }
td img { width: 140px; display: block; margin-bottom: 4px; }
td small { display: block; color: var(--suave); font-size: .82rem; margin-top: 2px; }
td.num { white-space: nowrap; font-variant-numeric: tabular-nums; }
tr.categoria th { background: var(--acento-suave); color: var(--texto); text-transform: none;
  letter-spacing: 0; font-size: .95rem; }
.etiqueta { font-size: .72rem; border: 1px solid var(--borde); border-radius: 999px; padding: 0 7px;
  color: var(--suave); }
.falta { color: var(--aviso); font-weight: 600; }
.precio { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 12px; margin: 16px 0; }
.tarjeta { display: flex; flex-direction: column; border: 1px solid var(--borde); border-radius: 10px; padding: 14px 16px; }
.tarjeta.destacada { border-color: var(--acento); background: var(--acento-suave); }
.rotulo { font-size: .85rem; color: var(--suave); }
.importe { font-size: 1.9rem; font-weight: 700; font-variant-numeric: tabular-nums; }
.importe-usd { font-weight: 600; color: var(--suave); }
.detalle { font-size: .82rem; color: var(--suave); margin-top: 4px; }
.aviso { background: var(--aviso-fondo); border-radius: 10px; padding: 4px 16px 12px; }
.fuente { font-size: .85rem; color: var(--suave); }
ol.pasos, ol.primeros { list-style: none; counter-reset: paso; padding: 0; }
ol.pasos > li, ol.primeros > li { counter-increment: paso; position: relative; border: 1px solid var(--borde);
  border-radius: 10px; padding: 12px 16px 12px 56px; margin: 10px 0; }
ol.pasos > li::before, ol.primeros > li::before { content: counter(paso); position: absolute; left: 14px; top: 12px;
  width: 30px; height: 30px; border-radius: 50%; background: var(--acento); color: var(--superficie);
  display: grid; place-items: center; font-weight: 700; font-size: .9rem; }
ol.pasos > li.hecho { opacity: .55; }
ol.pasos label.marca { float: right; margin-left: 12px; font-size: .82rem; color: var(--suave); cursor: pointer; }
.progreso { font-weight: 600; color: var(--acento); }
.leyenda { font-size: .9rem; color: var(--suave); border-left: 4px solid #e8512c; padding-left: 12px; }
figure.vista-paso { margin: 12px 0 0; }
figure.vista-paso img { display: block; width: 100%; max-width: 560px; border-radius: 8px;
  border: 1px solid var(--borde); background: #f8f8f8; }
ul.consejos { list-style: none; padding: 0; display: grid; gap: 10px; }
ul.consejos li { border-left: 4px solid var(--acento); background: var(--acento-suave); border-radius: 0 8px 8px 0;
  padding: 10px 14px; }
details.ficha > summary { cursor: pointer; font-weight: 600; padding: 12px 0; }
footer { color: var(--suave); font-size: .82rem; padding-top: 8px; padding-bottom: 40px; }
@media (max-width: 600px) {
  section { padding: 4px 14px 16px; border-radius: 10px; }
  ol.pasos > li, ol.primeros > li { padding-left: 48px; }
  ol.pasos > li::before, ol.primeros > li::before { left: 10px; }
}
@media print { nav, label.marca { display: none; } section { break-inside: auto; box-shadow: none; } }
</style>
</head>
<body>
<header><div class="contenido">
  <h1>{{titulo}}</h1>
  <p class="bajada">{{bajada}}</p>
  {{imagen}}
  <ul class="datos">{{datos}}</ul>
</div></header>
<nav aria-label="Índice"><div class="contenido">{{indice}}</div></nav>
<main>
<section id="componentes">
  <h2>Lo que necesitás y cuánto cuesta</h2>
  {{componentes}}
</section>
{{cuerpo}}
<section>
  <details class="ficha"><summary>Ficha técnica del diseño</summary>{{ficha}}</details>
</section>
</main>
<footer>Página generada con <code>scripts/generar_web.py</code> a partir de <code>{{guia}}</code> y
<code>{{bom}}</code>. Para cambiarla, editar esos archivos y volver a generarla.</footer>
<script>
(function () {
  var clave = "pasos-{{clave}}", hechos = {};
  try { hechos = JSON.parse(localStorage.getItem(clave) || "{}"); } catch (e) {}
  var lista = document.querySelector("ol.pasos");
  if (!lista) return;
  var items = lista.querySelectorAll(":scope > li");
  var progreso = document.createElement("p");
  progreso.className = "progreso";
  lista.parentNode.insertBefore(progreso, lista);
  function actualizar() {
    var n = 0;
    items.forEach(function (li, i) { if (hechos[i]) n++; li.classList.toggle("hecho", !!hechos[i]); });
    progreso.textContent = n + " de " + items.length + " pasos hechos";
  }
  items.forEach(function (li, i) {
    var label = document.createElement("label"), caja = document.createElement("input");
    label.className = "marca";
    caja.type = "checkbox";
    caja.checked = !!hechos[i];
    caja.addEventListener("change", function () {
      hechos[i] = caja.checked;
      try { localStorage.setItem(clave, JSON.stringify(hechos)); } catch (e) {}
      actualizar();
    });
    label.appendChild(caja);
    label.appendChild(document.createTextNode(" hecho"));
    li.insertBefore(label, li.firstChild);
  });
  actualizar();
})();
</script>
</body>
</html>
"""

if __name__ == "__main__":
    main()
