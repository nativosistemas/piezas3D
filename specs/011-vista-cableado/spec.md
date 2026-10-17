# Especificación de Funcionalidad: Vista de cableado en el visor 3D del puntero láser

**Rama de la funcionalidad**: `011-vista-cableado`

**Creada**: 2026-10-17

**Estado**: Implementada (pendiente: prueba interactiva en el navegador)

**Amplía**: [005-visor-armado-3d](../005-visor-armado-3d/spec.md),
[007-simulacion-funcionamiento](../007-simulacion-funcionamiento/spec.md),
[008-identificacion-componentes](../008-identificacion-componentes/spec.md),
[009-espacio-conectores](../009-espacio-conectores/spec.md) y
[010-barra-distribucion](../010-barra-distribucion/spec.md)

**Entrada**: Descripción del usuario: "Vista de cableado en el visor 3D del puntero láser. Agregar en
la web de armado un tercer botón "Ver el cableado", junto a "Ver el armado en 3D" y "Ver cómo
funciona", que abra el visor 3D (armado_3d.html#cableado) en un modo nuevo "Cableado": el diseño
completo armado, con la tapa de la electrónica transparente, todos los componentes (ESP32, relé, 2
ULN2003, regulador MP1584EN, barra de distribución, interruptor, power bank, motores, láser) y cada
cable dibujado por separado con su recorrido de pin a pin y sus conectores en cada extremo (Dupont
hembra, ficha JST de los motores, bornera, soldadura, USB). Hoy solo el cable del láser está
modelado; los Dupont son un bloque gris de espacio reservado ("conectores") y los recorridos de los
cables de los motores se calculan (recorrido_cable_alt/az) pero no se dibujan. Cada conexión de la
tabla de la guía (sección 5.4 Conexiones y Recorrido de los cables) se modela en el ensamblaje como
un cable con color por función (+5 V rojo, GND negro, cada señal con su color); el visor muestra una
lista de conexiones agrupadas por placa, y al pasar el puntero o tocar un cable (o su renglón en la
lista) se resalta y aparece su etiqueta, por ejemplo "Dupont: ESP32 GPIO 19 → ULN2003 altura IN1".
Fuente única: la tabla de conexiones de la guía y el ensamblaje; una comprobación verifica que cada
conexión de la guía tenga su cable modelado y que los cables no atraviesen placas, la tapa ni la
plataforma. Regenerar visor y web."

## Escenarios de usuario y pruebas *(obligatorio)*

### Historia de usuario 1 - Ver todo el cableado armado (Prioridad: P1)

Una persona llega al paso de la electrónica y no entiende por dónde va cada cable. En la web de
armado toca «Ver el cableado». El visor 3D se abre con el aparato completo, la tapa de la electrónica
transparente y cada cable dibujado por separado, desde el pin de una placa hasta el de la otra, con
el conector de cada punta. Gira la vista y acerca la cámara para ver cómo quedan los Dupont sobre las
placas, los cables de los motores entrando bajo la tapa y el cable del power bank por el conducto.

**Por qué esta prioridad**: es el pedido. Hoy la guía describe las conexiones con un esquema de texto
y una tabla, y el visor muestra los conectores como un bloque gris; nadie ve dónde termina cada cable.

**Prueba independiente**: se abre la web, se toca el botón nuevo y el visor muestra el conjunto
armado con todos los cables de la tabla de conexiones de la guía, cada uno de pin a pin.

**Escenarios de aceptación**:

1. **Dado** la web de armado del puntero láser, **cuando** se mira la sección de instrucciones paso a
   paso, **entonces** hay un tercer botón «Ver el cableado» junto a «Ver el armado en 3D» y «Ver cómo
   funciona», con una línea que dice qué muestra.
2. **Dado** el botón, **cuando** se toca, **entonces** el visor se abre en el modo Cableado con el
   conjunto completo armado y la tapa de la electrónica transparente.
3. **Dado** el modo Cableado, **cuando** se cuentan los cables dibujados, **entonces** hay uno por
   cada conexión de la tabla de la guía, y cada uno empieza y termina en el pin o borne que dice la
   guía.
4. **Dado** un cable, **cuando** se acerca la cámara a sus puntas, **entonces** se ve el conector de
   cada extremo según su tipo (Dupont hembra, ficha del motor, bornera, soldadura o enchufe USB).
5. **Dado** el visor ya abierto en otro modo, **cuando** se elige Cableado en sus pestañas o se abre
   el enlace con `#cableado`, **entonces** cambia a ese modo sin recargar.

---

### Historia de usuario 2 - Saber qué es cada cable (Prioridad: P2)

Mientras conecta, la persona tiene un Dupont en la mano y quiere saber a qué pin va. En el visor pasa
el puntero (o toca, en el celular) un cable: se resalta y aparece una etiqueta como «Dupont: ESP32
GPIO 19 → ULN2003 altura IN1». También puede recorrer la lista de conexiones del panel, agrupada por
placa, y al señalar un renglón se resalta su cable en la escena.

**Por qué esta prioridad**: ver los cables sirve poco si no se puede identificar cada uno; con 25 o
más cables juntos bajo la tapa, el color solo no alcanza.

**Prueba independiente**: se señala cada cable en la escena y cada renglón de la lista, y en todos los
casos se resalta el cable correcto con su etiqueta de origen y destino.

**Escenarios de aceptación**:

1. **Dado** el modo Cableado, **cuando** se señala un cable en la escena, **entonces** se resalta y
   su etiqueta dice el tipo de conexión, el origen (placa y pin) y el destino (placa y pin).
2. **Dado** el panel del modo Cableado, **cuando** se mira la lista, **entonces** están todas las
   conexiones agrupadas por placa, cada una con su color.
3. **Dado** un renglón de la lista, **cuando** se señala o se toca, **entonces** se resalta su cable en
   la escena.
4. **Dado** los colores de los cables, **cuando** se comparan, **entonces** todos los de +5 V son
   rojos, todos los de GND negros, y las señales usan colores distinguibles entre sí dentro de una
   misma placa.
5. **Dado** una placa o componente (no un cable), **cuando** se señala en el modo Cableado,
   **entonces** se identifica como en el modo de armado (feature 008).

---

### Historia de usuario 3 - Que el cableado dibujado sea el real (Prioridad: P3)

Quien mantiene el diseño cambia una conexión en la guía (por ejemplo, mueve una señal a otro GPIO) o
mueve una placa en la plataforma. Al regenerar, la validación avisa si la guía y el modelo dejaron de
coincidir o si un cable quedó atravesando una placa, la tapa o la plataforma.

**Por qué esta prioridad**: un dibujo de cables que no coincide con la guía es peor que no tenerlo,
porque la persona conecta lo que ve. Es lo que garantiza las dos historias anteriores en el tiempo.

**Prueba independiente**: se cambia a propósito una conexión solo en la guía, o solo en el modelo, y
la validación falla nombrando la conexión; se deshace y pasa.

**Escenarios de aceptación**:

1. **Dado** una conexión que figura en la tabla de la guía pero no en el modelo (o al revés),
   **cuando** se regenera, **entonces** la validación falla y nombra esa conexión.
2. **Dado** un cable cuyo recorrido atraviesa una placa, la tapa, la plataforma u otro componente
   sólido, **cuando** se valida, **entonces** falla y nombra el cable y aquello con lo que choca.
3. **Dado** un cable cuyo recorrido es más largo que el cable que se compra (Dupont de 20 cm o cable
   de fábrica del motor), **cuando** se valida, **entonces** falla y dice cuánto falta.
4. **Dado** el diseño sin cambios, **cuando** se regenera, **entonces** la validación pasa y el visor y
   la web quedan al día.

---

### Casos límite

- **Cables que giran**: el cable del láser ya se dobla con el eje de altura (feature 007). Los cables
  de los motores y la electrónica giran en azimut con la plataforma, así que no cambian; el cable del
  power bank no cruza el eje de azimut (guía 5.4). El modo Cableado muestra el aparato quieto en la
  posición de reposo; no simula movimiento.
- **Conexiones sin pin macho**: la bornera COM del relé y el pad IN− del regulador llevan un Dupont
  con un extremo cortado (guía 5.4); ese extremo se dibuja como bornera o soldadura, no como Dupont.
- **Conexiones soldadas sin cable propio**: la resistencia de 10 kΩ del relé y las uniones de la
  barra por debajo se dibujan como componente o soldadura, no como un cable más de la lista, salvo que
  la guía las liste como conexión.
- **Pines de reserva** de la barra: se ven libres, sin cable.
- **Cable sobrante**: los cables comprados (Dupont de 20 cm, cable de fábrica del motor de 230 mm)
  son más largos que su recorrido; el sobrante se representa recogido en el hueco para cable sobrante
  de la tapa (feature 009) o se omite, pero el largo informado es el del recorrido.
- **Bloque gris de espacio reservado**: en el modo Cableado no se muestra (lo reemplazan los cables
  reales); en el modo de armado sigue como hasta ahora.
- **Diseños sin cableado** (por ejemplo, el soporte de taladro): su web no muestra el botón y su
  visor no tiene la pestaña.
- **Pantalla de celular**: los cables bajo la tapa son finos; tocar un renglón de la lista es la forma
  segura de identificarlos.
- **Tamaño del visor**: los cables suman mallas; el visor sigue cumpliendo el límite de tamaño de la
  feature 005.

## Requisitos *(obligatorio)*

### Requisitos funcionales

- **FR-001**: La web de armado DEBE mostrar un botón «Ver el cableado» junto a los dos existentes,
  solo para los diseños cuyo visor tiene cableado, que abra el visor en el modo Cableado.
- **FR-002**: El visor DEBE tener un modo Cableado, seleccionable desde sus pestañas y desde la
  dirección `#cableado`, que muestre el conjunto completo armado con la tapa de la electrónica
  transparente y sin el bloque de espacio reservado de los conectores.
- **FR-003**: El ensamblaje DEBE modelar como elementos todos los componentes que intervienen en las
  conexiones de la guía, incluidos los que hoy no están (como mínimo el interruptor general, el cable
  USB del power bank y la resistencia de 10 kΩ del relé), con su nombre y tipo para el visor.
- **FR-004**: El ensamblaje DEBE modelar cada conexión de la tabla de la guía (sección 5.4) como un
  cable propio, con su recorrido de pin a pin, que siga los recorridos de la guía (conducto,
  canales, brida) y un conector dibujado en cada extremo según su tipo.
- **FR-005**: Cada cable DEBE tener un color por función: +5 V rojo, GND negro, y las señales con
  colores que se distingan entre sí dentro de una misma placa. Los cables de los motores y el del
  láser conservan los colores de sus hilos reales.
- **FR-006**: Cada cable DEBE tener una etiqueta con el tipo de conexión, el origen y el destino (placa
  y pin o borne), y el visor DEBE resaltarlo y mostrarla al señalarlo en la escena o en la lista.
- **FR-007**: El panel del modo Cableado DEBE listar todas las conexiones agrupadas por placa, con el
  color de cada cable.
- **FR-008**: La tabla de conexiones de la guía DEBE ser la fuente de qué se conecta con qué. Una
  comprobación DEBE fallar, nombrando la conexión, si la guía y el modelo no tienen exactamente las
  mismas conexiones.
- **FR-009**: Una comprobación DEBE fallar, nombrando el cable y el obstáculo, si un recorrido
  atraviesa una placa, la tapa, la plataforma u otro componente sólido, salvo en sus puntas (el pin o
  borne donde termina).
- **FR-010**: Una comprobación DEBE fallar, diciendo cuánto falta, si un recorrido es más largo que el
  cable que indica la lista de materiales para esa conexión.
- **FR-011**: Los cables no DEBEN cambiar ninguna pieza impresa: las STL quedan iguales, salvo que la
  comprobación de choques encuentre un problema real que obligue a corregir una pieza (eso se informa
  en el plan).
- **FR-012**: El visor y la web DEBEN regenerarse; los modos Armado y Funcionamiento, las vistas
  explotadas y los enlaces existentes siguen funcionando igual.

### Entidades clave

- **Conexión**: un renglón de la tabla de la guía; tiene origen (placa y pin), destino (placa y pin),
  función (+5 V, GND o señal) y tipo de conexión en cada extremo (Dupont, ficha, bornera, soldadura,
  USB).
- **Cable**: la representación de una conexión en el modelo; tiene recorrido, largo, color, conector
  en cada punta y etiqueta.
- **Componente de cableado**: placa o pieza comprada donde terminan los cables (ESP32, relé, ULN2003,
  regulador, barra, interruptor, power bank, motores, láser), con la posición de cada pin usado.

## Criterios de éxito *(obligatorio)*

### Resultados medibles

- **SC-001**: El 100 % de las conexiones de la tabla de la guía tiene su cable en el modo Cableado, y
  no hay cables que no estén en la guía.
- **SC-002**: Una persona encuentra a qué pin va un Dupont cualquiera en menos de 30 segundos desde
  que abre el modo Cableado.
- **SC-003**: Ningún cable atraviesa una placa, la tapa ni la plataforma, comprobado por el diseño y
  no a ojo.
- **SC-004**: Cambiar una conexión solo en la guía o solo en el modelo hace fallar la regeneración en
  una sola pasada, con un mensaje que nombra la conexión.
- **SC-005**: El visor abre el modo Cableado desde la web en el mismo tiempo que hoy abre el modo de
  armado (sin demora notable) y sigue dentro de su límite de tamaño.

## Supuestos

- Las conexiones son las de la guía al cerrar la 010: 5 de +5 V y 5 de GND desde la barra, 4 señales
  a cada ULN2003, la señal del relé, relé NA → regulador IN+, las entradas de la barra desde el
  interruptor y el cable USB, los cables de fábrica de los motores a su ULN2003 y el cable del láser
  (ya modelado).
- El recorrido de cada cable lo define el diseño con puntos de paso razonables (como el del cable del
  láser y los de los motores), no una simulación física del cable; el objetivo es que se entienda y
  que no choque, no reproducir la forma exacta de un cable real.
- El modo Cableado muestra el aparato en reposo, sin simulación de movimiento ni animación de armado.
- El USB del ESP32 se usa solo para programarlo: no se dibuja un cable conectado, pero su abertura en
  la tapa sigue siendo la de la 009.
- Las vistas explotadas PNG de la guía no muestran los cables, que se ven en el visor 3D. Solo se
  regeneran las del paso de la electrónica en adelante, porque el interruptor y la resistencia del
  relé pasan a ser piezas del modelo.
- No hay cargas mecánicas nuevas: no hace falta simulación FEM (justificación en el plan).
- Las otras webs de armado sin electrónica no cambian.
