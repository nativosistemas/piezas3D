# Contrato: la página del visor (identificación de piezas)

Amplía los contratos de la [005](../../005-visor-armado-3d/contracts/visor.md) y la
[007](../../007-simulacion-funcionamiento/contracts/visor.md).

## Lista "Piezas de este paso"

Cada renglón: marca de tipo (`🖨 Impresa` / `🛒 Comprada`, texto y símbolo) y nombre visible. Sin
nombres declarados: identificador con `_` como espacios y sin marca, como en la 005. Pasar el
puntero, enfocar con el teclado o tocar un renglón resalta esa pieza en la escena.

## Selección en la escena (modos Armado y Funcionamiento)

| Acción | Mouse | Tacto o lápiz |
|---|---|---|
| Señalar | Pasar el puntero sobre una pieza sin botones apretados | Tocar sin arrastrar (< 500 ms, < 6 px) |
| Soltar | Salir de la pieza o del lienzo | Tocar el fondo |
| Girar, acercar, desplazar | Suelta la selección; no se selecciona durante el arrastre | Igual |

Al señalar: la pieza se resalta (tono del acento del visor; si está atenuada, un poco más opaca) y
aparece una etiqueta junto al puntero con el nombre visible y, si hay, el tipo. Cambiar de paso o de
modo suelta la selección.

Se puede señalar solo lo visible del modo actual. Gana la pieza opaca más cercana en ese punto; si no
hay opacas, la atenuada más cercana. El haz, el halo, las marcas de giro de las poleas y el fondo no
se señalan.

## Dirección para revisión

| Dirección | Efecto |
|---|---|
| `armado_3d.html?paso=5&t=1&senalar=perno_az` | Muestra la etiqueta y el resalte de ese elemento, como si se lo señalara en el centro de su caja; para capturas |
| `armado_3d.html?modo=funcionamiento&senalar=polea20_alt` | Igual en el modo Funcionamiento |

Un elemento desconocido o no visible se ignora.

## Leyenda

La leyenda de cada modo suma: "Pasá el puntero (o tocá) una pieza para ver qué es."
