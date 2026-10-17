# Especificación de Funcionalidad: Barra de distribución de alimentación del puntero láser

**Rama de la funcionalidad**: `010-barra-distribucion`

**Creada**: 2026-10-17

**Estado**: Implementada (pendiente: armado real con los componentes, SC-003)

**Corrige**: [009-espacio-conectores](../009-espacio-conectores/spec.md) (cableado bajo la tapa) y
[006-laser-alimentacion-externa](../006-laser-alimentacion-externa/spec.md) (esquema de conexiones)

**Entrada**: Descripción del usuario: "Barra de distribución de alimentación en placa perforada para
el puntero láser. Hoy el esquema (guía 5.4) reparte +5 V del interruptor general a 5 destinos (ESP32
VIN, ULN2003 azimut +5V, ULN2003 altura +5V, relé VCC, relé COM) y GND a 6 puntos (power bank −, ESP32
GND, 2 ULN2003 −, relé GND, regulador IN−), pero un Dupont no se bifurca y ni la guía, ni la lista de
materiales, ni el modelo contemplan cómo hacer esa unión. Agregar una barra de distribución: placa
perforada (≈ 30 × 20 mm) con dos tiras de pines macho (+5 V y GND) a la que se suelda el cable del
interruptor y en la que cada placa se enchufa con su Dupont hembra-hembra. Modelarla como bloque
paramétrico con sus volúmenes de Dupont en el ensamblaje (incluida en las comprobaciones de choque de
la 009 contra tapa, plataforma, soportes y otras placas), darle un soporte en la plataforma bajo la
tapa, sumar a la lista de materiales la placa perforada, las tiras de pines y el termocontraíble con
precio, agregar a la guía las herramientas de soldadura (soldador, estaño, termocontraíble), el paso
de armado de la barra y el esquema actualizado, y regenerar STL, vistas explotadas, web y visor."

## Escenarios de usuario y pruebas *(obligatorio)*

### Historia de usuario 1 - Repartir la alimentación a todas las placas (Prioridad: P1)

Una persona tiene las placas encajadas en sus soportes y el interruptor atornillado. Arma la barra de
distribución siguiendo la guía (suelda las dos tiras de pines a la placa perforada, une los pines de
cada tira y suelda el cable que viene del interruptor y la masa del power bank). Encaja la barra en su
soporte y lleva un Dupont desde cada tira hasta el pin de +5 V o de GND de cada placa. Todas las placas
quedan alimentadas desde un único punto, sin empalmes improvisados.

**Por qué esta prioridad**: es el problema detectado. Sin un punto de reparto, el esquema no se puede
armar con los materiales comprados y cada persona improvisa empalmes, que se sueltan o hacen
cortocircuito bajo la tapa.

**Prueba independiente**: con la barra armada y el interruptor cerrado, el multímetro marca la tensión
del power bank (≈ 5 V) en el pin de +5 V de cada placa y continuidad de GND entre la barra y el GND de
cada placa; entre las dos tiras no hay continuidad.

**Escenarios de aceptación**:

1. **Dado** el esquema de la guía, **cuando** se cuentan los destinos de +5 V y de GND, **entonces** la
   barra tiene al menos un pin por destino en cada tira, más uno de reserva.
2. **Dado** la barra armada según la guía, **cuando** se mide con el interruptor abierto, **entonces**
   no hay tensión en ningún pin de la tira de +5 V.
3. **Dado** la barra armada, **cuando** se mide resistencia entre la tira de +5 V y la de GND con todo
   desconectado, **entonces** no hay continuidad (sin cortocircuito por soldadura).

---

### Historia de usuario 2 - Que la barra entre bajo la tapa (Prioridad: P2)

La persona encaja la barra en su soporte de la plataforma, conecta los Dupont y cierra la tapa. La
barra no se mueve al girar el aparato y ni ella ni sus Dupont tocan la tapa, las otras placas, los
soportes ni los cables que pasan por ahí.

**Por qué esta prioridad**: la feature 009 dejó el espacio bajo la tapa justo para lo que había; un
componente más sin lugar reservado vuelve a dejar la tapa sin cerrar.

**Prueba independiente**: en el ensamblaje, con la barra y los volúmenes de sus Dupont dibujados, las
comprobaciones de choque pasan con la holgura mínima de la feature 009.

**Escenarios de aceptación**:

1. **Dado** el diseño con los valores por defecto, **cuando** se valida el ensamblaje, **entonces** la
   barra y los volúmenes de sus Dupont con la curva del cable no se solapan con la tapa, la plataforma,
   los soportes ni otra placa o sus conectores.
2. **Dado** que una persona cambia las medidas de la placa perforada o la cantidad de pines,
   **cuando** se valida, **entonces** el soporte se adapta solo y la validación pasa, o falla con un
   mensaje que dice qué medida no entra.
3. **Dado** la barra en su soporte, **cuando** el aparato gira o se transporta, **entonces** la barra
   no se sale (queda retenida sin pegamento).

---

### Historia de usuario 3 - Comprar y armar con lo que dice la guía (Prioridad: P3)

La persona lee la lista de materiales y la de herramientas, compra lo que falta (placa perforada,
tiras de pines, termocontraíble) y tiene a mano el soldador y el estaño antes de empezar. En la web
de armado ve esos componentes con su precio y, en el paso de la electrónica, la barra en la vista
explotada y en el visor 3D.

**Por qué esta prioridad**: la guía ya obliga a soldar (regulador, interruptor, cable USB), pero no lo
dice; descubrirlo a mitad del armado frena el trabajo. Es importante, pero no impide el armado como
las dos historias anteriores.

**Prueba independiente**: la lista de materiales, la guía, la web y el visor nombran la barra, sus
materiales y las herramientas de soldadura, y la barra aparece en el paso de electrónica.

**Escenarios de aceptación**:

1. **Dado** la lista de materiales, **cuando** se busca la barra, **entonces** figuran la placa
   perforada, las tiras de pines macho y el termocontraíble, con cantidad y, si se pudo verificar,
   precio, tienda, enlace y fecha.
2. **Dado** la guía, **cuando** se lee la sección de herramientas o primeros pasos, **entonces** dice
   que hacen falta soldador, estaño y termocontraíble, además del multímetro.
3. **Dado** el esquema de conexiones de la guía, **cuando** se sigue un cable de alimentación,
   **entonces** cada destino de +5 V y de GND sale de la barra.

---

### Casos límite

- Destinos sin pines macho (bornera COM del relé, entrada IN− del regulador): se conectan con un cable
  soldado a la barra o con un Dupont con un extremo cortado; la guía dice cuál en cada caso.
- La resistencia de carga opcional del power bank (guía 5.4) o un accesorio futuro: usan el pin de
  reserva.
- Una placa perforada de otro tamaño o paso: se cambian los parámetros; si no entra, la validación lo
  dice.
- Corriente: toda la corriente del aparato (≈ 1,16 A según la guía) pasa por la barra y por el cable
  del interruptor; la guía indica unir los pines de cada tira con un puente de estaño o un hilo, no
  con pistas finas, y el calibre mínimo del cable de entrada.
- Si en la plataforma no hay lugar libre para el soporte con la holgura mínima, la validación DEBE
  fallar nombrando con qué choca, y el diseño se reacomoda hasta que pase.

## Requisitos *(obligatorio)*

### Requisitos funcionales

- **FR-001**: El diseño DEBE incluir una barra de distribución con una tira de +5 V y otra de GND, con
  al menos un pin por cada destino del esquema más uno de reserva en cada tira.
- **FR-002**: El diseño DEBE tener parámetros para la barra: largo, ancho y espesor de la placa
  perforada, paso de los agujeros, cantidad de pines por tira y alto de los pines, con valores típicos
  por defecto y la indicación de medirlos.
- **FR-003**: La plataforma DEBE tener un soporte para la barra, bajo la tapa, que la retenga sin
  pegamento y se dimensione desde los parámetros de la barra con las holguras del perfil de impresora.
- **FR-004**: El ensamblaje DEBE representar la barra y los volúmenes de sus Dupont conectados con la
  curva del cable, y sumarlos a las comprobaciones de choque de la feature 009 (tapa, plataforma,
  soportes, otras placas y sus conectores), con un mensaje que nombre la barra y la pieza con la que
  choca.
- **FR-005**: Si la barra o sus conectores hacen crecer la tapa, o la tapa más alta choca con el carro
  o el motor de altura o deja de entrar en la cama, la validación DEBE fallar (las comprobaciones
  existentes siguen vigentes).
- **FR-006**: La lista de materiales DEBE sumar la placa perforada, las tiras de pines macho y el
  termocontraíble, con cantidad y precio verificado (o vacío si no se pudo verificar).
- **FR-007**: La guía DEBE listar las herramientas de soldadura (soldador, estaño, termocontraíble)
  junto al multímetro, incluir un paso de armado de la barra (soldar las tiras, unir los pines, soldar
  la entrada, aislar con termocontraíble y comprobar con el multímetro antes de conectar las placas) y
  actualizar el esquema de conexiones para que cada +5 V y GND salga de la barra.
- **FR-008**: La guía DEBE indicar qué destino va en cada pin de la barra y cómo se conectan los
  destinos sin pines macho.
- **FR-009**: Las piezas que cambian (como mínimo la plataforma) DEBEN regenerar sus STL, y las demás
  DEBEN quedar iguales; las vistas explotadas, la web y el visor DEBEN regenerarse y mostrar la barra
  en el paso de electrónica.
- **FR-010**: La barra NO DEBE exportarse como pieza impresa; aparece en la lista de materiales por sus
  componentes comprados.

### Entidades clave

- **Barra de distribución**: placa perforada con dos tiras de pines (+5 V y GND); tiene medidas,
  cantidad de pines por tira, posición en la plataforma y la lista de destinos asignados a cada pin.
- **Destino de alimentación**: pin de +5 V o de GND de una placa, o borne sin pines (COM del relé, IN−
  del regulador), con la forma de conexión (Dupont o cable soldado).

## Criterios de éxito *(obligatorio)*

### Resultados medibles

- **SC-001**: El 100 % de los destinos de +5 V y GND del esquema tiene su pin asignado en la barra, y
  queda al menos un pin libre en cada tira.
- **SC-002**: Con los valores por defecto, la barra y sus conectores caben bajo la tapa con la holgura
  mínima, comprobado por el diseño y no a ojo.
- **SC-003**: Una persona arma la barra y alimenta todas las placas siguiendo la guía, sin materiales
  ni herramientas que no estén listados, y la prueba con multímetro da bien al primer intento.
- **SC-004**: Cambiar una medida de la barra y volver a validar indica en una sola pasada si sigue
  entrando y, si no, qué medida falla.

## Supuestos

- Placa perforada de paso 2,54 mm (≈ 30 × 20 mm, 1,6 mm de espesor) y tiras de pines macho rectos
  comunes de paso 2,54 mm, cortadas a medida; los Dupont son los hembra-hembra rectos de la lista de
  materiales (feature 009).
- Destinos por defecto: +5 V a ESP32 VIN, 2 × ULN2003, relé VCC y relé COM (5 destinos); GND a ESP32,
  2 × ULN2003, relé y regulador IN− (5 destinos) más la entrada de masa del power bank, que se suelda.
  La resistencia de 10 kΩ del relé sigue soldada en el relé, como hoy.
- La barra no soporta cargas mecánicas: no hace falta simulación FEM (justificación en el plan).
- El soldador, el estaño y el multímetro son herramientas: van en la guía, no en la lista de
  materiales con precio. El termocontraíble es material consumible y va en la lista.
- Sigue fuera de alcance diseñar una placa de circuito impreso o cambiar el tipo de conexión de las
  señales del ESP32 a las placas.
- El firmware no cambia.
