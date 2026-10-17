# Especificación de Funcionalidad: Marcas de orientación y de altura del puntero láser

**Rama de la funcionalidad**: `012-marcas-orientacion`

**Creada**: 2026-10-17

**Estado**: Implementada (pendiente: impresión y prueba física, quickstart §7). La escala va en un disco regulable sobre la polea (research R1).

**Amplía**: [002-puntero-laser-estelar](../002-puntero-laser-estelar/spec.md) y
[005-visor-armado-3d](../005-visor-armado-3d/spec.md)

**Entrada**: Descripción del usuario: "Marcas de orientación y de altura en el puntero láser. (1) Puntos
cardinales: grabar una «S» y una «O» con flecha en las caras laterales de la base fija
(adaptador_tripode), a 90° entre sí, y una marca de índice en el borde de la plataforma de azimut
alineada con la dirección del láser (+Y); cuando el índice coincide con la «S», el láser apunta al
sur. (2) Altura: una marca de 0° y una escala cada 15° grabadas en la polea de altura (gira con la
cuna) y una raya de índice en el brazo del motor; cuando la marca de 0° coincide con el índice, el
láser queda paralelo a la base (horizontal si el trípode está nivelado). Sin nivel de burbuja. Esto
define una posición de partida conocida (base con la «S» al sur, índice en «S», láser a 0°) que el
firmware puede tomar al encender; la alineación con 2 estrellas sigue siendo la que da la precisión
final. La guía debe explicar cómo orientar la base con brújula corrigiendo la declinación magnética
(Argentina, unos 5° a 10° según la zona). Actualizar piezas, STL, guía, web y visor 3D."

## Escenarios de usuario y pruebas *(obligatorio)*

### Historia de usuario 1 - Orientar el aparato al sur y al oeste (Prioridad: P1)

Una persona arma el trípode de noche en el campo. La base del aparato tiene grabadas una «S» y una
«O» con su flecha. Con una brújula (o el celular) gira la base hasta que la «S» mira al sur
geográfico, corrigiendo la declinación magnética como dice la guía. Después gira la plataforma a mano
hasta que su marca de índice queda frente a la «S»: el láser apunta al sur. Si gira la plataforma
hasta la «O», el láser apunta al oeste.

**Por qué esta prioridad**: es el pedido principal. Hoy el aparato no tiene ninguna referencia de
dirección y, al encender, su orientación es desconocida.

**Prueba independiente**: con el aparato armado y la base orientada con una brújula, se pone el
índice frente a la «S» y frente a la «O», y en cada caso se comprueba que el láser apunta a ese punto
cardinal.

**Escenarios de aceptación**:

1. **Dado** la base impresa, **cuando** se mira de costado con el aparato armado, **entonces** la «S»
   y la «O» con su línea de referencia se leen sin desarmar nada y están separadas 90°, con la «O» a la derecha de
   la «S» vista desde arriba (sentido horario, como en una brújula).
2. **Dado** la plataforma montada sobre la base, **cuando** se gira hasta que su índice queda frente a
   la «S», **entonces** el láser apunta en la dirección de la «S» (a 0° de azimut del aparato).
3. **Dado** el índice frente a la «O», **entonces** el láser apunta en la dirección de la «O».
4. **Dado** la guía, **cuando** se busca cómo orientar la base, **entonces** explica cómo usar una
   brújula o el celular, qué es la declinación magnética, cómo aplicar su signo y dónde consultar
   el valor del lugar.

---

### Historia de usuario 2 - Reconocer el láser horizontal y leer su altura (Prioridad: P1)

La persona quiere poner el láser paralelo al horizonte. En el costado del aparato, sobre la polea de
altura, hay un disco con una escala grabada (marca de 0° y rayas cada 15°), y el brazo del motor tiene
una aguja de índice. Gira la cuna hasta que el 0° queda frente al índice: el láser está paralelo a la base y, con
el trípode nivelado, horizontal. Con la misma escala puede leer a ojo a qué altura apunta (15°, 30°,
45°…).

**Por qué esta prioridad**: es la otra mitad del pedido y, junto con la historia 1, define la
posición de partida.

**Prueba independiente**: se pone la marca de 0° frente al índice y se mide con un nivel (o una app
de inclinación) que el láser quedó paralelo a la base; se repite con 45° y 90°.

**Escenarios de aceptación**:

1. **Dado** el aparato armado, **cuando** se mira el lado del motor de altura, **entonces** se ven la
   escala de la polea y el índice del brazo sin sacar la correa ni ninguna pieza.
2. **Dado** el 0° frente al índice, después de poner el cero una vez al armar, **entonces** el eje del
   láser queda paralelo a la cara de apoyo de la base.
5. **Dado** el armado, **cuando** se llega a la puesta a punto, **entonces** la guía explica cómo poner
   el cero de la escala una sola vez (láser paralelo a la mesa, comprobado con el haz en una pared) y
   cómo fijarlo.
3. **Dado** la escala, **cuando** se cuentan las marcas, **entonces** hay una raya cada 15° en todo el
   recorrido de altura del aparato, con el 0°, el 45° y el 90° destacados (más largos o numerados) para
   distinguirlos sin contar.
4. **Dado** una raya de la escala frente al índice, **entonces** el láser está a esa altura con un
   error de lectura de ±2° o menos.

---

### Historia de usuario 3 - Arrancar desde una posición conocida (Prioridad: P2)

Al encender, la persona deja el aparato en la posición de partida: base con la «S» al sur, índice en
la «S» y láser a 0°. La guía le dice que el firmware puede tomar esa posición como punto de partida, y
que después hace la alineación con 2 estrellas como siempre. La primera estrella queda cerca, porque
el aparato ya sabe aproximadamente hacia dónde apunta.

**Por qué esta prioridad**: es el beneficio de las dos marcas juntas, pero depende de ellas y no
cambia la precisión final, que sigue dándola la alineación con 2 estrellas.

**Prueba independiente**: se sigue la guía desde el trípode armado hasta la posición de partida y se
comprueba que el procedimiento está completo y que la alineación con 2 estrellas sigue descrita como
el paso que da la precisión.

**Escenarios de aceptación**:

1. **Dado** la guía, **cuando** se lee la puesta en estación, **entonces** describe la posición de
   partida (base al sur, índice en «S», láser a 0°) antes de la alineación con 2 estrellas.
2. **Dado** la sección del firmware de la guía, **entonces** dice que esa posición corresponde a
   azimut 180° (sur) y altura 0° y que sirve de estimación inicial, no de alineación.

---

### Historia de usuario 4 - Ver las marcas en la web y en el visor 3D (Prioridad: P3)

Quien arma el aparato abre la web y el visor 3D y ve las letras, el índice, la escala y la raya del
brazo en las piezas, igual que en las piezas impresas.

**Por qué esta prioridad**: completa el pipeline; las marcas físicas sirven aunque la web no las
muestre.

**Prueba independiente**: se abre el visor y se acerca la cámara a la base y a la polea.

**Escenarios de aceptación**:

1. **Dado** el visor 3D, **cuando** se acerca la cámara a la base, la plataforma, la polea de altura y
   el brazo del motor, **entonces** se ven las marcas.
2. **Dado** la web de armado, **cuando** se lee la puesta en estación, **entonces** incluye la
   orientación de la base y la posición de partida.

---

### Casos límite

- **Imanes de los motores**: los motores paso a paso tienen imanes que desvían la brújula. La guía
  pide tomar el rumbo a más de 50 cm del aparato y alinear la base con un objeto lejano.
- **Lectura en la oscuridad**: las marcas grabadas en un filamento oscuro casi no se ven con poca luz.
  La guía sugiere rellenarlas con pintura o marcador claro (o fosforescente) y alumbrarlas con una luz
  roja.
- **Hemisferio**: el diseño marca el sur y el oeste. En el hemisferio norte la «S» sigue siendo válida,
  pero la guía no cubre otras declinaciones fuera de Argentina, salvo decir dónde consultarlas.
- **Trípode desnivelado**: el 0° de la escala marca paralelo a la base, no al horizonte. La guía lo dice
  y repite que hay que nivelar el trípode (±2°, como hoy).
- **Base enroscada en otra posición**: la base se enrosca en el trípode y queda en cualquier ángulo. Se
  orienta girando el trípode o la cabeza del trípode, no aflojando la rosca. La guía lo aclara.
- **Interferencias**: las marcas no pueden tocar la correa, los dientes de las poleas, los alojamientos
  de los 608, la ventana de la llave ni el recorrido de los cables, ni cambiar los encajes.
- **Recorrido de altura**: la escala cubre solo el rango que el aparato alcanza; si una raya queda
  tapada por el brazo o el motor en algún ángulo, se omite y se documenta.
- **Firmware**: el diseño no incluye el firmware; la guía describe qué debe hacer con la posición de
  partida, como ya hace con los pasos y los sentidos de giro.

## Requisitos *(obligatorio)*

### Requisitos funcionales

- **FR-001**: La base fija DEBE llevar grabadas una «S» y una «O», cada una con una línea de referencia
  vertical que marca su dirección exacta, separadas 90° y con la «O» en sentido horario respecto de la
  «S» vista desde arriba.
- **FR-002**: La «S» DEBE estar en la dirección a la que apunta el láser cuando la plataforma está en
  0° de azimut, de modo que índice frente a la «S» equivalga a láser apuntando hacia la «S».
- **FR-003**: La plataforma de azimut DEBE llevar una marca de índice en su borde, alineada con la
  dirección del láser y legible junto a las letras de la base.
- **FR-004**: La polea de altura DEBE llevar una escala, grabada en un disco que gira con ella, con
  una raya cada 15° de 0° a 90° y el 0°, el 45° y el 90° destacados. El cero DEBE poder ajustarse una
  vez al armar y quedar fijo, porque el ángulo de la polea respecto de la cuna depende de cuánto se
  aprieta su perno.
- **FR-005**: El brazo del motor DEBE llevar una aguja de índice frente a la escala, en el mismo plano
  que ella, tal que el 0° frente al índice equivalga al láser paralelo a la base una vez puesto el cero.
- **FR-005b**: La guía DEBE explicar cómo poner el cero de la escala con herramientas comunes (cinta
  métrica y el haz en una pared) y cómo fijarlo.
- **FR-006**: Las marcas DEBEN poder imprimirse sin soportes en la orientación de impresión actual de
  cada pieza y verse con el aparato armado.
- **FR-007**: Las marcas NO DEBEN cambiar los encajes, la resistencia de las piezas ni el recorrido de
  correas y cables; las comprobaciones de choque del ensamblaje DEBEN seguir pasando.
- **FR-008**: Las STL de las piezas con marcas DEBEN regenerarse; las demás quedan iguales.
- **FR-009**: La guía DEBE explicar cómo orientar la base al sur con brújula o celular, corrigiendo la
  declinación magnética, con el sentido de la corrección (cómo saber si sumar o restar según el signo
  del valor) y dónde consultar el valor del lugar.
- **FR-010**: La guía DEBE describir la posición de partida (base con la «S» al sur, índice en «S»,
  láser a 0°) y, en la sección del firmware, cómo tomarla al encender como estimación inicial antes de
  la alineación con 2 estrellas.
- **FR-011**: La guía DEBE aclarar que el 0° es paralelo a la base y solo es horizontal con el trípode
  nivelado, y sugerir cómo resaltar las marcas para leerlas de noche.
- **FR-012**: El visor 3D, las vistas explotadas que muestran las piezas cambiadas y la web DEBEN
  regenerarse y mostrar las marcas.

### Entidades clave

- **Marca cardinal**: letra («S» u «O») con su flecha en la base fija; tiene dirección y ángulo
  respecto del 0° de azimut.
- **Índice de azimut**: marca de la plataforma que indica hacia dónde apunta el láser.
- **Escala de altura**: disco con rayas cada 15°, montado sobre la polea de altura con el cero regulable.
- **Índice de altura**: aguja fija del brazo del motor frente a la escala.
- **Posición de partida**: azimut del sur (180°) y altura 0°, que se logra alineando las marcas.

## Criterios de éxito *(obligatorio)*

### Resultados medibles

- **SC-001**: Con la base orientada con una brújula, poner el láser apuntando al sur u oeste lleva
  menos de 1 minuto y no requiere herramientas.
- **SC-002**: Con la base orientada con una brújula y el índice frente a una letra, el láser apunta a
  ese punto cardinal con un error de ±5° o menos (brújula y lectura a ojo incluidas). Alcanza para
  que la primera estrella de la alineación quede cerca.
- **SC-003**: Con el 0° de la escala frente al índice, el láser queda paralelo a la base con un error de
  ±2° o menos, comprobado con un medidor de inclinación.
- **SC-004**: Las piezas con marcas se imprimen sin soportes nuevos y pasan la verificación y las
  comprobaciones de choque sin cambios en los encajes.
- **SC-005**: Una persona que no conoce el aparato llega a la posición de partida siguiendo solo la
  guía, sin preguntar.

## Supuestos

- Las marcas son grabados (bajorrelieve) de unos 0,6 mm de profundidad, como la marca «+» de la pila
  falsa. La escala de altura va en una pieza impresa nueva (el disco), fijada con 2 tornillos M3
  autorroscantes con arandela: son los únicos renglones nuevos de la lista de materiales.
- Los márgenes de error (±5° en azimut, ±2° en altura) vienen de la brújula, del juego entre piezas
  y de la lectura a ojo; la precisión final la da la alineación con 2 estrellas, que no cambia.
- Sin nivel de burbuja: la nivelación del trípode sigue siendo a ojo (±2°), como hoy.
- La declinación magnética en Argentina cambia de valor, y en algunas zonas de signo, según el lugar
  (del orden de 5° a 10° en buena parte del país). El valor de cada zona se consulta en un calculador
  oficial (por ejemplo, el de la NOAA) y se verifica al escribir la guía. La guía no usa un valor fijo.
- El firmware no es parte del diseño; la guía describe lo que debe hacer con la posición de partida.
- No hay cargas nuevas: no hace falta simulación FEM. Los grabados poco profundos en zonas sin esfuerzo
  se justifican en el plan.
- Las marcas aparecen en el visor 3D porque salen de la geometría del ensamblaje, no como etiquetas
  aparte.
