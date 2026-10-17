# Contrato: guía, lista de materiales y web (012)

Cambios en `docs/puntero_laser_guia.md` y `docs/puntero_laser_bom.csv`. La web y el visor se regeneran
con `scripts/generar_web.py`, que no cambia.

## Lista de materiales (`docs/puntero_laser_bom.csv`)

Un renglón nuevo en la categoría «Tornillería M3», sin precio, como los demás tornillos:

```text
Tornillería M3;2 ×;Tornillo M3 × 8 mm + 2 × arandela M3: disco de la escala de altura, autorroscante en la polea;2;u;1;no;si;;;;;;;
```

## Guía

| Sección | Cambio |
|---|---|
| Valores del diseño entregado | El largo nuevo del brazo y el disco de la escala |
| 1. Impresión | Fila del disco: plano, escala hacia arriba y color claro recomendado. La aguja del brazo del motor se imprime sin soportes |
| 2. Instrucciones paso a paso | En el paso de la polea de altura: presentar el disco y los 2 tornillos sin apretar |
| 2. Montaje en el trípode | Nueva subsección **Orientación al sur**: brújula o celular en norte verdadero, declinación (R8), imanes de los motores, alinear la «S» girando la cabeza del trípode y la posición de partida |
| 3. Puesta a punto | Nueva subsección **3.x Cero de la escala de altura**: el método de la pared de R6, con la altura del eje `z_eje_altura` en mm |
| 3.6 Presupuesto de error | Una línea que aclara que las marcas dan ±5° de azimut y ±2° de altura para la posición de partida, y no entran en el presupuesto de apuntado |
| 5.1 / 5.3 Firmware | La posición de partida (azimut 180°, altura 0°) como estimación inicial al encender, antes de la alineación con 2 estrellas |
| 7. Consejos | Rellenar los grabados con pintura o marcador claro y leerlos con luz roja; el 0° es paralelo a la base, no al horizonte, si el trípode no está nivelado |

La declinación no lleva un valor fijo: lleva el método y el enlace al calculador de la NOAA. Si se da
un ejemplo con números, lleva su fuente y su fecha de consulta.

## Web y visor

- La web toma la guía como hoy. Las secciones nuevas aparecen en Primeros pasos y en los consejos según
  dónde caigan.
- El visor muestra el disco y los tornillos en el paso de la polea. En Funcionamiento, el azimut
  arranca en 180° y los objetivos apuntan a sus puntos cardinales reales.
