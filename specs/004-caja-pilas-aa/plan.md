# Plan de implementación: Caja con tapa a presión para 4 pilas AA

**Rama**: `004-caja-pilas-aa` | **Fecha**: 2026-10-06 | **Especificación**: [spec.md](spec.md)

**Entrada**: especificación de la funcionalidad en `specs/004-caja-pilas-aa/spec.md`

## Resumen

Estuche de PETG de dos piezas para 4 pilas AA acostadas en fila, de 67,2 × 54,9 × 26,9 mm cerrado:

- Una **caja** con 4 alojamientos de 14,9 × 50,9 mm separados por tabiques de 10 mm de alto, dos
  ranuras de encastre en las paredes largas y una muesca de apertura en una pared corta.
- Una **tapa** con una pollera interior de 8 mm y dos pestañas en voladizo con reborde a 45°, que se
  imprime con la cara exterior sobre la cama.

La deformación de las pestañas al cerrar es 1,38 % frente a 1,5 % admisible en PETG (research.md R4):
la simulación FEM **no aplica**. El generador recalcula ese valor y rechaza cualquier combinación que
lo supere.

## Contexto técnico

**Lenguaje/Versión**: OpenSCAD 2021.01 (`.tools/bin/openscad`)

**Dependencias principales**: `src/perfil_impresora.scad` (holguras y límites), scripts de
`scripts/` (`verificar_pieza.sh`, `capturas_armado.sh`, `generar_web.py`). No se usa FreeCAD (R4).

**Almacenamiento**: archivos del repositorio (`.scad`, `.stl`, `.md`, `.csv`, `.png`, `.html`)

**Pruebas**: escenarios de [quickstart.md](quickstart.md): derivados, verificación de cada pieza,
ensamblaje con `assert` de choque, capturas, variantes con `-D`, casos inválidos y pruebas físicas.

**Plataforma objetivo**: impresora FDM con boquilla de 0,4 mm y cama de 220 × 220 mm (perfil del
proyecto); uso en interiores, mochila o cajón.

**Tipo de proyecto**: generador paramétrico de dos piezas (skill `disenio-multipieza`).

**Objetivos de rendimiento**: render de cada pieza en < 30 s con `$fn = 64`.

**Restricciones**: sin soportes, voladizos ≤ 45°, paredes ≥ 1,2 mm, deformación de la pestaña ≤ 1,5 %.

**Escala/Alcance**: 4 archivos `.scad` (parámetros, caja, tapa, ensamblaje), 14 parámetros públicos,
9 reglas de validación, 2 STL, 1 guía, 1 lista de materiales y 1 web de armado.

## Comprobación de la constitución

*PUERTA: debe superarse antes de la Fase 0 y volver a comprobarse tras el diseño de la Fase 1.*

### Principios

| Principio | Cómo lo cumple el plan | Estado |
|-----------|------------------------|--------|
| I. Diseño paramétrico en OpenSCAD | 4 archivos en `src/` con encabezado y sección de parámetros. Las medidas compartidas se declaran una vez en `caja_pilas_parametros.scad`, que cada pieza incluye dentro de su sección de parámetros. Orden parámetros → derivadas → validaciones → ensamblaje → cuerpo → sumas → restas. `eps` en todos los cortes, `assert()` V-01…V-09 en español, posiciones relativas a los bordes, perfiles 2D extruidos (no se simula, así que no aplica la restricción CSG de FreeCAD) | ✅ |
| II. Pipeline de cinco fases | Las tareas se agrupan en 1) diseño, 2) simulación (no aplica, justificada), 3) exportación, 4) guía y lista de materiales y 5) web de armado | ✅ |
| III. Simulación en FreeCAD | **No aplica**: la única carga es la flexión de la pestaña, verificada con la fórmula de viga en voladizo (ε = 1,38 % ≤ 1,5 %) y recalculada por el generador para todo el rango aceptado (R4) | ✅ (justificado) |
| IV. Manufactura aditiva | Caja con la abertura arriba, tapa con la cara exterior sobre la cama; flancos a 45°; chaflán de 0,6 mm contra la pata de elefante; holguras de `holgura("suelto")` y `holgura("justo")`; el perfil está **sin medir** y la guía lo avisa; `$fn = 64` | ✅ |
| V. Documentación y web | `docs/caja_pilas_guia.md` (secciones A y B), `docs/caja_pilas_bom.csv` (filamento con precio verificado o vacío), captura isométrica, web en `specs/004-caja-pilas-aa/web/` con 2 vistas explotadas desde el ensamblaje | ✅ |

### Puertas de calidad

| Puerta | Verificación prevista | Estado |
|--------|-----------------------|--------|
| 1. Diseño | Escenarios 2–4 del quickstart: `verificar_pieza.sh` sin avisos en las 3 fuentes, cajas envolventes de la Entidad 4, capturas revisadas y `assert` del ensamblaje | ✅ Cumplida: caja 67,2 × 54,9 × 24,9 y tapa 67,2 × 54,9 × 10,0 mm, apoyo en Z = 0 y dentro de la cama; ensamblaje con reborde y ranura a 17,9 mm; capturas y corte del encastre revisados; variantes y 4 casos inválidos según el quickstart |
| 2. Simulación | Justificación de este plan y de R4 | ✅ (justificada) |
| 3. Exportación | 2 STL en `exports/` regenerados con los valores por defecto | ✅ Cumplida: `exports/caja_pilas_caja.stl` y `exports/caja_pilas_tapa.stl`, `Simple: yes` |
| 4. Documentación | Guía sin marcadores, con A y B, y su lista de materiales generada desde el CSV | ✅ Cumplida: `docs/caja_pilas_guia.md` y `docs/caja_pilas_bom.csv` |
| 5. Web de armado | `generar_web.py --comprobar` sin errores, precios con fuente y fecha, vistas revisadas y página revisada en el navegador | ✅ Cumplida: precio del PETG verificado en Printalot el 2026-10-06, dólar de DolarApi del 2026-10-05, 2 vistas revisadas y página revisada en Edge |

### Estructura del repositorio

Solo se escribe en `src/`, `exports/`, `docs/` y `specs/004-caja-pilas-aa/` (incluida su `web/`). No
se escribe en `simulation/`. Todo en español. ✅

**Resultado antes de la Fase 0**: SUPERADA. **Resultado tras la Fase 1**: SUPERADA; el diseño no
introduce desviaciones.

## Estructura del proyecto

### Documentación (esta funcionalidad)

```text
specs/004-caja-pilas-aa/
├── spec.md                        # Especificación
├── plan.md                        # Este archivo
├── research.md                    # Fase 0: decisiones R1–R8 y precálculo del encastre
├── data-model.md                  # Fase 1: parámetros, derivados, validaciones, piezas y pasos
├── quickstart.md                  # Fase 1: escenarios de verificación y pruebas físicas
├── contracts/interfaz_generador.md
├── checklists/requirements.md
├── tasks.md                       # Fase 2 (/speckit-tasks)
└── web/index.html                 # Web de armado (fase 5)
```

### Código fuente y entregables

```text
src/
├── caja_pilas_parametros.scad     # Parámetros, derivados y validaciones compartidos
├── caja_pilas_caja.scad           # Caja (abertura hacia arriba)
├── caja_pilas_tapa.scad           # Tapa (cara exterior sobre la cama)
└── caja_pilas_ensamblaje.scad     # Conjunto, comprobaciones y tabla de pasos (no se exporta)
exports/
├── caja_pilas_caja.stl
└── caja_pilas_tapa.stl
docs/
├── caja_pilas_guia.md
├── caja_pilas_bom.csv
└── img/caja_pilas*.png            # Isométrica y pasos de armado
```

**Decisión de estructura**: se sigue la sección 3 de la skill `disenio-multipieza` con el prefijo
`caja_pilas`. La división en dos piezas tiene un motivo de la sección 1 de esa skill: **acceso** (la
tapa se abre para meter y sacar las pilas).

## Seguimiento de complejidad

No hay violaciones de la constitución que justificar.
