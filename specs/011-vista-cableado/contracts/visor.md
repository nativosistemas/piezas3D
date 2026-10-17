# Contrato: la página del visor (modo Cableado)

Amplía los contratos de la [005](../../005-visor-armado-3d/contracts/visor.md), la
[007](../../007-simulacion-funcionamiento/contracts/visor.md) y la
[008](../../008-identificacion-componentes/contracts/visor.md).

## Pestañas y direcciones

- La barra de pestañas aparece si los datos traen `simulacion` **o** `cableado`. Cada pestaña aparece
  solo si existe su modo: Armado (siempre), Funcionamiento y Cableado.
- `armado_3d.html#cableado` abre el modo Cableado; al cambiar el hash con la página abierta, cambia de
  modo sin recargar. `#paso-N` y `#funcionamiento` siguen igual.
- Revisión: `armado_3d.html?modo=cableado&senalar=<id del cable o elemento>` resalta ese cable o esa
  pieza con su etiqueta, como en la 008.

## Escena del modo Cableado

- Todas las piezas del catálogo en su posición final, salvo las de `ocultos`. Las de `transparentes`
  se ven con la transparencia del armado (`ALFA_ARMADO`).
- **Atenuar las piezas** (casilla del panel, encendida al entrar): las piezas de tipo `impresa` se ven
  transparentes. Las compradas y los cables quedan opacos.
- Cada cable con `recorrido`: un tubo por hilo, siguiendo el recorrido con las esquinas redondeadas a
  `radio_curva` (o a la mitad del tramo más corto, si es menor). Los hilos de un mismo cable van
  paralelos y se tocan. En cada extremo, una caja con las medidas y el color de su tipo, apoyada en el
  pin y alineada con el tramo. Un cable con `elemento` usa la malla de ese elemento.
- Al entrar, la cámara encuadra la caja de todos los cables, desde la dirección por defecto.

## Panel

- Título «Cableado» y una línea: «Cada cable de pin a pin. +5 V en rojo, GND en negro; las señales,
  en colores.»
- La casilla «Atenuar las piezas».
- La lista de cables, con un subtítulo por grupo (en el orden de `grupos`) y, debajo, un renglón por
  cable: una muestra de color (los colores de sus hilos) y el nombre. Señalar, enfocar o tocar un
  renglón resalta el cable en la escena.
- El botón «Vista inicial».
- Leyenda: «Los recorridos son orientativos: muestran por dónde pasa cada cable, no su forma exacta.
  Pasá el puntero (o tocá) un cable para ver qué conecta. Teclado: Inicio para la vista inicial.»

## Selección

La de la 008, con estos cambios en el modo Cableado:
- Se pueden señalar los cables (tubos y conectores, como una sola cosa) y las piezas visibles.
- La etiqueta de un cable: el nombre en negrita y, debajo, «Cable · ≈ <largo redondeado a 5 mm> mm».
- Los tubos y sus conectores tienen prioridad sobre las piezas: si el rayo corta un cable y una pieza
  opaca más cercana, gana el cable cuando está a menos de 3 mm de la pieza (los cables pasan pegados a
  las placas).

## Sin WebGL o sin cableado

Igual que hoy. Un visor sin `cableado` no muestra la pestaña, y `#cableado` queda en el modo Armado.
