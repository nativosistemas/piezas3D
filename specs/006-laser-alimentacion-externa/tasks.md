---
description: "Lista de tareas para alimentar el láser del puntero estelar desde el power bank"
---

# Tareas: Láser alimentado desde el power bank

**Entrada**: documentos de diseño en `specs/006-laser-alimentacion-externa/`

**Prerrequisitos**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/interfaz_generador.md](contracts/interfaz_generador.md),
[contracts/interfaz_firmware.md](contracts/interfaz_firmware.md) y [quickstart.md](quickstart.md)

**Pruebas**: la especificación no pide TDD y no se crea `tests/`. La verificación la hacen las tareas
de comprobación: ejecutan los escenarios del [quickstart.md](quickstart.md) y cierran las puertas de
calidad de la constitución.

**Organización**: la constitución (Principio II) **obliga** a agrupar las tareas en las cinco fases
del pipeline: Diseño → Simulación → Exportación → Documentación → Web de armado. Esta regla prevalece
sobre la agrupación por historia de la plantilla. Cada tarea lleva la etiqueta de su historia para
mantener la trazabilidad:

- **US1** (P1): encender y apagar el láser cortando su alimentación.
- **US2** (P2): sacar los cables sin que se enreden en el giro de altura.
- **US3** (P3): adaptar la pila falsa y la tapa al láser real.

## Formato: `[ID] [P?] [Historia] Descripción`

- **[P]**: puede ejecutarse en paralelo (archivos distintos y sin dependencias pendientes).
- **[USn]**: historia de usuario de [spec.md](spec.md).

## Convenciones comunes a todas las tareas

- Se aplican las convenciones de la
  [lista de tareas de la 002](../002-puntero-laser-estelar/tasks.md#convenciones-comunes-a-todas-las-tareas):
  - ejecutar desde la raíz del repositorio con `.tools/bin/openscad` y dejar los temporales en
    `$TMPDIR`;
  - encabezado estándar e `include <puntero_laser_parametros.scad>` dentro de
    `// --- PARÁMETROS Y CONSTANTES ---`;
  - `module pieza_<nombre>()` en orientación de impresión, `ensamblaje_principal()`, sin números
    mágicos, agujeros horizontales con `agujero_gota()` y todo en español.
- Las piezas nuevas parten de la plantilla de la skill `pieza-openscad`. Cada pieza se cierra con
  `scripts/verificar_pieza.sh src/<pieza>.scad`, que debe terminar con código 0.
- Las holguras salen de `holgura("presion" | "justo" | "deslizante" | "suelto")` de
  `src/perfil_impresora.scad`. Como `perfil_medido = false`, son **valores por defecto, no medidos**,
  y la guía debe decirlo.
- **Ángulos del cable**: `angulo_cable = 150` está medido en el plano XY del sistema de impresión de
  la cuna, desde +X. En el conjunto equivale al lado −X, 30° por debajo de la horizontal
  ([research R6](research.md)). La tapa trasera usa el mismo ángulo respecto de su propio eje.
- Las capturas PNG y el navegador se ejecutan **fuera del sandbox** (ver `CLAUDE.md`).
- No se modifica ningún parámetro público de la 002 ni el nombre de ningún STL
  ([contrato del generador](contracts/interfaz_generador.md)).

---

## Fase 0: Preparación

- [X] T001 Guardar las cotas de referencia del diseño actual antes de tocar nada: ejecutar
  `.tools/bin/openscad -o "$TMPDIR/antes.echo" src/puntero_laser_parametros.scad` y anotar
  `l_trasero` (95), `altura_eje` (109,307), `alto_brazo` (126,307), `largo_plataforma` (194,3),
  `ancho_plataforma` (165,9), `alto_col_a` (79,4) y `alto_col_b` (114,4), para comparar en T013

---

## Fase 1: Diseño paramétrico (`src/puntero_laser_*.scad`)

### Fundacional: `src/puntero_laser_parametros.scad` (bloquea a todas las piezas)

- [X] T002 [US3] Agregar en `src/puntero_laser_parametros.scad` el grupo `/* [Láser sin batería] */`,
  después de `/* [Componentes comprados] */`, con los 11 parámetros de la
  [Entidad 1](data-model.md#entidad-1-parámetros-públicos-nuevos-customizer), cada uno con su comentario
  de una línea y su rango exacto:
  - `diametro_hueco_bateria = 18.5; // [16:0.1:22]`
  - `profundidad_hueco_bateria = 65; // [34:0.5:70]`
  - `diametro_zona_tapa = 30; // [20:0.1:40]`
  - `largo_zona_tapa = 12; // [8:0.5:20]`
  - `largo_tapa_original = 20; // [5:0.5:40]`
  - `masa_bateria_g = 45; // [15:1:60]`
  - `masa_tapa_original_g = 20; // [5:1:40]`
  - `tuercas_lastre_tapa = 2; // [0:1:3]`
  - `distancia_trasera_centro_masa_nueva = 0; // [0:1:200]`
  - `regulador_largo = 22; // [15:0.5:25]`
  - `regulador_ancho = 17; // [10:0.5:18]`

  Corregir los comentarios de `largo_laser`, `distancia_trasera_centro_masa` y `masa_laser_g` para
  aclarar que se miden **con la batería y la tapa original**, sin cambiar sus valores.
- [X] T003 [US1] Agregar en `/* [Hidden] */` de `src/puntero_laser_parametros.scad` las constantes de la
  [Entidad 2](data-model.md#entidad-2-constantes-nuevas-hidden), con estos valores:
  - `m10_tuerca_ec = 17`, `m10_tuerca_alto = 8`, `masa_tuerca_m10_g = 11`;
  - `largo_prisionero_tapa = 10`, `iso7380_m3_cabeza_d = 5.7`, `iso7380_m3_cabeza_alto = 1.65`,
    `espesor_ojal = 0.8`, `compresion_resorte = 2`, `d_hilo = 1.3`;
  - `ohm_por_m_26awg = 0.134`, `corriente_laser_a = 0.5`, `largo_cable_laser = 600`;
  - `angulo_cable = 150`;
  - `ancho_ranura_canaleta = 2.5`, `pared_canaleta = 1.2`, `puentes_canaleta = 3`;
  - `piso_tapa_trasera = 1.6`, `pared_tapa_trasera = 2.4`, `espesor_resalte_prisionero = 5`;
  - `ancho_grapa = 6`, `pared_grapa = 2`, `abertura_grapa = 100`, `recorrido_equilibrado = 5`;
  - `masa_pila_falsa_g = 11`, `masa_grapa_g = 2`, `masa_cable_g = 4`;
  - `alto_brazo_max_flexion = 131`.
- [X] T004 [US1] Agregar los derivados de la
  [Entidad 3](data-model.md#entidad-3-derivados-nuevos-o-que-cambian) en
  `src/puntero_laser_parametros.scad`:
  - de la tapa y la pila: `largo_laser_sin_tapa`, `largo_tapa_fuera`, `largo_laser_mod`,
    `d_pila_falsa`, `largo_pila_falsa`, `masa_tapa_trasera_g`;
  - del centro de masa: `masa_laser_mod_g` y `cm_mod_desde_borde`, por momentos respecto del borde
    trasero del tubo con las posiciones exactas de la tabla;
  - del barrido y el cable: `r_tapa_trasera`, `hueco_equilibrado` y `caida_cable_v`.

  Después:
  - reemplazar `l_trasero = distancia_trasera_centro_masa;` por
    `l_trasero = distancia_trasera_centro_masa_nueva > 0 ? distancia_trasera_centro_masa_nueva : cm_mod_desde_borde + largo_tapa_fuera;`;
  - reemplazar `l_delantero = largo_laser - l_trasero;` por `l_delantero = largo_laser_mod - l_trasero;`.

  `altura_eje`, `alto_brazo` y los demás derivados se recalculan solos.
- [X] T005 [US1] Agregar el regulador a la columna A en `src/puntero_laser_parametros.scad`:
  - `largo_soporte_regulador = regulador_largo + 2*holgura_encastre + 2*pared_soporte`;
  - `alto_col_a = 2*largo_soporte_uln + largo_soporte_regulador + 2*holgura_zonas`;
  - `y_reg0 = y_uln_az0 + largo_soporte_uln + holgura_zonas`;
  - `zona_regulador = [x_col_a0, y_reg0, x_col_a1, y_reg0 + largo_soporte_regulador, altura_placas, "regulador"]`,
    agregada a `zonas_componentes`.

  Además, sumar `[5, (x_col_a0+x_col_a1)/2, y_reg0 + largo_soporte_regulador/2]` a
  `masas_giratorias`.
- [X] T006 [US2] Cambiar `secciones(a)` en `src/puntero_laser_parametros.scad`: las secciones del láser
  que caen en el tramo `t ∈ [−l_trasero, −l_trasero + largo_tapa_fuera + largo_zona_tapa]` usan el
  radio `r_tapa_trasera` en lugar de `diametro_laser/2`. Lo mismo vale para el punto extremo trasero
  `[-l_trasero*cos(a), …]`. Las secciones de la cuna no cambian, porque la canaleta no supera
  `sobre_anillo_colim`.
- [X] T007 [US3] Agregar las reglas de la
  [Entidad 4](data-model.md#entidad-4-validaciones-nuevas-v-15--v-21) en
  `src/puntero_laser_parametros.scad`, con mensajes en español que empiecen por el parámetro:
  - V-15: `comprobar_rango` para los 11 parámetros de T002.
  - V-16: `diametro_hueco_bateria + 2*espesor_min_pared <= diametro_zona_tapa`.
  - V-17: el lastre entra en la tapa y el escalón del borde del tubo mide ≥ 1 mm, o
    `tuercas_lastre_tapa == 0`.
  - V-18:
    `espesor_resalte_prisionero + pared_tapa_trasera + holgura("deslizante") + m3_tuerca_alto + espesor_ojal + 1 <= largo_prisionero_tapa`.
  - V-19: `hueco_equilibrado >= ancho_grapa + 2*recorrido_equilibrado`.
  - V-20: `caida_cable_v < 0.1`.
  - V-21: el regulador entra en `ancho_col_a`.
  - Aviso: `if (alto_brazo > alto_brazo_max_flexion) echo(str("AVISO: alto_brazo=", alto_brazo, " supera 131 mm: repetir el cálculo de flexión (research 006, R5)"));`

  Actualizar el encabezado del archivo: "reglas de validación (V-01…V-21)".
- [X] T008 [US1] Agregar a la línea `echo(str("DISEÑO …"))` de `src/puntero_laser_parametros.scad`
  los valores `masa_laser_mod_g`, `l_trasero`, `largo_tapa_fuera`, `hueco_equilibrado`,
  `caida_cable_v` y `alto_col_a`. Ejecutar el escenario 1 del [quickstart](quickstart.md):
  - Valores esperados: `masa_laser_mod_g` ≈ 161 g, `l_trasero` ≈ 97 mm, `largo_tapa_fuera` ≈ 17,8 mm,
    `hueco_equilibrado` ≥ 16 mm, `caida_cable_v` ≈ 0,08 V y `alto_brazo` ≈ 128 mm.
  - No debe aparecer ninguna línea `AVISO`.

  Si algún valor se aleja más del 10 %, revisar T004 antes de seguir.

### Piezas nuevas (US1 y US3)

- [X] T009 [P] [US1] Crear `src/puntero_laser_pila_falsa.scad` a partir de la plantilla de
  `pieza-openscad` ([research R4](research.md), unión U-13). Debe tener:
  - **Cuerpo**: cilindro de Ø `d_pila_falsa` y alto `largo_pila_falsa`, de pie, con la cara trasera
    en Z = 0 y chaflán de 0,5 mm en los dos bordes.
  - **Contacto positivo**: agujero axial central para el tornillo M3 × 8 ISO 7380 en la cara superior
    (delantera), con autorroscante `diametro_autorroscante_m3`. Además, un alojamiento de tuerca M3
    a 4 mm de la cara, abierto por una ranura lateral horizontal con vértice hacia arriba.
  - **Paso del hilo**: agujero axial de Ø `d_hilo + 1.1` (2,4 mm), descentrado 5 mm, de cara a cara.
    En la cara trasera, una ranura radial de 2,4 × 2 mm desde ese agujero hasta el borde.
  - Una marca "+" en bajorrelieve de 0,6 mm en la cara delantera, junto al tornillo.

  Verificar con `scripts/verificar_pieza.sh src/puntero_laser_pila_falsa.scad`. Caja envolvente
  esperada: ≈ 17,7 × 17,7 × 64,6 mm.
- [X] T010 [P] [US1] Crear `src/puntero_laser_tapa_trasera.scad` ([research R3 y R5](research.md),
  uniones U-14 y U-15), impresa de pie con el **piso trasero sobre la cama**. De abajo hacia arriba:
  1. **Piso** de `piso_tapa_trasera`.
  2. **Hexágono del lastre**: `m10_tuerca_ec + 2*holgura("presion")` entre caras, de
     `tuercas_lastre_tapa*m10_tuerca_alto + holgura("presion")` de alto. Se omite si
     `tuercas_lastre_tapa == 0`.
  3. **Funda**: interior de Ø `diametro_zona_tapa + 2*holgura("deslizante")` y `largo_zona_tapa` de
     largo, con pared `pared_tapa_trasera`. El cambio de hexágono a funda forma el escalón de apoyo
     del borde del tubo.

  Además lleva:
  - 2 **resaltes** para prisioneros a `angulo_cable` (150°) y a `angulo_cable + 180`, a media altura
    de la funda, de espesor radial `espesor_resalte_prisionero` y con chaflán de 45° por debajo. Cada
    uno con agujero radial de `diametro_autorroscante_m3` en forma de gota.
  - Una **ranura radial en el escalón**, de 2,4 × 2 mm a `angulo_cable`, y una **ventana** en la pared
    de 3 mm de ancho × 4 mm de alto, desde el escalón, con techo a dos aguas a 45°.
  - 2 **ranuras para brida** de 3 × 1,5 mm, a los lados de la ventana y a 4 mm por debajo del
    escalón, que atraviesan la pared en dirección tangencial.

  Verificar con `scripts/verificar_pieza.sh`. El alto total debe ser
  `largo_tapa_fuera + largo_zona_tapa` ≈ 29,8 mm.
- [X] T011 [P] [US2] Crear `src/puntero_laser_grapa_cable.scad` (unión U-16): perfil 2D extruido
  `ancho_grapa`, plano sobre la cama. Debe tener:
  - un anillo de Ø interior `diametro_laser − 2*holgura("presion")` y pared `pared_grapa`, abierto
    `abertura_grapa` grados y centrado en el lado opuesto al cable;
  - en `angulo_cable` (150°), un ojal exterior para 2 hilos de Ø interior `2*d_hilo + 0.6`, con una
    ranura de entrada de `d_hilo − 0.2` para meter el cable a presión.

  Verificar con `scripts/verificar_pieza.sh`.

### Piezas modificadas (US1 y US2)

- [X] T012 [US2] Modificar `src/puntero_laser_cuna_laser.scad` ([research R6](research.md)):
  - Quitar `ranura_cable()` y su llamada.
  - Agregar en la parte que suma material `canaleta_cable()`: un nervio de `angulo_cable` (150°),
    desde `radio_exterior_cuna − eps` hasta `radio_exterior_cuna + sobre_anillo_colim`, de ancho
    `ancho_ranura_canaleta + 2*pared_canaleta`. Va desde Z = 0 hasta
    `z_centro_cuna − d_munon/2 − 2`.
  - En la parte que resta, la ranura de `ancho_ranura_canaleta` y 2,5 mm de profundidad, dejando
    `puentes_canaleta` puentes cerrados de 2 mm de alto, repartidos a lo largo de la canaleta.
  - Comprobar con un `assert` que la canaleta no toca los prisioneros del anillo trasero (90°, 210°
    y 330°): separación angular ≥ 30°.
  - Actualizar la descripción del encabezado.

  Verificar con `scripts/verificar_pieza.sh src/puntero_laser_cuna_laser.scad`. La caja envolvente
  no debe crecer respecto del STL actual.
- [X] T013 [US1] Modificar `src/puntero_laser_plataforma_azimut.scad`: agregar el soporte del
  regulador en `zona_regulador`, con el mismo módulo y la misma forma que los soportes de los
  ULN2003 (labio y `holgura_pcb`), para una placa de `regulador_largo × regulador_ancho`. Verificar
  con `scripts/verificar_pieza.sh` y comparar con T001: `largo_plataforma` y `ancho_plataforma`
  deben seguir en 194,3 × 165,9 mm.
- [X] T014 [US1] Regenerar y verificar las piezas que cambian solo por `altura_eje`, con
  `scripts/verificar_pieza.sh` en cada una:
  - `src/puntero_laser_brazo_horquilla.scad`, con `-D 'lado="motor"'` y con `-D 'lado="cable"'`;
  - `src/puntero_laser_polea_altitud.scad`;
  - `src/puntero_laser_adaptador_tripode.scad`;
  - `src/puntero_laser_tapa_electronica.scad`.

  Anotar el `alto_brazo` nuevo, que debe quedar ≈ 128 mm.

### Ensamblaje y comprobaciones (US1, US2 y US3)

- [X] T015 [US2] Modificar `src/puntero_laser_ensamblaje.scad`:
  - Hacer `use <>` de las 3 piezas nuevas.
  - Dibujar `laser()` como el tubo sin tapa: cilindro de Ø `diametro_laser` desde
    `−l_trasero + largo_tapa_fuera` hasta `l_delantero`.
  - Agregar los elementos `pila_falsa`, `tapa_trasera`, `lastre` (tuercas M10), `grapa` y
    `regulador`, con su color, posición final y punto de origen en `posicion_*`. Las 4 primeras se
    colocan con `laser_en(angulo_altura)` en su lugar sobre la cola. La grapa va a
    `largo_zona_tapa + 4` mm del borde, hacia adelante.
  - Dibujar el cable (2 hilos de Ø `d_hilo`) desde la ventana de la tapa, por la grapa y la canaleta,
    hasta el agujero del brazo cable.
- [X] T016 [US1] Actualizar la tabla `pasos` de `src/puntero_laser_ensamblaje.scad` según la
  [Entidad 7](data-model.md#entidad-7-pasos-de-armado-cambios-en-la-tabla-pasos):
  - insertar el paso 14 "Preparar el láser", con `pila_falsa`, `tapa_trasera`, `lastre` y `grapa`,
    con origen a lo largo de `-v_laser`;
  - renumerar los siguientes;
  - agregar `regulador` al paso de la electrónica (ahora 16);
  - cambiar `assert(len(pasos) == 18, …)` por `19`, con el mensaje actualizado.
- [X] T017 [US2] Ejecutar el escenario 4 del [quickstart](quickstart.md) (render limpio del
  ensamblaje). Deben pasar:
  - V-07 con la tapa trasera y su tuerca entre −10° y 95° (holgura ≥ 2 mm con el cubo central y el
    conducto);
  - V-19;
  - los choques de zonas, incluida `zona_regulador`.

  Si V-07 falla por la tuerca del negativo, girar la tuerca hacia el costado o bajar
  `espesor_resalte_prisionero`, y volver a T010.
- [X] T018 [US3] Ejecutar el escenario 5 del [quickstart](quickstart.md): las 4 variantes válidas
  (16340, sin lastre, láser ya medido y mini-360), con los mismos `-D` sobre el ensamblaje y las 3
  piezas nuevas. En la variante sin lastre debe aparecer el `AVISO` y nada debe fallar.
- [X] T019 [US3] Ejecutar el escenario 6 del [quickstart](quickstart.md): los 4 casos inválidos
  terminan con `ERROR: Assertion` y un mensaje que nombra el parámetro (V-16, V-20, V-19 y V-15).
- [X] T020 Generar capturas PNG (isométrica, frente, lateral y superior) **fuera del sandbox**, con
  `scripts/verificar_pieza.sh --capturas "$TMPDIR/cap" src/puntero_laser_<pieza>.scad`, para
  `pila_falsa`, `tapa_trasera`, `grapa_cable`, `cuna_laser` y `plataforma_azimut`. Mirarlas una por
  una:
  - la canaleta a 150° y que no quede la ranura vieja;
  - el escalón, la ranura y la ventana de la tapa;
  - la ranura lateral de la tuerca de la pila;
  - el soporte del regulador;
  - que no haya geometría flotante.

  Cierra la puerta 1.

---

## Fase 2: Simulación FEA (no aplica, con justificación)

- [X] T021 Confirmar con los valores de T008 y T014 que se cumple la condición de la justificación
  ([plan.md](plan.md) y [research R10](research.md)): `masa_laser_mod_g` ≤ 180 y `alto_brazo` ≤ 131.
  Si no se cumple, recalcular la flexión lateral por escalado (`0,089° × (alto_brazo/126,3)³`) y
  volver a la Fase 1 hasta que dé < 0,1°. Anotar el resultado en una nota al final de este archivo.
  Cierra la puerta 2.

---

## Fase 3: Exportación (`exports/`)

- [X] T022 Regenerar **los 13 STL** con los valores por defecto, con render limpio
  (`--hardwarnings`):
  - los 10 de la 002, con los brazos en sus 2 variantes;
  - `exports/puntero_laser_pila_falsa.stl`, `exports/puntero_laser_tapa_trasera.stl` y
    `exports/puntero_laser_grapa_cable.stl`.

  Medir la caja envolvente de cada uno: todos ≤ 200 × 200 mm. Cierra la puerta 3.

---

## Fase 4: Documentación (`docs/puntero_laser_guia.md` y `docs/puntero_laser_bom.csv`)

- [X] T023 [P] [US1] Actualizar `docs/puntero_laser_bom.csv` según la
  [Entidad 6](data-model.md#entidad-6-lista-de-materiales-docspuntero_laser_bomcsv), con las mismas
  columnas y el mismo formato que las filas actuales:
  - Agregar el regulador MP1584EN, la resistencia de 10 kΩ, los 2 prisioneros M3 × 10 DIN 914, el
    tornillo M3 × 8 ISO 7380 con su tuerca, la contratuerca M3, los 2 terminales de ojal M3 y las
    2 tuercas M10.
  - Cambiar el cable a 60 cm con la nota "regulador → láser".
  - Agregar a la nota del láser: "la batería y la tapa original se guardan".

  Los precios nuevos quedan vacíos hasta T030.
- [X] T024 [US1] Actualizar en `docs/puntero_laser_guia.md` la tabla de piezas impresas (sección A):
  agregar las 3 piezas nuevas con orientación, relleno, perímetros, soportes ("No") y masa del
  laminador, y sus capturas `docs/img/puntero_laser_<pieza>.png` (de T020). Aclarar que el ajuste de
  la funda y de la pila falsa usa holguras **por defecto, no medidas**.
- [X] T025 [US1] Actualizar los pasos de armado de `docs/puntero_laser_guia.md` para que coincidan con
  los 19 pasos de T016:
  - **Paso 14 nuevo, "Preparar el láser"**:
    1. Fijarse hacia dónde va el + de la batería.
    2. Sacar la batería y la tapa original, y guardarlas.
    3. Probar la continuidad (F1).
    4. Atornillar el contacto + con el ojal rojo.
    5. Enhebrar el hilo y poner la pila falsa.
    6. Meter a presión las 2 tuercas M10 en la tapa, con una gota de cianoacrilato.
    7. Calzar la tapa alineando la ranura de la pila con la ventana.
    8. Apretar los 2 prisioneros; en el de 150°, poner el ojal negro y la contratuerca.
    9. Colocar la brida y la grapa.
  - **Paso 15**: trabar el pulsador en encendido (o puentearlo si es momentáneo, por la ventana de la
    cuna) y enhebrar el cable por los puentes de la canaleta. Se elimina la soldadura en paralelo al
    pulsador.
  - **Paso 16**: regulador en su soporte y resistencia de 10 kΩ entre IN y GND del relé.
  - **Paso 17**: recorrido nuevo del cable.
- [X] T026 [US1] Reemplazar en `docs/puntero_laser_guia.md` la sección 5.4 de conexiones por el esquema
  de [contracts/interfaz_firmware.md](contracts/interfaz_firmware.md#3-conexiones-reemplaza-el-esquema-de-la-002).
  Agregar:
  - el **ajuste del regulador antes de conectar el láser** (F2), con advertencia destacada: "5 V
    directos queman el láser";
  - el consumo nuevo, ≈ 1,16 A;
  - la tabla "Recorrido de los cables" con el tramo del láser: tapa → grapa → canaleta → bucle de
    40 mm → brazo cable.
- [X] T027 [US1] Actualizar los requisitos del firmware en `docs/puntero_laser_guia.md` con la sección
  2.5 de [contracts/interfaz_firmware.md](contracts/interfaz_firmware.md):
  - tabla de lo que garantiza el hardware;
  - GPIO23 en bajo al inicio de `setup()`;
  - *watchdog* ≤ 5 s;
  - retardo de 50 ms;
  - verificaciones F3 y F4.
- [X] T028 [US3] Actualizar en `docs/puntero_laser_guia.md`:
  - **la tabla de medidas a tomar** (sección 4.1), con las de [research R11](research.md): cómo
    medir cada parámetro de la Entidad 1;
  - **el equilibrado** (sección 3.4): se hace con la pila falsa y la tapa puestas, y si el punto
    medido difiere del calculado se carga `distancia_trasera_centro_masa_nueva`;
  - **un apartado "Volver a la batería original"**, con el procedimiento inverso del paso 14
    (SC-007).
- [X] T029 [US1] Regenerar la lista de materiales de la guía desde `docs/puntero_laser_bom.csv`, con
  el mecanismo de la skill `guia-produccion`, sin editarla a mano. Revisar que la guía no tenga
  marcadores de plantilla y que no queden menciones a "en paralelo al pulsador" ni a "llave de
  seguridad en ON" (`grep -n "paralelo al pulsador\|llave" docs/puntero_laser_guia.md`). Cierra la
  puerta 4.

---

## Fase 5: Web de armado y visor 3D (`specs/002-puntero-laser-estelar/web/`)

- [X] T030 [US1] Buscar y verificar en tiendas los precios de los componentes nuevos de T023, con la
  skill `web-armado`: tienda, enlace y fecha de hoy. Cargarlos en `docs/puntero_laser_bom.csv`, o
  dejarlos vacíos si no se pueden verificar. Ningún precio se estima.
- [X] T031 Regenerar las vistas explotadas **fuera del sandbox** con
  `scripts/capturas_armado.sh puntero_laser`. Revisar una por una las de los pasos 14, 15, 16 y 17,
  y comprobar que las demás solo cambiaron de número.
- [X] T032 Regenerar la web y el visor con
  `python3 scripts/generar_web.py puntero_laser specs/002-puntero-laser-estelar`. Después,
  `python3 scripts/generar_web.py --comprobar puntero_laser specs/002-puntero-laser-estelar` debe
  terminar sin errores (escenario 8).
- [X] T033 Revisar **fuera del sandbox**, en el Edge de Windows,
  `specs/002-puntero-laser-estelar/web/index.html` y `armado_3d.html`:
  - el paso 14 muestra la pila falsa, la tapa, el lastre y la grapa llegando a su lugar;
  - el regulador aparece en el paso 16;
  - los precios nuevos y el aviso de total parcial, si falta alguno.

  Cierra la puerta 5.

---

## Fase final: Cierre y comprobaciones transversales

- [X] T034 Actualizar el estado de la [spec.md](spec.md) a "Implementada (pendiente de las pruebas
  físicas)" y marcar en la tabla de puertas de [plan.md](plan.md) las 5 puertas con su evidencia.
- [X] T035 Agregar al final de `specs/002-puntero-laser-estelar/spec.md` una línea "Modificada por
  [006-laser-alimentacion-externa](../006-laser-alimentacion-externa/spec.md)", para que la 002
  remita al cambio.
- [X] T036 Dejar en una nota final de este archivo las pruebas físicas F1–F9 del
  [quickstart](quickstart.md) como pendientes del usuario, junto con las medidas supuestas que debe
  reemplazar (Entidad 1).

---

## Dependencias y orden de ejecución

### Dependencias entre fases (Principio II: estrictamente lineales)

```text
Fase 0 (T001) → Fase 1 (T002–T020) → Fase 2 (T021) → Fase 3 (T022) → Fase 4 (T023–T029) → Fase 5 (T030–T033) → Cierre (T034–T036)
```

Dentro de la Fase 1:

```text
T002 → T003 → T004 → T005 → T006 → T007 → T008   (mismo archivo, en orden)
T008 → T009 ∥ T010 ∥ T011                         (piezas nuevas, archivos distintos)
T008 → T012, T013, T014                           (piezas modificadas)
T009–T014 → T015 → T016 → T017 → T018 → T019 → T020
```

### Dependencias entre historias

- **US1** (alimentación) es el MVP: parámetros, pila falsa, tapa, regulador, guía y BOM.
- **US2** (cable) depende de la tapa de US1 (T010), que define dónde sale el cable, y del
  `secciones()` de T006.
- **US3** (adaptar) depende de los parámetros (T002, T007) y de que existan las piezas.

### Oportunidades de paralelismo

- T009, T010 y T011: 3 archivos nuevos e independientes, una vez cerrado T008.
- T012 y T013: archivos distintos (cuna y plataforma). Comparten solo los parámetros.
- T023 (CSV) puede adelantarse mientras se escriben T024–T028, porque es otro archivo.

## Ejemplo de ejecución en paralelo: piezas nuevas

```text
# Con T008 en verde, lanzar juntas:
T009  src/puntero_laser_pila_falsa.scad
T010  src/puntero_laser_tapa_trasera.scad
T011  src/puntero_laser_grapa_cable.scad
```

## Estrategia de implementación

### MVP (US1: el láser se alimenta y se apaga con el ESP32)

1. Fase 0 y los parámetros (T001–T008).
2. Pila falsa, tapa y regulador (T009, T010, T013 y T014).
3. Ensamblaje con los pasos (T015–T017).
4. Simulación, exportación y guía (T021–T029).

Con esto ya se puede imprimir, armar y probar F1–F6.

### Entrega incremental

1. **+ US2**: grapa, canaleta y barrido (T011, T012 y T017). El cable queda guiado (F8).
2. **+ US3**: variantes y casos inválidos (T018 y T019) y medidas en la guía (T028).
3. **Web y visor** (T030–T033) y cierre (T034–T036).

## Notas

- Cada tarea de comprobación que falle devuelve a la tarea que la origina. No se avanza de fase con
  una puerta abierta.
- Si las medidas reales del láser llegan durante la implementación, se cargan en T002 y se rehacen
  T008, T017 y T022.

## Notas de implementación (desviaciones respecto al plan)

- **Perfil de impresora**: `puntero_laser_parametros.scad` ahora hace `include <perfil_impresora.scad>`
  (Principio IV) para usar `holgura()`. Se quitó su `espesor_min_pared` propio, igual al del perfil.
- **Tapa trasera**: prisioneros M3 × **12** (con 10 no entraban el ojal y la contratuerca), puestos a
  `angulo_cable` + 45° para no tapar la ventana del cable. **Sin oreja de brida**: no entraba en una
  funda de 12 mm; el alivio de tensión lo hace la grapa, con su ojal ajustado a los 2 hilos.
- **Grapa de 5 mm y equilibrado de ±3,5 mm**: el hueco entre la tapa y la cuna dio 13,0 mm.
- **Canaleta** de 2,8 × 2,8 mm, para 2 hilos de 26 AWG lado a lado.
- **Pila falsa**: el agujero del hilo se calcula entre la tuerca del contacto y la pared mínima, para
  que la variante 16340 entre.
- **Barrido**: la cola usa el radio de la funda (17,7 mm) y el de los prisioneros (27 mm) solo en su
  sección. `radio_barrido` tiene en cuenta el radio de la funda.
- **Lastre (corrección de R5)**: sin lastre el diseño también cumple (brazos de 129,4 mm, ≈ 0,096°). Se
  mantiene por defecto porque deja la geometría igual a la 002: `altura_eje` cambia 0,003 mm.
- **Vista del paso 16**: el regulador entra desde 150 mm de altura para que no lo tape la polea.
- **Guía**: se corrigió la prueba del relé de la 002 (con IN a 3,3 V un relé activo en nivel alto
  debe **cerrar**, no soltar).

### T021: condición de la justificación sin FEM

`masa_laser_mod_g` = 166,9 g ≤ 180 y `alto_brazo` = 126,31 mm ≤ 131: se cumple. La flexión lateral
queda en 0,089°, como en la 002.

### T030: precios

No se pudo verificar el precio de ningún componente nuevo: Mecatronix, e-LABShop, Tech Forge, Arsumo
y Electrocomponentes no tienen el MP1584, y la búsqueda web no devolvió tiendas argentinas. Los 7
renglones quedan sin precio y la web avisa que el total es parcial.

### T036: pendiente del usuario

1. **Medir el láser** y cargar en `src/puntero_laser_parametros.scad`:
   - `diametro_hueco_bateria`, `profundidad_hueco_bateria`, `diametro_zona_tapa`, `largo_zona_tapa`
     y `largo_tapa_original`;
   - `masa_bateria_g` y `masa_tapa_original_g`.

   Después, regenerar los STL y la web.
2. **Pruebas físicas F1–F9** del [quickstart](quickstart.md#pruebas-físicas): continuidad del tubo,
   ajuste del regulador, láser apagado con el ESP32 apagado y sin destellos, maniobras del relé,
   tensión con los motores en marcha, equilibrado, 20 recorridos del cable y cambio a la batería
   original.
3. **Precios** de los 7 componentes nuevos, cuando se encuentren en una tienda verificable.
