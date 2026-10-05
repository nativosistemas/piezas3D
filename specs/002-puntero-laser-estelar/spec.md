# Especificación de Funcionalidad: Puntero láser estelar motorizado (alt-az)

**Rama de la funcionalidad**: `002-puntero-laser-estelar`

**Creada**: 2026-10-04

**Estado**: Implementada (pendiente de las pruebas físicas)

**Entrada**: Descripción del usuario: "Aparato que tiene un láser para señalar una estrella en la
esfera celeste. El aparato se coloca en el trípode de un telescopio. Tiene un ESP32 que maneja la
lógica de cómo se mueven los motores o se enciende el láser. El láser es un 303 para astronomía. Los
motores son 2 paso a paso 28BYJ-48 y sus drivers. Tener en cuenta los cables. Hay un relé que
enciende o apaga el láser. Que el margen de error sea menor a 2 grados en la esfera celeste."

Decisiones ya acordadas con el usuario: fijación al trípode con rosca 3/8"-16; reducción externa por
correa dentada GT2 en cada eje (polea motriz 20T comprada, polea grande impresa ≈ 80T); alimentación
con un power bank USB de 5 V que viaja sobre la parte giratoria; impresora con cama de 220 × 220 mm.

## Escenarios de usuario y pruebas *(obligatorio)*

### Historia de usuario 1 - Fabricar, armar y montar el aparato en el trípode (Prioridad: P1)

Una persona aficionada a la astronomía quiere un puntero láser motorizado para mostrar estrellas en
sesiones de observación. Imprime las piezas con sus valores por defecto en una impresora doméstica,
consigue la tornillería, los rodamientos, las poleas y las correas de la lista de materiales, y monta
la electrónica (ESP32, 2 drivers, relé, power bank), los 2 motores y el láser 303 siguiendo la guía.
Después enrosca el aparato al trípode del telescopio con el tornillo de 3/8"-16 y comprueba a mano
que gira libremente en azimut y en altura.

**Por qué esta prioridad**: sin un conjunto físico armado, con la electrónica alojada y los cables
resueltos, no hay aparato. Es el valor central de la funcionalidad.

**Prueba independiente**: se imprimen todas las piezas, se arma el conjunto según la guía y se monta
en un trípode con rosca 3/8"-16. El aparato queda firme sobre el trípode, gira 360° en azimut sin
límite y el láser recorre de −10° a 95° en altura sin chocar con ninguna pieza ni tirar de los cables.

**Escenarios de aceptación**:

1. **Dado** el diseño con sus valores por defecto, **cuando** se preparan las piezas para imprimir,
   **entonces** cada pieza entra en una superficie de 200 × 200 mm y se imprime sin soportes, o con
   soportes solo donde la guía lo indique expresamente.
2. **Dado** el conjunto armado, **cuando** se enrosca la base al tornillo 3/8"-16 del trípode,
   **entonces** el aparato queda firme, sin holgura visible entre la base y la cabeza del trípode.
3. **Dado** el conjunto armado, **cuando** la parte giratoria da 3 vueltas completas seguidas en el
   mismo sentido, **entonces** ningún cable se enrosca, se estira ni se desconecta.
4. **Dado** el láser montado en su cuna, **cuando** se lleva de −10° a 95° de altura, **entonces**
   ninguna parte del láser ni de la cuna toca la plataforma, los brazos ni la electrónica, y los 2
   hilos que van al láser acompañan el movimiento sin quedar tensos.
5. **Dado** el conjunto armado, **cuando** se necesita cambiar el power bank o revisar la electrónica,
   **entonces** se accede a ella abriendo una tapa, sin desarmar los ejes.

---

### Historia de usuario 2 - Señalar una estrella con error menor a 2° (Prioridad: P2)

Con el aparato montado y alineado sobre dos estrellas conocidas, el usuario elige una estrella y el
aparato apunta el láser hacia ella. El haz cae a menos de 2° de la estrella, de forma que el público
la identifica sin dudas. El aparato puede volver varias veces a la misma estrella sin que el error
crezca.

**Por qué esta prioridad**: es el requisito de desempeño que pidió el usuario. Depende de que la
mecánica (reducción, juego, equilibrado del láser y colimación) permita esa precisión. El firmware
que calcula las posiciones queda fuera de alcance, pero la mecánica no debe ser el factor limitante.

**Prueba independiente**: en banco, sin cielo, se marca una referencia angular (transportador o
puntos en una pared a distancia conocida). Se ordenan movimientos de ida y vuelta de 90° en cada eje y
se mide la diferencia entre el ángulo ordenado y el real. Bajo el cielo, después de alinear con 2
estrellas, se apunta a 3 estrellas separadas entre sí más de 30° y se mide el error con una
referencia de tamaño angular conocido.

**Escenarios de aceptación**:

1. **Dado** el aparato armado y la regla de llegar siempre desde el mismo sentido, **cuando** cada
   eje hace 10 movimientos de ida y vuelta de 90° hacia una misma marca, **entonces** el error de
   posición en cada llegada no supera 0,5° y la dispersión entre llegadas no supera 0,3°.
2. **Dado** el láser en su cuna, **cuando** el aparato queda detenido en cualquier altura entre 0° y
   90° con los motores sin energía, **entonces** el láser no se mueve más de 0,2° (está equilibrado
   sobre su eje).
3. **Dado** el aparato alineado con 2 estrellas, **cuando** apunta a una tercera estrella situada
   entre 15° y 85° de altura, **entonces** el haz cae a menos de 2° de ella.
4. **Dado** un láser cuyo haz no sale paralelo al cuerpo, **cuando** el usuario sigue el
   procedimiento de colimación de la guía, **entonces** puede corregir el desvío del haz respecto del
   eje de la cuna hasta dejarlo por debajo de 0,25°.

---

### Historia de usuario 3 - Adaptar el diseño a los componentes reales (Prioridad: P3)

El láser, la placa ESP32, el módulo relé y el power bank que tiene el usuario no miden exactamente
lo mismo que los de referencia. El usuario mide sus componentes, cambia los valores en un único
lugar de parámetros compartidos y vuelve a generar todas las piezas, que siguen encajando entre sí.

**Por qué esta prioridad**: los láseres "303" y los power bank del mercado varían de tamaño. Sin
esta adaptación el diseño solo serviría para un lote concreto de componentes. Es secundaria porque
los valores por defecto ya cubren los componentes más comunes.

**Prueba independiente**: se cambian el diámetro y el largo del láser y las medidas del power bank a
otros valores dentro de los rangos admitidos, se regeneran las piezas y se comprueba que la cuna, el
alojamiento de la electrónica y la altura del eje se ajustan y que la vista de conjunto no muestra
choques.

**Escenarios de aceptación**:

1. **Dado** el diseño, **cuando** el usuario cambia el diámetro del láser de 30 a 26 mm, **entonces**
   la cuna se regenera para ese diámetro con la holgura declarada y sigue centrada en el eje de altura.
2. **Dado** el diseño, **cuando** el usuario aumenta el largo del láser, **entonces** la altura del
   eje de altura sobre la plataforma crece lo necesario para que el láser apunte a 95° sin chocar.
3. **Dado** el diseño, **cuando** el usuario cambia las medidas del power bank, **entonces** su
   alojamiento y la tapa se regeneran; si ya no entra en 200 × 200 mm, la generación se detiene con un
   mensaje claro.
4. **Dado** un cambio en un parámetro compartido, **cuando** se regeneran las piezas, **entonces**
   todas las piezas afectadas cambian a la vez y los archivos imprimibles se regeneran todos.

---

### Historia de usuario 4 - Conocer qué debe hacer el firmware para lograr la precisión (Prioridad: P4)

Quien programe el ESP32 (el usuario u otra persona) necesita saber qué reglas debe cumplir el
firmware para que la mecánica dé la precisión prometida: pasos por vuelta reales, relación de la
correa, compensación del juego, rango de cada eje, conexiones y uso seguro del láser.

**Por qué esta prioridad**: el firmware está fuera de alcance, pero sin estas reglas la mecánica no
alcanza los 2°. Basta con documentarlas.

**Prueba independiente**: una persona que no participó del diseño lee la guía y puede responder,
sin consultar a nadie, cuántos pasos de motor equivalen a 1° en cada eje, cómo compensar el juego, a
qué pines se conecta cada componente y qué hacer con el láser al terminar.

**Escenarios de aceptación**:

1. **Dado** la guía, **cuando** se busca la conversión de pasos a grados, **entonces** figura el
   número exacto de pasos de motor por vuelta del eje (relación real del motor × relación de correa) y
   los pasos por grado de cada eje.
2. **Dado** la guía, **cuando** se busca cómo llegar a una posición, **entonces** describe la regla de
   llegar siempre desde el mismo sentido y el sobrepaso recomendado.
3. **Dado** la guía, **cuando** se busca el cableado, **entonces** hay un esquema de conexiones y un
   recorrido de cables por la plataforma.
4. **Dado** la guía, **cuando** se busca seguridad, **entonces** incluye advertencias sobre el uso del
   láser (aeronaves, personas, normativa local) y la recomendación de un apagado automático.

---

### Casos límite

- **Láser apuntando al cenit (95°) o por debajo del horizonte (−10°)**: la parte trasera o delantera
  del láser no debe tocar la plataforma ni la electrónica. La altura del eje de altura se calcula a
  partir del largo del láser y de la posición de su centro de masa.
- **Láser desequilibrado** (centro de masa lejos del eje): el motor de altura, de poco par, puede
  perder pasos o el láser puede caer al cortar la energía. La cuna debe permitir correr el láser a lo
  largo de su eje para equilibrarlo.
- **Correa floja con el tiempo**: aumenta el juego. Cada eje debe tener un tensor que se pueda
  reajustar sin desarmar el aparato.
- **Cables de los motores más largos de lo necesario**: el sobrante debe poder recogerse en la
  plataforma sin que roce las poleas ni las correas.
- **Trípode con la cabeza fuera de nivel**: la alineación con 2 estrellas lo absorbe. La guía debe
  aclarar que conviene nivelar aproximadamente (±2°) para que la corrección sea buena.
- **Uso nocturno con humedad o rocío**: las piezas no deben deformarse ni perder ajuste, y la
  electrónica debe quedar cubierta por arriba.
- **Componentes más grandes que el rango admitido**: la generación se detiene con un mensaje que
  indica qué parámetro está fuera de rango.
- **Trípode de acero cerca de una brújula**: la orientación inicial no depende de brújula, sino de
  la alineación con estrellas.

## Requisitos *(obligatorio)*

### Requisitos funcionales

**Arquitectura del conjunto**

- **FR-001**: El aparato DEBE ser una montura altitud-azimut de dos ejes: una base fija al trípode,
  una plataforma que gira en azimut sobre ella y una cuna para el láser que gira en altura entre dos
  brazos (horquilla) montados sobre la plataforma.
- **FR-002**: El conjunto DEBE dividirse como mínimo en estas piezas impresas, cada una con el motivo
  de su corte:

  | Pieza | Cant. | Motivo del corte |
  |-------|-------|------------------|
  | Adaptador del trípode (base fija, con polea fija de azimut) | 1 | Parte fija frente a la parte giratoria |
  | Plataforma de azimut (giratoria; electrónica y motor de azimut) | 1 | Parte móvil |
  | Brazo de horquilla | 2 | Se imprime plano para que las capas no trabajen en la dirección del esfuerzo |
  | Cuna del láser | 1 | Parte móvil y ajuste de colimación y equilibrado |
  | Polea de altura | 1 | Parte móvil. Va por fuera del brazo, que queda entre la cuna y el plano de la correa |
  | Tapa de la electrónica | 1 | Acceso a la electrónica y al power bank |

- **FR-003**: Las piezas DEBEN tener guías de alineación (pasadores, rebajes o ranuras) para que
  solo encajen en la posición correcta.

**Ejes y transmisión**

- **FR-004**: Cada eje DEBE girar sobre rodamientos de bolas 608ZZ (22 × 8 × 7 mm) y no debe tener
  juego radial ni axial perceptible a mano después del armado.
- **FR-005**: Cada eje DEBE moverse con un motor 28BYJ-48 a través de una reducción por correa GT2
  con polea motriz de 20 dientes y polea conducida impresa. La relación debe ser como mínimo 1:4.
- **FR-006**: Cada transmisión DEBE tener un tensor de correa ajustable con tornillo, que se pueda
  reajustar con el aparato armado.
- **FR-007**: El eje de azimut DEBE poder girar sin límite en ambos sentidos. El eje de altura DEBE
  cubrir como mínimo de −10° a 95°.
- **FR-008**: La cuna DEBE permitir desplazar el láser a lo largo de su eje para dejar su centro de
  masa sobre el eje de altura, y DEBE tener tornillos de ajuste para alinear el haz con el eje de la
  cuna (colimación).

**Electrónica y cables**

- **FR-009**: La plataforma de azimut DEBE alojar el ESP32, los 2 drivers ULN2003, el módulo relé, el
  power bank y el motor de azimut, de modo que ningún cable cruce el eje de azimut.
- **FR-010**: El motor de azimut DEBE ir montado en la plataforma y engranar con una polea fija
  solidaria a la base.
- **FR-011**: Los únicos conductores que cruzan el eje de altura DEBEN ser los 2 hilos del relé al
  láser. Deben pasar por un recorrido guiado con un bucle de holgura que cubra todo el rango de
  altura sin tensarse.
- **FR-012**: La plataforma DEBE tener canales o sujetacables para todos los cables (motores,
  drivers, relé, alimentación) y un lugar para guardar el sobrante, lejos de poleas y correas.
- **FR-013**: El conector USB del power bank DEBE quedar accesible para cargarlo, y el aparato DEBE
  tener un lugar para un interruptor general.
- **FR-014**: La electrónica DEBE quedar cubierta por arriba con una tapa desmontable, con aberturas
  de ventilación que no dejen entrar agua que cae vertical.

**Montaje al trípode**

- **FR-015**: La base DEBE fijarse al tornillo 3/8"-16 del trípode mediante una tuerca embebida o un
  inserto roscado, y su cara de apoyo debe ser plana para asentar sin balanceo.

**Precisión**

- **FR-016**: La mecánica DEBE permitir un error de apuntado total menor a 2°, con un objetivo de
  diseño de 1° o menos. El presupuesto de error de cada fuente (resolución, juego del motor dividido
  por la reducción, juego de la correa, holguras de los ejes, colimación y alineación) DEBE quedar
  documentado.
- **FR-017**: La resolución angular de cada eje DEBE ser de 0,05° o mejor.

**Parámetros ajustables**

- **FR-018**: Las medidas compartidas (holguras, tornillería, rodamientos, poleas, componentes
  comprados) DEBEN declararse en un único lugar de parámetros compartidos, del que dependan todas las
  piezas. El usuario DEBE poder ajustar como mínimo:

  | Parámetro | Por defecto | Rango admitido |
  |-----------|-------------|----------------|
  | Diámetro del cuerpo del láser | 30 mm | 20 – 40 mm |
  | Largo total del láser | 190 mm | 120 – 260 mm |
  | Distancia del extremo trasero del láser a su centro de masa | 95 mm | 40 % – 60 % del largo |
  | Medidas del power bank (largo × ancho × alto) | 100 × 65 × 25 mm | hasta 150 × 75 × 30 mm |
  | Medidas de la placa ESP32 | 55 × 28 mm | 48 – 60 × 25 – 32 mm |
  | Medidas del módulo relé | 50 × 26 mm | 35 – 55 × 17 – 30 mm |
  | Dientes de la polea conducida | 80 | 80 – 100 (relación ≥ 1:4) |
  | Holgura de encastre | 0,25 mm | 0,1 – 0,5 mm |

- **FR-019**: La generación DEBE rechazar, con un mensaje que nombre el parámetro y su límite,
  cualquier valor fuera de rango y cualquier combinación que haga que una pieza no entre en
  200 × 200 mm o que el láser choque dentro de su rango de altura.

**Manufactura**

- **FR-020**: Cada pieza DEBE modelarse en su orientación de impresión, imprimirse en FDM con boquilla
  de 0,4 mm y entrar en 200 × 200 mm. Los voladizos no deben superar 45° salvo donde la guía indique
  soportes.
- **FR-021**: Ninguna pared DEBE tener menos de 1,2 mm de espesor.
- **FR-022**: DEBE entregarse un archivo imprimible por pieza, que corresponda a los parámetros
  documentados, y una vista de conjunto que muestre todas las piezas en su posición, sin choques. La
  vista de conjunto no se exporta.

**Validación**

- **FR-023**: Las piezas con carga relevante (brazos de horquilla y base) DEBEN validarse
  estructuralmente o tener una justificación escrita de por qué no hace falta, considerando el peso
  del conjunto y la tensión de la correa.
- **FR-024**: DEBE documentarse el cálculo del par necesario en el eje de altura con el láser
  equilibrado y con un desbalance de 10 mm, y compararlo con el par disponible después de la
  reducción.

**Documentación**

- **FR-025**: DEBE entregarse una única guía de producción con: tabla de piezas impresas (cantidad,
  material, orientación, relleno, perímetros, soportes), lista de materiales con cantidades y medidas
  exactas, orden de armado paso a paso, procedimiento de equilibrado y colimación del láser, y
  montaje en el trípode.
- **FR-026**: La guía DEBE incluir los requisitos para el firmware: pasos por vuelta y por grado de
  cada eje, regla de llegada unidireccional con su sobrepaso, rangos de cada eje, esquema de
  conexiones, alineación con 2 estrellas y apagado automático del láser.
- **FR-027**: La guía DEBE incluir advertencias de seguridad sobre el láser.

### Entidades clave

- **Conjunto de parámetros compartidos**: medidas que comparten las piezas (holguras, tornillería
  M3, rodamientos 608ZZ, poleas GT2, medidas de los componentes comprados), cada una con valor por
  defecto, rango y unidad.
- **Pieza impresa**: cada parte del conjunto, con su orientación de impresión, material y uniones
  con las demás piezas.
- **Componente comprado**: láser 303, ESP32, drivers ULN2003, motores 28BYJ-48, relé, power bank,
  rodamientos, poleas, correas y tornillería. Se caracteriza por sus medidas y, si corresponde, su
  masa.
- **Eje de movimiento**: azimut o altura, con su rango, su relación de reducción, sus pasos por grado
  y su aporte al presupuesto de error.
- **Presupuesto de error**: lista de fuentes de error de apuntado con su valor estimado y la suma
  total frente al límite de 2°.

## Criterios de éxito *(obligatorio)*

### Resultados medibles

- **SC-001**: El 100 % de las piezas se imprime en una cama de 220 × 220 mm, y como máximo una pieza
  necesita soportes.
- **SC-002**: Una persona con experiencia básica en impresión 3D y electrónica arma el conjunto
  completo siguiendo solo la guía en menos de 3 horas (sin contar la impresión), sin modificar
  ninguna pieza.
- **SC-003**: Después de alinear con 2 estrellas, el aparato señala 3 estrellas de prueba con un
  error menor a 2° en cada una (objetivo: 1°). *Requiere el firmware con alineación, que está fuera
  de alcance: este criterio queda condicionado a que exista y cumpla el contrato de firmware.*
- **SC-004**: En 10 llegadas consecutivas a una misma marca, la dispersión de la posición es de 0,3°
  o menos en cada eje. *Se verifica con el firmware o, mientras no exista, con un programa de prueba
  mínimo que solo mueva pasos con llegada unidireccional.*
- **SC-005**: El aparato completa 3 vueltas seguidas en azimut en cada sentido y 20 recorridos
  completos de altura sin que ningún cable se enrosque, se tense o se desconecte.
- **SC-006**: El aparato se monta y se desmonta del trípode en menos de 1 minuto sin herramientas.
- **SC-007**: Después de cambiar las medidas del láser o del power bank dentro de los rangos
  admitidos, todas las piezas siguen encajando sin retoques.

## Supuestos

- El láser es un puntero verde tipo "Laser 303" con batería propia. Medidas de referencia
  (Ø 30 mm × 190 mm, ≈ 180 g con batería) a verificar midiendo el ejemplar real. Se enciende con un
  relé cuyo contacto normalmente abierto se suelda en paralelo al pulsador, y la llave de seguridad
  queda en posición de encendido.
- El ESP32 es una placa DevKit de 30 o 38 pines (≈ 55 × 28 mm). Los drivers son las placas ULN2003
  que se venden con el 28BYJ-48 (≈ 35 × 32 mm). El relé es un módulo de 1 canal a 5 V.
- El 28BYJ-48 es la versión de 5 V, con relación interna real de 63,68:1 (≈ 4076 medios pasos por
  vuelta), par útil de ≈ 34 mN·m y un juego de caja de 1–3°.
- La polea motriz GT2 de 20 dientes y agujero de 5 mm entra en el eje del 28BYJ-48 (Ø 5 mm con dos
  caras planas). Las correas son GT2 de 6 mm de ancho, cerradas, de un largo que se definirá en la
  planificación.
- El power bank entrega 5 V y al menos 2 A y no se apaga solo con consumos bajos. Si se apaga,
  la guía indicará cómo evitarlo.
- Las holguras de encaje son **valores por defecto, no medidos**: el proyecto todavía no tiene
  `src/perfil_impresora.scad` (constitución v1.1.0, Principio IV). La probeta del 608 cubre el encaje
  más crítico.
- Material por defecto: PETG, por su resistencia a la humedad nocturna y a la temperatura dentro de
  un auto al sol. El PLA es aceptable para uso ocasional.
- El trípode tiene un tornillo macho de 3/8"-16 en la cabeza.
- La lógica de apuntado (cálculo de coordenadas, alineación, interfaz de usuario y seguimiento del
  movimiento del cielo) es firmware y queda fuera de alcance. Solo se documentan sus requisitos.
- Fuera de alcance: anillo rozante, finales de carrera y sensores de posición. Pueden agregarse en
  una versión futura para buscar una posición de referencia al encender.
