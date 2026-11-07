# Quickstart: validar el circuito del láser (013)

Escenarios de punta a punta. Formatos en [contracts/](contracts/) y campos en
[data-model.md](data-model.md).

## Requisitos previos

- Rama `013-circuito-laser`.
- `openscad` funciona dentro del sandbox; las capturas PNG y el Edge de Windows, fuera (ver
  `CLAUDE.md`).

## 1. El ensamblaje valida y declara el circuito

```bash
scripts/verificar_pieza.sh src/puntero_laser_ensamblaje.scad
```

Esperado: sin errores ni advertencias.

```bash
.tools/bin/openscad -D paso_armado=-1 -o "$TMPDIR/datos.csg" src/puntero_laser_ensamblaje.scad 2>&1 | grep '^ECHO: "CIRCUITOS;'
```

Esperado: una línea con el circuito `laser` y sus 7 grupos.

## 2. Las comprobaciones fallan cuando deben

Con `-D` o una copia en `$TMPDIR`, sin tocar `src/`:

| Cambio a propósito | Esperado |
|---|---|
| Un miembro mal escrito (`tornillo_contato`) | `circuitos: 'laser' nombra 'tornillo_contato', que no es un elemento ni un cable` |
| Poner `cable_laser` como miembro | `circuitos: …` pide nombrar el cable `hilos_laser` |
| Un translúcido que no es miembro (`tapa_trasera`) | `circuitos: …` lo nombra |
| Dos circuitos con el mismo id | `circuitos: 'laser' está repetido` |
| `-D diametro_hueco_bateria=12` | V-30 o la comprobación de la pila (el ojal no entra) |

Deshacer y comprobar que todo vuelve a pasar.

## 3. Captura del paso 14 (fuera del sandbox)

```bash
scripts/capturas_armado.sh puntero_laser
```

Mirar `docs/img/puntero_laser_paso_14.png`: la pila con el tornillo, el ojal y el hilo rojo entran
juntos; los prisioneros, la tuerca y el ojal negro, radiales desde la tapa; nada flota.

## 4. Visor y web

```bash
scripts/generar_web.py puntero_laser specs/002-puntero-laser-estelar
scripts/generar_web.py --comprobar puntero_laser specs/002-puntero-laser-estelar
scripts/generar_web.py --comprobar caja_pilas specs/004-caja-pilas-aa
```

Esperado: «1 circuitos» en la línea del visor del puntero láser; las comprobaciones pasan; la caja de
pilas sigue igual.

Capturas sin ventana (fuera del sandbox), con la orden de la skill `web-armado`:

| Dirección | Revisar |
|---|---|
| `?modo=cableado&circuito=laser` | Todo el camino encuadrado, del power bank a la cola del láser; el relé, la resistencia y el cable del GPIO 23 bajo el ESP32 translúcido; pila, tornillo, ojal y hilo rojo a través del tubo translúcido; prisionero, tuerca y ojal negro; todo lo demás casi invisible; el panel con la descripción y los 7 grupos |
| `?modo=cableado&circuito=laser&senalar=tornillo_contacto` | La etiqueta del tornillo |
| `?modo=cableado` | El modo Cableado igual que antes, con el botón nuevo |
| `?paso=14&t=0` | Igual que la captura del paso 14 |
| `?modo=funcionamiento&altura=95&laser=1` | Las piezas nuevas giran con el láser |

En el navegador, a mano (lo pide al usuario): tocar el botón, señalar renglones, soltar el botón y
volver, y cambiar de modo y volver.
