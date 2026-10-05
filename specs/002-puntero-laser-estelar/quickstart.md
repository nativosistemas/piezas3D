# Guía rápida de verificación: Puntero láser estelar motorizado (alt-az)

**Funcionalidad**: [spec.md](spec.md) |
**Contratos**: [interfaz_generador.md](contracts/interfaz_generador.md),
[interfaz_firmware.md](contracts/interfaz_firmware.md)

Escenarios ejecutables que demuestran que la funcionalidad cumple la especificación de principio a
fin. Los parámetros y las reglas V-01…V-14 están en [data-model.md](data-model.md). Todos los
comandos se ejecutan desde la raíz del repositorio.

## Requisitos previos

Las herramientas son las mismas de la funcionalidad 001 (OpenSCAD y FreeCAD del sistema), llamadas
con los lanzadores de `.tools/bin/`. La reinstalación está descrita en
[../001-soporte-pared-taladro/quickstart.md](../001-soporte-pared-taladro/quickstart.md#requisitos-previos).

```bash
.tools/bin/openscad --version
```

**Resultado esperado**: `OpenSCAD version 2021.01`. Para medir las cajas envolventes hace falta
`python3`. En este diseño no se usan FreeCAD, Gmsh ni CalculiX (R10).

## Escenario 1: derivados y valores para el firmware (FR-016, FR-017, US4)

```bash
.tools/bin/openscad -o "$TMPDIR/parametros.echo" src/puntero_laser_parametros.scad
```

```bash
grep ECHO "$TMPDIR/parametros.echo"
```

**Resultado esperado**: el código de salida es 0 y aparecen, entre otros:

| Valor | Esperado |
|-------|----------|
| `distancia_centros` | 45,97 (± 0,05) |
| `pasos_por_grado` | 45,286 |
| `grados_por_paso` | 0,0221 |
| `altura_eje` | ≈ 110 |
| `error_rss` (línea `PRESUPUESTO rss=…`) | ≤ 1 |
| `error_peor_caso` | < 2 |
| `x_centro_masa_plataforma` | En el rango ±20 |

## Escenario 2: renderizado y exportación de todas las piezas (Puerta 1, Puerta 3, US1)

```bash
for p in adaptador_tripode plataforma_azimut cuna_laser polea_altitud carro_motor separador_azimut tapa_electronica probeta_ajuste_608; do .tools/bin/openscad --hardwarnings --check-parameters=true --check-parameter-ranges=true -o exports/puntero_laser_$p.stl src/puntero_laser_$p.scad || echo "FALLA $p"; done
```

```bash
for l in motor cable; do .tools/bin/openscad --hardwarnings --check-parameters=true --check-parameter-ranges=true -D "lado=\"$l\"" -o exports/puntero_laser_brazo_horquilla_$l.stl src/puntero_laser_brazo_horquilla.scad || echo "FALLA brazo $l"; done
```

**Resultado esperado**: no aparece ninguna línea `FALLA`, `WARNING:` ni `ERROR:` y existen los 10
STL de la tabla del [contrato](contracts/interfaz_generador.md#21-éxito).

## Escenario 3: todo entra en la cama (SC-001, FR-020, V-03)

```bash
for f in exports/puntero_laser_*.stl; do python3 -c "import sys,re;v=[tuple(map(float,m)) for m in re.findall(r'vertex\s+(\S+)\s+(\S+)\s+(\S+)',open(sys.argv[1]).read())];d=[round(max(c)-min(c),1) for c in zip(*v)];print(('OK ' if d[0]<=200 and d[1]<=200 else 'NO ')+sys.argv[1],*d)" "$f"; done
```

**Resultado esperado**: las 10 líneas empiezan con `OK`, con X e Y ≤ 200 y Z = altura de impresión.
Como referencia aproximada, la plataforma mide ≤ 196 × 196 y el brazo ≈ 127 de largo.

## Escenario 4: ensamblaje sin choques (US1 escenarios 3 y 4, V-07…V-09)

Dentro del sandbox, OpenSCAD 2021.01 **no puede exportar PNG**, porque no hay OpenGL ("Can't create
OpenGL OffscreenView" / `Segmentation fault`). Las capturas de la sección 5.3 de
`.github/spec_kit_profile.md` se generan **fuera del sandbox** (WSLg), como indica `CLAUDE.md`; así
se obtuvieron las de `docs/img/`. Los `assert` del ensamblaje se comprueban renderizándolo a STL, que no se
guarda en el repositorio (tarda ≈ 2 min):

```bash
.tools/bin/openscad --hardwarnings -o "$TMPDIR/ensamblaje.stl" src/puntero_laser_ensamblaje.scad
```

**Resultado esperado**: el código de salida es 0 y no falla ningún `assert`: V-09, separaciones,
cables lejos de las correas, tapa por debajo del motor de altura.

**Vista de revisión**: se usa [vista_stl.py](vista_stl.py) con el Python de FreeCAD, que trae
matplotlib. Por ejemplo, para la plataforma:

```bash
VISTA_ENTRADAS="exports/puntero_laser_plataforma_azimut.stl:#6f9a6f" VISTA_SALIDA=".tools/tmp/vista.png" VISTA_VISTAS="55,-60;90,-90" .tools/bin/freecadcmd specs/002-puntero-laser-estelar/vista_stl.py
```

Se ejecuta fuera del sandbox, y la imagen va a `.tools/tmp/` porque el snap de FreeCAD no ve el
`/tmp` del sistema.

Para ver el conjunto en color, se exporta cada pieza en su posición (`intersection()` vacío o una
pieza por vez, con `use <src/puntero_laser_ensamblaje.scad>`) y se pasan todas a `VISTA_ENTRADAS`.

**Prueba de choques pieza a pieza**: para cada par de piezas, `intersection()` en su posición del
conjunto a −10°, 0°, 45°, 90° y 95°. Pares a probar:

- Cuna o láser con los brazos, la plataforma, el carro y el motor de azimut.
- Polea de altura con el brazo.
- Motor y polea 20T de altura con el brazo.
- Polea 20T de azimut con la plataforma y la base.
- Tapa con el brazo, el motor y el carro de altura.

**Resultado esperado**: todas las intersecciones vacías. Solo se admiten contactos de volumen 0, que
son apoyos: carro y tapa sobre la plataforma, pie de los brazos sobre la plataforma, orejas del motor
contra el carro.

## Escenario 5: adaptación a los componentes reales (US3, SC-007, FR-018, FR-022)

Se regeneran **todas** las piezas con los mismos `-D`:

```bash
D='-D diametro_laser=26 -D largo_laser=240 -D distancia_trasera_centro_masa=110 -D powerbank_largo=140 -D powerbank_ancho=70 -D powerbank_alto=16'; for p in plataforma_azimut cuna_laser tapa_electronica ensamblaje; do eval .tools/bin/openscad --hardwarnings $D -o "$TMPDIR/var_$p.stl" src/puntero_laser_$p.scad || echo "FALLA $p"; done
```

**Resultado esperado**:

- No aparece ninguna línea `FALLA`. La única excepción es el ensamblaje, que no exporta malla y se
  comprueba con `-o "$TMPDIR/var.png"`.
- El interior de la cuna mide Ø 30 (26 + 2 × 2).
- El `altura_eje` que muestra el `echo` crece (≈ 145 mm).
- El bolsillo y la tapa se agrandan para el power bank.
- Los STL siguen midiendo ≤ 200 × 200 (escenario 3 aplicado a `$TMPDIR`).

## Escenario 6: combinaciones inválidas rechazadas (FR-019, US3 escenario 3)

```bash
for d in 'powerbank_ancho=80' 'largo_laser=300' 'distancia_trasera_centro_masa=30' 'largo_correa=170' 'holgura_colimacion=0.5' 'ajuste_608=0.5'; do .tools/bin/openscad -D "$d" -o "$TMPDIR/inv.stl" src/puntero_laser_plataforma_azimut.scad 2>&1 | grep -q 'Assertion' && echo "RECHAZA $d" || echo "NO RECHAZA $d"; done
```

**Resultado esperado**: las 6 líneas empiezan con `RECHAZA`. Cada mensaje nombra el parámetro, su
valor y el límite (V-01, V-02, V-04, V-05/V-06 y V-12).

## Escenario 7: imprimibilidad (FR-020, FR-021, SC-001)

Se abren los STL en un laminador (PrusaSlicer, Orca o Cura) con boquilla de 0,4 mm y PETG, en la
orientación tal como vienen.

**Resultado esperado**:

- Ninguna pieza necesita soportes. La única excepción permitida es la que indique la guía, y como
  máximo una.
- La vista previa de capas no muestra paredes de menos de 3 líneas.
- Los dientes GT2 de la base y de la polea de altura se ven definidos en la vista previa.

## Escenario 8: guía de producción completa (Puerta 4, FR-025…FR-027)

```bash
grep -nE '\[(ej\.|Describir|Cant\.|Fragmento|Sí/No)' docs/puntero_laser_guia.md || echo "SIN MARCADORES"
```

**Resultado esperado**: `SIN MARCADORES`. Además, la guía contiene:

- La tabla de piezas.
- La BOM con medidas exactas.
- El orden de armado.
- El equilibrado y la colimación.
- El montaje en el trípode.
- Los requisitos de firmware: copia de [interfaz_firmware.md](contracts/interfaz_firmware.md) con
  los valores del escenario 1.
- Las advertencias de seguridad.

## Escenario 9: pruebas físicas (fuera del entorno automatizado)

| # | Prueba | Procedimiento | Criterio |
|---|--------|---------------|----------|
| F1 | Ajuste del 608 | Imprimir la `probeta_ajuste_608` y probar los 5 anillos | Elegir el anillo que entra con presión firme a mano o con prensa suave. Fijar `ajuste_608` y **regenerar todo** |
| F2 | Montaje en el trípode | Enroscar en un trípode con tornillo de 3/8"-16 | Firme y sin holgura visible. Se monta y desmonta en < 1 min (SC-006) |
| F3 | Cables | 3 vueltas de azimut en cada sentido y 20 recorridos de altura de −10° a 95° | Nada se enrosca, se tensa ni se desconecta (SC-005) |
| F4 | Equilibrio | Motores desenergizados, láser a 0°, 45° y 90° durante 5 min | Deriva ≤ 0,2° (US2 escenario 2) |
| F5 | Repetibilidad en banco | Puntero a una pared a 3 m (1° ≈ 52 mm). 10 idas y vueltas de 90° con llegada unidireccional | Dispersión ≤ 16 mm (0,3°) y error ≤ 26 mm (0,5°) (SC-004) |
| F6 | Constante de pasos | Ordenar 360° de azimut | Vuelve a la marca con ≤ 16 mm a 3 m |
| F7 | Colimación | Girar el láser dentro de la cuna apuntando a 10 m y ajustar los 6 prisioneros M3 | El punto describe un círculo de ≤ 44 mm de diámetro (≤ 0,25°) |
| F8 | Cielo | Alinear con 2 estrellas y apuntar a 3 estrellas separadas > 30°, a alturas de 15° a 85° | Error < 2° en cada una (SC-003). Se mide comparando con estrellas cercanas de separación angular conocida |
| F9 | Seguridad del láser | Encender 31 s; ordenar una altura de 5° | Se apaga a los 30 s; no enciende por debajo de 10° |
| F10 | Armado | Una persona que no participó del diseño arma el conjunto con la guía | < 3 h sin modificar piezas (SC-002) |

F5–F9 dependen del firmware, que queda fuera de alcance. Mientras no exista, F5 y F6 se pueden hacer
con un programa de prueba mínimo que solo mueva pasos.
