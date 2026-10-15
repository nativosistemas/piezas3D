# Especificación de Funcionalidad: Simulación de funcionamiento en el visor 3D

**Rama de la funcionalidad**: `007-simulacion-funcionamiento`

**Creada**: 2026-10-15

**Estado**: Implementada (pendiente en un navegador real: tiempos del modo automático a ×1 y la
prueba de comprensión SC-004)

**Amplía**: [005-visor-armado-3d](../005-visor-armado-3d/spec.md)

**Entrada**: Descripción del usuario: "¿Se puede hacer una web donde también simule el movimiento de
los motores y el encendido del láser?". Propuesta acordada: agregar al visor 3D de armado
(`specs/<NNN>/web/armado_3d.html`, generado por `scripts/generar_visor.py` desde
`src/<diseño>_ensamblaje.scad`) un modo "Funcionamiento" que simule el movimiento de los motores y el
encendido del láser del puntero láser estelar. Cadena cinemática: la base queda fija; el resto gira
en azimut alrededor del eje vertical; la cuna, el láser y lo que va montado en él, la tuerca del
muñón, el perno del lado cable y la polea de altura giran en altura alrededor del eje horizontal
(rango −10° a 95°). Las poleas de 20 dientes y los ejes de los motores giran según la relación de
cada correa. El láser muestra un haz que se enciende y apaga. Controles: deslizadores de azimut y
altura, botón de encendido del láser y un modo automático que recorre una secuencia de apuntes. Los
ejes, pivotes, grupos móviles y relaciones de transmisión deben salir del ensamblaje (fuente única,
como los pasos), no repetirse en la página. El cable del láser y las correas pueden quedar
aproximados. Debe seguir funcionando sin internet ni servidor, en un solo archivo, y servir para
otros diseños con partes móviles.

## Aclaraciones

### Sesión 2026-10-15

- P: ¿Qué recorre el modo automático? → R: objetivos de demostración declarados en el ensamblaje;
  las estrellas reales (fecha, hora y lugar) quedan para una funcionalidad posterior (FR-017).

## Escenarios de usuario y pruebas *(obligatorio)*

### Historia de usuario 1 - Mover el aparato a mano y ver qué gira (Prioridad: P1)

Una persona que está por armar (o ya armó) el puntero láser abre el visor y pasa al modo
"Funcionamiento". Ve el aparato completo, armado. Mueve el deslizador de azimut y todo lo que está
sobre la base gira alrededor del eje vertical, con el motor de azimut y su polea pequeña girando
mucho más rápido que la plataforma. Mueve el deslizador de altura y la cuna con el láser se inclina
entre los dos topes del diseño, mientras la polea de altura gira con ella y la polea del motor de
altura gira más rápido. Gira la vista para mirar cómo trabaja cada correa.

**Por qué esta prioridad**: es el núcleo del pedido y lo que más ayuda a entender el aparato: qué
pieza mueve a cuál, qué queda fijo y cuánto más rápido gira cada motor que el eje que mueve.

**Prueba independiente**: con solo esta historia, una persona que no conoce el diseño mueve los dos
deslizadores y explica qué motor mueve cada eje y qué partes quedan fijas.

**Escenarios de aceptación**:

1. **Dado** el visor de un diseño con partes móviles, **cuando** la persona elige el modo
   "Funcionamiento", **entonces** ve el conjunto completo armado, en sus colores, con un control por
   cada eje móvil, nombrado y con su valor en grados.
2. **Dado** el modo "Funcionamiento", **cuando** la persona mueve el control de azimut, **entonces**
   todas las piezas que no son de la base giran juntas alrededor del eje vertical y la base no se
   mueve.
3. **Dado** el modo "Funcionamiento", **cuando** la persona mueve el control de altura, **entonces**
   la cuna, el láser y lo montado en él giran juntos alrededor del eje horizontal, sin despegarse de
   la horquilla, y el resto no se mueve en altura.
4. **Dado** un eje movido, **cuando** se observa su motor, **entonces** la polea del motor gira en
   el sentido que corresponde y tantas veces más que el eje como indica la relación de su correa
   (4 a 1 en el puntero láser).
5. **Dado** el control de altura, **cuando** la persona intenta pasar los topes del diseño
   (−10° y 95°), **entonces** el movimiento se detiene en el tope.
6. **Dado** cualquier posición, **cuando** la persona vuelve al modo de armado, **entonces** los
   pasos se ven igual que antes de usar la simulación.

---

### Historia de usuario 2 - Encender y apagar el láser (Prioridad: P1)

En el modo "Funcionamiento", la persona toca el botón del láser: sale un haz verde de la punta del
láser, en la dirección en que apunta, y se nota un brillo en la salida. Al mover los ejes, el haz
acompaña al láser. Lo vuelve a tocar y el haz desaparece.

**Por qué esta prioridad**: el láser es la razón de ser del aparato; sin el haz no se entiende hacia
dónde apunta.

**Prueba independiente**: se enciende el láser con la altura a 45° y el haz sale de la punta, en la
dirección del eje del láser; se cambia la altura y el haz la sigue.

**Escenarios de aceptación**:

1. **Dado** el láser apagado, **cuando** la persona lo enciende, **entonces** aparece el haz desde
   la salida del láser y en la dirección de su eje, y el control muestra que está encendido.
2. **Dado** el láser encendido, **cuando** se mueve cualquier eje, **entonces** el haz sigue saliendo
   de la punta en la dirección del láser en todo momento.
3. **Dado** el láser encendido, **cuando** la persona lo apaga o sale del modo "Funcionamiento",
   **entonces** el haz desaparece.
4. **Dado** el visor recién abierto, **cuando** se entra al modo "Funcionamiento", **entonces** el
   láser empieza apagado.

---

### Historia de usuario 3 - Recorrido automático de apuntes (Prioridad: P2)

La persona activa el modo automático: el aparato apunta a un objetivo tras otro, moviendo los dos
ejes a la velocidad real de los motores, enciende el láser al llegar, lo mantiene unos segundos, lo
apaga y pasa al siguiente. Un texto muestra hacia qué objetivo va y en qué posición está.

**Por qué esta prioridad**: muestra el aparato funcionando como lo hará con el ESP32, incluido que el
láser solo se enciende cuando está quieto en el objetivo. Es valioso pero depende de las historias 1
y 2.

**Prueba independiente**: se activa el modo automático y se ve recorrer al menos tres objetivos
seguidos, con el láser apagado mientras se mueve y encendido al llegar.

**Escenarios de aceptación**:

1. **Dado** el modo automático activado, **cuando** se llega a un objetivo, **entonces** el láser se
   enciende, queda encendido un tiempo fijo y se apaga antes de moverse al siguiente.
2. **Dado** el modo automático, **cuando** el aparato se mueve entre dos objetivos, **entonces** los
   dos ejes se mueven a la vez, a una velocidad que no supera la máxima del diseño, y los controles
   manuales muestran la posición actual.
3. **Dado** el modo automático, **cuando** la persona toca cualquier control manual o lo desactiva,
   **entonces** el recorrido se detiene donde está y el láser se apaga.
4. **Dado** un objetivo de azimut del otro lado (por ejemplo, de 350° a 10°), **cuando** se mueve
   hacia él, **entonces** el azimut toma el camino que el aparato puede hacer de verdad (sin cruzar
   un límite de giro si lo hubiera, o por el camino más corto si no lo hay).
5. **Dado** el modo automático, **cuando** la persona elige un multiplicador de velocidad, **entonces**
   el movimiento se acelera en esa proporción y el visor indica que no es la velocidad real.

---

### Historia de usuario 4 - La simulación sale sola desde el ensamblaje (Prioridad: P1)

Quien diseña declara en el ensamblaje los ejes móviles (qué elementos mueve cada uno, alrededor de
qué eje y punto, en qué rango y dentro de qué otro eje), los motores con su relación de transmisión y
los emisores de luz. Genera la web como siempre y el visor incluye el modo "Funcionamiento". Si
cambia una cota que mueve un pivote, la relación de una correa o un rango, regenera y la simulación
queda al día; la comprobación de la puerta 5 avisa si se olvidó.

**Por qué esta prioridad**: si los ejes y relaciones se copiaran en la página, la simulación
mentiría apenas cambie el diseño. Declararlo en el ensamblaje lo mantiene coherente y sirve para
cualquier diseño futuro con partes móviles.

**Prueba independiente**: se cambia en los parámetros del puntero láser la cantidad de dientes de la
polea conducida, se regenera y la polea del motor gira en la nueva proporción sin tocar nada más;
la caja de pilas, que no declara ejes, genera su visor igual que antes y sin modo "Funcionamiento".

**Escenarios de aceptación**:

1. **Dado** un ensamblaje que declara ejes móviles, **cuando** se genera la web, **entonces** el
   visor tiene el modo "Funcionamiento" con esos ejes, motores y emisores.
2. **Dado** un ensamblaje sin ejes móviles declarados, **cuando** se genera la web, **entonces** el
   visor es igual que antes, sin el modo "Funcionamiento" y sin error.
3. **Dado** un eje declarado con un elemento que no existe en el catálogo, un rango invertido, un
   eje nulo o un elemento asignado a dos ejes, **cuando** se genera el visor, **entonces** la
   generación se detiene con un mensaje que nombra el eje y el problema.
4. **Dado** un cambio en un pivote, una relación o un rango, **cuando** se corre la comprobación de
   la puerta 5 sin regenerar, **entonces** falla e indica que el visor está desactualizado.
5. **Dado** un diseño con ejes declarados, **cuando** se generan las capturas de la guía y se muestra
   el modo de armado, **entonces** no cambian respecto de antes de declararlos.

---

### Casos límite

- **Choques**: la simulación no detecta choques entre piezas; se apoya en los rangos declarados, que
  el ensamblaje ya valida con sus comprobaciones en los extremos.
- **Elementos que se deforman** (el cable del láser, las correas): se muestran en una posición
  aproximada; el cable acompaña al grupo que lo sostiene en la mayor parte de su recorrido y las
  correas quedan quietas mientras giran sus poleas (los dientes no se animan). La página lo aclara.
- **Elementos que dependen del ángulo de las capturas** (la cuna inclinada a 45°): en el modo de
  armado se ven como hoy; en el modo "Funcionamiento" arrancan en la misma posición de las capturas.
- **Ejes encadenados**: un eje que va montado sobre otro (la altura sobre el azimut) se mueve con él;
  el orden de la cadena sale de la declaración.
- **Azimut sin límite**: si el diseño no declara rango de azimut, el control da la vuelta completa
  sin saltos al pasar de 359° a 0°.
- **Pestaña en segundo plano o celular lento**: el movimiento automático se basa en el tiempo real,
  no en la cantidad de cuadros, así que llega al mismo lugar aunque se vea a saltos.
- **Celular angosto (360 px)**: los controles de la simulación entran debajo de la vista 3D, sin
  desplazamiento horizontal, y se pueden manejar con el dedo.
- **Haz del láser**: se dibuja con un largo fijo, suficiente para ver la dirección; no se calcula
  dónde pega.

## Requisitos *(obligatorio)*

### Requisitos funcionales

**Declaración en el ensamblaje**

- **FR-001**: El ensamblaje de un diseño DEBE poder declarar, de forma opcional, sus ejes móviles:
  nombre legible, elementos que mueve, eje y punto de giro, rango en grados (o sin límite), posición
  de reposo y el eje sobre el que va montado, si lo hay.
- **FR-002**: El ensamblaje DEBE poder declarar motores: el elemento que gira (polea o eje del
  motor), su eje y punto de giro, el eje móvil que impulsa y la relación de transmisión, calculada
  desde los parámetros del diseño (no escrita a mano).
- **FR-003**: El ensamblaje DEBE poder declarar emisores de luz: el elemento que emite, punto de
  salida y dirección, color y el eje móvil que lo lleva.
- **FR-004**: La simulación DEBE partir de la posición en que el catálogo dibuja cada elemento (la
  de las capturas, declarada como reposo del eje) y girarla, sin exportar otra geometría para las
  piezas rígidas; la posición de las capturas y del modo de armado NO DEBE cambiar. Solo los
  elementos que se deforman (el cable) PUEDEN exportarse además en varios ángulos.
- **FR-005**: La generación DEBE detenerse con un mensaje que nombre el eje, motor o emisor y el
  problema si una declaración es inválida: elemento inexistente, elemento en dos ejes, eje nulo,
  rango invertido, relación no positiva o cadena de ejes circular.

**Generación y comprobación**

- **FR-006**: El visor de un diseño con ejes declarados DEBE incluir el modo "Funcionamiento" con el
  mismo comando que genera la web, sin archivos ni ajustes propios del diseño fuera del ensamblaje.
- **FR-007**: Un diseño sin ejes declarados DEBE generar el visor igual que antes, sin el modo
  "Funcionamiento".
- **FR-008**: La comprobación de la puerta 5 DEBE fallar si el visor no corresponde a las
  declaraciones actuales de ejes, motores y emisores.
- **FR-009**: El visor DEBE seguir siendo un solo archivo que funciona sin servidor ni internet, y
  respetar el tamaño máximo vigente (10 MB por diseño).

**Simulación**

- **FR-010**: El modo "Funcionamiento" DEBE mostrar el conjunto completo armado, con un control por
  eje móvil (nombre, valor en grados y rango) y los topes del rango respetados.
- **FR-011**: Al cambiar un eje, sus elementos y los de los ejes montados sobre él DEBEN girar
  juntos alrededor del eje y punto declarados; los demás no DEBEN moverse.
- **FR-012**: Cada motor DEBE girar según la relación declarada respecto del eje que impulsa, con el
  sentido correcto, y su valor DEBE poder verse (vueltas o grados del motor).
- **FR-013**: Cada emisor DEBE poder encenderse y apagarse; encendido, DEBE mostrar un haz visible
  desde su punto de salida y en su dirección, que acompañe al eje que lo lleva en todo momento.
- **FR-014**: Los elementos aproximados (cable, correas) DEBEN mostrarse sin desaparecer ni separarse
  de forma evidente de las piezas que los sostienen, y la página DEBE aclarar que son aproximados.
- **FR-015**: Un control DEBE devolver todos los ejes a su posición de reposo y apagar los emisores.

**Modo automático**

- **FR-016**: El modo automático DEBE recorrer una secuencia de objetivos (azimut y altura) en
  bucle, moviendo los ejes a la vez a la velocidad máxima declarada para cada eje, con el emisor
  apagado durante el movimiento y encendido un tiempo fijo al llegar.
- **FR-017**: La secuencia de objetivos DEBE ser una lista de objetivos de demostración (nombre,
  azimut y altura) declarada en el ensamblaje del diseño, dentro del rango de cada eje. Apuntar a
  estrellas reales queda para una funcionalidad posterior.
- **FR-018**: La persona DEBE poder elegir un multiplicador de velocidad (supuesto: ×1, ×5 y ×20);
  cualquier valor distinto de ×1 DEBE indicarse como velocidad no real.
- **FR-019**: Tocar un control manual o salir del modo DEBE detener el recorrido automático y apagar
  los emisores.

**Interfaz y documentación**

- **FR-020**: El modo "Funcionamiento" y el modo de armado DEBEN convivir en la misma página; pasar de
  uno al otro NO DEBE cambiar el paso de armado ni la vista elegida por la persona.
- **FR-021**: Los controles DEBEN poder usarse con mouse, teclado y tacto, desde 360 px de ancho.
- **FR-022**: Las instrucciones del proyecto para diseños de varias piezas y para la web de armado
  DEBEN explicar cómo declarar ejes, motores y emisores, y cómo revisar la simulación.
- **FR-023**: El puntero láser DEBE declarar sus dos ejes (azimut y altura), sus dos motores con la
  relación de su correa y el láser como emisor.

### Entidades clave

- **Eje móvil**: un grado de libertad del diseño: nombre, elementos que mueve, eje y punto de giro,
  rango, reposo, velocidad máxima y eje padre (si va montado sobre otro).
- **Motor**: elemento que gira para impulsar un eje móvil, con su relación de transmisión.
- **Emisor**: elemento que emite un haz (el láser), con punto de salida, dirección, color y eje que
  lo lleva.
- **Objetivo**: posición de los ejes a la que apunta el modo automático, con un nombre legible.
- **Estado de la simulación**: valor de cada eje, emisores encendidos o apagados, modo manual o
  automático y multiplicador de velocidad.

## Criterios de éxito *(obligatorio)*

### Resultados medibles

- **SC-001**: El visor del puntero láser tiene el modo "Funcionamiento" generado con el mismo comando
  de siempre; el de la caja de pilas se genera sin cambios y sin ese modo.
- **SC-002**: En las posiciones extremas y en la de las capturas (−10°, 45° y 95° de altura; 0°, 90°
  y 180° de azimut), las piezas móviles coinciden con el ensamblaje renderizado en esa posición, con
  una diferencia de 0,5 mm o menos.
- **SC-003**: Al girar el eje 90°, su motor gira exactamente la relación declarada por 90° (360° en
  el puntero láser, con la correa de 4 a 1).
- **SC-004**: Una persona que no conoce el diseño identifica en menos de 1 minuto qué motor mueve
  cada eje y qué partes quedan fijas, usando solo el modo "Funcionamiento".
- **SC-005**: Con el láser encendido, el haz sale de la punta y sigue la dirección del láser en el
  100 % de las posiciones probadas.
- **SC-006**: El movimiento se ve continuo en una computadora común y en un celular de gama media, y
  el modo automático tarda entre dos objetivos lo mismo que tardaría el aparato real a ×1 (±10 %).
- **SC-007**: Cambiar la relación de una correa, un pivote o un rango sin regenerar es detectado por
  la comprobación de la puerta 5 en el 100 % de los casos.
- **SC-008**: El visor del puntero láser sigue pesando 10 MB o menos.

## Supuestos

- La simulación es cinemática: muestra posiciones y giros, no fuerzas, inercia, pérdida de pasos ni
  choques. Los rangos declarados ya están validados por las comprobaciones del ensamblaje.
- Velocidad máxima por eje: la de la guía del puntero láser (≈ 20°/s en el eje); se declara en el
  ensamblaje junto al eje.
- El motor que se ve girar es la polea de 20 dientes y el eje de salida del 28BYJ-48; la reducción
  interna del motor no se dibuja (se puede informar como dato).
- El haz del láser es verde (láser 303) y tiene un largo fijo de demostración.
- El modo "Funcionamiento" vive dentro del mismo visor (`armado_3d.html`), como una pestaña o modo
  aparte del armado paso a paso; no se crea otra página.
- No se simula la lógica del ESP32, del relé ni del regulador; solo su efecto visible (el láser
  encendido o apagado). La regla de la 006 (láser apagado salvo orden del ESP32) se respeta: el
  láser arranca apagado y el modo automático lo apaga al moverse.
- El azimut del puntero láser no tiene tope mecánico declarado; si el cableado lo limitara, se
  declara un rango y la simulación lo respeta.
- No hace falta enmendar la constitución: el visor sigue siendo obligatorio y el modo
  "Funcionamiento" es opcional, solo para los diseños que declaran ejes.
- Fuera del alcance: apuntar a estrellas reales (funcionalidad posterior), realidad aumentada, sonido de los motores, cálculo de dónde pega el haz y
  control del aparato real desde la página.
