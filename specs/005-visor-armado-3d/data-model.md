# Modelo de datos: Visor 3D de armado

**Funcionalidad**: [spec.md](spec.md) · **Investigación**: [research.md](research.md)

## 1. En el ensamblaje (OpenSCAD)

La convención completa está en [contracts/ensamblaje.md](contracts/ensamblaje.md). Datos:

### Elemento

| Campo | Origen | Regla |
|---|---|---|
| nombre | `elementos` | Único, `snake_case`. Es el que aparece en el visor (con espacios) |
| color | `color_elemento(e)` | Nombre de color de OpenSCAD (CSS, p. ej. `SteelBlue`) |
| geometría | `elemento(e)` | En su posición final del conjunto; puede ser un grupo (p. ej. 4 tornillos) |
| anclas | `anclas(e)` | Solo para las flechas de las capturas; el visor no las usa |

### Paso de armado

Lista, posiblemente vacía, de **entradas**. La cantidad de pasos DEBE ser igual a la de la lista
numerada de "Instrucciones Paso a Paso" de la guía.

### Entrada de un paso

`[elemento, desplazamiento, resaltar, origen?, giro?]`

| Campo | Tipo | Regla |
|---|---|---|
| elemento | texto | DEBE estar en `elementos` |
| desplazamiento | vector [x, y, z] mm | Posición de la vista explotada respecto de la final; `[0, 0, 0]` = sin movimiento |
| resaltar | booleano | `true`: en color; `false`: transparente (contenedor o subconjunto que se mueve entero) |
| origen | vector o `undef` | Desplazamiento de la pieza que lo recibe; el movimiento va desplazamiento → origen → 0 |
| giro | `[punto, eje, grados]` o ausente | Punto del eje en la posición final, dirección del eje y ángulo total; solo el visor lo usa |

### Subconjunto

`grupo(e, n)` devuelve el subconjunto del elemento `e` en el paso `n` (después de los pasos de unión,
`"conjunto"`). **Contexto del paso n** = elementos de pasos anteriores que no están en el paso n y
cuyo grupo coincide con el de algún elemento del paso n. Lo calcula `contexto_paso(n)` en
`src/armado_comun.scad`, que usan tanto la vista explotada como el visor.

## 2. Datos incrustados en el visor (JSON)

Un objeto en `armado_3d.html`. El esquema detallado está en
[contracts/visor.md](contracts/visor.md).

| Campo | Contenido |
|---|---|
| `version` | Versión del formato (entero, empieza en 1) |
| `diseno` | Prefijo del diseño (`puntero_laser`) |
| `huella` | SHA-256 de las fuentes del visor (ver R2) |
| `fn` | Resolución de las curvas usada en la exportación (32) |
| `pasos[]` | `n`, `titulo`, `texto` (de la guía), `entradas[]` (`e`, `d`, `r`, `o`, `g`) y `contexto[]` |
| `elementos{}` | Por nombre: `color` y `malla` (Float32 x, y, z por vértice, en base64) |

**Reglas de validación** (el generador falla con un mensaje que nombra el dato):

- Cantidad de pasos de la tabla = cantidad de pasos de la guía.
- Todo elemento de una entrada o de un contexto tiene color y malla.
- Ninguna malla vacía (el elemento no dibuja nada).
- Tamaño total de la página ≤ 10 MB.
- La página no contiene URL `http(s)://` de recursos (funciona sin internet).

## 3. Estado del visor (en el navegador)

| Campo | Valor |
|---|---|
| paso actual | Índice en `pasos` (empieza en el del fragmento `#paso-N`, o en el 1) |
| t | Avance de la animación del paso, de 0 (explotado) a 1 (en su lugar) |
| reproduciendo | Si `t` avanza solo |
| cámara | La que deja la persona; al cambiar de paso solo se reencuadra (con el mismo ángulo) si lo que se ve en el paso queda fuera de cuadro (FR-017) |

**Transiciones**:

```text
abrir ──► paso N, t = 0, reproduciendo
reproduciendo ──(t llega a 1)──► quieto en t = 1
cualquier estado ──(Siguiente / Anterior / ir a paso)──► paso nuevo, t = 0, reproduciendo
cualquier estado ──(Repetir)──► t = 0, reproduciendo
cualquier estado ──(deslizador)──► t elegido, quieto
cualquier estado ──(Vista inicial)──► cámara inicial (el paso y t no cambian)
```

**Posición de una entrada en el instante t** (traslación; el giro se aplica igual, de `grados` a 0):

- Si ninguna entrada del paso tiene origen: `d · (1 − s(t))`.
- Si alguna tiene origen, en dos tramos (mitades de t):
  - con origen: de `d` a `o` en el primero; de `o` a 0 en el segundo;
  - sin origen: quieta en `d` en el primero; de `d` a 0 en el segundo.

`s` es una curva suave de 0 a 1 (arranca y frena despacio).
