# Quickstart: validar las marcas de orientación y de altura (012)

Escenarios para comprobar de punta a punta que la funcionalidad anda. Las piezas y los nombres están en
[contracts/ensamblaje.md](contracts/ensamblaje.md), los parámetros y validaciones en
[data-model.md](data-model.md) y los cambios de la guía en [contracts/guia.md](contracts/guia.md).

## Requisitos previos

- Rama `012-marcas-orientacion`, sobre `70ee3d6`.
- `openscad` funciona dentro del sandbox. Las capturas PNG y el Edge de Windows necesitan correr fuera
  (ver `CLAUDE.md`).

## 1. Las piezas cambiadas y la nueva verifican

```bash
for p in adaptador_tripode plataforma_azimut brazo_horquilla polea_altitud disco_escala; do scripts/verificar_pieza.sh --capturas .tools/tmp/012 src/puntero_laser_$p.scad; done
```

El brazo se verifica con su variante por defecto (`lado = "motor"`), que es la que cambia. Las
capturas van fuera del sandbox.

Esperado: sin errores ni advertencias, apoyo en Z = 0, dentro de la cama. Mirar las capturas:

- «S» y «O» legibles, con su línea, en la base.
- La raya y el triángulo en el borde +Y de la plataforma.
- La aguja vertical en la oreja del brazo.
- Los 2 agujeros guía en la polea.
- Las 7 rayas y las 2 ranuras en el disco.

## 2. El ensamblaje valida (M-03, M-07, M-08)

```bash
scripts/verificar_pieza.sh src/puntero_laser_ensamblaje.scad
```

Esperado: sin errores; las comprobaciones de choque de antes siguen pasando.

## 3. Las comprobaciones fallan cuando deben

Con `-D`, sin tocar `src/`:

| Cambio a propósito | Esperado |
|---|---|
| `-D holgura_aguja=0.5` | M-03: la aguja queda a menos de 2 mm de la correa de altura |
| `-D giro_ranura_disco=20` | M-06: las ranuras no cubren el escalón de 60° del hexágono |
| `-D alto_letra=40` | M-01: las letras no caben en el cilindro de apoyo |
| `-D paso_escala=17` | M-08 sigue pasando (cada raya cae en la aguja), pero la escala ya no llega a 90° y se avisa |

## 4. Las otras piezas no cambian

Comparar por vértices las 9 STL no tocadas con las de `70ee3d6`, incluida la variante cable del
brazo. Esperado: iguales.

## 5. Mirar el conjunto

Fuera del sandbox, generar la captura del conjunto con `scripts/capturas_armado.sh`. Esperado:

- **De costado (+X)**: la aguja arriba de la polea, en el plano del disco y sin tocar la correa.
- **Desde el frente (+Y), a la altura de la base**: la raya de la plataforma sobre la línea de la «S».

## 6. Visor y web

```bash
python3 scripts/generar_web.py --comprobar puntero_laser specs/002-puntero-laser-estelar
```

Esperado: sin errores (repetir con `caja_pilas specs/004-caja-pilas-aa`, que no debe cambiar). En el Edge:

- **Modo Armado**: el disco y sus tornillos entran en el paso de la polea.
- **Modo Funcionamiento**: el azimut arranca en 180°. En el modo automático, «Norte bajo» apunta hacia
  el lado opuesto a la «S» y «Oeste alto» hacia la «O».
- **Al subir el láser**: la raya de 45° del disco llega a la aguja cuando la altura marca 45°.
- **Web**: aparecen la orientación al sur, el cero de la escala y la posición de partida.

## 7. Prueba física (después de imprimir)

1. **Cero**: poner el cero con el método de la pared (guía 3.x).
2. **Altura**: con un medidor de inclinación sobre la cuna, comprobar 0°, 45° y 90° (±2°, SC-003).
3. **Azimut**: orientar la base con el celular en norte verdadero. Poner el índice en la «S» y en la
   «O» y comprobar contra un objeto lejano de rumbo conocido (±5°, SC-002).
