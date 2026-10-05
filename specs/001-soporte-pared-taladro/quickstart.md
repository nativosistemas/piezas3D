# Guía rápida de verificación: Soporte de pared paramétrico para taladro

**Funcionalidad**: [spec.md](spec.md) | **Contrato**: [contracts/interfaz_generador.md](contracts/interfaz_generador.md)

Escenarios ejecutables que demuestran que la funcionalidad cumple la especificación de principio a
fin. Los parámetros y las reglas de validación están en [data-model.md](data-model.md). Todos los
comandos se ejecutan desde la raíz del repositorio.

## Requisitos previos

Las herramientas son las del sistema (OpenSCAD 2021.01 instalado con `apt` y FreeCAD en snap) y
se invocan con los lanzadores de `.tools/bin/` (ignorado por git). No hace falta tocar el `PATH`.
Los lanzadores de FreeCAD, `ccx` y `gmsh` solo funcionan **fuera del sandbox**. Para comprobarlas:

```bash
.tools/bin/openscad --version
```

```bash
.tools/bin/freecadcmd --version
```

```bash
.tools/bin/ccx -v
```

```bash
.tools/bin/gmsh --version
```

**Resultado esperado**: `OpenSCAD version 2021.01`, `FreeCAD 1.1.1`, `Version 2.21` (CalculiX) y
`4.13.1` (Gmsh). Además hace falta `python3` del sistema, solo para medir la caja envolvente.

El snap de FreeCAD tiene un `/tmp` privado: lo que escriba en `$TMPDIR` o `/tmp` no se ve desde
fuera. Sus salidas temporales van a `.tools/tmp/`.

**Reinstalación** (por ejemplo en una máquina nueva): `sudo apt install openscad` y
`sudo snap install freecad`. Después se recrean los lanzadores de `.tools/bin/`:

- `openscad` ejecuta `/usr/bin/openscad`, convierte a absoluta la ruta de `-o` y termina con
  código 1 si no se crea el archivo de salida. OpenSCAD 2021.01 resuelve las rutas relativas de
  `-o` desde la carpeta del `.scad` y devuelve 0 aunque no pueda escribir.
- `freecad` y `freecadcmd` ejecutan `/snap/bin/freecad` y `/snap/bin/freecad.cmd`.
- `ccx` y `gmsh` vienen dentro del snap, que no los publica como comandos; se ejecutan con
  `snap run --shell freecad.cmd -c 'exec "$SNAP/usr/bin/<programa>" "$@"' sh "$@"`.

Hasta el 2026-10-05 se usaban las AppImage extraídas de OpenSCAD 2021.01 y FreeCAD 1.1.4
(CalculiX 2.23, Gmsh 4.15.0); los resultados de la simulación coinciden con los del snap.

Las salidas temporales de las pruebas van a `$TMPDIR`. Solo el STL por defecto se guarda en
`exports/`.

## Escenario 1: renderizado por defecto sin errores (Puerta 1, US1)

```bash
.tools/bin/openscad --hardwarnings -o exports/soporte_pared_taladro.stl src/soporte_pared_taladro.scad
```

**Resultado esperado**: el código de salida es 0, no aparece ninguna línea `WARNING:` ni `ERROR:` y
existe `exports/soporte_pared_taladro.stl`.

## Escenario 2: caja envolvente igual a los parámetros (SC-004, US2)

Con este fragmento se mide cualquier STL ASCII:

```bash
python3 -c "import sys,re;v=[tuple(map(float,m)) for m in re.findall(r'vertex\s+(\S+)\s+(\S+)\s+(\S+)',open(sys.argv[1]).read())];print(*[round(max(c)-min(c),2) for c in zip(*v)])" exports/soporte_pared_taladro.stl
```

**Resultado esperado**: `80.0 100.0 70.0` (± 0,1).

Variantes de US2 (escenarios de aceptación 1 a 3):

```bash
.tools/bin/openscad --hardwarnings -D ancho=100 -D profundidad=130 -D diametro_tornillo=4 -o "$TMPDIR/variante.stl" src/soporte_pared_taladro.scad
```

**Resultado esperado**: renderiza sin advertencias y la caja envolvente medida es `100.0 130.0 70.0`.
En la vista previa se comprueba que la ranura sigue centrada y que los orificios son más pequeños
(Ø 4,4 mm).

## Escenario 3: extremos de los rangos válidos (FR-005, FR-006)

Se renderizan, por ejemplo, estas combinaciones límite válidas:

| Caso | Valores con `-D` |
|------|------------------|
| Mínimo compacto | `ancho=70 profundidad=90 ancho_ranura=30 diametro_cuerpo_taladro=50 espesor=5 diametro_tornillo=3` |
| Máximo | `ancho=150 profundidad=160 ancho_ranura=60 diametro_cuerpo_taladro=90 espesor=10 altura_placa=120 diametro_tornillo=8` |
| Sin labio ni chaflanes | `altura_labio=0 chaflan_ranura=0 radio_esquinas=0 radio_filete=0` |

**Resultado esperado**: todas renderizan sin `WARNING:` ni `ERROR:` y la caja envolvente coincide con
`ancho × profundidad × altura_placa`.

## Escenario 4: combinaciones inválidas rechazadas (FR-010, SC-005, US2 escenario 4)

Cada fila se ejecuta como `.tools/bin/openscad -D … -o "$TMPDIR/x.stl" src/soporte_pared_taladro.scad`.

| Regla | Valores con `-D` | El mensaje debe empezar por |
|-------|------------------|-----------------------------|
| V-01 | `diametro_tornillo=2` | `diametro_tornillo=2` |
| V-01 | `ancho=-10` | `ancho=-10` |
| V-01 | `profundidad="abc"` | `profundidad=` |
| V-02 | `ancho_ranura=60 diametro_cuerpo_taladro=70` (con ancho 80) | `ancho_ranura=60` |
| V-03 | `ancho=60 ancho_ranura=30 diametro_tornillo=8` | `diametro_tornillo=8` |
| V-04 | `diametro_tornillo=8 espesor=4` | `diametro_tornillo=8` |
| V-05 | `diametro_tornillo=8 altura_placa=50` | `altura_placa=50` |
| V-06 | `profundidad=60` | `profundidad=60` |
| V-07 | `diametro_cuerpo_taladro=50` (ranura 46) | `diametro_cuerpo_taladro=50` |
| V-08 | `diametro_cuerpo_taladro=75` (ancho 80) | `diametro_cuerpo_taladro=75` |

**Resultado esperado**: en el 100 % de los casos la salida contiene `ERROR: Assertion` con el mensaje
indicado y **no** se crea `$TMPDIR/x.stl` (hay que borrarlo antes de cada caso).

## Escenario 5: imprimibilidad (SC-001, FR-011, FR-012)

0. **Comprobación automática (obligatoria)**: analizar las facetas del STL con el fragmento de
   `python3` descrito en T014 de [tasks.md](tasks.md). Busca voladizos con normal `n_z < −0,72` y
   excluye las facetas de la cama (Z ≈ 0) y los puentes de los orificios de los tornillos. El espesor
   mínimo de 1,2 mm (FR-012) se comprueba con las fórmulas de [data-model.md](data-model.md) (T017).
1. *(Opcional, si hay un laminador disponible)* Abrir `exports/soporte_pared_taladro.stl` en el
   laminador con la orientación de la guía (cara inferior de la bandeja sobre la cama).
2. *(Opcional)* Activar la vista de voladizos o soportes automáticos con un umbral de 45°.

**Resultado esperado**:

- El paso 0 no encuentra ninguna faceta en voladizo.
- Si se usa el laminador, no genera soportes ni muestra paredes de menos de 1,2 mm.
- La pieza cabe en una cama de 180 × 180 mm.

## Escenario 6: validación estructural (US3, SC-003, Puerta 2)

1. Exportar el CSG:

   ```bash
   .tools/bin/openscad -o simulation/soporte_pared_taladro.csg src/soporte_pared_taladro.scad
   ```

2. Ejecutar el análisis FEM sin interfaz gráfica:

   ```bash
   .tools/bin/freecadcmd simulation/soporte_pared_taladro_fem.py
   ```

3. Para revisar el resultado visualmente, abrir el proyecto en la interfaz gráfica:

   ```bash
   .tools/bin/freecad simulation/soporte_pared_taladro.FCStd
   ```

**Resultado esperado**: el script termina sin `Traceback` y crea `simulation/soporte_pared_taladro.FCStd`
(liviano, sin malla ni resultados; en la interfaz gráfica hay que mallar y resolver antes de ver
resultados).
Además imprime la tensión de von Mises máxima, que debe ser ≤ 10 MPa, y el desplazamiento del borde
frontal, que debe ser ≤ 1 mm con 25 N. Los valores quedan anotados en
`simulation/soporte_pared_taladro_fem.md`.

## Escenario 7: guía de producción completa (US1 escenario 4, Puerta 4)

```bash
grep -nE '\[[^]]*(ej\.|Describir|Cant\.|Fragmento)[^]]*\]' docs/soporte_pared_taladro_guia.md
```

**Resultado esperado**: sin coincidencias (no quedan marcadores de plantilla). La guía contiene las
secciones A (impresión) y B (BOM + instalación) y la explicación de cómo medir el taladro (FR-017).

## Escenario 8: prueba física (SC-002, SC-007), fuera del entorno automatizado

Imprimir, instalar y colgar un taladro de hasta 2,5 kg. Al cabo de 7 días, la flecha del borde
frontal debe ser ≤ 1 mm (medida con calibre o regla contra un nivel), no debe haber grietas y los
tornillos no deben tener holgura. Colgar y retirar el taladro con una mano debe llevar menos de 3 s.
