---
name: guia-produccion
description: Fase 4 del pipeline de piezas3D. Escribir la guía de producción docs/<diseño>_guia.md (impresión, lista de materiales, armado paso a paso, puesta a punto, consejos) y su lista de materiales en docs/<diseño>_bom.csv. Usar al documentar un diseño terminado o al cambiar sus piezas, su tornillería o sus componentes.
---

# Guía de producción

Lo que la guía debe contener (secciones A y B) lo exige el **Principio V** de
`.specify/memory/constitution.md`. Ejemplos completos: `docs/puntero_laser_guia.md` (varias piezas)
y `docs/soporte_pared_taladro_guia.md` (una pieza).

## 1. Partir de la plantilla

Copiar [plantilla_guia.md](plantilla_guia.md) a `docs/<diseño>_guia.md`.

**No cambiar los títulos fijos**: `scripts/generar_web.py` los busca para armar la web (fase 5).

| Título fijo | Qué hace la web con él |
|---|---|
| `## Primeros pasos` | Lo muestra como lista numerada destacada |
| `### Instrucciones Paso a Paso` | Cada ítem es una tarjeta con casilla "hecho" y su vista explotada |
| `## N. Consejos y buenas prácticas` | Lo muestra como tarjetas |
| Marcas `<!-- BOM:inicio -->` y `<!-- BOM:fin -->` | Las reemplaza por la lista que sale del CSV |

Las secciones marcadas "si aplica" se borran si no corresponden; no dejar marcadores sin rellenar
(puerta 4).

## 2. Lista de materiales: `docs/<diseño>_bom.csv`

La lista de materiales **no se escribe a mano en la guía**: vive en el CSV y
`scripts/generar_web.py` la copia entre las marcas. Separador `;`, codificación UTF-8, una fila por
línea de la lista y en el orden en que aparece en la guía.

| Columna | Contenido |
|---|---|
| `categoria` | Subtítulo en negrita de la guía (por ejemplo, `Tornillería M3`) |
| `texto_cantidad` | Cómo se lee la cantidad: `4 ×`, `2–4 ×`, `40 cm de` o vacío |
| `descripcion` | Medida exacta y para qué es: `Tornillo M3 × 12 mm + 4 × tuerca M3: pies de los brazos` |
| `cantidad`, `unidad` | Número para calcular el costo y su unidad (`u`, `cm`, `g`, `paquete`) |
| `paquete` | Cuánto trae lo que se compra, en la misma unidad (1, 100 cm, 1000 g) |
| `opcional` | `si` o `no`: lo opcional no suma al precio |
| `en_guia` | `no` para lo que no va en la lista de la guía (por ejemplo, el filamento) |
| `precio`, `moneda`, `tienda`, `url`, `fecha`, `nota` | Se completan en la fase 5 (skill `web-armado`); en la fase 4 pueden quedar vacíos |

Después de editar el CSV:

```bash
scripts/generar_web.py <diseño> specs/<NNN-nombre>
```

## 3. Cómo escribir cada parte

- **Introducción**: qué es y para qué sirve, en 2 a 4 oraciones; después la captura isométrica
  (`docs/img/<diseño>.png`, skill `pieza-openscad`).
- **Aviso de holguras**: si la pieza tiene encajes y `src/perfil_impresora.scad` tiene
  `perfil_medido = false`, dejar el aviso de la plantilla.
- **Impresión**: una fila por STL con orientación, relleno, perímetros, soportes y adherencia. Decir
  qué imprimir primero si hay una pieza de prueba.
- **Pasos de armado**:
  - Una acción por paso, con un título corto en negrita.
  - Nombrar la pieza y el herraje con su medida exacta (`perno M8 × 50`, no "el perno").
  - Decir desde dónde entra cada cosa y cuándo apretar.
  - En diseños de varias piezas, el paso N de la guía es el paso N de la tabla `pasos` del
    `_ensamblaje.scad` (skill `disenio-multipieza`): si se agrega, quita o reordena un paso, cambiar
    los dos.
- **Consejos y buenas prácticas**: resumir lo que la guía ya dice, en el orden en que aparece al
  construir, citando la sección de origen. No agregar recomendaciones que no estén respaldadas en
  la guía o en la especificación.
- **Herramientas**: las que piden los pasos (llaves, soldador, calibre), con su medida.
