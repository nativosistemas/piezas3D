<!--
Informe de Impacto de Sincronización
- Versión: 1.0.1 → 1.1.0 (MENOR: se añaden reglas y una puerta de calidad; no se elimina ni
  redefine ningún principio).
- Origen: buenas prácticas adaptadas del skill comunitario andreahaku/openscad_claude_skill.
- Principio I: orden fijo del archivo (parámetros → derivadas → cuerpo → añadidos → cortes →
  ensamblaje), `eps` obligatorio en los cortes, validación con `assert()`, cotas relativas a
  bordes y preferencia por perfiles 2D extruidos.
- Principio IV: perfil de impresora único (`src/perfil_impresora.scad`) como fuente de holguras
  y límites, con aviso obligatorio si no está medido; reglas FDM concretas.
- Principio V: captura isométrica de la pieza en la guía (DEBERÍA).
- Estructura: se permite `src/externos/` para STL de terceros que se modifican y `docs/img/`
  para las capturas de las guías.
- Puertas de calidad: la puerta 1 pasa a exigir validación estricta, chequeo numérico de
  medidas y revisión visual de capturas PNG.
- Plantillas afectadas: `.github/spec_kit_profile.md` (actualizada),
  `.claude/skills/disenio-multipieza/SKILL.md` (actualizada), `CLAUDE.md` (actualizada).
  `.specify/templates/plan-template.md` no requiere cambios (la sección Constitution Check se
  deriva de este documento).
- Pendiente: crear `src/perfil_impresora.scad` y el peine de calibración como diseño propio.
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
- El archivo DEBE seguir este orden: parámetros → dimensiones derivadas (calculadas a partir
  de los parámetros) → cuerpo principal → elementos que suman material (refuerzos, salientes)
  → elementos que restan material (agujeros, ranuras, vaciados), **siempre al final** →
  ensamblaje.
- DEBE declararse `eps = 0.01;` y usarse para que todo volumen que se resta sobresalga de la
  pieza. Ningún `difference()` DEBE dejar caras coplanarias.
- Los parámetros DEBEN validarse con `assert()` y un mensaje en español: espesores mínimos,
  holguras mayores que cero, pieza dentro de la cama y relaciones entre cotas (p. ej.,
  `assert(diametro_saliente > diametro_orificio + 2 * espesor_min_pared, "...")`).
- Las posiciones DEBEN definirse respecto de bordes o de otros elementos
  (`x_orificio = largo - margen_borde`), no como coordenadas absolutas sueltas.
- La geometría DEBERÍA construirse a partir de perfiles 2D (`polygon()` + `linear_extrude()`,
  `offset(r = ...)` para redondear esquinas, `rotate_extrude()` para piezas de revolución) en
  lugar de `hull()` de sólidos 3D o cilindros apilados.

**Justificación:** los parámetros al inicio permiten modificar el diseño sin tocar la
geometría y convierten cada pieza en un generador reutilizable. Un orden fijo y las
validaciones con `assert()` hacen que un valor imposible falle al renderizar y no después de
imprimir.

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
- Las holguras de encaje y los límites de impresión DEBEN salir de un único perfil de
  impresora, `src/perfil_impresora.scad` (plantilla en la sección 4.C de
  `.github/spec_kit_profile.md`), que las piezas incluyen con `include`. Mientras ese archivo no
  exista o tenga `perfil_medido = false`, los valores son **por defecto, no medidos**, y la
  especificación y la guía de producción DEBEN decirlo cuando la pieza dependa de un encaje.
- Límites FDM de referencia (boquilla de 0,4 mm), salvo que el perfil diga otra cosa:
  pared ≥ 1,2 mm, piso ≥ 0,8 mm, voladizo ≤ 45° respecto de la vertical sin soportes,
  puentes ≤ 10 mm sin apoyo. La cara plana más grande DEBERÍA ir sobre la cama; en las caras
  que miran hacia abajo DEBERÍAN usarse chaflanes en lugar de filetes.
- Las curvas del `.stl` final DEBERÍAN tener `$fn ≥ 64`.

**Justificación:** el entregable final es una pieza física; el diseño debe pensarse
desde el principio para fabricarse sin problemas. Las holguras genéricas son una suposición
sobre la impresora de otra persona: medirlas una vez evita reimprimir cada pieza con encaje.

### V. Documentación de Producción Obligatoria

Cada diseño DEBE incluir una guía de producción en `docs/<nombre_pieza>_guia.md` (plantilla de
referencia: sección 4.B de `.github/spec_kit_profile.md`) con dos secciones críticas:

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
- La guía DEBERÍA incluir una captura isométrica de la pieza (`docs/img/<nombre_pieza>.png`)
  para reconocerla a simple vista.

**Justificación:** cualquier persona debe poder imprimir y montar la pieza sin
conocimiento previo del diseño.

## Estructura del Repositorio y Formatos

Los artefactos del diseño DEBEN ubicarse estrictamente en este árbol:

```text
/
├── .github/
│   └── spec_kit_profile.md     # Perfil del agente: plantillas de salida (.scad y guía .md)
├── src/                        # TODO el código nativo de OpenSCAD (.scad)
│   ├── perfil_impresora.scad   # Holguras y límites medidos de la impresora
│   └── externos/               # STL de terceros que se modifican (con origen y licencia)
├── simulation/                 # Notas y pasos de simulación en FreeCAD (.FCStd)
├── exports/                    # Archivos de manufactura listos para producción (.stl)
└── docs/                       # Manuales de ensamblaje y guías de impresión (.md)
    └── img/                    # Capturas de las piezas para las guías (.png)
```

- Un STL de terceros que se modifica DEBE guardarse en `src/externos/` junto a un `.md` con su
  origen (URL) y su licencia. La modificación se hace en un `.scad` normal de `src/` que lo
  importa con `import()`, y el resultado pasa por el pipeline completo.

- Excepciones permitidas: los artefactos de Spec Kit (`specs/`, `.specify/`), la
  configuración del agente (`.claude/`, `CLAUDE.md`) y la carpeta local `.tools/` (excluida de
  git: lanzadores de OpenSCAD y FreeCAD en `.tools/bin/` y salidas temporales de FreeCAD en
  `.tools/tmp/`), que NO DEBEN contener artefactos del diseño.
- Las plantillas de salida obligatorias (encabezado `.scad` y guía de producción) están
  definidas en `.github/spec_kit_profile.md` y DEBEN seguirse.
- Herramientas objetivo: OpenSCAD (diseño), FreeCAD (simulación) y un laminador 3D
  (manufactura).
- Toda la documentación, los comentarios del código y los artefactos de Spec Kit DEBEN
  redactarse en español.

## Flujo de Trabajo y Puertas de Calidad

Antes de dar un diseño por terminado DEBEN cumplirse estas puertas:

1. **Diseño:** el `.scad` está en `src/`, tiene encabezado y sección de parámetros, y además:
   - **Validación estricta:** renderiza sin errores ni advertencias con
     `--hardwarnings --check-parameters=true --check-parameter-ranges=true` (comandos en la
     sección 5 de `.github/spec_kit_profile.md`).
   - **Chequeo numérico:** la caja envolvente del `.stl` coincide con las medidas pedidas y
     entra en la cama de la impresora. Lo que se puede calcular se calcula; no se juzga a ojo.
   - **Revisión visual:** se generan capturas PNG (isométrica, frente, lateral y superior) y
     el agente las mira para confirmar la forma, las proporciones y que no haya geometría de
     más, de menos o flotando. Si el entorno no puede generar capturas, se deja constancia y
     se pide al usuario que revise el modelo en OpenSCAD.
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

**Versión**: 1.1.0 | **Ratificada**: 2026-10-04 | **Última enmienda**: 2026-10-04
