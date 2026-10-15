# Especificación de Funcionalidad: Láser alimentado desde el power bank

**Rama de la funcionalidad**: `006-laser-alimentacion-externa`

**Creada**: 2026-10-14

**Estado**: Implementada (pendiente de las pruebas físicas y de medir el láser real)

**Modifica**: [002-puntero-laser-estelar](../002-puntero-laser-estelar/spec.md)

**Entrada**: Descripción del usuario: "Quiero colocar un relé entre la pila y el láser. Sacar la pila
y que el power bank lo alimente. Pensar por dónde salen los cables del láser al exterior. La tapa del
láser también impresa. Arrancar con valores supuestos y después los ajusto."

Decisiones ya acordadas con el usuario: se quita la batería del láser 303 y se alimenta desde el
power bank; el relé corta la línea de 5 V antes de un regulador reductor ajustado a 3,7 V; la
batería se reemplaza por una pila falsa impresa y la tapa trasera original por una tapa impresa sin
rosca, fijada con prisioneros M3; el cable sale por la cola del láser, corre pegado a él y pasa por
fuera de la cuna hasta el muñón −X, y desde ahí sigue el recorrido actual. Las medidas del láser son
supuestas y el usuario las ajusta después de medir su ejemplar.

## Aclaraciones

### Sesión 2026-10-14

- P: ¿Qué debe pasar con el láser cuando el ESP32 está apagado? → R: el láser DEBE estar apagado.
  Se entiende como cualquier estado en que el ESP32 no ordena encenderlo: sin energía, arrancando,
  reiniciándose, sin programa, en sueño profundo, colgado con el pin sin definir o con el cable de
  control suelto (FR-003, FR-003a, SC-002).

## Escenarios de usuario y pruebas *(obligatorio)*

### Historia de usuario 1 - Encender y apagar el láser cortando su alimentación (Prioridad: P1)

El usuario quiere que el relé corte de verdad la energía del láser, no que simule el pulsador. Saca
la batería del láser, coloca la pila falsa y la tapa trasera impresa, traba el pulsador del láser en
encendido y conecta los 2 cables al regulador y al relé dentro de la tapa de la electrónica. Desde
entonces el láser solo recibe energía cuando el ESP32 activa el relé, y una sola batería, el power
bank, alimenta todo el aparato.

**Por qué esta prioridad**: es el cambio que pidió el usuario y el que aporta seguridad: con el
ESP32 apagado, reiniciado o sin programa, el láser queda sin energía.

**Prueba independiente**: con el láser fuera de la cuna, se arma el circuito power bank → relé →
regulador → pila falsa, se mide la tensión de salida del regulador y se activa y desactiva el relé
10 veces. El láser enciende y apaga en cada maniobra y nunca recibe más tensión que la de su batería.

**Escenarios de aceptación**:

1. **Dado** el regulador recién instalado, **cuando** se lo ajusta según la guía antes de conectar
   el láser, **entonces** su salida queda entre 3,6 y 3,8 V, medida con multímetro.
2. **Dado** el aparato armado, **cuando** el ESP32 activa el relé, **entonces** el láser enciende
   sin tocar su pulsador; **cuando** lo desactiva, el láser se apaga y no queda tensión en la pila
   falsa.
3. **Dado** el aparato encendido con el interruptor general, **cuando** el ESP32 está apagado,
   arranca, se reinicia, no tiene programa o está en sueño profundo, **entonces** el láser
   permanece apagado y no destella ni un instante.
4. **Dado** el aparato encendido y el relé desactivado, **cuando** se desconecta el cable de control
   entre el ESP32 y el relé, **entonces** el láser sigue apagado.
5. **Dado** el láser encendido y los 2 motores moviéndose a la vez, **cuando** se mide la tensión
   en la pila falsa, **entonces** no baja de 3,5 V y el haz no parpadea a simple vista.
6. **Dado** el láser con la pila falsa, **cuando** se lo quiere volver a usar a mano, **entonces**
   la guía explica cómo poner de nuevo la batería y la tapa original.

---

### Historia de usuario 2 - Sacar los cables del láser sin que se enreden en el giro de altura (Prioridad: P2)

Los cables salen por la cola del láser, que queda fuera de la cuna y barre un radio grande al girar
en altura. El usuario los sujeta al cuerpo del láser con grapas impresas, los pasa por una canaleta
exterior de la cuna hasta el muñón −X y desde ahí sigue el recorrido de siempre hacia el brazo
cable. El láser recorre todo su rango de altura sin que los cables se tensen, rocen las correas o
toquen la plataforma.

**Por qué esta prioridad**: sin un recorrido guiado, el cable de la cola se enreda o se corta en
pocas maniobras. Es secundaria porque depende de que la alimentación (P1) esté resuelta.

**Prueba independiente**: con el aparato armado, se lleva el láser de −10° a 95° y de vuelta 20
veces y se observa el cable en todo su recorrido.

**Escenarios de aceptación**:

1. **Dado** el aparato armado, **cuando** el láser se lleva de −10° a 95°, **entonces** ni la tapa
   trasera impresa, ni las grapas, ni el cable tocan la plataforma, la tapa de la electrónica, los
   brazos, las poleas ni las correas.
2. **Dado** el cable sujeto al láser y a la cuna, **cuando** se completan 20 recorridos de altura,
   **entonces** el cable no se tensa, no se sale de la canaleta ni de las grapas y sigue conduciendo.
3. **Dado** el láser corrido a lo largo de la cuna para equilibrarlo, **cuando** se lo desplaza
   hasta el extremo del ajuste, **entonces** el tramo del cable entre la última grapa y la canaleta
   tiene holgura suficiente y no tira del láser.
4. **Dado** la tapa trasera colocada, **cuando** se tira del cable con la mano, **entonces** el
   tirón lo absorbe el alivio de tensión de la tapa y no llega a los contactos de la pila falsa.

---

### Historia de usuario 3 - Adaptar la pila falsa y la tapa al láser real (Prioridad: P3)

El usuario mide su láser (diámetro del tubo en la zona de la tapa, largo de esa zona, hueco de la
batería y largo de la tapa original), cambia esos valores en los parámetros compartidos y regenera
las piezas. La pila falsa y la tapa encajan en su ejemplar, y el diseño recalcula el equilibrio y la
altura del eje para la nueva cola.

**Por qué esta prioridad**: las medidas iniciales son supuestas; sin este ajuste las piezas nuevas
solo encajan por casualidad. Es la última porque los valores supuestos permiten probar el resto.

**Prueba independiente**: se cambian las medidas del hueco de la batería y del tubo a otros valores
dentro de su rango, se regeneran las piezas y se comprueba que la pila falsa, la tapa y la vista de
conjunto se ajustan sin choques.

**Escenarios de aceptación**:

1. **Dado** el diseño, **cuando** el usuario cambia el hueco de la batería de 18650 a 16340,
   **entonces** la pila falsa se regenera para ese tamaño.
2. **Dado** el diseño, **cuando** el usuario cambia el diámetro del tubo en la zona de la tapa,
   **entonces** la tapa trasera se regenera con la holgura de encaje del perfil de impresora.
3. **Dado** el diseño, **cuando** el usuario cambia el largo de la tapa nueva o del láser sin tapa,
   **entonces** la altura del eje se recalcula para que la cola no choque entre −10° y 95°.
4. **Dado** un valor fuera de rango, **cuando** se regeneran las piezas, **entonces** la generación
   se detiene con un mensaje que nombra el parámetro y su límite.

---

### Casos límite

- **Tubo anodizado**: la tapa impresa no conduce, así que el negativo ya no vuelve por la tapa
  original. Si el contacto no atraviesa el anodizado, el láser no enciende. La guía DEBE indicar
  cómo comprobarlo con un multímetro y qué hacer si falla.
- **ESP32 sin energía con el relé alimentado**: el ESP32, los drivers y el relé salen de la misma
  línea después del interruptor general, así que no pueden quedar con alimentaciones distintas. Si
  el ESP32 se alimenta por USB desde una computadora para programarlo, el relé queda sin energía y
  el láser apagado.
- **ESP32 colgado con el relé activado**: el hardware no puede distinguirlo de una orden de
  encendido. Lo cubre el firmware con un vigilante (watchdog) y el apagado automático que ya pide la
  002; la guía DEBE recordarlo en los requisitos del firmware.
- **Contactos del relé pegados**: es una falla del relé, no del diseño. La guía DEBE indicar que si
  el láser no se apaga con el ESP32 apagado, se corta el interruptor general y se cambia el relé.
- **Pulsador momentáneo**: si el pulsador del láser no se traba en encendido, hay que puentearlo y
  la guía DEBE explicarlo.
- **Regulador sin ajustar o desajustado**: 5 V directos pueden quemar el láser. El regulador DEBE
  ajustarse y medirse antes de conectar el láser, y la guía DEBE advertirlo.
- **Polaridad invertida**: los cables y contactos DEBEN estar identificados (color y marca en la pila
  falsa) para que no se puedan confundir.
- **Caída de tensión del power bank** al arrancar los motores: el regulador la absorbe mientras la
  entrada no baje de unos 4,5 V.
- **Power bank que se apaga con poco consumo**: con el láser apagado el consumo baja; se mantiene la
  indicación de la guía de la 002.
- **Equilibrio**: sacar la batería y la tapa original corre el centro de masa hacia adelante. La
  cuna ya permite correr el láser, pero el rango de ajuste DEBE alcanzar para la nueva posición.
- **Resorte del cabezal**: empuja la pila falsa hacia atrás. Si la tapa se afloja, el láser se apaga
  o se enciende de a ratos.
- **Rocío**: los contactos de la pila falsa quedan dentro del tubo, cubiertos por la tapa.

## Requisitos *(obligatorio)*

### Requisitos funcionales

**Alimentación del láser**

- **FR-001**: El láser DEBE alimentarse desde el power bank a través del relé y de un regulador
  reductor, en este orden. El relé corta la línea de 5 V antes del regulador, de modo que con el
  relé abierto el regulador tampoco consume.
- **FR-002**: El regulador DEBE ser ajustable y quedar ajustado a 3,7 V ± 0,1 V. DEBE soportar al
  menos 1 A de salida y alojarse dentro de la tapa de la electrónica junto a las demás placas.
- **FR-003**: Si el ESP32 está apagado, el láser DEBE estar apagado. El relé DEBE quedar abierto y
  el láser sin energía en todo estado en que el ESP32 no ordena encenderlo: sin energía, arrancando,
  reiniciándose, sin programa, en sueño profundo o con su salida sin definir. El láser DEBE ir en el
  contacto normalmente abierto del relé, de modo que el relé sin energía también lo deje apagado. Se
  mantiene la condición de la 002 de un módulo compatible con lógica de 3,3 V.
- **FR-003a**: La entrada de control del relé DEBE tener un estado de reposo fijo que la lleve a
  "apagado" aunque el ESP32 no la maneje o el cable de control se suelte. La salida del ESP32 que
  maneja el relé NO DEBE ser un pin que cambie de estado durante el arranque. La guía DEBE incluir la
  prueba: con el ESP32 sin programa y con el cable de control suelto, la tensión en la pila falsa
  es 0 V.
- **FR-004**: El consumo total con los 2 motores, el ESP32 y el láser encendidos DEBE quedar dentro
  de lo que entrega el power bank (≥ 2 A), con margen. Se estima en 1,1–1,3 A y la guía DEBE
  actualizar ese valor.
- **FR-005**: Los cables que cruzan el eje de altura DEBEN tener una sección que, a la corriente
  del láser, haga caer menos de 0,1 V en todo su largo.
- **FR-006**: El pulsador del láser DEBE quedar trabado en encendido, o puenteado si es momentáneo.
  Desaparece la llave de seguridad de la tapa original; el corte manual lo hace el interruptor
  general que ya existe.

**Piezas impresas nuevas**

- **FR-007**: DEBE haber una **pila falsa** del tamaño del hueco de la batería, con el contacto
  positivo en la punta delantera y su cable fijo a la pieza, de modo que un tirón no llegue al
  contacto.
- **FR-008**: El contacto negativo DEBE cerrar el circuito con el cuerpo metálico del tubo, porque la
  tapa impresa no conduce. Lo hace la tapa, apretando un contacto contra el metal del tubo con la
  fuerza suficiente para atravesar un anodizado fino.
- **FR-009**: DEBE haber una **tapa trasera** que reemplace la original: una funda sin rosca que
  calza por fuera del extremo del tubo, fijada con 2 prisioneros M3, que resiste el empuje del
  resorte del cabezal sin moverse. Los cables DEBEN salir por el costado de la tapa, sin doblez por
  detrás de ella, con alivio de tensión (lo da la grapa de FR-010, sobre el mismo tubo). La tapa PUEDE llevar un lastre para que el centro de masa
  del láser quede donde estaba con la batería (FR-014).
- **FR-010**: DEBE haber **grapas** impresas (1 o 2) que sujeten el cable al cuerpo del láser sin
  herramientas y sin dañar su superficie.
- **FR-011**: La cuna DEBE tener una **canaleta exterior** para el cable, desde su borde trasero
  hasta el punto de salida junto al muñón −X, del lado de arriba o de abajo. La canaleta NO DEBE ir
  del lado −X (donde chocaría con el brazo) y el cable NO DEBE pasar por dentro de la cuna (holgura
  de 2 mm y prisioneros de colimación).
- **FR-012**: Desde el muñón −X, el recorrido DEBE seguir igual que en la 002: bucle de holgura y
  agujero y canal del brazo cable.

**Geometría y equilibrio**

- **FR-013**: El largo del láser DEBE pasar a calcularse como el largo sin tapa más el largo de la
  tapa impresa, y la altura del eje DEBE recalcularse con ese valor para que
  nada choque entre −10° y 95°.
- **FR-014**: La masa del láser y la posición de su centro de masa DEBEN recalcularse sin la
  batería ni la tapa original y con la pila falsa, la tapa impresa, las grapas y el cable. El rango
  de desplazamiento de la cuna DEBE alcanzar para equilibrarlo.
- **FR-015**: La vista de conjunto DEBE incluir las piezas nuevas y el cable, y comprobar los choques
  en todo el rango de altura.

**Parámetros ajustables**

- **FR-016**: Las medidas nuevas DEBEN declararse en los parámetros compartidos del puntero láser,
  con estos valores supuestos y rangos:

  | Parámetro | Supuesto | Rango admitido |
  |-----------|----------|----------------|
  | Diámetro del hueco de la batería | 18,5 mm (18650) | 16 – 22 mm |
  | Profundidad del hueco de la batería (del borde trasero del tubo al contacto del cabezal) | 65 mm (18650) | 34 – 70 mm |
  | Diámetro exterior del tubo en la zona de la tapa | 30 mm | 20 – 40 mm |
  | Largo de la zona donde calza la tapa | 12 mm | 8 – 20 mm |
  | Largo de la tapa original (lo que sobresale del tubo) | 20 mm | 5 – 40 mm |
  | Tuercas de lastre en la tapa impresa | 2 | 0 – 3 |
  | Masa de la batería que se quita | 45 g | 15 – 60 g |
  | Masa de la tapa original que se quita | 20 g | 5 – 40 g |

- **FR-017**: La generación DEBE rechazar, con un mensaje que nombre el parámetro y su límite,
  valores fuera de rango y combinaciones imposibles (por ejemplo, una pila falsa más gruesa que el
  tubo o una tapa con pared menor que el mínimo).

**Manufactura y validación**

- **FR-018**: Las piezas nuevas DEBEN cumplir las reglas de manufactura de la 002 (FDM, boquilla de
  0,4 mm, sin soportes salvo donde la guía lo indique, pared ≥ 1,2 mm) y exportarse una por una.
- **FR-019**: La simulación estructural no aplica a las piezas nuevas: solo soportan el resorte del
  cabezal y el peso del cable. El plan DEBE justificarlo con un precálculo.

**Documentación y web**

- **FR-020**: La guía del puntero láser DEBE actualizarse: esquema de conexiones (power bank → relé →
  regulador → pila falsa), ajuste del regulador antes de conectar, comprobación del contacto negativo,
  armado de la pila falsa, la tapa y las grapas, recorrido del cable, nuevo equilibrado, nuevo consumo
  y cómo volver a la batería original.
- **FR-021**: La lista de materiales DEBE agregar el regulador, los contactos de la pila falsa y los
  prisioneros de la tapa, y ajustar el cable. Los precios nuevos DEBEN verificarse en una tienda o
  quedar vacíos.
- **FR-022**: La web de armado y el visor 3D del puntero láser DEBEN regenerarse con los pasos y las
  piezas nuevas.

### Entidades clave

- **Pila falsa**: reemplazo de la batería con el mismo tamaño, con el contacto positivo y su cable
  identificado.
- **Tapa trasera impresa**: funda que cierra la cola del láser, lleva el contacto negativo y el
  lastre y guía la salida de los cables.
- **Grapa del cable**: sujeta el cable al cuerpo del láser.
- **Regulador reductor**: convierte los 5 V del power bank en la tensión de la batería del láser.
- **Recorrido del cable del láser**: tramos desde la tapa trasera hasta el brazo cable, con sus
  puntos de sujeción y su holgura.

## Criterios de éxito *(obligatorio)*

### Resultados medibles

- **SC-001**: En 10 maniobras seguidas del relé, el láser enciende y apaga en el 100 % de ellas.
- **SC-002**: Con el ESP32 apagado, reiniciándose, sin programa o con el cable de control suelto,
  la tensión en la pila falsa es 0 V en el 100 % de las pruebas, y en 10 arranques seguidos el láser
  no destella ninguna vez.
- **SC-003**: Con el láser y los 2 motores funcionando a la vez, la tensión en la pila falsa queda
  entre 3,5 y 3,8 V.
- **SC-004**: En 20 recorridos completos de altura, el cable no se tensa, no roza correas ni poleas
  y no se suelta de ninguna sujeción.
- **SC-005**: Con el láser equilibrado, queda quieto (menos de 0,2° de movimiento) en cualquier
  altura entre 0° y 90° con los motores sin energía, como en la 002.
- **SC-006**: Después de medir el láser real y cambiar los parámetros, la pila falsa y la tapa
  encajan en la primera impresión, sin retoques.
- **SC-007**: El cambio de la batería original a la pila falsa, o al revés, lleva menos de
  10 minutos siguiendo la guía.

## Supuestos

- El láser 303 usa una batería 18650 dentro del tubo, detrás del cabezal, y su circuito de
  negativo vuelve por la tapa trasera y el cuerpo metálico del tubo. El borde trasero del tubo
  conduce (no está anodizado o lo está solo por fuera). Todo esto se verifica midiendo el ejemplar.
- La tapa original trae la llave de seguridad. Se guarda para volver a usar el láser a mano.
- El pulsador lateral del láser se traba en encendido.
- La batería pesa ≈ 45 g y la tapa original ≈ 20 g. Las medidas de la tabla de FR-016 son supuestas
  y el usuario las reemplaza después de medir.
- El regulador es un módulo reductor ajustable común (tipo MP1584 o mini-360), de no más de
  25 × 18 mm, y entra en la tapa de la electrónica junto a las placas actuales.
- Las holguras de encaje de la tapa y de la pila falsa salen de `src/perfil_impresora.scad`; si
  sigue con `perfil_medido = false`, son **valores por defecto, no medidos**.
- Los requisitos de la 002 que esta funcionalidad no menciona se mantienen sin cambios.
- Fuera de alcance: cambiar el firmware, medir la potencia del haz y usar otro láser que no sea el
  303.
