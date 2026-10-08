# Especificación de Funcionalidad: Caja con tapa a presión para 4 pilas AA

**Rama de la funcionalidad**: `004-caja-pilas-aa`

**Creada**: 2026-10-06

**Estado**: Implementada (pendiente de las pruebas físicas)

**Entrada**: Descripción del usuario: "Quiero una caja con tapa a presión para guardar 4 pilas AA."

## Escenarios de usuario y pruebas *(obligatorio)*

### Historia de usuario 1 - Imprimir la caja y guardar las pilas (Prioridad: P1)

Una persona quiere llevar 4 pilas AA de repuesto en la mochila o en un cajón sin que se mezclen con
otras cosas ni hagan contacto entre sí. Imprime las dos piezas con los valores por defecto, coloca
las pilas en sus alojamientos, cierra la tapa empujándola con el pulgar hasta oír o sentir el
encastre y la abre después tirando de la tapa con la uña o la yema del dedo, sin herramientas.

**Por qué esta prioridad**: es el valor central del diseño: un estuche físico, listo para imprimir,
que guarda las pilas y se abre y se cierra a mano.

**Prueba independiente**: se imprimen la caja y la tapa, se cargan 4 pilas AA, se cierra la tapa, se
sacude la caja cerrada y se la deja caer desde la altura de una mesa; la tapa sigue cerrada y las
pilas siguen cada una en su alojamiento. Después se abre a mano.

**Escenarios de aceptación**:

1. **Dado** el diseño por defecto, **cuando** se prepara para imprimir, **entonces** cada pieza se
   imprime sin material de soporte en una cama de 200 × 200 mm o mayor.
2. **Dado** la caja vacía, **cuando** se coloca una pila AA en cada alojamiento, **entonces** cada pila
   entra por su peso, sin forzarla, y queda separada de las vecinas.
3. **Dado** la caja cargada, **cuando** se apoya la tapa y se la empuja con el pulgar, **entonces** la
   tapa encastra sin herramientas y queda al ras del borde de la caja.
4. **Dado** la caja cerrada, **cuando** se la sacude con fuerza en cualquier dirección, **entonces** la
   tapa no se abre y ninguna pila pasa al alojamiento de al lado.
5. **Dado** la caja cerrada, **cuando** el usuario mete la uña en la muesca de apertura y levanta la
   tapa, **entonces** la tapa se suelta con una sola mano o con las dos, sin herramientas.
6. **Dado** la caja abierta, **cuando** se la da vuelta sobre la mano, **entonces** las pilas caen solas.

---

### Historia de usuario 2 - Adaptar la caja a otra cantidad de pilas o a otras medidas (Prioridad: P2)

El usuario quiere guardar 2, 6 u 8 pilas, o pilas de otro tamaño cilíndrico (por ejemplo AAA o
recargables algo más gruesas). Cambia la cantidad, el diámetro y el largo de la pila en la sección de
parámetros y obtiene una caja y una tapa coherentes que siguen encastrando, sin tocar la geometría.

**Por qué esta prioridad**: convierte la pieza en un generador reutilizable, pero el caso de 4 pilas
AA ya resuelve el pedido.

**Prueba independiente**: se cambian la cantidad y las medidas de la pila a valores dentro de rango,
se regeneran las dos piezas y se comprueba en el modelo que las medidas exteriores cambian según los
parámetros y que el encastre sigue alineado entre caja y tapa.

**Escenarios de aceptación**:

1. **Dado** el diseño, **cuando** el usuario cambia la cantidad de pilas de 4 a 6, **entonces** la
   caja y la tapa se alargan en el ancho de dos alojamientos y el encastre sigue alineado.
2. **Dado** el diseño, **cuando** el usuario cambia el diámetro y el largo de la pila a los de una AAA
   (10,5 × 44,5 mm), **entonces** la caja y la tapa se achican en proporción.
3. **Dado** el diseño, **cuando** el usuario introduce un valor imposible (pared más fina que el mínimo
   imprimible, encastre que deformaría la tapa más de lo que el material admite, caja más grande que
   la cama), **entonces** la generación se detiene con un mensaje que nombra el parámetro y su límite.

---

### Casos límite

- **Pilas de distinto fabricante**: el diámetro de una AA va de 13,5 a 14,5 mm y el largo de 49,2 a
  50,5 mm. Los alojamientos se dimensionan para la medida máxima, así que las más chicas entran con
  algo de juego.
- **Pila que salta de alojamiento**: con la caja cerrada, el recorrido vertical libre de una pila tiene
  que ser menor que la altura de los separadores, para que no pueda pasar por encima de ellos.
- **Encastre demasiado duro o flojo**: depende de la impresora. Mientras el perfil de impresora no esté
  medido, la guía tiene que avisarlo y explicar qué parámetro tocar.
- **Pestañas del encastre que se rompen**: la deformación del material al cerrar tiene que quedar por
  debajo del límite que admite el plástico en uso repetido; si un parámetro la supera, la generación
  se rechaza.
- **Tapa al revés**: la tapa tiene que encastrar en las dos orientaciones posibles (girada 180°).
- **Valores negativos, cero o fuera de rango**: se rechazan con un mensaje.

## Requisitos *(obligatorio)*

### Requisitos funcionales

**Geometría y uso**

- **FR-001**: El diseño DEBE estar formado por dos piezas impresas: una caja con un alojamiento por
  pila y una tapa que cierra la caja.
- **FR-002**: Las pilas DEBEN guardarse acostadas, una al lado de la otra, cada una en su alojamiento,
  separadas por tabiques que impiden el contacto entre pilas.
- **FR-003**: La tapa DEBE cerrar a presión, sin tornillos, imanes ni bisagras, mediante pestañas
  flexibles que enganchan en la caja.
- **FR-004**: La tapa DEBE poder abrirse a mano gracias a una muesca en el borde de la caja que deja
  meter la uña o la yema del dedo debajo de la tapa.
- **FR-005**: La tapa DEBE encastrar en sus dos orientaciones posibles (girada 180°).
- **FR-006**: Con la caja cerrada, una pila NO DEBE poder pasar de un alojamiento a otro.

**Parámetros ajustables**

- **FR-007**: El usuario DEBE poder ajustar como mínimo estos parámetros, con estos valores por
  defecto y rangos admitidos:

  | Parámetro | Por defecto | Rango admitido |
  |-----------|-------------|----------------|
  | Cantidad de pilas | 4 | 1 – 10 |
  | Diámetro de la pila | 14,5 mm | 8 – 20 mm |
  | Largo de la pila | 50,5 mm | 30 – 70 mm |
  | Espesor de pared | 2,0 mm | 1,6 – 4 mm |
  | Espesor de piso y de tapa | 2,0 mm | 1,2 – 4 mm |

- **FR-008**: Todas las medidas de la caja y de la tapa DEBEN derivarse de los parámetros; las medidas
  compartidas por las dos piezas DEBEN declararse en un solo lugar para que sigan encastrando.
- **FR-009**: Las holguras de los alojamientos y del encastre DEBEN salir del perfil de impresora del
  proyecto.

**Validación de parámetros**

- **FR-010**: La generación DEBE rechazar, con un mensaje que nombre el parámetro y su límite: paredes
  o pisos más finos que el mínimo imprimible, pestañas cuya deformación al cerrar supere el límite
  admisible del material, separadores más bajos que el recorrido libre de la pila y piezas que no
  entren en la cama.

**Manufactura**

- **FR-011**: Cada pieza DEBE imprimirse sin material de soporte, con voladizos no mayores de 45°, la
  caja con la abertura hacia arriba y la tapa con su cara exterior sobre la cama.
- **FR-012**: Ninguna sección DEBE tener menos de 1,2 mm de espesor.
- **FR-013**: Cada pieza DEBE entregarse como archivo de malla imprimible que corresponda exactamente
  a los parámetros documentados.

**Documentación**

- **FR-014**: DEBE entregarse una guía de producción con orientación de impresión, parámetros del
  laminador, material recomendado, lista de materiales y pasos de armado y uso, y una web de armado
  con los componentes y su precio en ARS y USD.
- **FR-015**: La guía DEBE explicar qué parámetro ajustar si el encastre sale duro o flojo.

### Entidades clave

- **Pila**: cilindro de diámetro y largo dados; es lo que se guarda, no un componente del diseño.
- **Caja**: pieza con piso, paredes, tabiques entre alojamientos, ranuras de encastre y muesca de
  apertura.
- **Tapa**: placa con una pollera interior que entra en la caja y lleva las pestañas flexibles.
- **Conjunto de parámetros**: valores compartidos por las dos piezas, con valor por defecto, rango y
  unidad (mm).

## Criterios de éxito *(obligatorio)*

### Resultados medibles

- **SC-001**: Las dos piezas por defecto se imprimen sin soportes y sin fallos en el primer intento
  siguiendo la guía.
- **SC-002**: Las 4 pilas se cargan en menos de 15 segundos y se vacían dando vuelta la caja en
  menos de 3 segundos.
- **SC-003**: La tapa se cierra y se abre a mano 50 veces seguidas sin que se rompa ni se afloje una
  pestaña.
- **SC-004**: Cerrada y con las 4 pilas, la caja cae desde 75 cm sobre un piso duro sin abrirse.
- **SC-005**: Para cualquier combinación de parámetros dentro de rango, las medidas exteriores del
  modelo coinciden con las calculadas a partir de los parámetros con una desviación ≤ 0,1 mm.
- **SC-006**: El 100 % de las combinaciones inválidas descritas en los casos límite se rechazan con un
  mensaje que nombra el parámetro.

## Supuestos

- Medidas de la pila AA según IEC 60086 (LR6): diámetro máximo 14,5 mm y largo máximo 50,5 mm. Los
  alojamientos usan los máximos más la holgura del perfil de impresora.
- Las pilas van acostadas en una sola fila (4 × 1): da la caja más chata, del tamaño de un bolsillo.
- Las pilas se sacan dando vuelta la caja; no hay mecanismo para extraerlas de a una.
- Las holguras de encaje son **valores por defecto, no medidos** (`perfil_medido = false` en el
  perfil de impresora): el encastre puede salir algo duro o flojo hasta calibrar la impresora.
- Material por defecto: PETG, que admite más deformación repetida que el PLA en las pestañas. El PLA
  sirve si se acepta un encastre más rígido.
- Impresora FDM con boquilla de 0,4 mm y cama de 220 × 220 mm, según el perfil del proyecto.
- La caja no es estanca ni resiste golpes fuertes; no está pensada para pilas dañadas o con pérdidas.
- La lista de materiales solo incluye el filamento: las pilas son lo que se guarda, no parte del
  diseño.
- Fuera de alcance: contactos eléctricos, indicador de pilas cargadas o descargadas, bisagra y
  versiones estancas.
