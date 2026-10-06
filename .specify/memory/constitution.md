# Constitución de piezas3D

## Principios Fundamentales

### I. Diseño Paramétrico en OpenSCAD (NO NEGOCIABLE)

- Todo el modelado DEBE realizarse con código paramétrico de **OpenSCAD** y guardarse como
  archivo `.scad` dentro de `src/`.
- Cada archivo `.scad` DEBE comenzar con el encabezado estándar (Proyecto, Componente,
  Descripción) seguido de la sección `// --- PARÁMETROS Y CONSTANTES ---`, donde se declaran
  TODAS las dimensiones clave y `$fn`. No se permiten números mágicos dimensionales dentro de
  los módulos.
- El archivo DEBE seguir este orden: parámetros → dimensiones derivadas → cuerpo principal →
  elementos que suman material → elementos que restan material, **siempre al final** →
  ensamblaje. El código DEBE ser limpio, ordenado y comentado, con la geometría en módulos
  nombrados y un módulo de ensamblaje principal (`ensamblaje_principal()` o equivalente).
- Los nombres de variables y módulos DEBEN ser descriptivos, en español y en `snake_case`.
- DEBE declararse `eps = 0.01;` y usarse para que todo volumen que se resta sobresalga de la
  pieza. Ningún `difference()` DEBE dejar caras coplanarias.
- Los parámetros DEBEN validarse con `assert()` y un mensaje en español: espesores mínimos,
  holguras mayores que cero, pieza dentro de la cama y relaciones entre cotas.
- Las posiciones DEBEN definirse respecto de bordes o de otros elementos, no como coordenadas
  absolutas sueltas.
- La geometría DEBERÍA construirse a partir de perfiles 2D extruidos en lugar de `hull()` de
  sólidos 3D o cilindros apilados, salvo en las piezas que se simulan en FreeCAD, que DEBEN usar
  solo primitivas que su importador CSG reconstruye (`cube`, `cylinder`, `polyhedron`).

**Justificación:** los parámetros al inicio permiten modificar el diseño sin tocar la geometría y
convierten cada pieza en un generador reutilizable. Un orden fijo y las validaciones con
`assert()` hacen que un valor imposible falle al renderizar y no después de imprimir.

### II. Pipeline Lineal de Cinco Fases (NO NEGOCIABLE)

Toda solicitud de diseño DEBE progresar en este orden, sin saltar fases:

```text
[1. DISEÑO] ──> [2. SIMULACIÓN FEA] ──> [3. EXPORTACIÓN] ──> [4. DOCUMENTACIÓN] ──> [5. WEB DE ARMADO]
 (.scad)          (FreeCAD)              (.stl)              (guía .md + .csv)     (specs/<NNN>/web/)
```

- Una fase NO DEBE comenzar hasta que la anterior esté completa.
- La fase 2 puede declararse "no aplica" solo con una justificación explícita registrada en el
  plan (Principio III).
- Las tareas generadas por `/speckit-tasks` DEBEN agruparse siguiendo estas cinco fases.

**Justificación:** un flujo predecible garantiza que cada pieza llegue validada, fabricable,
documentada y lista para que otra persona la construya.

### III. Validación y Simulación en FreeCAD (Cuando Aplique)

- Si el diseño requiere evaluar esfuerzo mecánico, análisis de elementos finitos (FEA/FEM),
  dinámica de fluidos, integridad estructural u otras pruebas que OpenSCAD no soporta, DEBE
  incluirse una fase de simulación en **FreeCAD**.
- Los criterios de aceptación (carga, material, factor de seguridad, deformación admisible) DEBEN
  fijarse en la especificación antes de simular.
- La documentación y los archivos de simulación DEBEN guardarse en `simulation/` y permitir
  repetirla: exportación del modelo, material, restricciones, cargas, criterios, resultados y el
  **rango de parámetros validado**, fuera del cual hay que simular de nuevo.
- Si no se simula, la especificación o el plan DEBE justificar por qué no es necesario, con un
  precálculo cuando haya cargas.

**Justificación:** las piezas funcionales o sometidas a carga deben validarse antes de fabricarse
para evitar fallos e impresiones desperdiciadas.

### IV. Diseño para Manufactura Aditiva

- La geometría DEBE optimizarse para impresión 3D: minimizar voladizos y la necesidad de soportes,
  y respetar espesores de pared y tolerancias realistas para FDM.
- Cada pieza DEBE exportarse en formato **`.stl`** dentro de `exports/`, y el `.stl` DEBE
  corresponder exactamente a los valores de parámetros documentados; si cambian, DEBE regenerarse.
- Las holguras de encaje y los límites de impresión (pared, piso, voladizo, puente, cama) DEBEN
  salir de un único perfil de impresora, `src/perfil_impresora.scad`, que las piezas incluyen con
  `include`. Mientras tenga `perfil_medido = false`, los valores son **por defecto, no medidos**, y
  la especificación y la guía DEBEN decirlo cuando la pieza dependa de un encaje.
- La cara plana más grande DEBERÍA ir sobre la cama; en las caras que miran hacia abajo DEBERÍAN
  usarse chaflanes en lugar de filetes. Las curvas del `.stl` final DEBERÍAN tener `$fn ≥ 64`.

**Justificación:** el entregable final es una pieza física; el diseño debe pensarse desde el
principio para fabricarse sin problemas. Las holguras genéricas son una suposición sobre la
impresora de otra persona: medirlas una vez evita reimprimir cada pieza con encaje.

### V. Documentación de Producción y Web de Armado

Cada diseño DEBE incluir una guía de producción en `docs/<diseño>_guia.md` con dos secciones
críticas:

- **A. Guía de impresión 3D**: orientación óptima, parámetros del laminador (relleno, perímetros,
  soportes, adherencia) y material recomendado.
- **B. Manual de ensamblaje y armado**: lista de materiales con cantidades y medidas exactas
  (p. ej., `Tornillo M3x12mm`) e instrucciones paso a paso en orden cronológico.

Además:

- La lista de materiales DEBE vivir en `docs/<diseño>_bom.csv`; la de la guía DEBE generarse desde
  ese archivo y no editarse a mano.
- La guía DEBERÍA incluir una captura isométrica de la pieza (`docs/img/<diseño>.png`).
- Cada diseño DEBE tener una **web de armado** en `specs/<NNN-nombre>/web/index.html`, generada con
  `scripts/generar_web.py` a partir de la guía, la lista de materiales y el tipo de cambio, con los
  componentes, el precio en **ARS y USD**, los primeros pasos, el armado paso a paso y los consejos.
- Cada precio DEBE tener tienda, enlace y fecha, y haberse verificado en la página de la tienda.
  Un precio que no se pudo verificar DEBE quedar vacío, y la web DEBE indicar que el total es
  parcial. Ningún precio DEBE estimarse ni inventarse.
- En los diseños de varias piezas, cada paso de armado que agrega piezas DEBE tener su vista
  explotada, generada desde el ensamblaje.

**Justificación:** cualquier persona debe poder imprimir, comprar y montar la pieza sin
conocimiento previo del diseño. Un precio sin fuente engaña más que un precio que falta.

## Estructura del Repositorio y Formatos

Los artefactos del diseño DEBEN ubicarse estrictamente en este árbol:

```text
/
├── src/                          # TODO el código OpenSCAD (.scad)
│   ├── perfil_impresora.scad     # Holguras y límites de la impresora
│   └── externos/                 # STL de terceros que se modifican (con origen y licencia)
├── simulation/                   # Simulaciones en FreeCAD
├── exports/                      # Archivos listos para imprimir (.stl)
├── docs/                         # Guías de producción (.md) y sus datos
│   ├── <diseño>_bom.csv          # Lista de materiales con precios
│   ├── tipo_cambio.csv           # Cotización del dólar con fuente y fecha
│   └── img/                      # Capturas de piezas, conjuntos y pasos de armado (.png)
├── scripts/                      # Automatización del pipeline
└── specs/<NNN-nombre>/web/       # Web de armado generada
```

- Un diseño de varias piezas DEBE usar `src/<diseño>_parametros.scad` para las medidas compartidas,
  un archivo por pieza modelada en su orientación de impresión y `src/<diseño>_ensamblaje.scad`
  (no se exporta), que comprueba los choques con `assert()` y define la tabla de pasos de armado.
- Un STL de terceros que se modifica DEBE guardarse en `src/externos/` junto a un `.md` con su
  origen (URL) y su licencia; la modificación se hace en un `.scad` de `src/` que lo importa.
- `scripts/` DEBE contener solo automatización (verificación, capturas, generación de la web), no
  artefactos del diseño.
- Excepciones al árbol: los artefactos de Spec Kit (`specs/`, `.specify/`), la configuración del
  agente (`.claude/`, `CLAUDE.md`) y la carpeta local `.tools/` (excluida de git: lanzadores y
  temporales), que NO DEBEN contener artefactos del diseño salvo la web generada en
  `specs/<NNN-nombre>/web/`.
- Las piezas y guías nuevas DEBEN partir de las plantillas de las skills `pieza-openscad` y
  `guia-produccion`.
- Herramientas objetivo: OpenSCAD (diseño), FreeCAD (simulación) y un laminador 3D (manufactura).
- Toda la documentación, los comentarios del código y los artefactos de Spec Kit DEBEN redactarse
  en español.

## Flujo de Trabajo y Puertas de Calidad

Antes de dar un diseño por terminado DEBEN cumplirse estas puertas:

1. **Diseño:** el `.scad` está en `src/` con encabezado y sección de parámetros, y además:
   - `scripts/verificar_pieza.sh` pasa: validación estricta sin errores ni advertencias, caja
     envolvente coincidente con las medidas pedidas, apoyo en Z = 0 y pieza dentro de la cama.
     Lo que se puede calcular se calcula; no se juzga a ojo.
   - Se generan capturas PNG (isométrica, frente, lateral y superior) y el agente las mira para
     confirmar la forma, las proporciones y que no haya geometría de más, de menos o flotando. Si
     el entorno no puede generarlas, se deja constancia y se pide al usuario que revise el modelo.
   - En diseños de varias piezas, el ensamblaje pasa sus comprobaciones de choque.
2. **Simulación:** existe la documentación en `simulation/` o una justificación explícita de que no
   aplica.
3. **Exportación:** hay un `.stl` por pieza en `exports/` y coincide con los parámetros actuales.
4. **Documentación:** la guía en `docs/` contiene las secciones A y B completas, sin marcadores de
   plantilla, y su lista de materiales sale de `docs/<diseño>_bom.csv`.
5. **Web de armado:** `scripts/generar_web.py --comprobar` termina sin errores, los precios cargados
   tienen fuente y fecha, las vistas explotadas se revisaron una por una y la página se revisó en un
   navegador.

La sección "Constitution Check" de cada `plan.md` DEBE verificar los cinco principios y estas
cinco puertas.

## Gobernanza

- Esta constitución prevalece sobre cualquier otra práctica del repositorio. Las
  especificaciones, planes y tareas que la contradigan DEBEN corregirse.
- En este documento, **DEBE** equivale a *MUST* y **DEBERÍA** a *SHOULD* para las herramientas de
  Spec Kit (`/speckit-analyze`, `/speckit-converge`).
- **Organización de las instrucciones**: cada regla DEBE estar en un solo lugar, elegido según
  cuándo la necesita el agente; los demás documentos la enlazan.

  | Cuándo se necesita | Dónde va |
  |---|---|
  | Siempre, en cada mensaje | `CLAUDE.md` (mapa del proyecto y avisos de entorno) |
  | Al planificar una feature | Esta constitución (reglas verificables, sin comandos ni plantillas) |
  | En una fase concreta | Una skill en `.claude/skills/<nombre>/`, con sus plantillas como archivos |
  | Se puede comprobar con código | Un script de `scripts/` o un hook de `.claude/settings.json` |
  | Es un dato del proyecto | Un archivo real (`src/perfil_impresora.scad`, `docs/<diseño>_bom.csv`) |

- Las skills `speckit-*` las genera Spec Kit y NO DEBEN editarse a mano.
- Las enmiendas se realizan con `/speckit-constitution`, documentando el cambio y su motivo en el
  Informe de Impacto de Sincronización.
- Versionado semántico: MAYOR para eliminar o redefinir principios; MENOR para añadir principios o
  secciones; PARCHE para aclaraciones y redacción.
- Toda revisión de un diseño DEBE verificar el cumplimiento de esta constitución. Cualquier
  complejidad adicional DEBE justificarse en el plan.

**Versión**: 2.0.0 | **Ratificada**: 2026-10-04 | **Última enmienda**: 2026-10-06
