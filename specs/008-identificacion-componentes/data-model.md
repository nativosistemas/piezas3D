# Modelo de datos: Identificación de componentes en el visor 3D

Amplía el [modelo de la 005](../005-visor-armado-3d/data-model.md) y el de la
[007](../007-simulacion-funcionamiento/data-model.md).

## 1. En el ensamblaje (OpenSCAD)

`nombres_elementos` (opcional): lista de `[elemento, nombre, tipo]`.

| Campo | Tipo | Regla |
|---|---|---|
| `elemento` | texto | Está en `elementos`; aparece una sola vez en la lista |
| `nombre` | texto | No vacío. Lo comprado usa la descripción de `docs/<diseño>_bom.csv` y puede agregar entre paréntesis dónde va; si el elemento agrupa varias piezas, lo dice (p. ej. "(4)") |
| `tipo` | texto | `"impresa"` o `"comprada"` |

Si la lista existe, cada elemento de `elementos` DEBE tener su entrada. Las violaciones son `assert`
con mensaje que nombra el elemento (los valida `comprobar_nombres()` de `armado_comun.scad`).

Salida con `paso_armado = -1`, una línea por entrada:

```text
ECHO: "NOMBRE;<elemento>;<tipo>;<nombre>"
```

## 2. En los datos del visor (JSON incrustado, `version` 3)

```json
"elementos": {
  "608_base_sup": { "color": "Silver", "malla": "…", "nombre": "Rodamiento 608ZZ (base, superior)", "tipo": "comprada" }
}
```

`nombre` y `tipo` aparecen en todos los elementos o en ninguno (diseño sin la lista). El resto del
formato no cambia.

## 3. En la página (estado)

| Estado | Valores | Cambia con |
|---|---|---|
| `señalada` | malla resaltada o `null` | puntero encima, toque, renglón de la lista |
| `guardado` | `emissive`, intensidad y opacidad previos de la malla señalada | al resaltar; se restaura al soltar |
| `arrastrando` | sí / no | `start` / `end` de los controles de la cámara |
| `puntero` | última posición sobre el lienzo o `null` | movimiento, salida del lienzo |

Transiciones que sueltan la selección: salir del lienzo, toque en el fondo, empezar a mover la vista,
cambiar de paso, cambiar de modo, la pieza deja de estar visible.

Nombre visible de un elemento: `nombre` si existe; si no, el identificador con `_` como espacios.
Tipo visible: `🖨 Impresa`, `🛒 Comprada` o nada.
