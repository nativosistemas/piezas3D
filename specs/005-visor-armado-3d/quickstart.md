# Validación: Visor 3D de armado

Escenarios para comprobar la funcionalidad de punta a punta. Los comandos se corren desde la raíz del
repositorio. Contratos: [scripts](contracts/scripts.md), [visor](contracts/visor.md) y
[ensamblaje](contracts/ensamblaje.md).

## Requisitos previos

- La funcionalidad 004 (caja de pilas) con commit y traída a esta rama ([research R11](research.md#r11-dependencia-con-la-funcionalidad-004)).
- OpenSCAD 2021.01 en `.tools/bin/openscad` (funciona dentro del sandbox).
- Para revisar en el navegador: el Edge de Windows, **fuera del sandbox**. Abreviatura usada abajo:

  ```bash
  edge="/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
  ```

## 1. El visor sale con la web, para los dos diseños (historia 2, SC-001)

```bash
scripts/generar_web.py puntero_laser specs/002-puntero-laser-estelar
scripts/generar_web.py caja_pilas specs/004-caja-pilas-aa
```

**Esperado**: cada comando informa la web y el visor (`armado_3d.html`, tamaño y cantidad de piezas).
El primero tarda alrededor de un minuto (exporta 43 piezas); repetido sin cambios, unos segundos
("mallas reutilizadas"). El puntero láser pesa ≤ 10 MB (SC-005; referencia: 2,9 MB).

## 2. Comprobación de la puerta 5 (SC-006)

```bash
scripts/generar_web.py --comprobar puntero_laser specs/002-puntero-laser-estelar
```

**Esperado**: `✓` para la guía, la web y el visor. Después:

- Cambiar un parámetro de `src/puntero_laser_parametros.scad` (por ejemplo `margen_punta_perno`) y
  repetir: falla con "cambiaron las fuentes". Deshacer el cambio: vuelve a pasar.
- Cambiar una palabra del paso 8 en `docs/puntero_laser_guia.md` y repetir: falla con "cambió la
  guía". Deshacer.
- Borrar `armado_3d.html` y repetir: falla con "Falta el visor 3D".

## 3. Sin internet y sin servidor (FR-018)

```bash
grep -c "https\?://" specs/002-puntero-laser-estelar/web/armado_3d.html   # recursos externos: 0
"$edge" --headless=new --host-resolver-rules="MAP * ~NOTFOUND" --use-angle=swiftshader \
  --enable-unsafe-swiftshader --hide-scrollbars --window-size=1280,800 --virtual-time-budget=10000 \
  --screenshot="$(wslpath -w "$PWD/.tools/tmp/visor.png")" \
  "file:///$(wslpath -w "$PWD/specs/002-puntero-laser-estelar/web/armado_3d.html" | tr '\\' '/')?paso=8&t=0.25"
```

**Esperado**: la captura muestra la horquilla bajando sobre la plataforma y las tuercas M3 entrando
de costado en las ranuras, con el texto del paso 8 al lado.

## 4. Mismo contenido que las capturas (SC-002)

Para cada paso con piezas, capturar el visor con `?paso=N&t=0` (piezas en su posición explotada) y
compararlo con `docs/img/<diseño>_paso_NN.png`.

**Esperado**: las mismas piezas en color, las mismas transparentes, los mismos desplazamientos. En
el puntero láser, el carro del motor de altura NO aparece antes del paso 13 (subconjuntos).

## 5. Movimiento en dos tramos (FR-011)

Capturar el paso 8 del puntero láser en `t = 0.25` y `t = 0.75`.

**Esperado**: en 0,25 las tuercas del pie van entrando de costado mientras los brazos esperan
arriba; en 0,75 bajan juntos.

## 6. Interacción (historia 1)

Abrir el visor del puntero láser con doble clic (o con `"$edge" "$(wslpath -w …/armado_3d.html)"`) y
recorrerlo:

- Siguiente / Anterior, flechas del teclado y el selector de paso.
- Repetir y el deslizador (deja la pieza quieta en el punto elegido).
- Girar, acercar y desplazar; "Vista inicial" encuadra todo; cambiar de paso no mueve la cámara.
- Un paso sin piezas (16, cableado) muestra el texto y el conjunto armado, sin movimiento.
- Desde `index.html`, el enlace "Ver en 3D" del paso 8 abre el visor en el paso 8.

## 7. Celular (FR-019)

Abrir el visor en un celular (copiando el archivo o publicado) o con la emulación de dispositivos
del Edge a 360 px de ancho.

**Esperado**: la vista 3D arriba y el texto abajo, sin desplazamiento horizontal; girar con un dedo,
acercar pellizcando; el primer paso aparece en menos de 10 s (SC-004).

## 8. Giro de la polea (historia 3)

Capturar el paso 7 del puntero láser en `t = 0.5`.

**Esperado**: la polea de altura avanza hacia el brazo girando sobre su eje. Las capturas PNG del
paso 7 no cambian respecto de antes de declarar el giro.

## 9. Diseño sin ensamblaje

Ningún diseño de una sola pieza tiene web todavía (el soporte de pared no tiene lista de
materiales), así que se simula con la caja de pilas:

```bash
mv src/caja_pilas_ensamblaje.scad .tools/tmp/
scripts/generar_web.py caja_pilas specs/004-caja-pilas-aa
mv .tools/tmp/caja_pilas_ensamblaje.scad src/
scripts/generar_web.py caja_pilas specs/004-caja-pilas-aa
```

**Esperado**: la primera generación sale sin errores, sin visor nuevo y sin enlaces "Ver en 3D"; la
segunda vuelve a dejar la web y el visor como estaban.
