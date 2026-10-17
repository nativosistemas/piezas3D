---

description: "Lista de tareas de la barra de distribución de alimentación del puntero láser"
---

# Tareas: Barra de distribución de alimentación del puntero láser

**Entrada**: documentos de diseño de `specs/010-barra-distribucion/`

**Requisitos previos**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/parametros.md](contracts/parametros.md),
[quickstart.md](quickstart.md)

**Pruebas**: no hay tareas de prueba aparte. Cada fase se cierra con las validaciones de OpenSCAD y
los escenarios del quickstart.

**Organización**: por las cinco fases del pipeline (Principio II, igual que en la 009). Cada tarea
lleva su historia de usuario:
- **US1**: repartir la alimentación.
- **US2**: que la barra entre bajo la tapa.
- **US3**: comprar y armar con lo que dice la guía.

## Formato: `[ID] [P?] [Historia] Descripción`

---

## Fase 0: Preparación

- [X] T001 Tomar la línea de base:
  - Comprobar que `scripts/generar_web.py --comprobar puntero_laser specs/002-puntero-laser-estelar` pasa y que `git status --short exports docs/img` está limpio.
  - Guardar las 13 STL del puntero en `.tools/tmp/stl_antes/` para comparar después.
  - Anotar el eco `COTAS` y `DISEÑO` de `src/puntero_laser_parametros.scad`: `alto_tapa=33.5`, el tamaño de la plataforma y `masa_estimada_g`.

---

## Fase 1: Diseño (`src/*.scad`)

- [X] T002 [US1] En `src/puntero_laser_parametros.scad`, sección `/* [Conectores y cables] */`, agregar los parámetros de data-model.md §1 con su rango y la palabra "medir" en el comentario:
  - `pines_barra = 6; // [6:1:10]`
  - `barra_largo = 25.4; // [20:0.1:36]`
  - `barra_ancho = 7.6; // [7:0.1:10]`

  Agregar como constantes Hidden `destinos_5v = 5`, `destinos_gnd = 5` y `masa_barra_g = 3`.
- [X] T003 [US2] En `src/puntero_laser_parametros.scad`, agregar las derivadas de data-model.md §2:
  - `x_reg1 = x_col_a0 + regulador_ancho + 2*(pared_soporte + holgura_encastre)`.
  - `x_barra0 = x_reg1 + holgura_zonas` e `y_barra0 = y_reg0`.
  - `ancho_soporte_barra` y `largo_soporte_barra`: la medida de la placa `+ 2*(holgura_encastre + pared_soporte)`.
  - `y_sob0`: sumar `y_barra0 + largo_soporte_barra` dentro del `max(…)`.
  - `zona_regulador`: que termine en `x_reg1` y no en `x_col_a1`.
  - `zona_barra = [x_barra0, y_barra0, x_barra0 + ancho_soporte_barra, y_barra0 + largo_soporte_barra, altura_placas, "barra"]`, agregada a `zonas_componentes`.
  - La masa de la barra (`masa_barra_g`, en el centro de su soporte), agregada a la lista del centro de masa.
- [X] T004 [US1] En `src/puntero_laser_parametros.scad`, agregar las validaciones de data-model.md §4, con estos mensajes:
  - **V-27**: `pines_barra ≥ max(destinos_5v, destinos_gnd) + 1`. Mensaje: `pines_barra=…: la barra necesita al menos … pines por tira (… destinos + reserva)`.
  - **V-28**: `barra_largo ≥ (pines_barra + 4)*paso_pines − 0.5` y `barra_ancho ≥ 3*paso_pines − 0.5`. Mensaje: `barra_largo=…: la placa no tiene lugar para … pines, la entrada y las esquinas libres`, y el equivalente para `barra_ancho`.
  - **V-29**: `x_barra0 + ancho_soporte_barra ≤ x_col_a1`. Mensaje: `barra_ancho=…: la barra no entra al lado del regulador (máx. … mm)`.

  Actualizar la lista de validaciones del encabezado del archivo.
- [X] T005 [US2] En `src/puntero_laser_plataforma_azimut.scad`, dentro de `soportes_placas()`, agregar `soporte_placa(x_barra0, y_barra0, barra_ancho, barra_largo, alto_soporte_placa, pad_soporte);   // barra de distribución (010)` y nombrar la barra en el comentario del encabezado.
- [X] T006 [US2] En `src/puntero_laser_ensamblaje.scad`, agregar el elemento `barra`:
  - Agregarlo al catálogo de elementos, a la tabla de identificación (`"Barra de distribución +5 V / GND (placa perforada)"`, tipo `"comprada"`) y darle un color propio.
  - Dibujarlo como `placa(x_barra0, y_barra0, barra_ancho, barra_largo, alto_soporte_placa, …)` con las dos tiras de `pines_barra` pines en los agujeros 2 a `pines_barra + 1` de las columnas de los costados (research R2).
  - Ancla: el centro de la placa, a `z_sup`.
  - Agregarlo al paso 16 con `[0, 0, 70]`, como las otras placas.
- [X] T007 [US2] En `src/puntero_laser_ensamblaje.scad`, dentro del elemento `conectores`, agregar la caja de los Dupont de la barra: ocupa la planta de la placa, desde `z_sup + alto_soporte_placa + espesor_pcb` con alto `alto_dupont_conectado`, como la de los ULN2003. Revisar que el comentario del paso 17 siga siendo válido.
- [X] T008 Validar el diseño:
  - Correr `scripts/verificar_pieza.sh --rapido` sobre los parámetros y el ensamblaje, sin avisos.
  - Escenario §1 del quickstart: `alto_tapa=33.5`, la plataforma del mismo tamaño que en T001 y la masa +≈ 3 g.
  - Escenario §2 del quickstart: `pines_barra=5`, `barra_largo=20`, `barra_ancho=10` y `uln2003_ancho=28` fallan cada uno con su mensaje, y `-D pines_barra=8 -D barra_largo=30.5` pasa (la tapa crece en Y) o nombra lo que choca.
  - Anotar los resultados en "Notas de la implementación".

---

## Fase 2: Simulación

- [X] T009 La simulación FEM no aplica (plan.md, Principio III, research R7): no hay tarea de simulación.

---

## Fase 3: Exportación

- [X] T010 [US2] Exportar la plataforma:
  - Correr `scripts/verificar_pieza.sh src/puntero_laser_plataforma_azimut.scad`: caja envolvente igual a la de antes, cama y capturas PNG fuera del sandbox.
  - Revisar a ojo que el soporte nuevo quede al lado del regulador.
  - Exportar `exports/puntero_laser_plataforma_azimut.stl`.
- [X] T011 Comparar por vértices ordenados las otras 12 STL del puntero, tapa incluida, con `.tools/tmp/stl_antes/`: deben ser iguales.

---

## Fase 4: Documentación

- [X] T012 [US3] En `docs/puntero_laser_bom.csv`, categoría Electrónica, con el mismo formato que los otros renglones (precio vacío por ahora, lo completa T019):
  - Agregar `1 ×;Placa perforada (placa experimental) de paso 2,54 mm: se corta un trozo de 3 × 10 agujeros (barra de distribución)`.
  - Agregar `1 ×;Tira de pines macho 1 × 40 de paso 2,54 mm (se cortan 2 tiras de 6)`.
  - Agregar `20 cm de;tubo termocontraíble de 2 a 3 mm` (paquete según la tienda).
  - Cambiar el cable de silicona de 60 a **70 cm** y su descripción a "(regulador → láser e interruptor → barra)".
- [X] T013 [US1] En `docs/puntero_laser_guia.md`, sección 5.4:
  - Cambiar el esquema de conexiones para que todo +5 V y GND salga de la barra. La entrada E+ llega desde el interruptor con 10 cm de cable rojo de 26 AWG, y la E− desde el negro del cable USB.
  - Agregar la tabla de pines de research R5, con la conexión de COM del relé (Dupont pelado en la bornera) y de IN− del regulador (Dupont soldado y aislado).
  - Agregar el procedimiento de armado de la barra: cortar la placa de 3 × 10, soldar las dos tiras de 6 pines en los agujeros 2 a 7 de las columnas de los costados, unir cada tira por abajo con un hilo de cobre de un Dupont pelado, soldar las entradas en el agujero 8 y aislar con termocontraíble.
  - Agregar la prueba con multímetro (quickstart §5): sin continuidad entre las dos tiras, continuidad dentro de cada tira, ≈ 5 V con el interruptor cerrado y 0 V abierto.
  - Indicar que el pin de reserva sirve para la resistencia de carga de 100 Ω.
- [X] T014 [US1] En `docs/puntero_laser_guia.md`, paso 16 (Electrónica): armar y probar la barra en el banco (remitir a 5.4) y encajarla en su soporte, al lado del regulador, con los pines hacia arriba. En el paso 17, conectar todos los +5 V y GND desde la barra. No agregar pasos: siguen siendo 19.
- [X] T015 [P] [US3] En `docs/puntero_laser_guia.md`, primeros pasos (punto 4): las herramientas son el **multímetro**, un **soldador de 30 a 40 W** y **estaño de 0,8 mm con resina**, y el termocontraíble va en la lista de materiales. Si la guía tiene un consejo sobre soldar, también nombrarlas ahí.
- [X] T016 [P] [US2] En `docs/puntero_laser_guia.md`:
  - Agregar los parámetros `barra_largo`, `barra_ancho` y `pines_barra` a la tabla de adaptación (sección 4).
  - Agregar V-27 a V-29 a la tabla de errores.
  - Actualizar la masa estimada si figura (desde el eco de T008).
- [X] T017 Regenerar la lista de materiales de la guía desde el CSV con el mecanismo que usa la skill `guia-produccion` (no editarla a mano) y comprobar que la guía no tenga marcadores pendientes.

---

## Fase 5: Web de armado y visor

- [X] T018 Regenerar las capturas con `scripts/capturas_armado.sh puntero_laser` (fuera del sandbox) y revisar una por una las que cambian:
  - Las que muestran la plataforma, desde el paso 8.
  - El paso 16, con la barra bajando.
  - El paso 17, con sus Dupont en el volumen transparente.
  - `docs/img/puntero_laser.png` y la de la plataforma.
- [X] T019 [US3] Con la skill `web-armado`, buscar y verificar en la página de la tienda el precio de la placa perforada, la tira de pines y el termocontraíble, y completar precio, moneda, tienda, URL y fecha en `docs/puntero_laser_bom.csv`. Si un precio no se puede verificar, queda vacío (la web marca el total como parcial). Revisar si cambia el paquete del cable de silicona.
- [X] T020 Generar la web:
  - Correr `scripts/generar_web.py puntero_laser specs/002-puntero-laser-estelar` y después `--comprobar`.
  - Revisar en Edge (fuera del sandbox) los componentes nuevos con su precio, el paso 16 del visor (`?paso=16&senalar=barra`) con la etiqueta de la barra, y el paso 17.

---

## Fase final: Cierre

- [X] T021 Revisar los criterios de éxito:
  - **SC-001**: los 10 destinos tienen su pin y queda 1 libre por tira.
  - **SC-002**: lo comprueba T008.
  - **SC-004**: los mensajes de T008.

  Marcar SC-003 como pendiente del armado real. Actualizar el estado de `spec.md`, marcar las tareas y completar "Notas de la implementación".

## Dependencias y orden

- T001 → T002 → T003 y T004 → T005, T006 y T007 → T008.
- T008 → T010 y T011 → T012 a T016 → T017 → T018 → T019 → T020 → T021.
- T005 (plataforma) y T006 y T007 (ensamblaje) son archivos distintos y pueden hacerse en paralelo una vez que T003 está terminada.
- T015 y T016 pueden hacerse en paralelo con T013 y T014, cuidando que tocan secciones distintas de la misma guía.

## Estrategia

US1 (T002, T004, T013 y T014) resuelve el problema de fondo: la persona sabe cómo repartir la
alimentación. US2 (T003 y T005 a T007) le da a la barra su lugar comprobado bajo la tapa. US3 (T012,
T015 y T019) completa la compra y las herramientas. El incremento mínimo útil es US1 junto con US2,
porque la guía no puede mandar a encajar la barra en un soporte que no existe.

## Notas de la implementación

- **Con los valores por defecto**:
  - La barra va en X = 67,4…78,7, Y = 27,85…56,95, al lado del regulador.
  - La tapa sigue en 33,5 mm y la plataforma en 194,3 × 165,9 mm.
  - La masa pasa de 972 a 975 g.
  - El centro de masa pasa a (4,12; 3,20) mm. En parte se mueve porque ahora la masa del regulador
    está en su soporte real y no en el centro de la columna.
- **V-27 a V-29 antes de V-08**: el bloque de validaciones quedó antes de V-08 para que una barra
  ancha diga "no entra al lado del regulador" y no "componentes solapados".
- **Barras más largas**: `-D pines_barra=8 -D barra_largo=30.5` y `-D pines_barra=10 -D
  barra_largo=35.6` pasan. Con la segunda, el sobrante y la tapa crecen y la plataforma pasa a
  194,3 × 175,85 mm.
- **Apoyo de la barra**: es de 2 mm (`pad_soporte_barra`) y no de 3 mm, porque con 3 mm la
  soldadura del agujero 2 quedaba a ≈ 0,05 mm del apoyo. Con 2 mm queda ≈ 1 mm.
- **Postes del soporte**: como la placa mide 7,6 mm de ancho, los postes en L de cada extremo se
  unen y forman una pared corta. No molesta, porque los Dupont entran desde arriba.
- **STL**: cambia solo la de la plataforma. Las otras 12, tapa incluida, son iguales por vértices.
- **Capturas**: cambian las de los pasos 8 a 18 (el soporte nuevo, la barra en el 16 y sus Dupont en
  el 17). Se revisaron el 16 y el 17, y el visor con `?paso=16&t=1&senalar=barra`.
- **Precios** (2026-10-17), verificados en la página de cada tienda:
  - Placa perforada simple faz de 5 × 7 cm en Oriel: $ 2.690. La página no indica el paso, y la nota
    pide confirmarlo.
  - Tira de pines de 40 en Oriel: $ 3.690 el pack de 10.
  - Termocontraíble de 2,5 mm en Electrocomponentes: $ 342 el metro.
  - Se agregó el tipo de cambio del día (US$ 1 = $ 1.535).
  - La web queda con 38 componentes, 14 con precio, y el total marcado como parcial.
- **Pendiente (SC-003)**: armar la barra real y hacer la prueba con multímetro de la sección 5.4.
