# Plan de implementación: Soporte de pared paramétrico para taladro

**Rama**: `main` (ID de funcionalidad `001-soporte-pared-taladro`) | **Fecha**: 2026-10-04 | **Especificación**: [spec.md](spec.md)

**Entrada**: especificación de la funcionalidad en `specs/001-soporte-pared-taladro/spec.md`

## Resumen

Se diseñará un soporte de pared imprimible en 3D para colgar un taladro inalámbrico con el
portabrocas hacia abajo. La pieza es única, con forma de «L», y tiene estos elementos:

- Una bandeja horizontal con una ranura en U abierta al frente y un labio de retención.
- Una placa trasera vertical con 2 orificios avellanados para fijarla a la pared.
- Dos cartelas laterales que rigidizan el voladizo.

Todo se define con parámetros en un único `.scad`: ancho, profundidad, diámetro de tornillo, ancho
de la ranura, espesores, etc. Los parámetros se validan con `assert`. La pieza se imprime en la
posición de uso (bandeja sobre la cama) sin soportes. El precálculo analítico (tensión máxima de
8,5 MPa con FS 3; flecha cercana a 1 mm sin cartelas) muestra que la simulación en FreeCAD
**aplica**. Se ejecuta sin interfaz gráfica con un script de FreeCAD en `simulation/`, que además
sirve de guía para repetirla. El detalle técnico está en [research.md](research.md).

## Contexto técnico

**Lenguaje/Versión**: OpenSCAD 2021.01

**Dependencias principales**: todas están instaladas en `.tools/` (ignorado por git) y se invocan con
los lanzadores de `.tools/bin/`:

| Herramienta | Versión | Lanzador | Uso |
|-------------|---------|----------|-----|
| OpenSCAD | 2021.01 (AppImage extraída) | `.tools/bin/openscad` | Diseño, Customizer y exportación a STL y CSG por línea de comandos |
| FreeCAD | 1.1.4 (AppImage extraída) | `.tools/bin/freecadcmd` (sin interfaz) y `.tools/bin/freecad` (con interfaz) | Importación de CSG (`importCSG`) y banco *FEM* |
| Gmsh | 4.15.0 (incluido en FreeCAD) | `.tools/bin/gmsh` | Mallado de segundo orden |
| CalculiX | 2.23 (incluido en FreeCAD) | `.tools/bin/ccx` | Solver estático lineal |
| Python | 3.14 del sistema | `python3` | Medir la caja envolvente del STL |
| Laminador FDM | PrusaSlicer, Cura u Orca | — (fuera del entorno) | Comprobación de imprimibilidad |

`.tools/bin/freecadcmd` redirige la configuración de usuario de FreeCAD a `.tools/freecad-home`,
porque en el sandbox `~/.config` y `~/.local` no se pueden escribir. También añade `ccx` y `gmsh` al
`PATH`. Ya se verificó que funciona: un análisis FEM de prueba de una viga coincidió con el cálculo
analítico con una diferencia inferior al 4 %, y un CSG de OpenSCAD se importó como sólido válido con
el volumen exacto.

**Almacenamiento**: archivos del repositorio (`.scad`, `.csg`, `.stl`, `.md` y `.FCStd`)

**Pruebas**: verificación por línea de comandos definida en [quickstart.md](quickstart.md):

- Renderizado con `--hardwarnings`.
- Caja envolvente del STL medida con `python3`.
- Barrido de parámetros válidos e inválidos (`assert`).
- Simulación FEM automatizada con `.tools/bin/freecadcmd`.
- Prueba física.

**Plataforma objetivo**:

- Desarrollo: Linux (Ubuntu 26.04 en WSL2), dentro del sandbox, con las herramientas de `.tools/bin/`.
- Fabricación: impresora FDM con boquilla de 0,4 mm y cama de al menos 180 × 180 mm.

**Tipo de proyecto**: generador paramétrico de una pieza para manufactura aditiva

**Objetivos de rendimiento**:

- Renderizado CGAL completo en < 60 s con `$fn = 64`.
- Regeneración de una variante (medir, cambiar parámetros y exportar) en < 10 min por parte del
  usuario (SC-006).

**Restricciones**:

- Sin soportes de impresión y con voladizos ≤ 45° (FR-011).
- Ninguna sección de menos de 1,2 mm (3 líneas de extrusión de 0,4 mm, FR-012).
- Caja envolvente igual a los parámetros con ±0,1 mm (SC-004).
- Solo primitivas importables por CSG en FreeCAD: sin `hull` ni `minkowski` (R10).
- Carga de diseño de 25 N con FS 3: σ ≤ 10 MPa y flecha del borde frontal ≤ 1 mm (SC-003).

**Escala/Alcance**:

- 1 archivo `.scad` con ~8 módulos, 14 parámetros públicos y 10 reglas de validación.
- 1 STL, 1 script y 1 guía de simulación, y 1 guía de producción.

## Comprobación de la constitución

*PUERTA: debe superarse antes de la Fase 0 y volver a comprobarse tras el diseño de la Fase 1.*

### Principios

| Principio | Cómo lo cumple el plan | Estado |
|-----------|------------------------|--------|
| I. Diseño paramétrico en OpenSCAD | `src/soporte_pared_taladro.scad` con encabezado estándar y la sección `// --- PARÁMETROS Y CONSTANTES ---`, que contiene todos los parámetros (con grupos del Customizer) y `$fn`. Los derivados van en `[Hidden]`, no hay números mágicos en los módulos y los módulos tienen nombres en español y `snake_case`, más `ensamblaje_principal()` ([data-model.md](data-model.md)) | ✅ |
| II. Pipeline lineal de cuatro fases | Las tareas se agruparán en: 1) diseño `.scad`, 2) simulación FEM (aplica), 3) exportación `.stl` y 4) guía `docs/`. Ninguna fase empieza sin cerrar la anterior | ✅ |
| III. Simulación en FreeCAD | **Aplica**: voladizo con carga permanente y flecha cercana al límite en el precálculo (R9). El script `simulation/soporte_pared_taladro_fem.py` (ejecutado con `.tools/bin/freecadcmd`) importa el `.csg` y monta el análisis *FEM* con material PETG, fijaciones, carga de 25 N, malla Gmsh y CalculiX. Guarda el `.FCStd` y vuelca los resultados. `simulation/soporte_pared_taladro_fem.md` documenta los pasos (también para hacerlos en la interfaz gráfica), los criterios de aceptación y los resultados obtenidos (R10) | ✅ |
| IV. Diseño para manufactura aditiva | Impresión en la posición de uso, sin soportes, con voladizos ≤ 45°, chaflanes en lugar de aristas vivas y holgura de tornillo de 0,4 mm. El STL en `exports/` se regenera con los valores por defecto documentados (R2) | ✅ |
| V. Documentación de producción | `docs/soporte_pared_taladro_guia.md`, que sigue la plantilla B de `.github/spec_kit_profile.md`. Contiene: A) orientación, relleno, perímetros, soportes, adherencia y material; B) BOM (2 × tornillo avellanado 5 × 50 y 2 × taco Ø8) e instalación paso a paso, más la forma de medir el taladro (FR-017) | ✅ |

### Puertas de calidad

| Puerta | Verificación prevista | Estado |
|--------|-----------------------|--------|
| 1. Diseño | Escenario 1 del quickstart: `.tools/bin/openscad --hardwarnings` sin errores ni advertencias | ✅ Cumplida (T013, T029): código 0, 0 `WARNING`/`ERROR`, `Simple: yes`, `Volumes: 2`, caja 80 × 100 × 70 mm, render en ≈ 4–6 s; 0 facetas en voladizo > 45° |
| 2. Simulación | Escenario 6 del quickstart: `.tools/bin/freecadcmd simulation/soporte_pared_taladro_fem.py` genera el `.FCStd` y los resultados cumplen σ ≤ 10 MPa y flecha ≤ 1 mm. La guía de `simulation/` recoge los valores | ✅ Cumplida (T020, T029): base σ = 0,486 MPa y flecha = 0,0405 mm; pésima σ = 2,18 MPa y flecha = 0,21 mm; malla convergida (< 1 %); `.FCStd` guardado |
| 3. Exportación | `exports/soporte_pared_taladro.stl` regenerado con los valores por defecto (escenarios 1 y 2) | ✅ Cumplida (T022): la huella SHA-256 del `.scad` (`e02f77cc…`) coincide con la simulada; caja 80 × 100 × 70 mm; 1756 facetas |
| 4. Documentación | Guía sin marcadores de plantilla (escenario 7) | ✅ Cumplida (T028): `docs/soporte_pared_taladro_guia.md` sin marcadores, secciones 1–4 completas y valores iguales a los del `.scad` |

### Estructura del repositorio

Solo se escribe en `src/`, `simulation/`, `exports/` y `docs/`, más los artefactos de Spec Kit en
`specs/`. **No** se crea un directorio `tests/`: la verificación se describe con comandos en el
quickstart (R12). Las herramientas locales viven en `.tools/`, que está ignorado por git y no
contiene artefactos del diseño. Todo está en español. ✅

**Resultado antes de la Fase 0**: SUPERADA. No hay violaciones que justificar.
**Resultado tras la Fase 1**: SUPERADA. El diseño no introduce desviaciones. Las puertas 1 a 4 quedan
como criterios de cierre de la implementación.

## Estructura del proyecto

### Documentación (esta funcionalidad)

```text
specs/001-soporte-pared-taladro/
├── spec.md                       # Especificación (/speckit-specify)
├── plan.md                       # Este archivo (/speckit-plan)
├── research.md                   # Fase 0: decisiones de diseño y precálculo
├── data-model.md                 # Fase 1: parámetros, derivados, validaciones y módulos
├── quickstart.md                 # Fase 1: escenarios de verificación ejecutables
├── contracts/
│   └── interfaz_generador.md     # Fase 1: interfaz pública del generador (parámetros, CLI, salidas, errores)
├── checklists/
│   └── requirements.md           # Calidad de la especificación
└── tasks.md                      # Fase 2 (/speckit-tasks, NO lo crea /speckit-plan)
```

### Código fuente y entregables (raíz del repositorio)

```text
src/
└── soporte_pared_taladro.scad        # Fase 1 del pipeline: modelo paramétrico
simulation/
├── soporte_pared_taladro.csg         # Fase 2: exportación para FreeCAD (generada)
├── soporte_pared_taladro_fem.py      # Fase 2: script FEM para .tools/bin/freecadcmd
├── soporte_pared_taladro_fem.md      # Fase 2: guía FEM paso a paso + resultados
└── soporte_pared_taladro.FCStd       # Fase 2: proyecto FreeCAD (lo genera el script)
exports/
└── soporte_pared_taladro.stl         # Fase 3: malla con los valores por defecto
docs/
└── soporte_pared_taladro_guia.md     # Fase 4: guía de impresión, BOM e instalación
```

**Decisión de estructura**: se usa el árbol fijo de la constitución, con un archivo por fase y el
prefijo común `soporte_pared_taladro`. La guía de producción lleva el nombre de la pieza en lugar de
`guia_impresion_y_armado.md`, para que el repositorio pueda alojar más diseños sin colisiones de
nombres. La plantilla de referencia sigue siendo la del perfil.

## Riesgos y mitigaciones

| Riesgo | Mitigación |
|--------|------------|
| Herramientas locales ausentes en otra máquina o clon (`.tools/` no se versiona) | El quickstart documenta cómo reinstalarlas (descarga de las AppImage oficiales con verificación SHA-256 y extracción) |
| Selección de caras frágil en el script FEM (los nombres `FaceN` cambian con los parámetros) | El script elige las caras por geometría (normal y posición), no por nombre |
| El importador CSG de FreeCAD no reconstruye alguna operación | Solo se usan primitivas compatibles (R10). Como vía alternativa, se importa el STL y se convierte a sólido |
| Fluencia del PETG bajo carga permanente | FS 3, cartelas obligatorias y prueba física de 7 días (SC-002) |
| Flecha > 1 mm en configuraciones fuera del rango validado | La guía exige repetir la simulación fuera de ese rango ([data-model.md](data-model.md#reglas-de-validación)) |

## Seguimiento de la complejidad

Sin violaciones de la constitución: no aplica.
