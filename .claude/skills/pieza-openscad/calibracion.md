# Perfil de impresora y calibración

`src/perfil_impresora.scad` guarda el comportamiento **medido** de la impresora real: holguras,
expansión horizontal y límites (paredes, voladizos, puentes, cama). Toda pieza con encajes lo
incluye y toma de ahí sus holguras, así que calibrar una vez corrige todas las piezas que vienen
después.

Mientras tenga `perfil_medido = false`, los valores son **por defecto, no medidos**. Cada vez que se
entregue una pieza con encajes, la especificación y la guía tienen que avisarlo, y la primera
impresión es la que confirma el ajuste.

## Calibración (una vez por impresora y material)

Se hace con un **peine de calibración**, que es un diseño propio del proyecto y pasa por el pipeline
como cualquier otro (todavía no está hecho):

1. Una placa con siete agujeros para un pasador de 6,00 mm, cada uno con una holgura distinta
   (0,05 · 0,10 · 0,15 · 0,20 · 0,25 · 0,30 · 0,40 mm) grabada debajo.
2. Un pasador de 6,00 mm impreso **acostado** para que salga redondo.
3. Un cubo de 20,00 mm para medir la expansión horizontal.

Se imprime con el mismo material y perfil del laminador que las piezas funcionales. Después:

1. Probar el pasador en cada agujero y anotar cuál queda a presión, justo, deslizante y suelto.
   La holgura de cada nivel es `agujero_elegido − 6,00`.
2. Medir el cubo con calibre en X y en Y: `expansion_xy = (medida − 20,00) / 2`.
3. Cargar los valores en `src/perfil_impresora.scad`, completar impresora, material y fecha, y poner
   `perfil_medido = true`.
4. Regenerar los STL de las piezas con encajes.

Las holguras cambian con el material: si se imprime en otro (PLA ≠ PETG ≠ ABS), repetir la
calibración o anotar en la guía que los valores son de otro material.
