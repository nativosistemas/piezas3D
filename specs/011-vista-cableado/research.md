# Investigación: Vista de cableado en el visor 3D (011)

Decisiones de la fase 0. Las medidas citadas salen de `src/puntero_laser_parametros.scad` y de
`src/puntero_laser_ensamblaje.scad` al cerrar la 010 (commit `ed17342`).

## R1. Cómo se declara un cable en el ensamblaje

**Decisión**: una lista opcional nueva, `cables`, en el ensamblaje del diseño (contrato de
[contracts/ensamblaje.md](contracts/ensamblaje.md)). Cada cable es un dato: identificador, desde,
hasta, función, grupo, hilos (colores), diámetro, recorrido (lista de puntos), tipo de conector de cada
extremo y largo comprado. Los cables **no** entran en `elementos`. La biblioteca común
(`src/armado_comun.scad`) los valida, los entrega al visor por `echo` y tiene un módulo que los dibuja
en OpenSCAD para revisarlos.

**Por qué**: un cable es una polilínea con dos conectores. Como dato, el visor construye su tubo en
el navegador a partir de los puntos, sin exportar 26 mallas con OpenSCAD. Así el visor casi no crece
(unos 30 kB de puntos frente a 3,8 MB actuales) y la regeneración no se alarga. Las comprobaciones de
choque y de largo se hacen sobre los mismos puntos, así que lo que se dibuja es lo que se comprueba.

**Alternativas descartadas**:
- *Un elemento por cable en `elementos`*, dibujado con `cordon()` como el cable del láser: 26 mallas
  más que exportar, la lista de nombres y los pasos de armado se llenan de cables, y el visor no
  puede agruparlos por placa ni distinguir un cable de una pieza.
- *Dibujar los cables solo en la plantilla del visor*, con puntos escritos a mano en el HTML: el
  visor dejaría de salir del ensamblaje (Principio V) y los puntos no seguirían a los parámetros.

## R2. Fuente de qué se conecta con qué

**Decisión**: la guía suma, en la sección 5.4, una **Tabla de cables** con un renglón por cable:
número, desde, hasta, conectores y función ([contracts/guia.md](contracts/guia.md)). El esquema de
texto y la tabla de pines de la barra se quedan como están, porque explican el circuito. El
ensamblaje declara los mismos cables con el **mismo texto** de desde y hasta. `generar_visor.py`
compara las dos listas y falla nombrando el renglón que sobra o falta en cada lado.

**Por qué**: la spec pide que la guía sea la fuente de qué se conecta con qué (FR-008), y la persona
que arma lee la guía, no el `.scad`. El esquema de texto no se puede leer de forma fiable (flechas,
ramas `┬`, notas entre corchetes), y una tabla sí. Comparar textos exactos es simple y da mensajes
claros.

**Alternativas descartadas**:
- *Generar la tabla de la guía desde el ensamblaje*: nunca habría diferencias, pero la guía dejaría de
  ser la fuente y la tabla quedaría como texto generado dentro de un archivo escrito a mano (la única
  parte generada de la guía hoy es la lista de materiales, y sale del CSV).
- *Comparar solo la cantidad de cables*: no detecta una señal movida de GPIO.

## R3. Qué cables hay

**Decisión**: 26 cables, en 7 grupos (el grupo es la placa o el componente donde se los busca en la
lista del visor).

| Grupo | Cables | Extremos |
|---|---|---|
| Alimentación (power bank e interruptor) | USB +5 V: power bank → interruptor; USB GND: power bank → barra GND (entrada); interruptor → barra +5 V (entrada) | USB-A / soldadura; soldadura / soldadura |
| Barra +5 V | → ESP32 VIN, → ULN2003 azimut +, → ULN2003 altura +, → relé VCC, → relé COM | Dupont / Dupont; el de COM, Dupont / bornera |
| Barra GND | → ESP32 GND, → ULN2003 azimut −, → ULN2003 altura −, → relé GND, → regulador IN− | Dupont / Dupont; el de IN−, Dupont / soldadura |
| ESP32 → ULN2003 azimut | GPIO 16, 17, 18, 19 → IN1…IN4 | Dupont / Dupont |
| ESP32 → ULN2003 altura | GPIO 25, 26, 27, 33 → IN1…IN4 | Dupont / Dupont |
| ESP32 → relé y regulador | GPIO 23 → relé IN; relé NA → regulador IN+ | Dupont / Dupont; bornera / soldadura |
| Motores y láser | Motor azimut → ULN2003 azimut; motor altura → ULN2003 altura; regulador OUT± → láser | ficha JST / ficha JST (cable de fábrica); soldadura / pila falsa y tapa trasera |

- **Cable USB del power bank**: tiene dos hilos que salen del mismo enchufe y van juntos por el
  conducto. Se modelan como dos cables que comparten el primer tramo, desplazados un diámetro entre
  sí. Así cada renglón de la guía tiene un solo origen y un solo destino.
- **Cables de los motores**: el cable de fábrica tiene 5 hilos (azul, rosa, amarillo, naranja, rojo).
  Se dibuja como un cable de 5 hilos paralelos con esos colores (FR-005), con el recorrido que ya
  calcula el ensamblaje (`recorrido_cable_alt`, `recorrido_cable_az`; 009, R6).
- **Cable del láser**: el tramo que acompaña al láser ya es un elemento (`cable_laser`) y un
  deformable de la simulación; el cable lo **referencia** (campo `elemento`) y el visor usa su malla en
  la posición de reposo. El tramo fijo (del regulador, bajo los ULN2003, por el conducto y subiendo por
  la cara exterior del brazo cable) es el recorrido del mismo cable. En el conducto, los hilos del
  láser van del lado +Y y los del USB del −Y, para que no se crucen.
- **Resistencia de 10 kΩ** (entre IN y GND del relé) y **puentes de la barra** (por debajo): son
  soldaduras sobre una misma placa, no cables entre componentes. La resistencia pasa a ser un elemento
  comprado (`resistencia_rele`, FR-003); los puentes no se dibujan.
- **USB del ESP32**: solo se usa para programar, así que no lleva cable (supuesto de la spec).

**Elementos nuevos** en el catálogo: `interruptor` (cuerpo, buje y palanca, en su soporte) y
`resistencia_rele`. Los dos son comprados y ya están en la lista de materiales, así que no hay
renglones nuevos. Entran en la tabla de pasos del paso donde se colocan (16), cuya vista explotada se
regenera.

## R4. Dónde está cada pin

**Decisión**: cada placa declara sus pines como constantes con nombre en el ensamblaje (sección de
parámetros), en coordenadas locales medidas desde una esquina de la placa. Las posiciones globales se
calculan con la misma posición de la placa que ya usa `placa()`. Los valores de referencia y la
orientación de cada placa en su soporte son los siguientes:

| Placa | Pines usados | Referencia | Orientación en su soporte |
|---|---|---|---|
| ESP32 DevKit de 38 pines | Columna −X: 5V (VIN, pin 19), GND (pin 14), GPIO 33, 25, 26, 27 (pines 8 a 11). Columna +X: GPIO 23 (pin 2), 19, 18 (8 y 9), 17, 16 (11 y 12) | Pinout de la DevKitC V4: 19 pines por lado a 2,54 mm, filas separadas 25,4 mm (`separacion_filas_esp32`) | USB hacia −Y (hacia la abertura de la tapa, como en la 009); pin 1 de cada columna hacia +Y |
| ULN2003 | IN1…IN4 (tira de 4 en el borde +X), − y + (tira de 2 en la esquina +X, +Y), ficha del motor (borde −X, centrada) | Placa común de 35 × 32 mm | Ficha del motor hacia −X (la pared por donde entran los cables de los motores, guía 5.4) y entradas hacia +X (hacia el ESP32) |
| Relé de 1 canal | VCC, GND, IN (tira de 3 en el borde −Y); bornera COM, NA, NC (borde +Y) | Módulo de 50 × 26 mm | Tira hacia el ESP32 (−Y) y bornera hacia el hueco del sobrante (+Y) |
| MP1584EN | IN+, IN− (borde −Y), OUT+, OUT− (borde +Y), en las esquinas | Módulo de 22 × 17 mm | Entrada hacia la barra |
| Barra de distribución | Pines 1 a 5 y entrada (agujero 8) de cada tira | Tabla de la guía 5.4 (010) | La de la 010 |

**Por qué**: las placas comerciales varían un poco y la spec pide que se entienda y que no choque, no
una réplica exacta (supuesto de la spec). Con constantes con nombre el dibujo sigue a las medidas de la
placa (`uln2003_largo`, `esp32_largo`, …) y no hay números mágicos (Principio I). La orientación elegida
acorta los cables: las entradas de los ULN2003 miran al ESP32, y la ficha de los motores mira a la
pared por donde entran sus cables.

**Alternativa descartada**: *parámetros editables (con rango) por pin*. Son más de 40 valores que nadie
va a medir y que solo cambian el dibujo. Si una placa real tiene otra disposición, el armado no cambia:
la guía conecta por nombre de pin.

La guía (paso 16) dice en qué sentido va cada placa en su soporte, porque ahora el dibujo lo supone.

## R5. Regla de recorrido

**Decisión**: recorridos ortogonales con puntos de paso calculados por una función del ensamblaje,
no escritos a mano:

1. **Salida**: del pin, en la dirección del conector (hacia arriba en las placas bajas, hacia abajo en
   el ESP32), hasta el final del cuerpo del Dupont (`alto_tira_pines + largo_dupont`), más la curva
   (`radio_curva_cable`).
2. **Nivel de recorrido**: los cables de arriba van por un plano horizontal entre lo más alto de los
   conectores (`alto_conectores_arriba`) y el techo de la tapa. Hoy queda la holgura de techo de 2 mm,
   así que el plano va a `diametro_cable_dupont/2` sobre los conectores. Los cables que bajan del ESP32
   van por debajo de la placa, hacia el centro (la franja que la 009 reservó para su curva), y salen
   por los costados ±Y del soporte, entre los postes en L.
3. **Llegada**: el tramo simétrico hasta el pin de destino.
4. **Varios cables por el mismo lugar**: se desplazan `diametro_cable_dupont` entre sí según su
   número de pin, para que no se dibujen superpuestos.

Los cables de los motores usan los recorridos de la 009. El USB va por el conducto elevado
(`y_conducto`).

**Por qué**: un recorrido ortogonal por niveles es como se ordena un cableado real bajo una tapa, se
calcula desde las posiciones de los pines y es fácil de comprobar. La forma exacta del cable real no
importa (supuesto de la spec).

**Riesgo**: con 2 mm de holgura de techo, el plano de recorrido puede no tener lugar para cruzar
encima de los Dupont de otra placa. En ese caso la comprobación de R6 lo dice, y hay dos salidas en
este orden: (a) pasar ese tramo por los pasillos entre soportes (`holgura_zonas`); (b) subir
`holgura_techo_tapa`. La (b) cambia la STL de la tapa y la caja de la plataforma, y FR-011 obliga a
informarlo. Se evalúa en la implementación con los números reales.

## R6. Comprobaciones de choque y de largo

**Decisión**: dos comprobaciones en OpenSCAD, con `assert` en la biblioteca común y funciones
genéricas, que el ensamblaje llama sobre la lista `cables`.

- **Choque** (FR-009): cada tramo del recorrido se muestrea cada `diametro/2`, y cada muestra se
  compara con una lista de **obstáculos**, que son cajas `[mín, máx, nombre]` del ensamblaje: cada
  placa, los postes y apoyos de los soportes, la plataforma (debajo de `z_sup`), el interruptor, el
  power bank y las paredes y el techo de la tapa; las muestras dentro de un paso declarado (el
  conducto y las entradas de los motores en la pared −X) no chocan. Una muestra choca si queda a menos de `diametro/2` de un obstáculo. Las muestras del primer y
  del último tramo no se comparan con la placa de su propio extremo, porque el cable nace en un pin
  de esa placa.
- **Largo** (FR-010): `largo_polilinea(recorrido) + reserva ≤ largo comprado`. El largo comprado es
  200 mm para los Dupont de la lista de materiales y 230 mm (`largo_cable_motor`) para los motores, con
  una `reserva_cable` de 10 mm. Para los cables cortados de un rollo (silicona de 26 AWG, USB)
  se informa el largo pero no se limita. La V-26 de los motores pasa a ser un caso de esta regla, con
  el mismo mensaje.

Mensajes: `cables: '<id>' atraviesa <obstáculo> cerca de [x, y, z]` y `cables: '<id>' mide <L> mm y
el cable comprado <C> mm (faltan <F> mm)`.

**Por qué**: muestrear contra cajas es suficiente porque los obstáculos de la zona de la electrónica
son prismas, y en OpenSCAD cuesta poco: 26 cables × unas 200 muestras × unos 20 obstáculos son unas
100 000 comparaciones. Que las cajas salgan de las mismas variables que dibujan las piezas evita una
segunda geometría a mano.

**Alternativas descartadas**:
- *Intersección booleana del tubo con las piezas* (`intersection()` y medir el volumen): OpenSCAD no
  devuelve volúmenes a un `assert`. Habría que exportar y medir con un script, que es mucho más lento.
- *Comprobar en Python*: la constitución pide que el ensamblaje compruebe sus choques con `assert`.

## R7. El modo Cableado en el visor

**Decisión**: una tercera pestaña, «Cableado», con su panel ([contracts/visor.md](contracts/visor.md)).
- **Escena propia** (`raizCableado`): las mallas del catálogo en su posición final, todas opacas salvo
  las de `transparentes_cableado` (la tapa); las de `ocultos_cableado` no se dibujan (el bloque gris
  `conectores`). Encima, los cables: un tubo por hilo, construido en el navegador desde los puntos, con
  las esquinas redondeadas con `radio_curva_cable`, y un conector por extremo según su tipo, con las
  medidas de `conectores_cableado`.
- **Panel**: la lista de cables agrupada por grupo, en el orden de la guía. Cada renglón muestra la
  muestra de color y el nombre. Señalar un renglón resalta su cable, como la lista de piezas de la 008.
- **Etiqueta**: el nombre del cable («Dupont: ESP32 GPIO 19 → ULN2003 altura IN1») y, debajo, «Cable ·
  ≈ 74 mm». Las piezas se identifican como en la 008.
- **Pestañas**: aparecen si el visor tiene simulación **o** cableado, y cada una solo si su modo
  existe. `#cableado` abre el modo; `#paso-N` y `#funcionamiento` siguen igual.
- **Atenuar**: un interruptor «Atenuar las piezas», encendido por defecto, deja las piezas impresas
  transparentes para que los cables se vean desde cualquier ángulo. Las placas y los componentes
  comprados quedan opacos, porque son donde terminan los cables.

**Por qué**: reutiliza la escena, la selección y la etiqueta de la 008, y el patrón de modos de la 007.
Los tubos en el navegador cuestan unos pocos kB. Atenuar resuelve que la plataforma y los brazos
tapen los cables sin quitar la referencia de dónde está cada cosa.

**Alternativa descartada**: *mostrar solo la electrónica* (sin piezas impresas). Se pierde dónde entra
el cable de cada motor y el recorrido por el conducto.

## R8. Botón de la web

**Decisión**: `generar_web.py` agrega «Ver el cableado» (con la leyenda «Cada cable de pin a pin, con
sus conectores.») después de «Ver cómo funciona», solo si los datos del visor tienen `cableado`,
igual que hoy decide el de Funcionamiento con `simulacion`.

## R9. Simulación FEM

**Decisión**: **no aplica**. Los cables y los dos elementos nuevos son comprados y no cargan ninguna
pieza. Los cables pesan menos de 15 g en total, ya contados en la masa de las placas (`masa_placas_g`,
006). Si R5 obliga a subir la tapa unos milímetros, la carga del soporte de la tapa no cambia de forma
apreciable: queda dentro del rango de la justificación de la 009.

## R10. Formato de datos del visor

**Decisión**: `VERSION = 4`. `datos.cableado = {cables, grupos, conectores, transparentes, ocultos}`
([data-model.md](data-model.md#3-en-el-visor)). Un visor con la versión 3 se regenera solo, porque
cambió la versión. Los diseños sin `cables` no tienen la clave y su visor queda igual salvo el número
de versión.
