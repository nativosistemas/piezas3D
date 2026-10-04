<!--
Informe de Impacto de Sincronización (Sync Impact Report)
- Cambio de versión: plantilla sin completar → 1.0.0 (ratificación inicial)
- Principios definidos:
  - [PRINCIPLE_1_NAME] → I. Diseño Paramétrico en OpenSCAD (NO NEGOCIABLE)
  - [PRINCIPLE_2_NAME] → II. Pipeline Lineal de Cuatro Fases (NO NEGOCIABLE)
  - [PRINCIPLE_3_NAME] → III. Validación y Simulación en FreeCAD (Cuando Aplique)
  - [PRINCIPLE_4_NAME] → IV. Diseño para Manufactura Aditiva
  - [PRINCIPLE_5_NAME] → V. Documentación de Producción Obligatoria
- Secciones añadidas: Estructura del Repositorio y Formatos; Flujo de Trabajo y Puertas de Calidad
- Secciones eliminadas: ninguna
- Fuentes: "Perfil de GitHub Spec Kit: Agente de IA para Diseño Mecánico" (conservado en
  .github/spec_kit_profile.md) y "Directiva de Diseño y Manufactura 3D" (integrada aquí)
- Plantillas: .specify/templates/* no requieren cambios; leen esta constitución en tiempo de ejecución
- TODOs diferidos: ninguno
-->
# Constitución de piezas3D

## Principios Fundamentales

### I. Diseño Paramétrico en OpenSCAD (NO NEGOCIABLE)

- Todo el modelado DEBE realizarse con código paramétrico de **OpenSCAD** y guardarse como
  archivo `.scad` dentro de `src/`.
- Cada archivo `.scad` DEBE comenzar con el encabezado estándar (Proyecto, Componente,
  Descripción) seguido de la sección `// --- PARÁMETROS Y CONSTANTES ---`, donde se declaran
  TODAS las dimensiones clave y `$fn`. No se permiten números mágicos dimensionales dentro
  de los módulos.
- El código DEBE ser limpio, ordenado y comentado, con la geometría organizada en módulos
  nombrados y un módulo de ensamblaje principal (`ensamblaje_principal()` o equivalente).
- Los nombres de variables y módulos DEBEN ser descriptivos y en español con `snake_case`
  (p. ej., `espesor_pared`, `diametro_orificio`).

**Justificación:** los parámetros al inicio permiten modificar el diseño sin tocar la
geometría y convierten cada pieza en un generador reutilizable.

### II. Pipeline Lineal de Cuatro Fases (NO NEGOCIABLE)

Toda solicitud de diseño DEBE progresar en este orden, sin saltar fases:

```text
[1. DISEÑO PARAMÉTRICO] ──> [2. SIMULACIÓN FEA] ──> [3. EXPORTACIÓN] ──> [4. DOCUMENTACIÓN]
   (OpenSCAD .scad)            (Guía FreeCAD)           (.stl)           (Manual .md)
```

- Una fase NO DEBE comenzar hasta que la anterior esté completa.
- La fase 2 puede declararse "no aplica" solo con una justificación explícita registrada en
  el plan (ver Principio III).
- Las tareas generadas por `/speckit-tasks` DEBEN agruparse siguiendo estas cuatro fases.

**Justificación:** un flujo predecible garantiza que cada pieza llegue validada, fabricable
y documentada.

### III. Validación y Simulación en FreeCAD (Cuando Aplique)

- Si el diseño requiere evaluar esfuerzo mecánico, análisis de elementos finitos (FEA/FEM),
  dinámica de fluidos, integridad estructural u otras pruebas que OpenSCAD no soporta de
  forma nativa, DEBE incluirse una fase de simulación en **FreeCAD**.
- El flujo DEBE indicar cómo exportar el modelo a un formato compatible con FreeCAD
  (`.csg` o `.step`) y explicar paso a paso el banco de trabajo a usar (p. ej.,
  *FEM Workbench*), el material asignado, las restricciones (fijaciones), las cargas
  aplicadas y los criterios de aceptación.
- Las notas y archivos de simulación (`.FCStd`) DEBEN guardarse en `simulation/`.
- Si no se simula, la especificación o el plan DEBE justificar por qué no es necesario.

**Justificación:** las piezas funcionales o sometidas a carga deben validarse antes de
fabricarse para evitar fallos e impresiones desperdiciadas.

### IV. Diseño para Manufactura Aditiva

- La geometría DEBE optimizarse para impresión 3D: minimizar voladizos y la necesidad de
  soportes, y respetar espesores de pared y tolerancias realistas para FDM.
- El modelo final renderizado DEBE exportarse en formato **`.stl`** dentro de `exports/`.
- El `.stl` DEBE corresponder exactamente a los valores de parámetros documentados; si
  cambian los parámetros, el `.stl` DEBE regenerarse.

**Justificación:** el entregable final es una pieza física; el diseño debe pensarse
desde el principio para fabricarse sin problemas.

### V. Documentación de Producción Obligatoria

Cada diseño DEBE incluir una guía de producción en `docs/` (plantilla de referencia:
`docs/guia_impresion_y_armado.md`) con dos secciones críticas:

- **A. Guía de impresión 3D:**
  - Orientación óptima (qué cara va sobre la cama) para minimizar soportes y maximizar
    la resistencia estructural.
  - Parámetros del laminador (slicer): porcentaje y patrón de relleno (infill), número de
    perímetros (paredes), soportes (sí/no y ubicación) y adherencia (brim/raft).
  - Material recomendado según la aplicación (PLA, PETG, ABS, TPU, etc.).
- **B. Manual de ensamblaje y armado:**
  - Lista de materiales (BOM) cuando el diseño tenga varias piezas o requiera tornillería
    externa, con cantidades y especificaciones (p. ej., `Tornillo M3x12mm`).
  - Instrucciones paso a paso, en orden cronológico, claras y concisas.

**Justificación:** cualquier persona debe poder imprimir y montar la pieza sin
conocimiento previo del diseño.

## Estructura del Repositorio y Formatos

Los artefactos del diseño DEBEN ubicarse estrictamente en este árbol:

```text
/
├── .github/
│   └── spec_kit_profile.md     # Perfil del agente: plantillas de salida (.scad y guía .md)
├── src/                        # TODO el código nativo de OpenSCAD (.scad)
├── simulation/                 # Notas y pasos de simulación en FreeCAD (.FCStd)
├── exports/                    # Archivos de manufactura listos para producción (.stl)
└── docs/                       # Manuales de ensamblaje y guías de impresión (.md)
```

- Excepciones permitidas: los artefactos de Spec Kit (`specs/`, `.specify/`) y la
  configuración del agente (`.claude/`, `CLAUDE.md`).
- Las plantillas de salida obligatorias (encabezado `.scad` y guía de producción) están
  definidas en `.github/spec_kit_profile.md` y DEBEN seguirse.
- Herramientas objetivo: OpenSCAD (diseño), FreeCAD (simulación) y un laminador 3D
  (manufactura).
- Toda la documentación, los comentarios del código y los artefactos de Spec Kit DEBEN
  redactarse en español.

## Flujo de Trabajo y Puertas de Calidad

Antes de dar un diseño por terminado DEBEN cumplirse estas puertas:

1. **Diseño:** el `.scad` está en `src/`, tiene encabezado y sección de parámetros, y
   renderiza sin errores ni advertencias de geometría (con `openscad` en línea de comandos
   cuando esté disponible).
2. **Simulación:** existe la guía de FreeCAD en `simulation/` o una justificación
   explícita de que no aplica.
3. **Exportación:** el `.stl` está en `exports/` y coincide con los parámetros actuales.
4. **Documentación:** la guía en `docs/` contiene las secciones A y B completas, sin
   marcadores de plantilla sin rellenar.

La sección "Constitution Check" de cada `plan.md` DEBE verificar los cinco principios y
estas cuatro puertas.

## Gobernanza

- Esta constitución prevalece sobre cualquier otra práctica del repositorio. Las
  especificaciones, planes y tareas que la contradigan DEBEN corregirse.
- En este documento, **DEBE** equivale a *MUST* y **DEBERÍA** a *SHOULD* para las
  herramientas de Spec Kit (`/speckit-analyze`, `/speckit-converge`).
- Las enmiendas se realizan con `/speckit-constitution`, documentando el cambio y su
  motivo en el Informe de Impacto de Sincronización.
- Versionado semántico: MAYOR para eliminar o redefinir principios; MENOR para añadir
  principios o secciones; PARCHE para aclaraciones y redacción.
- Toda revisión de un diseño DEBE verificar el cumplimiento de esta constitución. Cualquier
  complejidad adicional DEBE justificarse en el plan.

**Versión**: 1.0.0 | **Ratificada**: 2026-10-04 | **Última enmienda**: 2026-10-04
