# Quickstart: validar la vista de cableado (011)

Escenarios para comprobar de punta a punta que la funcionalidad anda. Los formatos están en
[contracts/](contracts/) y los campos en [data-model.md](data-model.md).

## Requisitos previos

- Rama `011-vista-cableado`, con la 010 ya en la historia (`ed17342`).
- `openscad` funciona dentro del sandbox. Las capturas PNG y el Edge de Windows necesitan correr fuera
  (ver `CLAUDE.md`).

## 1. El ensamblaje valida y declara los cables

```bash
scripts/verificar_pieza.sh src/puntero_laser_ensamblaje.scad
```

Esperado: sin errores ni advertencias. En la consola, las líneas `CABLES largo_<id>=…` de los 26
cables (y `largo_hilos_laser_total`), ninguno más largo que su cable comprado.

```bash
.tools/bin/openscad -D paso_armado=-1 -o "$TMPDIR/datos.csg" src/puntero_laser_ensamblaje.scad 2>&1 | grep -c '^ECHO: "CABLE;'
```

Esperado: `26`.

## 2. Las comprobaciones fallan cuando deben (SC-003, SC-004)

Cada una con una copia del ensamblaje en `$TMPDIR` o con `-D`, sin tocar `src/`:

| Cambio a propósito | Esperado |
|---|---|
| `-D x_pasillo=78` (el pasillo cae sobre los ULN2003) | `cables: 'v5_esp32' atraviesa el ULN2003 de altura cerca de […]` |
| `-D x_carril_usb=84` (el USB sube pegado al ESP32) | `cables: 'usb_5v' atraviesa el ESP32 cerca de […]` |
| `-D reserva_cable=60` | `cables: 'v5_esp32' mide 184 mm y el cable comprado 200 mm (faltan 44 mm)` |
| Cambiar en la guía «GPIO 16» por «GPIO 4» en un renglón | `generar_visor.py` falla: la guía tiene «ESP32 GPIO 4 → ULN2003 azimut IN1» y el ensamblaje no (y al revés) |
| Borrar un renglón de la Tabla de cables | Falla nombrando el cable que quedó solo en el ensamblaje |

Deshacer cada cambio y comprobar que todo vuelve a pasar.

## 3. Revisar los recorridos en OpenSCAD

Fuera del sandbox:

```bash
.tools/bin/openscad -D ver_cables=true -D ver_tapa=false --imgsize=1600,1200 --viewall --autocenter -o "$PWD/.tools/tmp/cableado.png" src/puntero_laser_ensamblaje.scad
```

Mirar la captura: cada cable sale de un pin, no atraviesa placas y llega al pin de destino. Los
Dupont del ESP32 salen por debajo, y los cables de los motores entran por la pared −X.

## 4. Las piezas impresas no cambian (FR-011)

```bash
scripts/verificar_pieza.sh src/puntero_laser_tapa_electronica.scad
```

Comparar por vértices las 13 STL de `exports/` con las del commit `ed17342`. Esperado: iguales. Si
R5 obligó a subir la tapa, cambian solo la tapa y lo que dependa de su alto, y eso queda anotado en el
plan.

## 5. Visor y web

```bash
scripts/generar_web.py puntero_laser specs/002-puntero-laser-estelar
scripts/generar_web.py --comprobar puntero_laser specs/002-puntero-laser-estelar
```

Esperado: el resumen dice `26 cables`, y la comprobación pasa. El visor pesa menos de 4,5 MB.

En el Edge de Windows, con `specs/002-puntero-laser-estelar/web/index.html`:

1. En «Instrucciones Paso a Paso» hay tres botones; el tercero es «Ver el cableado» (FR-001).
2. Tocarlo abre el visor en la pestaña Cableado, con la tapa transparente y sin el bloque gris.
3. La lista tiene 26 renglones en 7 grupos. Señalar «Dupont: ESP32 GPIO 19 → ULN2003 azimut IN4»
   resalta ese cable. Pasar el puntero sobre el cable muestra la misma etiqueta y su largo.
4. Los +5 V son rojos, los GND negros, y los 4 cables de cada ULN2003 tienen colores distintos.
5. Con «Atenuar las piezas» apagado, las piezas impresas vuelven a ser opacas.
6. Las pestañas Armado y Funcionamiento siguen funcionando, y `#paso-16` y `#funcionamiento` también.
7. Con el ancho de un celular (≤ 760 px), tocar un renglón resalta su cable (SC-002: un Dupont
   cualquiera se encuentra en menos de 30 s).

Para las capturas de revisión, usar
`armado_3d.html?modo=cableado&senalar=sen_az_in4` (o `cable_motor_alt`, `v5_esp32`).

## 6. Otros diseños

```bash
scripts/generar_web.py caja_pilas specs/004-caja-pilas-aa
scripts/generar_web.py --comprobar caja_pilas specs/004-caja-pilas-aa
```

Esperado: la caja de pilas (el otro diseño con visor) se regenera por el cambio de versión, la
comprobación pasa, y su web y su visor no tienen el botón ni la pestaña Cableado.
