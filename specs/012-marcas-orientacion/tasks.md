---

description: "Lista de tareas de las marcas de orientación y de altura del puntero láser"
---

# Tareas: Marcas de orientación y de altura del puntero láser

**Entrada**: documentos de diseño de `specs/012-marcas-orientacion/`

**Requisitos previos**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Pruebas**: no hay tareas de prueba aparte. Cada fase se cierra con las validaciones de OpenSCAD
(M-01 a M-09), los casos que fallan a propósito, las capturas y los escenarios del quickstart.

**Organización**: por las cinco fases del pipeline (Principio II, como en la 009 a la 011). Cada tarea
lleva su historia de usuario:
- **US1**: orientar el aparato al sur y al oeste (P1).
- **US2**: reconocer el láser horizontal y leer su altura (P1).
- **US3**: arrancar desde una posición conocida (P2).
- **US4**: ver las marcas en la web y en el visor 3D (P3).

## Formato: `[ID] [P?] [Historia] Descripción`

---

## Fase 0: Preparación

- [X] T001 Tomar la línea de base:
  - Comprobar que pasan `scripts/generar_web.py --comprobar puntero_laser specs/002-puntero-laser-estelar` y `scripts/generar_web.py --comprobar caja_pilas specs/004-caja-pilas-aa`.
  - Comprobar que `git status --short exports docs/img src` está limpio.
  - Copiar las 13 STL de `exports/puntero_laser_*.stl` a `.tools/tmp/stl_antes/` para comparar después.

---

## Fase 1: Diseño (`src/*.scad`)

### Parámetros compartidos (bloquea todo lo demás)

- [X] T002 En `src/puntero_laser_parametros.scad`, agregar la sección `/* [Marcas] */` con los parámetros de [data-model.md](data-model.md), con estos valores y comentarios en español:
  - `profundidad_grabado = 0.6`, `ancho_raya = 1.0`, `ancho_linea_referencia = 1.2`.
  - `alto_letra = 10` y `fuente_marcas = "Liberation Sans:style=Bold"`.
  - `espesor_disco_escala = 2`, `d_interior_disco_escala = 20` y `giro_ranura_disco = 32`.
  - `paso_escala = 15`, `angulo_escala_max = 90`, `holgura_aguja = 2.5` y `seccion_aguja = [5, 4]` (radial × tangencial).
- [X] T003 En `src/puntero_laser_parametros.scad`, agregar los derivados:
  - `r_borde_polea_alt = d_exterior_conducida/2 + espesor_brida` y `r_exterior_disco_escala = r_borde_polea_alt`.
  - `r_aligerado`, movido desde `src/puntero_laser_polea_altitud.scad` con la misma fórmula, y `r_agujeros_disco = r_aligerado`.
  - `r_aguja_int = r_borde_polea_alt + holgura_aguja` y `r_aguja_ext = r_aguja_int + seccion_aguja[0]`.
  - `x_punta_aguja = x_ext_polea_alt + espesor_disco_escala` y `alto_aguja = x_punta_aguja - x_cara_ext_brazo`.
  - `r_correa_ext_alt`: radio primitivo de la polea de 80 dientes, más el espesor de la correa GT2 por fuera de la línea primitiva. Usar las constantes GT2 existentes y, si falta el espesor de la correa, agregarlo como constante con su valor de catálogo (1,38 mm total).
  - `azimut_reposo = 180`, con el comentario: «azimut de brújula del láser en la posición modelada (+Y = sur)».
- [X] T004 En `src/puntero_laser_parametros.scad`:
  - Hacer que `alto_brazo` sea el mayor entre su valor actual y `altura_eje + r_aguja_ext + espesor_min_pared`.
  - Sumar los nuevos parámetros editables a `comprobar_rango()` donde corresponda (por ejemplo, `holgura_aguja` de 1,5 a 6 y `alto_letra` de 6 a 14).
  - Verificar con `.tools/bin/openscad -o "$TMPDIR/p.csg" src/puntero_laser_parametros.scad` que no hay avisos.

### Piezas

- [X] T005 [P] [US1] En `src/puntero_laser_adaptador_tripode.scad`, agregar `marcas_cardinales()` y restarlo al final del `difference()` de `pieza_adaptador_tripode()`. Detalle en research R3:
  - «S» centrada en el ángulo +Y y «O» en +X, con `text(..., size = alto_letra, font = fuente_marcas, halign = "center", valign = "center")`, en el cilindro de apoyo (r = `diametro_apoyo_tripode/2`).
  - Las letras tienen que leerse derechas desde afuera. Las posiciones en Z se definen respecto de `chaflan_base` y `z_cuerpo_base_sup`, no como números sueltos.
  - Debajo de cada letra, una línea vertical de `ancho_linea_referencia` de ancho, alineada con el centro de la letra.
  - Profundidad uniforme: intersecar el 2D extruido en sentido radial con una cáscara entre `r − profundidad_grabado` y `r + eps`.
  - Asserts M-01 y M-02 de [data-model.md](data-model.md):
    - M-01: las letras y las líneas caben entre `chaflan_base` y `z_cuerpo_base_sup`, y no tocan la ventana de la llave (−Y).
    - M-02: queda al menos `espesor_min_pared` hasta la cámara interior.
  - Actualizar la Descripción del encabezado.
- [X] T006 [P] [US1] En `src/puntero_laser_plataforma_azimut.scad`, agregar `indice_azimut()` y restarlo al final. Detalle en research R4:
  - Una raya vertical de `ancho_linea_referencia` × `profundidad_grabado` en la cara del borde +Y (`y_plat1` en el sistema del conjunto) en x = 0, de toda la altura del borde.
  - Un triángulo grabado en la cara superior junto al borde, apuntando a +Y.
  - Assert M-09: la raya y el triángulo no tocan otros vaciados del borde +Y. Si hay un reborde o un vaciado en x = 0, mover el triángulo, no la raya.
  - Actualizar la Descripción.
- [X] T007 [P] [US2] En `src/puntero_laser_brazo_horquilla.scad`, solo en la variante `"motor"`. Detalle en research R2:
  - Sumar al `hull()` de `cuerpo_brazo()` una oreja hasta `altura_eje + r_aguja_ext + espesor_min_pared`, con el ancho de la aguja más 2 × `espesor_min_pared`.
  - Agregar `aguja_indice_altura()` en la unión: una columna de `seccion_aguja`, con su cara interior a `r_aguja_int` del eje, centrada en x = 0 del sistema de impresión y alineada con el eje de altura (las 12 en el conjunto). Va desde la cara exterior (`z = espesor_brazo`) hasta `espesor_brazo + alto_aguja`.
  - La punta lleva un bisel en V hacia el eje, imprimible sin soportes.
  - Assert M-04: `alto_brazo ≤ cama_max`.
  - La variante `"cable"` no debe cambiar ni un vértice: la oreja y la aguja van dentro de `if (lado == "motor")`.
  - Actualizar la Descripción.
- [X] T008 [P] [US2] En `src/puntero_laser_polea_altitud.scad`:
  - Usar `r_aligerado` de parámetros y borrar el local.
  - Restar 2 agujeros guía de `diametro_autorroscante_m3`, a `r_agujeros_disco` y a 0° y 180° en el sistema de la pieza (entre aligerados, que están a 30° + k·60°), desde la cara exterior (z = 0) con 8 mm de profundidad.
  - Assert M-05: la pared de cada agujero a los aligerados y a la raíz del dentado es ≥ `espesor_min_pared`.
  - Actualizar la Descripción.
- [X] T009 [P] [US2] Crear `src/puntero_laser_disco_escala.scad` desde la plantilla de la skill `pieza-openscad`. Detalle en research R1 y R7:
  - Encabezado y `include <puntero_laser_parametros.scad>`.
  - `pieza_disco_escala()`: un anillo de `d_interior_disco_escala` a `2*r_exterior_disco_escala` y `espesor_disco_escala` de alto. La z = 0 apoya en la polea.
  - Ranuras: 2 en arco centradas a 0° y 180°, a `r_agujeros_disco`, de ±`giro_ranura_disco`, con el ancho `m3_d + holgura_tornillo_m3`.
  - Escala: rayas de `ancho_raya` × `profundidad_grabado` desde la cara z = `espesor_disco_escala`, a ángulos `a = 0, paso_escala, …, angulo_escala_max`, todas hasta el borde. Las de múltiplos de 45° nacen en r = 19 mm y las demás en r = 21,5 mm; los dos radios van como parámetros de la pieza.
  - Sentido de las rayas: la raya de `a` va a `a` grados de la marca de 0°, en el sentido que la lleva hacia la aguja cuando la cuna sube `a` grados. Queda definido por M-08 en T011.
  - Assert M-06: `giro_ranura_disco ≥ 30`, y las ranuras no tocan las rayas largas ni el agujero central.
  - Para el verificador, la pieza se imprime plana con la escala arriba.

### Ensamblaje

- [X] T010 [US2] En `src/puntero_laser_ensamblaje.scad`:
  - Agregar `use <puntero_laser_disco_escala.scad>`.
  - Elemento `disco_escala`: `translate([x_ext_polea_alt, 0, z_eje_altura]) rotate([angulo_altura, 0, 0]) rotate([0, 90, 0])` (o la rotación que deja la cara z = 0 sobre la cara exterior de la polea, mirando a +X).
  - Elemento `tornillos_disco`: 2 tornillos M3 × 8 con arandela, a `r_agujeros_disco`, dibujados como la otra tornillería.
  - Sumar los dos a `elementos`, `grupo_horquilla` y `elementos_altura`.
  - En `nombres_elementos`: `["disco_escala", "Disco de la escala de altura", "impresa"]` y `["tornillos_disco", "Tornillos M3 × 8 del disco de la escala", "comprada"]`.
  - En `color_elemento()`: `disco_escala` en "WhiteSmoke"; los tornillos con el gris por defecto.
  - En `pasos`: sumarlos al paso 7 (donde entra `polea_alt`), con un desplazamiento explotado en +X mayor que el de la polea (45).
- [X] T011 [US2] En `src/puntero_laser_ensamblaje.scad`, agregar los asserts:
  - M-03: `r_aguja_int − r_correa_ext_alt ≥ 2` y `r_aguja_int > r_exterior_disco_escala`.
  - M-08: para cada `a` de la escala, la posición de su raya girada `a` grados alrededor del eje de altura (como gira la polea con `rotate([a, 0, 0])`) cae en el ángulo de la aguja (+Z), a menos de 0,1°.
  - Si M-08 falla por el sentido, corregir el sentido de las rayas en `src/puntero_laser_disco_escala.scad` (T009), no el assert.
- [X] T012 [US1] En `src/puntero_laser_ensamblaje.scad`, agregar el assert M-07: con el azimut en reposo, la dirección del emisor del láser (`[0, cos(0), sin(0)]` = +Y) apunta al ángulo de la «S» de la base, y la «O» está 90° en sentido horario visto desde arriba (+X). Usar los ángulos que define `marcas_cardinales()`, expuestos como constantes en parámetros (`angulo_marca_sur`, `angulo_marca_oeste`).
- [X] T013 [US3] En `src/puntero_laser_ensamblaje.scad`, cambiar el 7.º campo de la articulación `azimut` en `articulaciones` de `0` a `azimut_reposo`. Actualizar el comentario de `objetivos` para decir que los azimuts son de brújula (0 = norte), con la posición modelada en 180° (sur).
- [X] T014 [US1] [US2] Verificar el diseño:
  - `scripts/verificar_pieza.sh` sobre `adaptador_tripode`, `plataforma_azimut`, `brazo_horquilla`, `polea_altitud`, `disco_escala` y `ensamblaje`: sin errores ni avisos.
  - Fuera del sandbox, generar las capturas con `--capturas .tools/tmp/012` y mirarlas una por una ([quickstart.md](quickstart.md) §1): letras legibles y derechas, raya del índice, aguja vertical sin piezas flotando, agujeros guía entre aligerados, 7 rayas y 2 ranuras.
- [X] T015 [US1] [US2] Correr los casos que fallan a propósito de [quickstart.md](quickstart.md) §3, con `-D` sobre copias en `$TMPDIR` y sin tocar `src/`:
  - `holgura_aguja=0.5` tiene que fallar con M-03.
  - `giro_ranura_disco=20` tiene que fallar con M-06.
  - `alto_letra=40` tiene que fallar con M-01.
  - Anotar los mensajes.
- [X] T016 [US1] [US2] Fuera del sandbox, capturar el conjunto de costado (+X) y desde el frente (+Y), a la altura de la base ([quickstart.md](quickstart.md) §5). Comprobar dos cosas:
  - La aguja queda sobre la polea, en el plano del disco y sin tocar la correa.
  - La raya de la plataforma cae sobre la línea de la «S».

---

## Fase 2: Simulación

- [X] T017 No aplica: research R9 y la tabla de la constitución de [plan.md](plan.md). No hay archivos en `simulation/`. Confirmar que nada de la Fase 1 agregó una carga no prevista; por ejemplo, que la aguja no quedó como apoyo de algo.

---

## Fase 3: Exportación

- [X] T018 [P] [US1] [US2] Exportar a `exports/` las STL de `adaptador_tripode`, `plataforma_azimut`, `brazo_horquilla_motor` (con `lado="motor"`), `polea_altitud` y la nueva `disco_escala`, igual que las demás (`--export-format binstl` si así se hizo antes).
- [X] T019 [US1] [US2] Exportar `brazo_horquilla_cable` y las otras 8 STL no tocadas, y compararlas por vértices con `.tools/tmp/stl_antes/`. Las 9 tienen que ser iguales. Si alguna cambia, entender por qué antes de seguir.

---

## Fase 4: Documentación (`docs/`)

- [X] T020 [P] [US2] En `docs/puntero_laser_bom.csv`, agregar el renglón de [contracts/guia.md](contracts/guia.md) en la categoría «Tornillería M3», después del de las orejas de los motores: `2 ×;Tornillo M3 × 8 mm + 2 × arandela M3: disco de la escala de altura, autorroscante en la polea`, sin precio.
- [X] T021 [US2] En `docs/puntero_laser_guia.md`, siguiendo la skill `guia-produccion`:
  - **Valores del diseño entregado**: el largo nuevo del brazo y el disco de la escala.
  - **Sección 1 (impresión)**: la fila del disco (plano, escala hacia arriba, color claro recomendado, sin soportes) y una nota de que la aguja del brazo del motor sale vertical, sin soportes.
  - **Paso 7 (polea de altura)**: presentar el disco con la escala hacia afuera y los 2 tornillos con arandela sin apretar; el cero se pone en la puesta a punto.
  - **Lista de materiales**: regenerarla desde el CSV, sin editarla a mano.
- [X] T022 [US2] En `docs/puntero_laser_guia.md`, agregar en la sección 3 la subsección **Cero de la escala de altura**, con el método de research R6:
  - Mesa, pared a 2 o 3 m y el punto a `z_eje_altura` sobre el plano de apoyo. Tomar el valor en mm del eco del diseño, redondeado a 1 mm.
  - Aflojar los tornillos, girar el disco y apretar.
  - La alternativa con una app de inclinación sobre la cuna.
  - La aclaración de que el 0° es paralelo a la base y solo es horizontal con el trípode nivelado.
  - Sumar a la 3.6 la línea de [contracts/guia.md](contracts/guia.md) sobre los márgenes (±5° de azimut y ±2° de altura) de la posición de partida.
- [X] T023 [US1] Antes de escribir, consultar el calculador de declinación de la NOAA (modelo WMM) para 3 o 4 ciudades de Argentina de zonas distintas (por ejemplo, Buenos Aires, Córdoba, Mendoza y Ushuaia). Anotar los valores, el signo, la fuente y la fecha. Si no se puede consultar, no dar valores, solo el método y el enlace.
- [X] T024 [US1] En `docs/puntero_laser_guia.md`, en «Montaje en el trípode», agregar la subsección **Orientación al sur** (research R8):
  - El celular con brújula en norte verdadero.
  - La brújula magnética con rumbo 180° − D y la convención del signo.
  - Los ejemplos de T023 con fuente y fecha.
  - Tomar el rumbo a más de 50 cm del aparato, por los imanes de los motores, sobre un objeto lejano.
  - Girar la cabeza del trípode, sin desenroscar la base, hasta que la línea de la «S» apunte a ese objeto.
  - Agacharse frente a la base para alinear la raya de la plataforma con la línea de la «S» (paralaje, R4).
- [X] T025 [US3] En `docs/puntero_laser_guia.md`:
  - Describir la **posición de partida** al final de «Orientación al sur»: base con la «S» al sur, raya de la plataforma en la «S» y 0° de la escala en la aguja. Así el láser apunta al sur y horizontal.
  - En la 5.3, antes de la alineación con 2 estrellas: el firmware toma al encender azimut 180° y altura 0° como estimación inicial. La alineación con 2 estrellas sigue siendo la que da la precisión. Con el índice en la «O», el azimut es 270°.
- [X] T026 [P] [US1] [US2] En `docs/puntero_laser_guia.md`, sección 7 (Consejos):
  - Rellenar los grabados con pintura o marcador claro (o fosforescente) y leerlos con luz roja.
  - No aflojar la base para orientarla.
  - Volver a poner el cero si se desarma la polea.
- [X] T027 [US1] [US2] Revisar `docs/puntero_laser_guia.md` contra la skill `guia-produccion`: sin marcadores de plantilla, las secciones A y B completas y los enlaces internos bien.

---

## Fase 5: Web de armado y visor

- [X] T028 [US4] Fuera del sandbox, regenerar con `scripts/capturas_armado.sh` las capturas de `docs/img/`:
  - Las 5 piezas tocadas más `puntero_laser_disco_escala.png` y el conjunto.
  - Todas las vistas explotadas `puntero_laser_paso_NN.png`, porque la base aparece desde el paso 1.
  - Mirar una por una las de los pasos 1, 4, 7 y 8 y la del conjunto. En el paso 7, el disco y los tornillos tienen que entrar explotados en +X.
- [X] T029 [US4] Regenerar la web y el visor con `scripts/generar_web.py puntero_laser specs/002-puntero-laser-estelar` y comprobar con `--comprobar`, que tiene que pasar sin errores. Correr también `--comprobar caja_pilas specs/004-caja-pilas-aa`, que no debe cambiar.
- [X] T030 [US4] [US3] Fuera del sandbox, revisar `specs/002-puntero-laser-estelar/web/armado_3d.html` en el Edge ([quickstart.md](quickstart.md) §6):
  - **Modo Armado**: el paso 7 con el disco; las letras y la aguja de cerca.
  - **Modo Funcionamiento**:
    - El azimut arranca en 180°.
    - En el modo automático, «Norte bajo» apunta al lado opuesto de la «S» y «Oeste alto» hacia la «O».
    - Con la altura en 45°, la raya larga de 45° queda frente a la aguja.
  - **Modo Cableado**: sin cambios.
  - **Celular**: en un ancho de 600 px.
- [X] T031 [US4] Revisar `specs/002-puntero-laser-estelar/web/index.html`: aparecen la orientación al sur, el cero de la escala y la posición de partida, y la lista de materiales incluye los tornillos del disco.

---

## Fase final: Cierre

- [X] T032 Actualizar en [spec.md](spec.md) el estado a «Implementada» y agregar en este archivo las «Notas de la implementación»: valores finales, mensajes de M-01 a M-09, diferencias con el plan y lo que quede pendiente, como la prueba física de [quickstart.md](quickstart.md) §7.
- [X] T033 Revisar con `git status` que solo cambiaron los archivos previstos en [plan.md](plan.md) («Código y datos»), y proponer al usuario el commit con el mensaje `feat: marcas de orientación y escala de altura del puntero láser (012)`. No hacer el commit sin su visto bueno.

---

## Dependencias y orden

- **T001** va primero. **T002 → T003 → T004** bloquean todas las piezas.
- **T005 a T009** son paralelas entre sí (archivos distintos).
- **T010 y T011** necesitan T008 y T009. **T012** necesita T005; **T013** no depende de las piezas.
- **T014 a T016** cierran la Fase 1. Las Fases 2 a 5 siguen en orden (Principio II).
- En la Fase 4, **T020** es independiente. **T023** va antes de **T024**, y **T024** antes de **T025**.
- **T028** necesita las STL y la guía (las capturas de pasos salen del ensamblaje). **T029** necesita T028 y la guía terminada.

## Ejemplos de trabajo en paralelo

- **Fase 1**: después de T004, T005 (base), T006 (plataforma), T007 (brazo), T008 (polea) y T009 (disco)
  van en paralelo, porque cada una toca un archivo.
- **Fase 4**: T020 (CSV) y T023 (consulta de la declinación) pueden ir en paralelo con T021.

## Estrategia

- **El incremento mínimo útil es US1 + US2**, las dos de prioridad P1: las letras, el índice, el disco y
  la aguja (T002 a T016), con sus STL (T018 y T019). Con eso el aparato físico ya se orienta y se
  nivela.
- **US3** es la guía de la posición de partida y del firmware (T025), más el `reposo` del visor (T013).
- **US4** es la regeneración de capturas, web y visor (T028 a T031).

La constitución no deja entregar un diseño sin sus cinco fases, así que todo se cierra junto antes del
commit.

## Notas de la implementación

- **Valores finales** (por defecto):
  - Brazo motor de 144,4 mm (antes 126,5) con la aguja de 42 mm sobre la cara exterior. La aguja
    queda a 2,1 mm de la correa de altura (M-03 pide 2 mm).
  - Disco de 52,4 mm × 2 mm, ≈ 4 g, con ranuras de ±32°.
  - Agujeros guía de la polea a r = 15,9 mm, a 0° y 180°.
  - Letras de 10 mm en el cilindro de apoyo, a 0,6 mm de profundidad.
  - Raya y triángulo de 8 mm en el borde +Y de la plataforma.
- **Cambio respecto de T004**: `alto_brazo` no cambió, porque también lo usa el criterio de flexión de
  131 mm (research 006, R5), que depende de la altura del eje y no de la oreja. La aguja no lleva
  carga. Se agregó `alto_brazo_motor` y la V-04 nueva que lo controla contra la cama y la plataforma.
- **Cambio de alcance (anclas)**: la primera vista del paso 7 tenía una flecha suelta en el origen.
  Faltaban las `anclas()` del disco y de sus tornillos, y se agregaron.
- **Mensajes comprobados a propósito**:
  - `holgura_aguja=0.5` → M-03: «la aguja de índice queda a 0.12 mm de la correa de altura (mín. 2 mm)».
  - `giro_ranura_disco=20` → M-06.
  - `alto_letra=40` lo frena antes el rango del personalizador [6, 14]. M-01 se comprobó con
    `angulo_marca_sur=270`, que pone la letra sobre la ventana de la llave.
  - `angulo_marca_sur=0` → M-07.
  - `paso_escala=20` → aviso de que la última raya queda en 80°.
- **Comprobación del sentido de la escala**: con la cuna a 45°, la raya larga de 45° queda bajo la punta
  de la aguja (render de cerca), y M-08 lo comprueba para las 7 rayas.
- **STL**: cambiaron las 4 piezas tocadas y se agregó la del disco. Las otras 9, incluida la variante
  cable del brazo, son iguales por vértices a las de `70ee3d6`.
- **Declinación** (NOAA, WMM-2025, consultada el 17/10/2026):
  | Lugar | Declinación |
  |---|---|
  | Buenos Aires | −10,3° |
  | Córdoba | −7,2° |
  | Salta | −9,4° |
  | Mendoza | −2,0° |
  | Ushuaia | +11,6° |

  El signo cambia en el sur del país, como anticipaba R8.
- **Visor**: 3,9 MB.
  - Revisado en el Edge sin ventana: el azimut arranca en 180°, el paso 7 muestra el disco y sus
    tornillos, con azimut 0° el láser apunta al lado opuesto de la «S», y el ancho de 600 px se ve
    bien.
  - Las letras y la escala casi no se ven en el visor, porque los grabados de 0,6 mm sin color
    distinto se pierden en el sombreado. Se ven en las capturas de OpenSCAD con render.
- **Capturas**: se regeneraron todas las vistas explotadas (la base aparece desde el paso 1), las 5
  piezas tocadas, el disco nuevo y el conjunto.
- **Pendiente**:
  - Imprimir, armar y hacer la prueba física de [quickstart.md](quickstart.md) §7: el cero con la
    pared, 0°, 45° y 90° con un medidor de inclinación, y la orientación con la brújula.
  - Probar el visor a mano con mouse y dedo.
