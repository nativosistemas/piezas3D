---

description: "Lista de tareas de la vista de cableado en el visor 3D del puntero láser"
---

# Tareas: Vista de cableado en el visor 3D del puntero láser

**Entrada**: documentos de diseño de `specs/011-vista-cableado/`

**Requisitos previos**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Pruebas**: no hay tareas de prueba aparte. Cada fase se cierra con las validaciones de OpenSCAD,
las comprobaciones de los generadores y los escenarios del quickstart.

**Organización**: por las cinco fases del pipeline (Principio II, como en la 009 y la 010). Cada tarea
lleva su historia de usuario:
- **US1**: ver todo el cableado armado (P1).
- **US2**: saber qué es cada cable (P2).
- **US3**: que el cableado dibujado sea el real (P3).

## Formato: `[ID] [P?] [Historia] Descripción`

---

## Fase 0: Preparación

- [X] T001 Tomar la línea de base:
  - Comprobar que `scripts/generar_web.py --comprobar puntero_laser specs/002-puntero-laser-estelar` y `scripts/generar_web.py --comprobar caja_pilas specs/004-caja-pilas-aa` pasan.
  - Comprobar que `git status --short exports docs/img src` está limpio.
  - Guardar las 13 STL del puntero en `.tools/tmp/stl_antes/` para comparar después.
  - Anotar el tamaño de `specs/002-puntero-laser-estelar/web/armado_3d.html` (3,8 MB) y el eco `CABLES largo_alt=…, largo_az=…` del ensamblaje.

---

## Fase 1: Diseño (`src/*.scad`)

### Biblioteca común (contrato del ensamblaje)

- [X] T002 [US3] En `src/armado_comun.scad`:
  - Sumar al encabezado las listas opcionales de [contracts/ensamblaje.md](contracts/ensamblaje.md) y enlazar ese contrato: `cables`, `grupos_cableado`, `conectores_cableado`, `obstaculos_cableado`, `interior_tapa_cableado`, `pasos_tapa_cableado`, `transparentes_cableado`, `ocultos_cableado` y `reserva_cable`.
  - Agregar las funciones de lectura con `is_undef`, como las de la 007 (`cableado_cables()`, `cableado_grupos()`, …). Cada una devuelve `[]` (o `0` para `reserva_cable`) si el diseño no declara la lista.
- [X] T003 [US3] En `src/armado_comun.scad`, agregar el módulo `comprobar_cables()` y llamarlo desde `armado()` después de `comprobar_nombres()`. Valida C-01 y C-02 de [data-model.md §4](data-model.md#4-validaciones), con los mensajes exactos de la tabla de errores del contrato:
  - Cada cable tiene 11 campos.
  - El `id` es único y no coincide con ningún elemento.
  - `desde` y `hasta` no están vacíos y no tienen `;`.
  - La función es `"+5V"`, `"GND"` o `"señal"`, y el diámetro es mayor que 0.
  - El grupo está en `grupos_cableado`, cada tipo de `extremos` en `conectores_cableado` y el `elemento` en `elementos`.
  - Hay "un recorrido de 2 o más puntos o un elemento (no los dos)".
- [X] T004 [US3] En `src/armado_comun.scad`, agregar las funciones genéricas de C-03 y C-04 (research R6) y sus `assert` dentro de `comprobar_cables()`. Solo corren si el diseño declara `obstaculos_cableado`.
  - `largo_polilinea(p)`: moverla desde `src/puntero_laser_ensamblaje.scad`, sin duplicarla.
  - `choques_cable(c)`:
    - Muestrea cada tramo cada `diámetro/2`.
    - Una muestra choca si queda a menos de `diámetro/2` de una caja de `obstaculos_cableado`, salvo en el primer y el último tramo contra el obstáculo cuyo `componente` es el prefijo de `desde` o de `hasta`.
    - También choca si sale de `interior_tapa_cableado` sin estar dentro de una caja de `pasos_tapa_cableado`.
    - Devuelve el primer choque como `[nombre del obstáculo, punto]`, o `undef`.
  - `falta_largo(c)`: `largo_polilinea(recorrido) + reserva_cable − largo_comprado` si `largo_comprado` no es `undef`; si no, 0.
  - Mensajes: `cables: '<id>' atraviesa <obstáculo> cerca de [x, y, z]`, `cables: '<id>' sale de la tapa fuera del conducto y de la pared −X cerca de [x, y, z]` y `cables: '<id>' mide <L> mm y el cable comprado <C> mm (faltan <F> mm)`.
- [X] T005 [US1] En `src/armado_comun.scad`, dentro de `datos_armado()` y después de las líneas `NOMBRE;`, agregar:
  - `CABLE;<id>;<vector [función, grupo, hilos, diámetro, recorrido, extremos, largo, elemento]>;<desde>;<hasta>` por cable, con `largo = largo_polilinea(recorrido)`, o `undef` si tiene elemento.
  - `GRUPOS_CABLEADO;`, `CONECTORES_CABLEADO;`, `TRANSPARENTES_CABLEADO;`, `OCULTOS_CABLEADO;` y `RADIO_CURVA_CABLEADO;`. El radio sale de una variable opcional `radio_curva_cableado` del diseño (0 si no está).
- [X] T006 [US1] En `src/armado_comun.scad`, agregar el módulo `cables_modelados()`:
  - Cada hilo de cada cable con recorrido es una cadena de `hull()` de dos esferas por tramo, con `$fn = 12`. Los hilos van desplazados un diámetro en perpendicular al tramo.
  - Cada extremo es un `cube` con las medidas y el color de `conectores_cableado`, apoyado en el pin y alineado con su tramo.

### Ensamblaje del puntero láser

- [X] T007 [US1] En `src/puntero_laser_ensamblaje.scad`, sección de parámetros:
  - Agregar `ver_cables = false;`, con un comentario que diga que dibuja los cables en el conjunto (solo para revisar).
  - Agregar las constantes de pines de research R4 como `[nombre, [x, y] local desde la esquina −X −Y de la placa, sentido]`, con un comentario de la referencia:
    - `pines_esp32`: 5V, GND (columna −X, pines 19 y 14), GPIO 33, 25, 26, 27 (columna −X, pines 8 a 11), GPIO 23 (columna +X, pin 2) y GPIO 19, 18, 17, 16 (columna +X, pines 8, 9, 11, 12), con el pin 1 hacia +Y, el USB hacia −Y y sentido −1. Las columnas van separadas `separacion_filas_esp32` y centradas en `esp32_ancho`.
    - `pines_uln2003`: IN1 a IN4 en el borde +X, `−` y `+` en la esquina +X +Y, y `ficha` centrada en el borde −X, con sentido +1.
    - `pines_rele`: VCC, GND e IN en el borde −Y; COM, NA y NC (bornera) en el borde +Y.
    - `pines_regulador`: IN+ e IN− en el borde −Y, OUT+ y OUT− en el borde +Y, en las esquinas.
    - `pines_barra_cableado`: los pines 1 a 5 y la entrada (agujero 8) de cada tira, en las posiciones que ya usa el elemento `barra`.
  - Agregar la función `pin(componente, nombre)`, que devuelve `[x, y, z]` en el conjunto (en la punta de la tira, donde nace el conector), con la misma esquina que usa `placa()` para cada placa. `componente` es uno de `"ESP32"`, `"ULN2003 azimut"`, `"ULN2003 altura"`, `"Relé"`, `"Regulador"`, `"Barra +5 V"`, `"Barra GND"`, `"Interruptor"`, `"Power bank"`.
- [X] T008 [US1] En `src/puntero_laser_ensamblaje.scad`, agregar los elementos `interruptor` y `resistencia_rele` (data-model §1.6):
  - Agregarlos a `elementos` y a `nombres_elementos`, con el nombre igual a la descripción de `docs/puntero_laser_bom.csv` y tipo `"comprada"`.
  - Darles color en `color_elemento` y geometría en `elemento()`. El interruptor es un cuerpo de `alto_interruptor`, un buje de `d_interruptor` y una palanca hacia +X, en `x_interruptor`, `y_interruptor`. La resistencia es un cilindro con dos patas a los pines IN y GND de `pines_rele`.
  - Darles ancla en `anclas()` y sumarlos al paso 16 con `[0, 0, 70]`, como las placas.
  - Revisar que `grupo()` los ubique en `"plataforma"`.
- [X] T009 [US1] En `src/puntero_laser_ensamblaje.scad`, agregar las funciones de recorrido de research R5, todas desde `pin()` y los parámetros de la 009, sin coordenadas sueltas:
  - `recorrido_dupont(desde, hasta, carril)`: salida vertical desde el pin hasta `alto_tira_pines + largo_dupont` más `radio_curva_cable`, y tramo horizontal al nivel de recorrido. Ese nivel está `diametro_cable_dupont/2` sobre `alto_conectores_arriba`, o bajo el ESP32, hacia el centro, saliendo por los costados ±Y entre los postes en L. Después, la llegada simétrica. `carril` desplaza el tramo horizontal `carril*diametro_cable_dupont` para que no se superpongan.
  - `recorrido_usb(hasta)`: del enchufe USB del power bank por el conducto (`y_conducto`) hasta el destino bajo la tapa.
  - `recorrido_soldado(desde, hasta)`: para interruptor → barra.
  - Los motores usan `recorrido_cable_az` y `recorrido_cable_alt`, que ya existen, terminando en `pin("ULN2003 …", "ficha")`.
- [X] T010 [US1] En `src/puntero_laser_ensamblaje.scad`, junto a `nombres_elementos`, declarar:
  - `grupos_cableado`, en este orden: `alimentacion` («Alimentación: power bank e interruptor»), `barra_5v` («Barra de distribución: +5 V»), `barra_gnd` («Barra de distribución: GND»), `esp32_az` («ESP32 → ULN2003 azimut»), `esp32_alt` («ESP32 → ULN2003 altura»), `rele_regulador` («ESP32, relé y regulador») y `motores_laser` («Motores y láser»).
  - `conectores_cableado`, con los 6 tipos de data-model §1.4. Las medidas sin parámetro van como constantes con nombre (`largo_enchufe_usb_cableado = 30`, `lado_bornera_cableado = 3`, `lado_soldadura_cableado = 2`).
  - `transparentes_cableado = ["tapa"]`, `ocultos_cableado = ["conectores"]`, `reserva_cable = reserva_cable_motor`, `radio_curva_cableado = radio_curva_cable` y `largo_cable_dupont = 200`, con un comentario que diga que es el largo del paquete de la lista de materiales.
- [X] T011 [US1] En `src/puntero_laser_ensamblaje.scad`, declarar `cables` con estos 26, en este orden: `[id, desde, hasta, función, grupo, hilos]`. +5 V = `["Red"]` y GND = `["Black"]`. Diámetro: `diametro_cable_dupont`, o `d_hilo` para los soldados de silicona. `largo_comprado`: `largo_cable_dupont` para los Dupont, `largo_cable_motor` para los motores y `undef` para lo cortado de rollo.
  1. `usb_5v`, "Power bank USB +5 V", "Interruptor", +5V, alimentacion: usb / soldadura.
  2. `usb_gnd`, "Power bank USB GND", "Barra GND (entrada)", GND, alimentacion: usb / soldadura.
  3. `interruptor_barra`, "Interruptor", "Barra +5 V (entrada)", +5V, alimentacion: soldadura / soldadura.
  4. `v5_esp32`, "Barra +5 V pin 1", "ESP32 VIN", +5V, barra_5v: dupont / dupont.
  5. `v5_uln_az`, "Barra +5 V pin 2", "ULN2003 azimut +": dupont / dupont.
  6. `v5_uln_alt`, "Barra +5 V pin 3", "ULN2003 altura +": dupont / dupont.
  7. `v5_rele_vcc`, "Barra +5 V pin 4", "Relé VCC": dupont / dupont.
  8. `v5_rele_com`, "Barra +5 V pin 5", "Relé COM": dupont / bornera.
  9. `gnd_esp32`, "Barra GND pin 1", "ESP32 GND", GND, barra_gnd: dupont / dupont.
  10. `gnd_uln_az`, "Barra GND pin 2", "ULN2003 azimut −".
  11. `gnd_uln_alt`, "Barra GND pin 3", "ULN2003 altura −".
  12. `gnd_rele`, "Barra GND pin 4", "Relé GND".
  13. `gnd_regulador`, "Barra GND pin 5", "Regulador IN−": dupont / soldadura.
  14. a 17. `sen_az_in1` … `sen_az_in4`, "ESP32 GPIO 16" … "ESP32 GPIO 19" → "ULN2003 azimut IN1" … "IN4", señal, esp32_az, hilos `["DodgerBlue"]`, `["Orange"]`, `["Gold"]`, `["MediumSeaGreen"]`.
  18. a 21. `sen_alt_in1` … `sen_alt_in4`, "ESP32 GPIO 25", "ESP32 GPIO 26", "ESP32 GPIO 27", "ESP32 GPIO 33" → "ULN2003 altura IN1" … "IN4", señal, esp32_alt, con los mismos 4 colores.
  22. `sen_rele`, "ESP32 GPIO 23", "Relé IN", señal, rele_regulador, `["Violet"]`.
  23. `rele_regulador`, "Relé NA", "Regulador IN+", +5V, rele_regulador: bornera / soldadura, `d_hilo`.
  24. `cable_motor_az`, "Motor de azimut", "ULN2003 azimut (ficha del motor)", señal, motores_laser, `["Blue", "HotPink", "Yellow", "Orange", "Red"]`: jst / jst, `largo_cable_motor`.
  25. `cable_motor_alt`, "Motor de altura", "ULN2003 altura (ficha del motor)", lo mismo.
  26. `hilos_laser`, "Regulador OUT±", "Láser (pila falsa y tapa trasera)", señal, motores_laser, `["Red", "Black"]`, `d_hilo`, `undef`: soldadura / pila_falsa, con el recorrido fijo (regulador → conducto → salida del brazo cable) y el elemento `"cable_laser"` para el tramo que acompaña al láser.

  En el mismo orden, emitir `echo(str("CABLES largo_", id, "=", …))` por cable con recorrido. La Tabla de cables de la guía (T017) copia esos largos.
- [X] T012 [US3] En `src/puntero_laser_ensamblaje.scad`, declarar los obstáculos (data-model §1.2):
  - `obstaculos_cableado`: cada placa (ESP32, relé, 2 ULN2003, regulador y barra, con su componente), el interruptor, los soportes de las placas (como cajas de sus paredes), la plataforma (debajo de `z_sup`), el power bank y los dos motores, con su componente `""`. Todas salen de las mismas variables que dibujan cada elemento.
  - `interior_tapa_cableado`: el interior de la tapa.
  - `pasos_tapa_cableado`: el conducto (`zona_conducto`) y la entrada de los cables de los motores por la pared −X.
  - Quitar los dos `assert` de la V-26 (C-04 los reemplaza con el mismo dato) y dejar el `echo` `CABLES largo_alt=…` solo si algo lo usa; si no, lo reemplaza el eco por cable de T011.
- [X] T013 [US1] En `src/puntero_laser_ensamblaje.scad`, dentro de `ensamblaje_principal()`, agregar `if (ver_cables) cables_modelados();` y no dibujar `%elemento("conectores")` cuando `ver_cables` es `true`.
- [X] T014 Validar el diseño:
  - Correr `scripts/verificar_pieza.sh --rapido src/puntero_laser_ensamblaje.scad` sin avisos ([quickstart.md §1](quickstart.md)). Deben salir los 26 `CABLE;` y ningún choque ni falta de largo.
  - Si hay choques (research R5, riesgo), corregir el recorrido en este orden: (a) pasar el tramo por los pasillos entre soportes (`holgura_zonas`); (b) solo si no alcanza, subir `holgura_techo_tapa` en `src/puntero_laser_parametros.scad` y anotarlo en plan.md (FR-011).
  - Correr los 5 casos de [quickstart.md §2](quickstart.md) que fallan a propósito (los de la guía, después de T017 y T020) y comprobar cada mensaje.
  - Fuera del sandbox, capturar con `-D ver_cables=true -D ver_tapa=false` en `.tools/tmp/cableado.png` (quickstart §3) y revisar a ojo cada grupo de cables.
  - Anotar los resultados en "Notas de la implementación".

---

## Fase 2: Simulación

- [X] T015 La simulación FEM no aplica (plan.md, Principio III, research R9): no hay tarea de simulación.

---

## Fase 3: Exportación

- [X] T016 Comparar por vértices ordenados las 13 STL del puntero con `.tools/tmp/stl_antes/` (quickstart §4); deben ser iguales.
  - Si T014 cambió `holgura_techo_tapa`, regenerar con `scripts/verificar_pieza.sh` la tapa (y lo que dependa de su alto), revisar sus capturas, comprobar el límite del carro de altura y la cama, y anotarlo en plan.md.

---

## Fase 4: Documentación

- [X] T017 [US3] En `docs/puntero_laser_guia.md`, sección 5.4, después de la tabla de pines de la barra, agregar la **Tabla de cables** con el formato exacto de [contracts/guia.md](contracts/guia.md):
  - Encabezado `**Tabla de cables**:` y columnas `N.º | Desde | Hasta | Conectores | Largo`.
  - 26 renglones con los textos de Desde y Hasta **idénticos** a los de T011, en el mismo orden.
  - Los conectores escritos para la persona (p. ej. «Dupont hembra / Dupont hembra», «USB-A / soldado», «Ficha del motor / ficha del ULN2003»).
  - El largo de los ecos `CABLES largo_<id>` redondeado a 5 mm (`≈ 75 mm`). Para el láser, «≈ 310 mm» desde el recorrido de la tabla de recorridos.

  Agregar una línea que remita al visor: «En la web, "Ver el cableado" muestra cada uno de estos cables en 3D.»
- [X] T018 [US1] En `docs/puntero_laser_guia.md`, paso 16, decir en qué sentido va cada placa en su soporte (research R4):
  - Los ULN2003, con la ficha del motor hacia −X y las entradas IN hacia el ESP32 (+X).
  - El relé, con la tira VCC/GND/IN hacia −Y y la bornera hacia +Y.
  - El regulador, con la entrada hacia la barra.
  - El ESP32, con el USB hacia −Y (hacia la abertura de la tapa).

  Mantener la mención de la resistencia de 10 kΩ y del interruptor. Siguen siendo 19 pasos.
- [X] T019 [P] [US3] En `docs/puntero_laser_guia.md`, sección 4.4 (mensajes de error):
  - Reemplazar el renglón de la V-26 por el de C-04 (`cables: '<id>' mide … mm y el cable comprado … mm (faltan … mm)` → empalmar un alargue o usar un cable más largo).
  - Agregar el de C-03 (`cables: '<id>' atraviesa …` → revisar las medidas o la posición de las placas).

---

## Fase 5: Web de armado y visor

- [X] T020 [US3] En `scripts/generar_visor.py` ([contracts/scripts.md](contracts/scripts.md)):
  - `VERSION = 4`.
  - En `datos_del_ensamblaje()`, leer las líneas `CABLE;` (los textos van al final: `^ECHO: "CABLE;([^;]+);(.*?);([^;]*);(.*)"$`) y las 5 listas del cableado. Devolver `None` si no hay cables.
  - Agregar `tabla_de_cables(diseno)`, que lee la Tabla de cables de la guía según [contracts/guia.md](contracts/guia.md) (quitar `**` y espacios; numeración 1, 2, 3…). Agregar la comparación C-05 con los mensajes del contrato, primero los renglones que están solo en la guía.
  - Construir `datos["cableado"]` con la forma de [data-model.md §3](data-model.md#3-en-el-visor): puntos redondeados a 0,1 mm, `nombre` = tipo legible («Dupont», «Cable del motor», «Cable USB» o «Cable», según los extremos) + `": " + desde + " → " + hasta`, y `largo` del eco (para el láser, el largo de su recorrido).
  - Exportar también las mallas de los elementos de `elemento` y de `transparentes`. C-06 va en `validar()`.
  - `huella()` suma `docs/<diseño>_guia.md` solo si el ensamblaje declara cables. Para no exportar mallas por un cambio de la guía, la reutilización compara la huella **de los `.scad`** y la página nueva se arma igual.
  - Sumar `, 26 cables` al resumen.
  - Actualizar el docstring y la lista de contratos.
- [X] T021 [US1] En `scripts/plantilla_visor.html`, estructura y estilo:
  - Agregar el botón de pestaña `pestana-cableado` («Cableado»).
  - Agregar el panel `panel-cableado`: título, la línea de [contracts/visor.md](contracts/visor.md), la casilla «Atenuar las piezas» (marcada), la lista `cables` con subtítulos por grupo, el botón «Vista inicial» y la leyenda exacta del contrato.
  - Estilos: `.muestra` (rectángulo con los colores de los hilos), `.grupo-cables` (subtítulo) y `.cables li` (igual que `.piezas li`), con el diseño para ≤ 760 px que ya existe.
- [X] T022 [US1] En `scripts/plantilla_visor.html`, la escena del modo Cableado:
  - Crear `const CAB = DATOS.cableado` y `raizCableado`, oculta al inicio.
  - Las piezas: una malla por elemento del catálogo que no esté en `CAB.ocultos`, compartiendo la geometría de `piezas`, con `material(color, opaca)`. Son transparentes las de `CAB.transparentes`, y las de tipo `impresa` mientras «Atenuar las piezas» esté marcada.
  - Los cables: por hilo, un `TubeGeometry` sobre un `CurvePath` de rectas, con las esquinas reemplazadas por `QuadraticBezierCurve3` de radio `min(CAB.radio_curva, mitad del tramo más corto)`. Los hilos de un cable van desplazados un diámetro entre sí, en perpendicular al primer tramo.
  - En cada extremo, una `BoxGeometry` con las medidas y el color de `CAB.conectores[tipo]`, alineada con el tramo y apoyada en el pin. `pila_falsa` no dibuja nada.
  - Un cable con `elemento` usa la geometría de `piezas[elemento]`.
  - Todas las mallas de un cable llevan `userData.cable = id`.
  - Calcular `cajaCables` y la función `vistaCableado()`, que encuadra esa caja desde `direccion`.
- [X] T023 [US2] En `scripts/plantilla_visor.html`, modos, selección y lista:
  - Generalizar `cambiarModo()` a `"armado" | "funcionamiento" | "cableado"`. Mostrar `pestanas` si hay `SIM` o `CAB`, y cada pestaña solo si su modo existe.
  - `#cableado` en `hashchange` y al cargar, y `?modo=cableado`. `Inicio` → `vistaCableado()`.
  - Al entrar al modo, encuadrar la caja de los cables la primera vez.
  - `seleccionables()` del modo Cableado: las mallas de `raizCableado` visibles.
  - En `elegir()`, dar prioridad al cable cuando su corte está a menos de 3 mm del corte opaco más cercano.
  - Resaltar un cable resalta todas sus mallas (hilos y conectores).
  - La etiqueta de un cable lleva el nombre y «Cable · ≈ <largo redondeado a 5> mm».
  - Lista agrupada en el orden de `CAB.grupos`, con la muestra de color y el nombre. `pointerover`, `focusin` y `click` resaltan el cable, como la lista de piezas.
  - `?modo=cableado&senalar=<id>` acepta un id de cable o de elemento.
- [X] T024 [US1] En `scripts/generar_web.py`, en `vistas_de_pasos()`, si `visor` tiene `cableado`, agregar después del enlace de Funcionamiento:
  `<p><a class="boton-3d" href="armado_3d.html#cableado">Ver el cableado</a> Cada cable de pin a pin, con sus conectores.</p>`
  Usar el mismo marcado y la misma clase de los otros dos botones. Actualizar el docstring.
- [X] T025 Regenerar las vistas explotadas con `scripts/capturas_armado.sh puntero_laser`, fuera del sandbox. Revisar una por una las que cambian: el paso 16, con el interruptor y la resistencia bajando, y el 17 y el 18, con ellos en contexto. Las demás no deben cambiar.
- [X] T026 Generar la web y el visor:
  - `scripts/generar_web.py puntero_laser specs/002-puntero-laser-estelar` y `--comprobar`. El resumen debe decir `26 cables` y el visor pesar menos de 4,5 MB.
  - `scripts/generar_web.py caja_pilas specs/004-caja-pilas-aa` y `--comprobar`: sin botón ni pestaña Cableado (quickstart §6).
  - Comprobar que C-05 falla con los casos de quickstart §2 que tocan la guía, y deshacerlos.
- [X] T027 [US2] Revisar en el Edge de Windows (fuera del sandbox) los 7 puntos de [quickstart.md §5](quickstart.md):
  - Los tres botones de la web.
  - La pestaña Cableado con la tapa transparente.
  - Las piezas atenuadas y opacas.
  - 26 renglones en 7 grupos.
  - Resaltado y etiqueta desde la escena y desde la lista.
  - Colores por función.
  - Armado, Funcionamiento, `#paso-16` y `#funcionamiento` intactos.
  - Ancho de celular.

  Tomar capturas con `armado_3d.html?modo=cableado&senalar=sen_az_in4` y `…&senalar=cable_motor_alt`.
- [X] T028 [P] Fuera del sandbox de escritura, sumar un apartado a dos skills, como los de la 007 y la 008:
  - `.claude/skills/disenio-multipieza/SKILL.md`: cómo declarar `cables` y sus listas, con enlace a [contracts/ensamblaje.md](contracts/ensamblaje.md).
  - `.claude/skills/web-armado/SKILL.md`: cómo revisar la pestaña Cableado (`?modo=cableado&senalar=<id>`) y que la Tabla de cables de la guía tiene que coincidir con el ensamblaje.

---

## Fase final: Cierre

- [X] T029 Revisar los criterios de éxito:
  - **SC-001**: 26 de 26 cables, C-05 sin diferencias.
  - **SC-002**: lo comprueba T027 con la lista.
  - **SC-003**: C-03 sin choques en T014.
  - **SC-004**: los casos de T014 y T026.
  - **SC-005**: el tamaño y la apertura del visor en T026 y T027.

  Actualizar el estado de `spec.md`, marcar las tareas y completar "Notas de la implementación".

## Dependencias y orden

- T001 → T002 → T003 y T004 → T005 y T006 (biblioteca común).
- T007 → T008 y T009 → T010 y T011 → T012 → T013 → T014 (ensamblaje; necesita la biblioteca terminada).
- T014 → T015 → T016 → T017, T018 y T019 → T020.
- T020 → T021 → T022 → T023 (la plantilla necesita los datos del generador).
- T024 puede hacerse en paralelo con T021 a T023, porque es otro archivo.
- T025 necesita T008. T026 necesita T017 y T020 a T024. T027 necesita T026.
- T028 puede hacerse en cualquier momento después de T014.
- T019 puede hacerse en paralelo con T017 y T018, porque toca otra sección de la guía.

## Ejemplos de trabajo en paralelo

- Con la biblioteca terminada (T006): T007 (pines en el ensamblaje) puede avanzar mientras se escribe T020 (lectura de los ecos en el generador), porque el formato de los ecos lo fija el contrato.
- Con el generador listo (T020): T021 a T023 (plantilla) y T024 (web) van en paralelo.
- En la documentación: T019 en paralelo con T017 y T018.

## Estrategia

El incremento mínimo útil es **US1**: biblioteca, pines, recorridos, los 26 cables, la escena, las
pestañas y el botón (T002 a T013 sin las comprobaciones, más T020 a T022 y T024). Con eso la persona ya
ve el cableado completo.

**US2** (T023 y T027) agrega la identificación de cada cable: la lista, el resaltado y la etiqueta.

**US3** (T003, T004, T012, T017 y T019, y C-05 en T020) asegura que lo dibujado coincida con la guía y
no atraviese nada.

Como la constitución no permite entregar un diseño sin sus comprobaciones de choque, las tres
historias se cierran juntas antes del commit.

## Notas de la implementación

- **Cables**: 26 en 7 grupos, de 65 a 440 mm. Los Dupont más largos son ESP32 VIN (≈ 185 mm) y GND
  (≈ 170 mm): con la reserva de 10 mm entran en los de 20 cm. Los de los motores pasan a ≈ 135 mm
  (altura) y ≈ 160 mm (azimut) porque ahora terminan en la ficha, en el borde −X del ULN2003, y no en
  el centro de la placa; sobran ≈ 70 mm de 230.
- **Recorridos** (research R5): señales en el nivel 0, GND en el 1 y +5 V en el 2. Entre los conectores
  y el techo entran justo los tres niveles, y ningún par de cables comparte un tramo. Los Dupont del
  ESP32 se doblan hacia el centro, como pide la guía, corren por 11 carriles bajo la placa en dos
  alturas alternadas y salen por el pasillo entre columnas (x = 81,4). GPIO23 sale entre el ESP32 y el
  relé. Los cables de los ULN2003 de azimut usan carriles que no se cruzan; en los de altura hay
  cruces puntuales a la misma altura (no tramos compartidos), porque el orden de sus pines en el ESP32
  no permite evitarlos.
- **El riesgo de R5 no apareció**: no hubo choques y la tapa no cambió. Las 13 STL son iguales por
  vértices a las de `ed17342`.
- **Cambios respecto del plan**:
  - Los identificadores de tres cables cambiaron (`cable_motor_az`, `cable_motor_alt` y
    `hilos_laser`), porque C-01 no deja repetir el nombre de un elemento.
  - El cable del láser lleva también el tramo fijo (regulador → conducto → brazo). Antes no estaba
    dibujado.
  - La tapa son obstáculos (paredes y techo) con aberturas como pasos, en vez de una caja contenedora.
  - `reserva_cable` es de 10 mm y no de 20: con 20, el Dupont del ESP32 VIN quedaba 4 mm corto en el
    dibujo.
  - `largo_elementos_cableado` suma el tramo móvil al largo del cable del láser (≈ 412 mm).
  - `pad_soporte`, `alto_labio_soporte`, `ancho_entrada_cable` y `alto_entrada_cable` pasaron a los
    parámetros compartidos, para que el ensamblaje arme los obstáculos con las mismas medidas que
    las piezas. Ninguna pieza cambió.
- **Comprobaciones a propósito**: `x_pasillo=78`, `y_cruce_rele=0` y `x_carril_usb=84` fallan con
  C-03, y `reserva_cable=60` falla con C-04. En la guía, cambiar un GPIO falla con C-05 (los dos
  mensajes) y borrar un renglón falla por la numeración.
- **Capturas**: cambian las vistas de los pasos 16 a 18 (el interruptor bajando y después en
  contexto). La resistencia va bajo el relé, del lado de las soldaduras, y no se ve. Las de los
  pasos 8 a 15 se volvieron a generar con diferencias de render de ≈ 0,03 % y se dejaron como estaban.
- **Visor**: 3,8 MB (los cables suman ≈ 13 kB de puntos). Se revisó en el Edge sin ventana:
  - el modo Cableado, la etiqueta de `sen_az_in4`, `cable_motor_alt` y `v5_esp32`;
  - el modo Funcionamiento y el paso 16 del armado;
  - el ancho de 600 px.
- **Caja de pilas**: su web estaba desactualizada desde la 010 (tipo de cambio). Se regeneró junto con
  su visor, por el cambio de versión; no tiene pestaña ni botón de cableado.
- **Enchufe USB** (pedido después de la implementación):
  - El enchufe USB-A pasó a ser un elemento comprado (`enchufe_usb`, paso 17), del que nacen los dos
    hilos; el conector `usb` de los cables ya no se dibuja. Los hilos USB quedan en ≈ 415 mm.
  - La guía (5.4) explica cómo identificar con el multímetro el +5 V y el GND del cable USB, y la
    prueba de la barra comprueba la polaridad.
- **Pendiente**: probar con el mouse y con el dedo el resaltado desde la escena y desde la lista, y
  la casilla «Atenuar las piezas». El Edge sin ventana no los prueba.
