# Contrato: el ensamblaje de un diseño de varias piezas

Lo que `src/<diseño>_ensamblaje.scad` DEBE ofrecer para tener vistas explotadas y visor 3D. La
maquinaria común vive en `src/armado_comun.scad`; el ensamblaje la incluye y define solo lo propio.

## Lo que define el diseño

```openscad
include <armado_comun.scad>

paso_armado = 0;      // 0 = conjunto; n = vista explotada del paso n; -1 = datos de los pasos
solo_elemento = "";   // si no está vacío, dibuja solo ese elemento, en su lugar y sin color

/* [Hidden] */
alfa_contexto = 0.22;
color_flecha = "OrangeRed";
diametro_flecha = 2.4;   // la punta y su largo salen de este valor

pasos = [ /* 1 */ [[elemento, desplazamiento, resaltar, origen?, giro?], …], … ];
elementos = [ … ];
function color_elemento(e) = …;
module elemento(e) { … }
function anclas(e) = …;
function grupo(e, n) = …;    // sin subconjuntos: function grupo(e, n) = "conjunto";

armado();                    // despacha según paso_armado y solo_elemento
```

Los campos de cada entrada están en [../data-model.md](../data-model.md#entrada-de-un-paso).

## Lo que ofrece `armado_comun.scad`

| Nombre | Qué hace |
|---|---|
| `armado()` | `solo_elemento` → `elemento(solo_elemento)`; `-1` → datos; `0` → conjunto; `n` → `vista_paso(n)` |
| `vista_paso(n)` | Vista explotada: lo opaco primero, después lo transparente y el contexto; flechas con origen |
| `contexto_paso(n)` | Lista de elementos ya armados que se ven en el paso n (según `grupo`) |
| `datos_armado()` | Las líneas de `echo` de abajo |
| `flecha(desde, hasta)` | Flecha de `diametro_flecha` |
| `contiene(lista, x)`, `unicos(lista)` | Utilidades |
| comprobaciones | Todo elemento de `pasos` está en `elementos`; los campos tienen el tipo correcto |

`ensamblaje_principal()` (conjunto completo) sigue siendo del diseño, porque cada uno decide qué
mostrar transparente (la tapa, los ángulos extremos del láser).

## Salida con `paso_armado = -1`

Una línea por dato, en este orden (`ECHO: "…"` de OpenSCAD):

```text
PASO;<n>;<cantidad de entradas>          una por paso (la usa scripts/capturas_armado.sh)
PASOS;<tabla de pasos completa>          vector de OpenSCAD; undef → null para leerlo como JSON
COLOR;<elemento>;<nombre de color>       uno por elemento de `elementos`
CONTEXTO;<n>;<lista de elementos>        uno por paso
```

## Exportar un elemento

```bash
.tools/bin/openscad -D 'solo_elemento="brazo_motor"' -D '$fn=32' -o brazo_motor.stl src/puntero_laser_ensamblaje.scad
```

DEBE producir solo la geometría de ese elemento, en su posición final del conjunto.
