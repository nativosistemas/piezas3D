---

description: "Lista de tareas del espacio para conectores y cableado del puntero láser"
---

# Tareas: Espacio para conectores y cableado del puntero láser

**Entrada**: documentos de diseño de `specs/009-espacio-conectores/`

**Requisitos previos**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/parametros.md](contracts/parametros.md),
[quickstart.md](quickstart.md)

**Pruebas**: no se piden tareas de prueba aparte; cada fase se cierra con las validaciones de OpenSCAD
y los escenarios del quickstart.

**Organización**: por las cinco fases del pipeline (Principio II), con la historia de usuario en cada
tarea: US1 (conectar y cerrar la tapa), US2 (USB con la tapa puesta), US3 (cables de los motores).

## Formato: `[ID] [P?] [Historia] Descripción`

---

## Fase 0: Preparación

- [X] T001 Línea de base: `scripts/generar_web.py --comprobar puntero_laser specs/002-puntero-laser-estelar` pasa y `git status --short exports docs/img` está limpio; guardar las 13 STL del puntero en `.tools/tmp/stl_antes/` para comparar después

---

## Fase 1: Diseño (`src/*.scad`)

- [X] T002 [US1] En `src/puntero_laser_parametros.scad`: sección `/* [Conectores y cables] */` con los parámetros de data-model.md §1 (con rango y "medir" en el comentario) y las constantes Hidden; derivadas de §2: `curva_cable`, `alto_dupont_conectado`, `alto_conectores_arriba`; `elevacion_esp32` pasa a derivada (`alto_dupont_conectado + holgura_conector`); `alto_interior_tapa = max(altura_placas, alto_conectores_arriba, alto_esp32_total) + holgura_techo_tapa` (reemplaza el `+ 5`)
- [X] T003 [US1] En `src/puntero_laser_parametros.scad`: validaciones V-22 (conectores bajo el techo), V-23 (Dupont del ESP32 sobre la plataforma con `holgura_conector`) y V-24 (franjas del ESP32 contra los apoyos de las esquinas, `pad_soporte_esp32` pasado a parámetros si hace falta), con mensajes como en data-model.md §4; actualizar la lista V-01…V-21 del encabezado y la tabla de la guía después (T012)
- [X] T004 [US2] En `src/puntero_laser_parametros.scad` y `src/puntero_laser_tapa_electronica.scad`: abertura USB calculada desde `ancho_enchufe_usb`, `alto_enchufe_usb` y `holgura_usb`, centrada en el conector del ESP32 (sobre su PCB), con la punta de gota; V-25 (enchufe dentro de la abertura y abertura bajo el techo)
- [X] T005 [US3] En `src/puntero_laser_parametros.scad` o `src/puntero_laser_ensamblaje.scad` (donde estén los puntos): `function largo_polilinea(p)`; recorridos de los dos cables de motor según la tabla de recorridos de la guía (research R6); V-26 con la reserva; echo `CABLES largo_alt=…, largo_az=…, reserva_alt=…, reserva_az=…`
- [X] T006 [US1] En `src/puntero_laser_ensamblaje.scad`: elemento `conectores` (catálogo, color translúcido gris, anclas, nombre "Cables Dupont y enchufes (espacio reservado)" tipo `"comprada"`), dibujado con las cajas de data-model.md §3; agregarlo al paso 17 (cableado) junto al cable del láser; choques de esos volúmenes contra la tapa, la plataforma y las otras placas (assert con nombre del conector)
- [X] T007 Validar: `scripts/verificar_pieza.sh --rapido` sobre parámetros y ensamblaje sin avisos; quickstart §1 (alto_tapa 33,5, elevación 23,9, reservas ≥ 20 mm) y §2 (cada valor inválido falla con su mensaje)

---

## Fase 2: Simulación

- [X] T008 FEM no aplica (justificado en plan.md, Principio III): sin tarea de simulación

---

## Fase 3: Exportación

- [X] T009 `scripts/verificar_pieza.sh` sobre `src/puntero_laser_plataforma_azimut.scad` y `src/puntero_laser_tapa_electronica.scad` (caja envolvente, cama, capturas PNG revisadas a ojo: postes del ESP32 y abertura USB) y exportar sus STL a `exports/`
- [X] T010 Comparar por vértices ordenados las otras 11 STL del puntero con `.tools/tmp/stl_antes/`: deben ser iguales

---

## Fase 4: Documentación

- [X] T011 [US1] En `docs/puntero_laser_guia.md`: paso 16, conectar los Dupont al ESP32 **antes** de encajarlo, con los cables doblados hacia el centro, y pines del ESP32 hacia abajo como vienen
- [X] T012 [P] [US1] En `docs/puntero_laser_guia.md`: medidas que cambian (alto de la tapa, masa estimada y de la tapa si figuran, tabla de valores del diseño), parámetros nuevos en la tabla de adaptación (sección 4) y las validaciones V-22…V-26 en la tabla de errores
- [X] T013 [P] [US3] En `docs/puntero_laser_guia.md`: en la tabla de recorridos de cables, el largo de cada recorrido de motor y la reserva (desde el echo `CABLES`)

---

## Fase 5: Web de armado y visor

- [X] T014 `scripts/capturas_armado.sh puntero_laser` (fuera del sandbox); revisar una por una las capturas que cambian (las que muestran la plataforma o la tapa, y el paso 17 con los conectores); regenerar `docs/img/puntero_laser.png` y las de las piezas si las genera `verificar_pieza.sh`
- [X] T015 `scripts/generar_web.py puntero_laser specs/002-puntero-laser-estelar` y `--comprobar`; revisar en Edge el paso 17 del visor (`?paso=17&t=1&senalar=conectores`) y el modo Funcionamiento

---

## Fase final: Cierre

- [X] T016 Revisar que la BOM no cambie (los Dupont ya están) y que la web siga mostrando el total; actualizar el estado de `spec.md` y marcar las tareas

## Dependencias y orden

T002 → T003–T006 → T007 → T009–T010 → T011–T013 → T014 → T015 → T016. T012 y T013 en paralelo.

## Estrategia

US1 es el núcleo (T002, T003, T006): con eso la tapa y el ESP32 ya quedan bien dimensionados. US2
(T004) y US3 (T005) son comprobaciones que se agregan sobre el mismo archivo.

## Notas de la implementación

- Resultado con los valores por defecto: `elevacion_esp32` 15 → 23,9 mm; `alto_tapa` 27,6 → 33,5 mm
  (límite del carro de altura: 34,34 mm). El margen admite Dupont de hasta ≈ 14,8 mm de cuerpo
  (probado: 14,8 pasa, 14,9 falla con el mensaje de la tapa); la guía lo dice en la sección 4.1 y la
  lista de materiales pide Dupont rectos de 14 mm.
- Cables de los motores: altura ≈ 115 mm y azimut ≈ 139 mm de 230 mm (sobran 115 y 91 mm).
- `pad_soporte_esp32` y `pierna_soporte` pasaron de la plataforma a los parámetros (los usan V-24 y
  V-25); `y_entrada_motor_az` pasó de la tapa a los parámetros y se sumó `y_entrada_motor_alt` (los
  usa el recorrido de los cables del ensamblaje).
- Masas macizas: plataforma 212 → 213 g, tapa 54 → 61 g; total del aparato ≈ 972 g. Los 440 g de
  filamento de la lista no cambian (estimación que corrige el laminador).
- Las otras 11 STL se regeneraron en una carpeta temporal y son iguales por vértices.
- Cambian las capturas de los pasos 8 a 18 (postes del ESP32, conectores en el 17, tapa en el 18) y las
  de la plataforma, la tapa y el conjunto.

