# Plan de implementación: Identificación de componentes en el visor 3D

**Rama**: `008-identificacion-componentes` | **Fecha**: 2026-10-15 | **Especificación**: [spec.md](spec.md)

**Entrada**: especificación de la funcionalidad en `specs/008-identificacion-componentes/spec.md`

## Resumen

El visor 3D (`armado_3d.html`) deja de mostrar identificadores internos: cada elemento del
ensamblaje tiene un nombre legible y un tipo (impresa o comprada). La lista "Piezas de este paso" los
muestra con una marca de tipo, y señalar una pieza en la escena (puntero encima o toque) la resalta y
muestra una etiqueta, en los modos Armado y Funcionamiento.

Enfoque ([research.md](research.md)):

- **Declaración en el ensamblaje**: una lista opcional `nombres_elementos = [[elemento, nombre,
  tipo], …]` junto al catálogo. `armado_comun.scad` la lee con `is_undef`, la valida con `assert`
  (cobertura exacta del catálogo, tipo válido) y la entrega con `paso_armado = -1`, una línea de
  `echo` por elemento con el nombre al final (R1, R2).
- **Generador**: `generar_visor.py` agrega `nombre` y `tipo` a cada elemento de los datos
  incrustados (formato `version` 3); sin la lista, no los agrega (R3).
- **Página**: un `Raycaster` de three.js sobre las mallas de piezas visibles del modo actual, con
  prioridad de las opacas; resalte por color emisivo (y más opacidad si la pieza está atenuada) que
  se deshace al soltar; etiqueta HTML que sigue al puntero (R4–R7).

## Contexto técnico

**Lenguaje/Versión**: Python 3 (biblioteca estándar), OpenSCAD 2021.01, HTML + CSS + JavaScript
(módulos ES).

**Dependencias principales**: las de la 005 y la 007, sin agregados: OpenSCAD
(`.tools/bin/openscad`), three.js 0.160.0 incrustado (`scripts/vendor/three-0.160.0/`, ya trae
`Raycaster`), Edge de Windows para revisar.

**Almacenamiento**: archivos del repositorio; los visores generados se versionan.

**Pruebas**: escenarios de [quickstart.md](quickstart.md): validación estricta de los `.scad`,
declaraciones inválidas a propósito, `--comprobar` (puerta 5) y revisión en el navegador
(capturas con `?paso=N&señalar=…`). El proyecto no tiene pruebas unitarias y esta funcionalidad no
lo justifica.

**Plataforma**: navegadores actuales de computadora y celular, abriendo el archivo local.

**Tipo de proyecto**: herramienta del pipeline (biblioteca OpenSCAD + script + plantilla HTML).

**Objetivos de rendimiento**: etiqueta en < 0,25 s (SC-003); a lo sumo un cálculo de selección por
cuadro, también durante el modo automático.

**Restricciones**: sin internet ni servidor; ≤ 10 MB por diseño (los nombres suman ≈ 5 kB);
STL y capturas de armado sin cambios; `--hardwarnings` sin avisos (por eso `is_undef`).

**Escala**: 49 elementos en el puntero láser y 3 en la caja de pilas.

## Verificación de la constitución

*Puerta: se cumple antes de la investigación y se vuelve a revisar después del diseño.*

| Principio / puerta | Cómo se cumple | Estado |
|---|---|---|
| I. Diseño paramétrico | La lista nueva son textos, no cotas; las validaciones son `assert` con mensaje en español; `armado_comun.scad` mantiene su encabezado y orden | ✅ |
| II. Pipeline de cinco fases | Tareas agrupadas: 1) `.scad` (biblioteca y dos ensamblajes); 2) FEM: no aplica; 3) exportación: STL sin cambios; 4) documentación: skills y contratos; 5) generador, plantilla, webs y revisión en el navegador | ✅ |
| III. Simulación FEM | **No aplica**: ninguna pieza ni carga cambia; es una mejora de la página | ✅ (justificado) |
| IV. Manufactura aditiva | Las piezas no cambian; se comprueba que las STL sigan iguales | ✅ |
| V. Documentación y web | El visor sigue saliendo del ensamblaje y la guía, sin trabajo a mano; los nombres de lo comprado coinciden con `docs/<diseño>_bom.csv` (FR-012); las capturas PNG no cambian | ✅ |
| Gobernanza: un solo lugar por regla | Los nombres viven en el ensamblaje (junto al catálogo), no en la página; la convención va en la skill `disenio-multipieza` y la revisión en `web-armado`; la constitución no cambia | ✅ |
| Puerta 1 (diseño) | `verificar_pieza.sh --rapido` sobre la biblioteca y los dos ensamblajes | ✅ planificado |
| Puerta 3 (exportación) | STL sin cambios (`git status exports`) | ✅ planificado |
| Puerta 4 (documentación) | Guías sin cambios | ✅ planificado |
| Puerta 5 (web) | `generar_web.py --comprobar` pasa para los dos diseños; visores revisados en el navegador (lista del paso y selección en los dos modos) | ✅ planificado |

**Revisión después del diseño (fase 1)**: sin violaciones. La validación de cobertura en OpenSCAD
convierte un elemento sin nombre en un error al generar (puerta 1: "lo que se puede calcular se
calcula").

## Estructura del proyecto

### Documentación (esta funcionalidad)

```text
specs/008-identificacion-componentes/
├── spec.md
├── plan.md               # este archivo
├── research.md           # fase 0
├── data-model.md         # fase 1
├── quickstart.md         # fase 1
├── contracts/
│   ├── ensamblaje.md     # cómo declarar nombres_elementos
│   ├── scripts.md        # cambios en generar_visor.py
│   └── visor.md          # lista del paso, selección y etiqueta
├── checklists/requirements.md
└── tasks.md              # fase 2 (/speckit-tasks)
```

### Código y datos (raíz del repositorio)

```text
src/
├── armado_comun.scad              # lectura con is_undef, validación y echo NOMBRE
├── puntero_laser_ensamblaje.scad  # nombres_elementos de los 49 elementos
└── caja_pilas_ensamblaje.scad     # nombres_elementos de los 3 elementos

scripts/
├── generar_visor.py               # lee NOMBRE, agrega nombre y tipo, version 3
└── plantilla_visor.html           # lista con tipo, selección, resalte y etiqueta

specs/002-puntero-laser-estelar/web/armado_3d.html   # regenerado
specs/004-caja-pilas-aa/web/armado_3d.html           # regenerado

specs/005-visor-armado-3d/contracts/*.md             # enlace a la ampliación de la 008
.claude/skills/disenio-multipieza/SKILL.md           # convención para nombrar los elementos
.claude/skills/web-armado/SKILL.md                   # revisar nombres y selección
```

**Decisión de estructura**: todo entra en los archivos existentes; no hay archivos nuevos de código.
La plantilla crece ≈ 100 líneas.

## Seguimiento de la complejidad

Sin violaciones que justificar.
