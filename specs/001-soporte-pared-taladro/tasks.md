---
description: "Lista de tareas para implementar el soporte de pared paramétrico para taladro"
---

# Tareas: Soporte de pared paramétrico para taladro

**Entrada**: documentos de diseño en `specs/001-soporte-pared-taladro/`

**Prerrequisitos**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/interfaz_generador.md](contracts/interfaz_generador.md) y
[quickstart.md](quickstart.md)

**Pruebas**: la especificación no pide TDD. No se crean tests unitarios ni un directorio `tests/`,
porque la constitución limita el árbol del repositorio. La verificación se hace con las tareas de
comprobación, que ejecutan los escenarios del [quickstart.md](quickstart.md). Son obligatorias porque
cierran las puertas de calidad de la constitución.

**Organización**: la constitución (Principio II) **obliga** a agrupar las tareas en las cuatro fases
del pipeline: Diseño → Simulación → Exportación → Documentación. Esta regla prevalece sobre la
agrupación por historia de la plantilla de Spec Kit. Por eso las fases siguen el pipeline y cada tarea
lleva la etiqueta de su historia (`[US1]`, `[US2]`, `[US3]`) para mantener la trazabilidad. Ninguna
fase empieza hasta que la anterior esté completa.

## Formato: `[ID] [P?] [Historia] Descripción`

- **[P]**: puede ejecutarse en paralelo (archivos distintos y sin dependencias pendientes).
- **[USn]**: historia de usuario de [spec.md](spec.md) a la que sirve la tarea.

## Convenciones comunes a todas las tareas

- Ejecutar todo desde la raíz del repositorio (`/home/nuc/piezas3D`).
- Usar **siempre** los lanzadores de `.tools/bin/`: `openscad`, `freecadcmd`, `freecad`, `gmsh` y `ccx`.
  No usar `sudo` ni `apt`.
- Ejes: X = ancho, Y = profundidad (la pared está en el plano Y = 0), Z = altura (la cara inferior de
  la bandeja está en Z = 0). El origen es la esquina inferior trasera izquierda. La pieza se modela
  en la orientación de impresión.
- Las salidas temporales van a `$TMPDIR`. Solo se escriben en el repositorio los entregables del plan.
- Todo (comentarios, mensajes y documentos) va en español. Variables y módulos en `snake_case`.
- Medida de la caja envolvente de un STL ASCII (se cita como **«medir caja»**):
  `python3 -c "import sys,re;v=[tuple(map(float,m)) for m in re.findall(r'vertex\s+(\S+)\s+(\S+)\s+(\S+)',open(sys.argv[1]).read())];print(*[round(max(c)-min(c),2) for c in zip(*v)])" <archivo.stl>`

---

## Fase 0: Preparación (infraestructura común)

**Propósito**: confirmar que el entorno está listo antes de modelar.

- [X] T001 Verificar las herramientas según el apartado «Requisitos previos» de specs/001-soporte-pared-taladro/quickstart.md: `.tools/bin/openscad --version` (2021.01), `.tools/bin/freecadcmd --version` (1.1.4), `.tools/bin/ccx -v` (2.23), `.tools/bin/gmsh --version` (4.15.0) y `python3 --version`. Si alguna falla, reinstalarla siguiendo la sección «Reinstalación» del quickstart y comprobar que `.gitignore` contiene `.tools/`.

---

## Fase 1: Diseño paramétrico (`src/soporte_pared_taladro.scad`)

**Propósito**: escribir el generador completo y comprobar la Puerta 1 de la constitución. Todas las
tareas de esta fase editan el **mismo archivo**, así que se ejecutan en orden y sin [P].

### Fundacional (bloquea al resto de la fase)

**⚠️ CRÍTICO**: ninguna tarea de geometría empieza hasta completar T002 a T004.

- [X] T002 Crear src/soporte_pared_taladro.scad con el encabezado estándar de .github/spec_kit_profile.md (`Proyecto: piezas3D`, `Componente: Soporte de pared para taladro`, `Descripción: soporte paramétrico de pared para colgar un taladro inalámbrico por el portabrocas`) seguido de `// --- PARÁMETROS Y CONSTANTES ---`. Declarar los 14 parámetros públicos con grupos y rangos del Customizer **exactamente** como en la Entidad 1 de data-model.md:
  - `/* [Dimensiones principales] */`: `ancho = 80; // [50:1:150]`, `profundidad = 100; // [60:1:160]` y `diametro_tornillo = 5; // [3:0.5:8]`.
  - `/* [Taladro] */`: `ancho_ranura = 46; // [30:1:60]` y `diametro_cuerpo_taladro = 60; // [40:1:90]`.
  - `/* [Estructura] */`: `espesor = 6; // [4:0.5:10]`, `altura_placa = 70; // [50:1:120]` y `espesor_cartela = 5; // [3:0.5:10]`.
  - `/* [Detalles] */`: `holgura_tornillo = 0.4; // [0.2:0.05:1.0]`, `altura_labio = 3; // [0:0.5:4.5]`, `chaflan_ranura = 1.5; // [0:0.5:3]`, `radio_esquinas = 4; // [0:0.5:10]` y `radio_filete = 3; // [0:0.5:6]`.
  - `/* [Calidad] */`: `$fn = 64; // [24:8:128]`.

  Cada parámetro lleva un comentario breve en español que explica qué controla.
- [X] T003 En src/soporte_pared_taladro.scad, añadir `/* [Hidden] */` con las constantes y los derivados de la Entidad 2 de data-model.md, con estas fórmulas literales:
  - Constantes: `longitud_labio = 6;`, `holgura_cuerpo_min = longitud_labio + 2;`, `margen_cuerpo_carril = 8;`, `espesor_min_pared = 1.2;`, `espesor_min_bajo_avellanado = 1.5;`, `rebaje_cabeza = 0.3;` y `eps = 0.01;` (solape para evitar caras coplanarias).
  - Derivados: `diametro_orificio = diametro_tornillo + holgura_tornillo;`, `diametro_cabeza = 2 * diametro_tornillo;`, `profundidad_avellanado = (diametro_cabeza - diametro_orificio) / 2 + rebaje_cabeza;`, `ancho_carril = (ancho - ancho_ranura) / 2;`, `centro_ranura_y = espesor + (profundidad - espesor) / 2;`, `fondo_ranura_y = centro_ranura_y - ancho_ranura / 2;`, `tornillo_z = altura_placa - diametro_cabeza;`, `tornillo_x = [diametro_cabeza, ancho - diametro_cabeza];`, `altura_cartela = tornillo_z - diametro_cabeza;` y `fin_cartela_y = profundidad - longitud_labio - 2;`.

  No usar números mágicos dimensionales fuera de esta sección (Principio I).
- [X] T004 En src/soporte_pared_taladro.scad, añadir la sección `// --- VALIDACIÓN DE PARÁMETROS ---` (antes de la llamada a `ensamblaje_principal();`) con los `assert(condición, mensaje)` de las reglas V-01 a V-10 de data-model.md, **en ese orden**:
  - **V-01**: un assert por parámetro editable con `is_num(p) && p >= mín && p <= máx`, usando los rangos de T002. Mensaje: `str("<nombre>=", <valor>, ": fuera de rango [mín, máx] mm")`.
  - **V-02**: `ancho_carril >= 2 * espesor`.
  - **V-03**: `ancho >= 4 * diametro_cabeza`.
  - **V-04**: `espesor - profundidad_avellanado >= espesor_min_bajo_avellanado`.
  - **V-05**: `altura_cartela - espesor >= 2 * radio_filete + 10`.
  - **V-06**: `profundidad >= espesor + diametro_cuerpo_taladro + 2 * holgura_cuerpo_min`.
  - **V-07**: `diametro_cuerpo_taladro >= ancho_ranura + margen_cuerpo_carril`.
  - **V-08**: `diametro_cuerpo_taladro <= ancho - 2 * espesor_cartela - 2`.
  - **V-09**: `fondo_ranura_y - espesor >= espesor`.
  - **V-10**: `espesor_cartela <= ancho_carril - chaflan_ranura`.

  Cada mensaje **empieza por** el parámetro principal que exige la tabla del Escenario 4 de quickstart.md: V-02 → `ancho_ranura=`, V-03 y V-04 → `diametro_tornillo=`, V-05 → `altura_placa=`, V-06 → `profundidad=`, V-07 y V-08 → `diametro_cuerpo_taladro=`, V-09 → `profundidad=` y V-10 → `espesor_cartela=`. Después del parámetro, el mensaje explica el problema, da el límite numérico calculado y sugiere qué ajustar. Ejemplo de contracts/interfaz_generador.md: `"ancho_ranura=60: deja carriles de 10 mm; con espesor=6 se necesitan al menos 12 mm (reduzca ancho_ranura o aumente ancho)"`.

**Punto de control**: el archivo se evalúa sin errores con los valores por defecto (aunque aún no
genere geometría).

### Geometría de la pieza por defecto (US1)

Restricción R10 para todos los módulos: solo `cube`, `cylinder` (incluido `r1/r2` o `d1/d2`),
`circle`, `square`, `polygon`, `linear_extrude`, `translate`, `rotate`, `mirror`, `union`,
`difference` e `intersection`. **Prohibido** usar `hull`, `minkowski`, `offset` y `rotate_extrude`
con ángulo parcial. Cada elemento opcional se omite con `if` cuando su parámetro vale 0.

- [X] T005 [US1] En src/soporte_pared_taladro.scad, escribir el módulo `placa_trasera()`: `cube([ancho, espesor, altura_placa])` en el origen (FR-001).
- [X] T006 [US1] En src/soporte_pared_taladro.scad, escribir el módulo `bandeja()`: placa de Y = 0 a `profundidad`, Z = 0 a `espesor` y ancho `ancho`, hecha con `linear_extrude(espesor)` de un contorno 2D con las dos esquinas frontales (Y = `profundidad`, X = 0 y X = `ancho`) redondeadas con `radio_esquinas` mediante `square` + `circle`. Escribir también un módulo auxiliar `contorno_bandeja_2d()` que T009 reutilizará (FR-001, FR-003).
- [X] T007 [US1] En src/soporte_pared_taladro.scad, escribir el módulo `cartelas()`: dos prismas triangulares de espesor `espesor_cartela` en X = 0 y X = `ancho - espesor_cartela`. El perfil en el plano YZ es un `polygon` con vértices (Y, Z) = (`espesor - eps`, `espesor - eps`), (`fin_cartela_y`, `espesor - eps`) y (`espesor - eps`, `altura_cartela`), extruido en X con `rotate` + `linear_extrude`. Comprobar que la hipotenusa queda hacia arriba y hacia fuera, sin voladizo al imprimir (R1, FR-001).
- [X] T008 [US1] En src/soporte_pared_taladro.scad, escribir el módulo `filete_interior()`: en la arista interior placa–bandeja (Y = `espesor`, Z = `espesor`), un `cube([ancho, radio_filete, radio_filete])` menos un `cylinder(r = radio_filete)` con eje X centrado en (Y = `espesor + radio_filete`, Z = `espesor + radio_filete`), con el solape `eps` necesario. Si `radio_filete == 0`, se omite (R1).
- [X] T009 [US1] En src/soporte_pared_taladro.scad, escribir el módulo `labios_retencion()`: sobre cada carril, en el borde frontal, un prisma de perfil trapezoidal en el plano YZ. La base va de Y = `profundidad - longitud_labio` a `profundidad` en Z = `espesor - eps`. La cara frontal es vertical y enrasada con Y = `profundidad`. La cara trasera, orientada hacia el taladro, es un chaflán de 45° hasta la altura `espesor + altura_labio`, de modo que la cara superior va de Y = `profundidad - longitud_labio + altura_labio` a `profundidad`. En X ocupa de 0 a `ancho_carril` y de `ancho - ancho_carril` a `ancho`, recortado con `intersection()` por la extrusión de `contorno_bandeja_2d()` para respetar las esquinas redondeadas. Si `altura_labio == 0`, se omite (R3).
- [X] T010 [US1] En src/soporte_pared_taladro.scad, escribir el módulo `vaciado_ranura()`, que se resta de la pieza:
  - **U pasante**: un `cylinder(d = ancho_ranura)` con eje Z centrado en (X = `ancho/2`, Y = `centro_ranura_y`) unido a un `cube` de ancho `ancho_ranura` desde Y = `centro_ranura_y` hasta `profundidad + 1`. Ambos van de Z = −1 a `espesor + altura_labio + 1` para cortar también los labios (FR-002).
  - **Chaflán superior de `chaflan_ranura` a 45°** en el borde superior de la U, en Z = `espesor - chaflan_ranura` .. `espesor + eps`: un `cylinder(r1 = ancho_ranura/2, r2 = ancho_ranura/2 + chaflan_ranura + eps)` en el fondo semicircular más un prisma trapezoidal extruido a lo largo de Y en el tramo recto (FR-003). Si `chaflan_ranura == 0`, se omite.
  - **Redondeo de las dos esquinas de la boca** de la ranura (intersección de la ranura con el borde frontal) con radio `radio_esquinas`, mediante `cube` − `cylinder` de eje Z (FR-003). Si `radio_esquinas == 0`, se omite.
- [X] T011 [US1] En src/soporte_pared_taladro.scad, escribir el módulo `vaciado_tornillos()`, que se resta de la pieza. Para cada X de `tornillo_x`, en Z = `tornillo_z`:
  - Un `cylinder(d = diametro_orificio)` con eje Y desde Y = −1 hasta `espesor + 1`.
  - Un cono avellanado a 90° abierto hacia la cara frontal de la placa (Y = `espesor`): `cylinder` de eje Y que empieza en Y = `espesor - profundidad_avellanado` con `d1 = diametro_orificio` y sigue 1 mm más allá de la cara con `d2 = diametro_orificio + 2 * (profundidad_avellanado + 1)`.

  Comprobar que `diametro_cabeza` cabe por encima de `altura_cartela` (FR-004, FR-007, FR-009).
- [X] T012 [US1] En src/soporte_pared_taladro.scad, escribir `ensamblaje_principal()` como `difference() { union() { placa_trasera(); bandeja(); cartelas(); filete_interior(); labios_retencion(); } vaciado_ranura(); vaciado_tornillos(); }`. La llamada `ensamblaje_principal();` va bajo `// --- MÓDULOS PRINCIPALES Y ENSAMBLAJE ---`, después de la validación. Añadir comentarios breves por módulo que citen el requisito (FR-xxx) al que responde.
- [X] T013 [US1] Comprobar la Puerta 1 (Escenario 1 del quickstart, sin escribir todavía en `exports/`) con `.tools/bin/openscad --hardwarnings -o "$TMPDIR/defecto.stl" src/soporte_pared_taladro.scad`. Debe cumplir:
  - Código de salida 0, sin líneas `WARNING:` ni `ERROR:`, y en el resumen CGAL `Simple: yes` y `Volumes: 2` (un único sólido).
  - Tiempo total de renderizado < 60 s.
  - «Medir caja» da `80.0 100.0 70.0` ± 0,1 (SC-004).

  Corregir src/soporte_pared_taladro.scad hasta que se cumpla todo.
- [X] T014 [US1] Comprobar la imprimibilidad sin soportes (FR-011, SC-001, Escenario 5) sobre `$TMPDIR/defecto.stl` con un fragmento de `python3` (sin crear archivos en el repositorio). Debe listar las facetas con normal `n_z < -0.72` (voladizo de más de 45°), excluyendo las de la cama (Z ≈ 0) y las de los orificios horizontales de los tornillos (puentes admisibles: |Z − 60| ≤ 6 e Y ≤ 6 en la configuración por defecto). El resultado esperado es una lista vacía. Si aparecen facetas, corregir la geometría en src/soporte_pared_taladro.scad y repetir T013.

### Validación de parámetros y variantes (US2)

- [X] T015 [P] [US2] Ejecutar el Escenario 2 (variante `ancho=100 profundidad=130 diametro_tornillo=4`) y el Escenario 3 (casos «mínimo compacto», «máximo» y «sin labio ni chaflanes») de specs/001-soporte-pared-taladro/quickstart.md con `.tools/bin/openscad --hardwarnings -D …` y salida en `$TMPDIR`. Todos deben renderizar sin `WARNING:` ni `ERROR:`, con `Volumes: 2`, y «medir caja» debe coincidir con `ancho × profundidad × altura_placa` ± 0,1 (FR-005, FR-006, SC-004). Corregir src/soporte_pared_taladro.scad si alguno falla.
- [X] T016 [P] [US2] Ejecutar las 10 filas del Escenario 4 de specs/001-soporte-pared-taladro/quickstart.md con `.tools/bin/openscad -D … -o "$TMPDIR/x.stl"`, borrando antes `$TMPDIR/x.stl`. El caso de texto se pasa como `-D 'profundidad="abc"'`. En cada caso se exige:
  - El código de salida es ≠ 0.
  - La salida contiene `ERROR: Assertion` con un mensaje que empieza por el prefijo de la tabla.
  - No se crea `$TMPDIR/x.stl` (FR-010, SC-005).

  Con `profundidad="abc"` pueden aparecer `WARNING:` previos de los derivados; es aceptable si después aparece el error de V-01. Ajustar el orden o el texto de los asserts en src/soporte_pared_taladro.scad hasta que las 10 filas pasen.
- [X] T017 [US2] Revisar en src/soporte_pared_taladro.scad que la interfaz pública cumple contracts/interfaz_generador.md §1.1:
  - Los 14 parámetros llevan anotación `// [mín:paso:máx]` y están en los 5 grupos.
  - Ningún derivado queda fuera de `/* [Hidden] */`.
  - No hay literales dimensionales dentro de los módulos, salvo `eps`, 0, ±1 de holgura de corte y factores de forma como `/2` o `*2`.

  Comprobarlo con `grep -nE '^[a-z_$]+ *=' src/soporte_pared_taladro.scad` y una lectura de los módulos.

  Comprobar además con las fórmulas (FR-012) que cada elemento delgado es ≥ `espesor_min_pared` (1,2 mm) en todo el rango admitido: cara superior del labio `longitud_labio − altura_labio`, pared bajo el avellanado `espesor − profundidad_avellanado` y `espesor_cartela` (ver «Espesor mínimo» en data-model.md).

**Punto de control (cierre de la Fase 1)**: T013 a T017 en verde. El `.scad` está listo y la Puerta 1
queda cumplida.

---

## Fase 2: Simulación FEA en FreeCAD (US3)

**Propósito**: confirmar SC-003 (σ ≤ 10 MPa y flecha del borde frontal ≤ 1 mm con 25 N) y cerrar la
Puerta 2. Depende de que la Fase 1 esté completa.

- [X] T018 [US3] Exportar el árbol CSG con `.tools/bin/openscad -o simulation/soporte_pared_taladro.csg src/soporte_pared_taladro.scad`. Comprobar con un script temporal en `$TMPDIR` ejecutado por `.tools/bin/freecadcmd` que:
  - `importCSG.insert(...)` produce **un único sólido válido** (`isValid()`), tras `removeSplitter()` si hace falta.
  - Su volumen difiere menos del 0,5 % del volumen del STL de T013 (calculado en `python3` con la fórmula del tetraedro con signo).

  Si falla, revisar en src/soporte_pared_taladro.scad las primitivas no admitidas (R10) y volver a T013.
- [X] T019 [US3] Crear simulation/soporte_pared_taladro_fem.py, un script para `.tools/bin/freecadcmd simulation/soporte_pared_taladro_fem.py` comentado en español que:
  1. Resuelve las rutas desde la raíz del repositorio (`os.getcwd()`, con `__file__` como respaldo si existe).
  2. Importa `simulation/soporte_pared_taladro.csg` con `importCSG` y crea un `Part::Feature` «Soporte» con la forma refinada.
  3. Deduce la geometría **por forma, no por nombre `FaceN`**: `profundidad` = `BoundBox.YMax`; `espesor` = Z de la cara plana con normal +Z más baja por encima de Z = 0.
  4. Crea el análisis con `ObjectsFem`:
     - `makeSolverCalculiXCcxTools`.
     - `makeMaterialSolid` PETG: `YoungsModulus = "2000 MPa"`, `PoissonRatio = "0.38"`, `Density = "1270 kg/m^3"`.
     - `makeConstraintFixed` sobre todas las caras con `Surface` de tipo `Part.Cone` (avellanados).
     - `makeConstraintDisplacement` sobre las caras planas con normal −Y en Y ≈ 0, con solo Y bloqueado. Inspeccionar `PropertiesList` en FreeCAD 1.1 para elegir las propiedades correctas.
     - `makeConstraintForce` de `"25 N"` sobre las caras planas con normal +Z en Z ≈ `espesor` (cara superior de la bandeja), dirigida hacia −Z mediante una arista recta paralela a Z como `Direction`, con `Reversed` según haga falta. Verificar el signo comprobando que el desplazamiento Z del borde frontal es negativo.
     - `makeMeshGmsh` con `ElementOrder = "2nd"` y `CharacteristicLengthMax` configurable (por defecto `"2 mm"`), mallado con `femmesh.gmshtools.GmshTools(...).create_mesh()`.
  5. Ejecuta `femtools.ccxtools.FemToolsCcx` (`update_objects`, `setup_working_dir` en `$TMPDIR`, `setup_ccx`, `check_prerequisites`, `write_inp_file`, `ccx_run` y `load_results`).
  6. Calcula:
     - `sigma_max` = máximo de `vonMises`, excluyendo los nodos a menos de 2 mm de las caras fijadas (singularidad). También informa el máximo bruto.
     - `flecha_frontal` = máximo de |U_z| en los nodos con Y ≥ `profundidad − 0.5` y Z ≤ `espesor`.
  7. Admite variantes por variable de entorno:
     - `FEM_VARIANTE=base` (por defecto): sin cambios.
     - `conservadora`: el desplazamiento Y = 0 solo se aplica a la franja de la cara trasera con Z ≤ `espesor + 10`. *(Implementado como apoyo en la arista inferior trasera, que es más conservador y no obliga a partir la cara; ver «Notas de implementación».)*
     - `pesima`: la carga va solo sobre las caras superiores de los labios.

     También admite `FEM_MALLA_MM` para fijar el tamaño de malla.
  8. Guarda `simulation/soporte_pared_taladro.FCStd` (solo en la variante `base`).
  9. Imprime líneas parseables: `RESULTADO variante=… malla_mm=… nodos=… sigma_max_MPa=… sigma_bruta_MPa=… flecha_frontal_mm=… cumple=SI|NO`, con los criterios σ ≤ 10 MPa y flecha ≤ 1 mm.
- [X] T020 [US3] Ejecutar `.tools/bin/freecadcmd simulation/soporte_pared_taladro_fem.py` (variante `base`) y repetirlo con `FEM_MALLA_MM=1.5` para comprobar la convergencia: la diferencia en `sigma_max` y en `flecha_frontal` debe ser < 5 %; si no, refinar más. Después ejecutar las variantes `conservadora` y `pesima`. Si la variante `base` **no cumple**, volver a la Fase 1: ajustar los valores por defecto de `espesor` o `espesor_cartela` en src/soporte_pared_taladro.scad, actualizar data-model.md, repetir T013 a T018 y volver a simular (Principio II). Anotar todas las líneas `RESULTADO`. Cuando la variante `base` cumpla, registrar la salida de `sha256sum src/soporte_pared_taladro.scad` para incluirla en la sección de resultados de simulation/soporte_pared_taladro_fem.md (T021).
- [X] T021 [US3] Crear simulation/soporte_pared_taladro_fem.md con:
  - Objetivo y criterios: carga de diseño de 25 N, FS 3, σ_adm = 10 MPa y flecha ≤ 1 mm (SC-003).
  - Exportación a CSG y vía alternativa por STL (R10).
  - Pasos **en la interfaz gráfica** (`.tools/bin/freecad`): banco OpenSCAD → *Import CSG*; banco *FEM* → material PETG (E = 2000 MPa, ν = 0,38, ρ = 1270 kg/m³) → *ConstraintFixed* en los avellanados → *ConstraintDisplacement* Y = 0 en la cara trasera → *ConstraintForce* de 25 N en −Z sobre la bandeja → malla Gmsh de segundo orden de 2 mm → CalculiX estático → lectura de von Mises y desplazamiento.
  - Uso del script de T019 con sus variables `FEM_VARIANTE` y `FEM_MALLA_MM`.
  - Tabla de resultados de T020: variante, malla, nodos, σ máx., σ bruta, flecha y cumple, comparada con el precálculo R9 de research.md.
  - Conclusión.
  - Sección «Cuándo repetir la simulación» con el rango validado de data-model.md: `profundidad ≤ 100`, `espesor ≥ 6`, `ancho ≥ 80`, `espesor_cartela ≥ 5` y material PETG o PLA (FR-017).

**Punto de control (cierre de la Fase 2)**: existen `simulation/soporte_pared_taladro.csg`, `.FCStd`,
`_fem.py` y `_fem.md` con resultados que cumplen. La Puerta 2 queda cumplida.

---

## Fase 3: Exportación (`exports/`)

**Propósito**: generar el entregable de manufactura que corresponde exactamente a los parámetros
documentados (Principio IV, Puerta 3).

- [X] T022 [US1] Generar `exports/soporte_pared_taladro.stl` con los valores por defecto: `.tools/bin/openscad --hardwarnings -o exports/soporte_pared_taladro.stl src/soporte_pared_taladro.scad`. Verificar código 0, sin `WARNING:` ni `ERROR:`, y «medir caja» = `80.0 100.0 70.0` ± 0,1 (Escenarios 1 y 2). Comprobar que el `sha256sum` actual de src/soporte_pared_taladro.scad coincide con el registrado en T020 (anotado en simulation/soporte_pared_taladro_fem.md); si no coincide, volver a la Fase 2.
- [X] T023 [US1] Anotar, para la guía de la Fase 4, el número de facetas del STL, sus dimensiones, su volumen en cm³ y la masa estimada en PETG (ρ = 1,27 g/cm³). Calcularlo con `python3` sobre exports/soporte_pared_taladro.stl, sin crear archivos en el repositorio.

**Punto de control (cierre de la Fase 3)**: la Puerta 3 queda cumplida.

---

## Fase 4: Documentación (`docs/`)

**Propósito**: guía de producción completa según la plantilla B de .github/spec_kit_profile.md
(Principio V, Puerta 4). Todas las tareas editan el mismo archivo y van en orden.

- [X] T024 [US1] Crear docs/soporte_pared_taladro_guia.md con el título `# Guía de Producción: Soporte de pared para taladro`, una tabla con los valores por defecto de los 14 parámetros y los datos de T023. Añadir la sección `## 1. Especificaciones de Impresión 3D` (FR-016, R2 y R8):
  - **Orientación óptima**: cara inferior de la bandeja sobre la cama, tal como se modela, y por qué es la más resistente.
  - **Laminador**: capa de 0,2 mm, 4 perímetros, 5 capas superiores e inferiores, relleno del 40 % giroide, soportes **No**, adherencia: sin brim (borde de 3 mm opcional si se despega en la cama).
  - **Material**: PETG (230–245 °C boquilla, 70–85 °C cama) y PLA como alternativa solo para interiores sin calor.
- [X] T025 [US1] En docs/soporte_pared_taladro_guia.md, añadir `## 2. Ensamblaje y Lista de Materiales (BOM)` (FR-016, R5, Entidad 5 de data-model.md):
  - **BOM**: 2 × tornillo de cabeza avellanada Ø5 × 50 mm y 2 × taco de nailon Ø8 × 40 mm, más una nota sobre el tipo de taco según la pared (ladrillo, hormigón o pladur con taco basculante).
  - **Instrucciones de instalación** paso a paso y en orden: elegir la ubicación con al menos 25 cm libres por debajo para el portabrocas y la broca → presentar la pieza y marcar los dos orificios con nivel → taladrar Ø8 a 45 mm → colocar los tacos → atornillar hasta que la cabeza quede enrasada sin aplastar la pieza → comprobar que no hay holgura → colgar el taladro con el portabrocas hacia abajo y la empuñadura hacia el frente, pasando por encima del labio.
  - Retirada con una mano (SC-007).
- [X] T026 [US2] En docs/soporte_pared_taladro_guia.md, añadir `## 3. Adaptación a otro taladro o tornillería` (FR-017):
  - **Cómo medir**: el Ø exterior del portabrocas, que debe ser ≤ `ancho_ranura − 2`; el Ø del cuerpo o caja de engranajes → `diametro_cuerpo_taladro`; y el peso con batería, que debe ser ≤ 2,5 kg.
  - **Cómo cambiar parámetros** con el Customizer de OpenSCAD (`.tools/bin/openscad src/soporte_pared_taladro.scad`) y por línea de comandos con `-D` (comandos de contracts/interfaz_generador.md §1.2).
  - **Tabla de errores** de validación V-01 a V-10 con qué significan y cómo corregirlos.
  - **Recordatorio**: regenerar el STL tras cualquier cambio (Principio IV).
- [X] T027 [US3] En docs/soporte_pared_taladro_guia.md, añadir `## 4. Validación estructural` con un resumen de los resultados de simulation/soporte_pared_taladro_fem.md (σ máx., flecha y cumple) y la regla «repetir la simulación fuera del rango validado» con el enlace a la guía FEM.
- [X] T028 [US1] Comprobar la Puerta 4 (Escenario 7) con `grep -nE '\[[^]]*(ej\.|Describir|Cant\.|Fragmento)[^]]*\]' docs/soporte_pared_taladro_guia.md`: no debe haber coincidencias. Comprobar también que estén las secciones 1 (A) y 2 (B) completas y que los valores citados coincidan con los parámetros por defecto del `.scad` y con el STL de T022.

**Punto de control (cierre de la Fase 4)**: la Puerta 4 queda cumplida.

---

## Fase final: Cierre y comprobaciones transversales

- [X] T029 Volver a ejecutar de principio a fin los Escenarios 1 a 7 de specs/001-soporte-pared-taladro/quickstart.md con el estado final del repositorio y anotar cualquier discrepancia (en el Escenario 5 basta el paso 0 automático; el laminador es opcional); si hay alguna, corregirla en la fase que corresponda respetando el orden del pipeline.
- [X] T030 Actualizar specs/001-soporte-pared-taladro/plan.md: en «Puertas de calidad», cambiar el estado de las puertas 1 a 4 a ✅ con la evidencia (comando y resultado) de T013, T020, T022 y T028. En specs/001-soporte-pared-taladro/spec.md, cambiar **Estado** a «Implementada (pendiente de la prueba física)».
- [X] T031 Informar al usuario de que el Escenario 8 (prueba física de 7 días, SC-002 y SC-007) queda pendiente porque requiere imprimir e instalar la pieza, y entregarle el resumen de comandos para regenerar y validar.

---

## Dependencias y orden de ejecución

### Dependencias entre fases (Principio II: estrictamente lineales)

```text
Fase 0 ─> Fase 1 (T002–T004 fundacional ─> T005–T014 US1 ─> T015–T017 US2)
       ─> Fase 2 (T018 ─> T019 ─> T020 ─> T021)
       ─> Fase 3 (T022 ─> T023)
       ─> Fase 4 (T024 ─> T025 ─> T026 ─> T027 ─> T028)
       ─> Final (T029 ─> T030 ─> T031)
```

- Si una comprobación de una fase posterior (T018, T020) obliga a modificar el `.scad`, se vuelve a
  la Fase 1 y se repiten sus comprobaciones antes de seguir.

### Dependencias entre historias

- **US1 (P1)**: geometría base, exportación y guía. Es la base de las demás.
- **US2 (P2)**: depende de la geometría de US1 (T005–T012), porque valida y varía sus parámetros.
  Las validaciones en sí (T004) son fundacionales.
- **US3 (P3)**: depende de la geometría de US1, porque simula la pieza por defecto. La constitución la
  hace **obligatoria antes de exportar**, así que forma parte del camino crítico del MVP aunque sea P3.

### Oportunidades de paralelismo

Son escasas a propósito: casi todo el trabajo edita un único `.scad` o una única guía, y el pipeline
es lineal.

- **T015 ∥ T016**: comprobaciones de US2 independientes, solo escriben en `$TMPDIR`. Si alguna
  obliga a editar el `.scad`, las correcciones se aplican en serie.
- **T017** puede revisarse a la vez que T015 y T016 si no hay correcciones pendientes.

## Ejemplo de ejecución en paralelo: US2

```bash
# Las dos comprobaciones se lanzan juntas (solo escriben en $TMPDIR):
Tarea: "T015 Escenarios 2 y 3 del quickstart (variantes y extremos válidos)"
Tarea: "T016 Escenario 4 del quickstart (10 combinaciones inválidas)"
```

---

## Estrategia de implementación

### MVP (pieza por defecto fabricable, validada y documentada)

Por el Principio II, el MVP recorre las cuatro fases para la configuración por defecto:

1. Fase 0 (T001).
2. Fase 1 fundacional y US1 (T002–T014).
3. Fase 2 completa (T018–T021): la simulación de US3 es obligatoria antes de exportar.
4. Fase 3 (T022–T023).
5. Fase 4, secciones de US1 (T024, T025 y T028).
6. **Parar y validar**: la pieza por defecto es imprimible e instalable (Escenarios 1, 2, 5, 6 y 7).

### Entrega incremental

1. Añadir US2: T015–T017 y T026. Si T015–T017 tocan el `.scad`, se repiten T018–T022 (regenerar
   CSG, simulación y STL).
2. Añadir el resumen de US3 en la guía (T027).
3. Cierre (T029–T031).

---

## Notas

- [P] = archivos distintos o solo lectura, sin dependencias pendientes.
- La etiqueta [USn] da la trazabilidad con spec.md. La agrupación por fases del pipeline la impone la
  constitución.
- Hacer commit al cerrar cada fase del pipeline (solo si el usuario lo pide).
- Evitar: editar el `.scad` después de exportar sin regenerar el STL y la simulación; usar
  herramientas fuera de `.tools/bin/`; escribir archivos temporales en el repositorio.

## Notas de implementación (desviaciones respecto al plan)

- **T005–T012 (primitivas):** los prismas se construyen como `polyhedron` (módulo auxiliar
  `prisma_yz`) y los redondeos con `cylinder` 3D, en lugar de `linear_extrude` y primitivas 2D.
  El motivo es que el importador CSG de FreeCAD 1.1.4 falla con `linear_extrude` dentro de
  booleanas anidadas y con `circle` 2D (se detectó en T018). La geometría resultante es idéntica:
  79 520,5 mm³ antes y después del cambio.
- **T014 (voladizo detectado y corregido):** los labios quedaban en voladizo sobre el chaflán de la
  ranura (1,5 × 6 mm). Se corrigió prolongando en vertical el vaciado del chaflán por encima de la
  bandeja.
- **T018 (lanzador de OpenSCAD):** OpenSCAD 2021.01 resuelve las rutas relativas de `-o` desde la
  carpeta del `.scad` y devuelve 0 aunque no pueda escribir. `.tools/bin/openscad` convierte la ruta
  a absoluta y devuelve 1 si no se crea la salida.
- **T019 (variante conservadora):** se implementó como apoyo lineal en la arista inferior trasera en
  vez de una franja de la cara trasera. Es más conservador y no obliga a partir la cara.
- **Derivados añadidos:** `radio_ranura`, `radio_esquinas_util`, `holgura_cuerpo_cartela` y
  `altura_cartela_min_util`, documentados en data-model.md.

