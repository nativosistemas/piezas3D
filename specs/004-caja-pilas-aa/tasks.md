---

description: "Lista de tareas de la caja con tapa a presión para 4 pilas AA"
---

# Tareas: Caja con tapa a presión para 4 pilas AA

**Entrada**: documentos de diseño de `specs/004-caja-pilas-aa/`

**Requisitos previos**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/interfaz_generador.md](contracts/interfaz_generador.md),
[quickstart.md](quickstart.md)

**Pruebas**: no se piden tareas de prueba aparte; cada fase se cierra con los escenarios del
quickstart.

**Organización**: por las cinco fases del pipeline (Principio II), con la historia de usuario en cada
tarea.

## Formato: `[ID] [P?] [Historia] Descripción`

- **[P]**: se puede hacer en paralelo (otro archivo y sin dependencias pendientes).
- **[Historia]**: US1 (imprimir y guardar las pilas) o US2 (adaptar cantidad y medidas).

---

## Fase 1: Diseño paramétrico (`src/caja_pilas_*.scad`)

### Fundacional (bloquea a las dos piezas)

- [X] T001 [US2] Crear `src/caja_pilas_parametros.scad` desde la plantilla de la skill
  `pieza-openscad`: encabezado, `include <perfil_impresora.scad>`, los 14 parámetros públicos de la
  Entidad 1 con su comentario `[mín:paso:máx]` y grupos del Customizer, las constantes `[Hidden]` y
  los derivados de la Entidad 2 de [data-model.md](data-model.md).
- [X] T002 [US2] Agregar en `src/caja_pilas_parametros.scad` las reglas V-01…V-09 de la Entidad 3
  con mensajes en español que empiezan con el parámetro (V-05: "deformacion_pestana ≤
  deformacion_admisible"; V-06: "alto_tabique > juego_vertical_pila y alto_tabique < alto_zona_pilas")
  y el `echo` de los derivados del escenario 1 del quickstart; comprobar con
  `scripts/verificar_pieza.sh --rapido`.

### Piezas

- [X] T003 [P] [US1] Modelar `src/caja_pilas_caja.scad`: cuerpo con chaflán de 0,6 mm en la base,
  cavidad, tabiques de `alto_tabique`, ranuras trapezoidales a 45° en el centro de las paredes largas
  a `z_reborde` del borde y muesca con fondo redondeado en una pared corta (R3, R6, R7).
- [X] T004 [P] [US1] Modelar `src/caja_pilas_tapa.scad` en su orientación de impresión: placa con
  chaflán de 0,6 mm en la cara sobre la cama, pollera interior con `holgura_pollera` por lado, dos
  ranuras verticales a cada lado de cada pestaña y reborde trapezoidal a 45° a
  `distancia_reborde_punta` de la punta (R3, R7).
- [X] T005 [US1] Crear `src/caja_pilas_ensamblaje.scad`: catálogo `elemento()` (caja, tapa, pilas),
  `assert` del conjunto (pollera dentro de la boca, reborde a la altura de la ranura, pollera por
  encima de los tabiques y de las pilas), tabla `pasos` de la Entidad 7 y parámetro `paso_armado`
  (skill `disenio-multipieza`, sección 4).
- [X] T006 [US1] Verificar las tres fuentes con `scripts/verificar_pieza.sh` (escenarios 2 y 3) y
  comparar las cajas envolventes con la Entidad 4.
- [X] T007 [US1] Generar y revisar las capturas de la caja y de la tapa fuera del sandbox
  (escenario 4).
- [X] T008 [US2] Ejecutar los escenarios 5 (variantes) y 6 (casos inválidos) del quickstart.

**Punto de control**: Puerta 1 cumplida.

---

## Fase 2: Simulación FEA (no aplica, con justificación)

- [X] T009 [US1] Confirmar que el `echo` de `deformacion_pestana` con los valores finales coincide con
  research.md R4 (≤ 0,015) y dejar registrada la Puerta 2 en [plan.md](plan.md).

---

## Fase 3: Exportación (`exports/`)

- [X] T010 [US1] Exportar `exports/caja_pilas_caja.stl` y `exports/caja_pilas_tapa.stl` con
  `--hardwarnings` y los valores por defecto (skill `pieza-openscad`, sección 4).

---

## Fase 4: Documentación (`docs/`)

- [X] T011 [US1] Crear `docs/caja_pilas_bom.csv` (filamento PETG) con el formato de la skill
  `guia-produccion`.
- [X] T012 [US1] Escribir `docs/caja_pilas_guia.md` desde la plantilla de `guia-produccion`: sección A
  (orientación, laminador, PETG y aviso de PLA de R4), sección B (lista de materiales desde el CSV y
  los 3 pasos de la Entidad 7), aviso de perfil sin medir y qué tocar si el encastre sale duro o flojo
  (FR-015).
- [X] T013 [US1] Generar la captura isométrica `docs/img/caja_pilas.png` fuera del sandbox.

---

## Fase 5: Web de armado (`specs/004-caja-pilas-aa/web/`)

- [X] T014 [US1] Buscar y verificar el precio del filamento en una tienda y cargarlo con tienda,
  enlace y fecha en `docs/caja_pilas_bom.csv`, o dejarlo vacío (skill `web-armado`).
- [X] T015 [US1] Generar las vistas de los pasos con `scripts/capturas_armado.sh caja_pilas` fuera del
  sandbox y revisarlas una por una.
- [X] T016 [US1] Generar `specs/004-caja-pilas-aa/web/index.html` con `scripts/generar_web.py`, pasar
  `--comprobar` y revisar la página en el navegador.

---

## Fase final: Cierre

- [X] T017 Actualizar las puertas de [plan.md](plan.md) y el estado de [spec.md](spec.md).

## Dependencias y orden de ejecución

- Fases estrictamente lineales: 1 → 2 → 3 → 4 → 5 → cierre.
- T001 → T002 → (T003 ∥ T004) → T005 → T006 → T007 → T008.
- US2 no agrega piezas: se cumple porque todo deriva de los parámetros; T008 lo comprueba.

## Estrategia de implementación

**MVP**: US1 con los valores por defecto (T001–T013): dos STL imprimibles y su guía. La web (T014–T016)
cierra el pipeline.
