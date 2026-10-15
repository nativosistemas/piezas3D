---

description: "Lista de tareas de la identificación de componentes en el visor 3D"
---

# Tareas: Identificación de componentes en el visor 3D

**Entrada**: documentos de diseño de `specs/008-identificacion-componentes/`

**Requisitos previos**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/ensamblaje.md](contracts/ensamblaje.md),
[contracts/scripts.md](contracts/scripts.md), [contracts/visor.md](contracts/visor.md),
[quickstart.md](quickstart.md)

**Pruebas**: no se piden tareas de prueba aparte; cada fase se cierra con los escenarios del
quickstart y las validaciones de OpenSCAD.

**Organización**: por las cinco fases del pipeline (Principio II), con la historia de usuario en cada
tarea. La fase 5 está agrupada por historia, en orden de prioridad.

## Formato: `[ID] [P?] [Historia] Descripción`

- **[P]**: se puede hacer en paralelo (otro archivo y sin dependencias pendientes).
- **[Historia]**: US1 (nombres en la lista del paso), US2 (impresa o comprada), US3 (señalar en la
  escena).

---

## Fase 0: Preparación

- [X] T001 Confirmar la línea de base: `scripts/generar_web.py --comprobar` pasa para `puntero_laser specs/002-puntero-laser-estelar` y `caja_pilas specs/004-caja-pilas-aa`, y `git status --short exports docs/img` está limpio

---

## Fase 1: Diseño (`src/*.scad`) — fundacional

- [X] T002 [US1] En `src/armado_comun.scad`: documentar `nombres_elementos` en el encabezado (lista opcional `[elemento, nombre, tipo]`, contrato `specs/008-identificacion-componentes/contracts/ensamblaje.md`); agregar `function nombres_declarados() = is_undef(nombres_elementos) ? [] : nombres_elementos;`; agregar `module comprobar_nombres()` con los asserts del contrato (entrada `[elemento, nombre, tipo]` de 3 campos, elemento en `elementos`, sin repetidos, si la lista no está vacía "falta el nombre de '<e>'" para cada elemento del catálogo sin entrada, nombre texto no vacío, tipo `"impresa"` o `"comprada"`); llamarlo desde `armado()`; en `datos_armado()` emitir por entrada `echo(str("NOMBRE;", e, ";", tipo, ";", nombre))` con el nombre al final
- [X] T003 [P] [US1] [US2] En `src/caja_pilas_ensamblaje.scad`, junto a `elementos`: declarar `nombres_elementos` para `caja`, `pilas`, `tapa` (las pilas con la descripción de `docs/caja_pilas_bom.csv` y tipo `"comprada"`; caja y tapa `"impresa"`)
- [X] T004 [P] [US1] [US2] En `src/puntero_laser_ensamblaje.scad`, junto a `elementos`: declarar `nombres_elementos` para los 49 elementos; lo comprado con la descripción de `docs/puntero_laser_bom.csv` más dónde va entre paréntesis y la cantidad si el elemento agrupa varias piezas (mirar en `elemento(e)` cuántas dibuja); lo impreso con el nombre de su pieza en `docs/puntero_laser_guia.md`
- [X] T005 Validar: `scripts/verificar_pieza.sh --rapido` sobre `src/armado_comun.scad`, `src/caja_pilas_ensamblaje.scad` y `src/puntero_laser_ensamblaje.scad` sin errores ni avisos; probar las declaraciones inválidas del quickstart, sección 2 (cada una falla con su mensaje)

---

## Fase 2: Simulación

- [X] T006 Registrar en `plan.md` (ya está) que FEM no aplica: ninguna pieza ni carga cambia

---

## Fase 3: Exportación

- [X] T007 Confirmar que las STL de `exports/` no cambian (la lista nueva no toca geometría): `git status --short exports`

---

## Fase 4: Documentación

- [X] T008 [P] En `.claude/skills/disenio-multipieza/SKILL.md`: indicar que el ensamblaje declara `nombres_elementos` (nombre de lo comprado igual a la lista de materiales, tipo impresa o comprada) con enlace al contrato de la 008
- [X] T009 [P] En `.claude/skills/web-armado/SKILL.md`: agregar a la revisión del visor los nombres de la lista del paso y la selección en la escena
- [X] T010 [P] En `specs/005-visor-armado-3d/contracts/ensamblaje.md` y `specs/005-visor-armado-3d/contracts/visor.md`: enlazar la ampliación de la 008

---

## Fase 5: Web de armado y visor

### Generador (fundacional para las historias de la fase 5)

- [X] T011 [US1] En `scripts/generar_visor.py`: `datos_del_ensamblaje()` lee `^ECHO: "NOMBRE;([^;]+);([^;]+);(.*)"$` y devuelve un diccionario elemento → (tipo, nombre); `exportar()` agrega `nombre` y `tipo` a cada elemento exportado si hay nombres; `VERSION = 3`; `validar()` exige, si algún elemento trae `nombre`, que todos tengan `nombre` no vacío y `tipo` en `impresa`/`comprada`; el resumen de `ejecutar()` dice "piezas con nombres"; actualizar el docstring con el contrato de la 008

### Historia 1 - Saber qué es cada pieza del paso (P1) 🎯 MVP

- [X] T012 [US1] En `scripts/plantilla_visor.html`: `nombreDe(e)` devuelve `DATOS.elementos[e].nombre` o el identificador con `_` como espacios; la lista "Piezas de este paso" lo usa, escapado como el resto del texto
- [X] T013 [US1] Regenerar `specs/004-caja-pilas-aa/web/armado_3d.html` y `specs/002-puntero-laser-estelar/web/armado_3d.html` con `scripts/generar_web.py` y confirmar en los datos que todos los elementos tienen nombre

### Historia 2 - Distinguir lo que se imprime de lo que se compra (P2)

- [X] T014 [US2] En `scripts/plantilla_visor.html`: `tipoDe(e)` devuelve "🖨 Impresa", "🛒 Comprada" o ""; cada renglón de la lista del paso lleva la marca (estilo `.tipo`, texto y símbolo, no solo color) antes del nombre

### Historia 3 - Identificar una pieza señalándola en la escena 3D (P3)

- [X] T015 [US3] En `scripts/plantilla_visor.html`: lista de mallas seleccionables por modo (en Armado las de `piezas` visibles; en Funcionamiento las rígidas y el fotograma visible de cada deformable, con `userData.elemento`); `elegir(x, y)` con `THREE.Raycaster`: la opaca más cercana y, si no hay, la atenuada más cercana (research R4)
- [X] T016 [US3] En `scripts/plantilla_visor.html`: `resaltar(malla)` / `soltar()` guardando y restaurando `emissive`, `emissiveIntensity`, `opacity` y `depthWrite` (research R5); etiqueta `#etiqueta` dentro de `#escena` con nombre y tipo vía `textContent`, junto al puntero y sin salirse del lienzo (R7)
- [X] T017 [US3] En `scripts/plantilla_visor.html`: eventos (R6): mouse sin botones → señalar como máximo una vez por cuadro; `pointerleave` suelta; toque < 500 ms y < 6 px → señalar o soltar si es el fondo; `controles` `start` suelta y bloquea hasta `end`; cambiar de paso o de modo suelta; con el puntero quieto y algo moviéndose (animación del paso, modo automático o deslizadores), recalcular en el cuadro
- [X] T018 [US3] En `scripts/plantilla_visor.html`: renglones de la lista del paso con `data-e`, `tabindex="0"`; `pointerenter`/`focus` resaltan la pieza y `pointerleave`/`blur` la sueltan (FR-016)
- [X] T019 [US3] En `scripts/plantilla_visor.html`: dirección de revisión `?senalar=<elemento>` (resalta y pone la etiqueta en el centro proyectado de su caja) y la frase de la leyenda en los dos modos (contrato del visor)
- [X] T020 [US3] Regenerar los dos visores y revisar en Edge (fuera del sandbox) con las capturas y la lista manual del quickstart, sección 5

---

## Fase final: Cierre

- [X] T021 `scripts/generar_web.py --comprobar` para los dos diseños sin errores; tamaño ≤ 10 MB
- [X] T022 Revisar que cada nombre de lo comprado del puntero láser y de la caja de pilas se encuentre en su `docs/<diseño>_bom.csv` (SC-002)
- [X] T023 Actualizar el estado de `spec.md` y marcar las tareas hechas
- [X] T024 [US3] Separar el elemento `placas` de `src/puntero_laser_ensamblaje.scad` en `placa_esp32`, `placa_rele`, `placa_uln_az` y `placa_uln_alt` (catálogo, color, anclas, paso 16 y nombres), regenerar la vista del paso 16 (`scripts/capturas_armado.sh`, solo cambia `docs/img/puntero_laser_paso_16.png`) y el visor; agregar la regla "un elemento solo agrupa piezas iguales" al contrato y a la skill `disenio-multipieza`

**Notas de la implementación**

- Al revisar en Edge apareció un error que venía de la 007: `.pestanas { display: flex }` le ganaba
  al atributo `hidden` y la caja de pilas mostraba las pestañas sin tener simulación. Se agregó
  `.pestanas[hidden] { display: none; }` en `scripts/plantilla_visor.html`.
- `senalarElemento` y `elegir` actualizan la matriz de la cámara antes de proyectar: la cámara no
  está en la escena y su matriz solo se actualiza al dibujar.
- 🖨 lleva el selector de variante U+FE0F para que se dibuje como emoji.
- Puntero encima (también con el automático a ×20), arrastre, toque y renglón de la lista se
  probaron con eventos sintéticos en un iframe y capturas de Edge sin ventana; falta la prueba a
  mano en un navegador con mouse y en un celular (SC-003, SC-004).

---

## Dependencias y orden

- T002 antes que T003–T005; T011 depende de T002; T012–T019 dependen de T011.
- US1 (T012–T013) es el MVP; US2 (T014) y US3 (T015–T019) tocan el mismo archivo: van en orden.
- La fase 4 (T008–T010) puede hacerse en paralelo con la fase 5.

## Paralelismo

- T003 y T004 (dos ensamblajes distintos).
- T008, T009 y T010 (documentos distintos).

## Estrategia

1. Fase 1 y el generador (T002–T011), regenerar: los datos ya llevan nombres.
2. US1: la lista del paso con nombres (MVP, valor inmediato).
3. US2: marcas de tipo.
4. US3: selección en la escena, la parte de más riesgo, al final y revisada en el navegador.
