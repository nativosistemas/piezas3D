# Especificación de Funcionalidad: Soporte de pared paramétrico para taladro

**Rama de la funcionalidad**: N/A (sin hook de creación de rama; se trabaja sobre `main`)

**Creada**: 2026-10-04

**Estado**: Implementada (pendiente de la prueba física)

**Entrada**: Descripción del usuario: "Soporte de pared paramétrico para un taladro, con ancho, profundidad y diámetro de tornillos ajustables"

## Escenarios de usuario y pruebas *(obligatorio)*

### Historia de usuario 1 - Fabricar e instalar el soporte con valores por defecto (Prioridad: P1)

Una persona aficionada al bricolaje quiere guardar su taladro atornillador inalámbrico colgado en la
pared del taller. Toma el diseño con sus valores por defecto, imprime la pieza en una impresora 3D
doméstica de filamento, la atornilla a la pared siguiendo la guía de producción y cuelga el taladro
con la punta (portabrocas) hacia abajo, pasando el portabrocas por la ranura frontal del soporte de
modo que el cuerpo del taladro descanse sobre la bandeja.

**Por qué esta prioridad**: es el valor central de la funcionalidad: una pieza física, lista para
imprimir y montar, que sostiene un taladro estándar de forma segura sin que el usuario tenga que
modificar nada.

**Prueba independiente**: se imprime la pieza por defecto, se fija a una pared con la tornillería
indicada en la guía y se cuelga un taladro inalámbrico típico con batería; el taladro queda estable,
se puede sacar y volver a colocar con una mano y la pieza no presenta grietas ni deformación visible.

**Escenarios de aceptación**:

1. **Dado** el diseño con sus valores por defecto, **cuando** se prepara para imprimir, **entonces**
   la pieza se imprime en una sola pieza, sin material de soporte, en una cama de impresión de
   180 × 180 mm o mayor.
2. **Dado** el soporte impreso y fijado a la pared con 2 tornillos del diámetro por defecto,
   **cuando** se cuelga un taladro inalámbrico de hasta 2,5 kg (con batería), **entonces** el taladro
   queda retenido por el portabrocas en la ranura, sin caerse ni balancearse hasta salirse.
3. **Dado** el taladro colgado, **cuando** el usuario lo retira y lo vuelve a colocar con una sola
   mano, **entonces** la operación no requiere forzar la pieza ni herramientas.
4. **Dado** el diseño entregado, **cuando** el usuario consulta la guía de producción, **entonces**
   encuentra la orientación de impresión, los parámetros del laminador, el material recomendado, la
   lista de tornillería y los pasos de instalación en pared.

---

### Historia de usuario 2 - Adaptar el soporte a un taladro y una tornillería concretos (Prioridad: P2)

El usuario tiene un taladro más grande (o más pequeño) que el de referencia, o dispone de tornillos de
otro diámetro. Ajusta los parámetros de ancho, profundidad y diámetro de tornillo (y, si lo necesita,
el ancho de la ranura del portabrocas) en la sección de parámetros del diseño y obtiene una nueva pieza
coherente con esos valores, sin tener que modificar la geometría.

**Por qué esta prioridad**: la parametrización es lo que convierte la pieza en un generador
reutilizable; sin ella solo serviría para un taladro concreto.

**Prueba independiente**: se cambian el ancho, la profundidad y el diámetro de tornillo a valores
dentro de los rangos admitidos, se regenera la pieza y se miden en el modelo resultante las cotas
afectadas; coinciden con los valores introducidos (dentro de la tolerancia declarada).

**Escenarios de aceptación**:

1. **Dado** el diseño, **cuando** el usuario cambia el ancho a 100 mm, **entonces** la pieza generada
   mide 100 mm de ancho y la ranura sigue centrada.
2. **Dado** el diseño, **cuando** el usuario cambia la profundidad a 130 mm, **entonces** la bandeja
   sobresale 130 mm de la pared y los refuerzos laterales se escalan en proporción.
3. **Dado** el diseño, **cuando** el usuario cambia el diámetro de tornillo de 5 mm a 4 mm,
   **entonces** los orificios de fijación y sus avellanados se recalculan para ese tornillo, con la
   holgura de paso declarada.
4. **Dado** el diseño, **cuando** el usuario introduce una combinación imposible (p. ej., una ranura
   más ancha que el ancho disponible), **entonces** la generación se detiene con un mensaje que indica
   qué parámetro está fuera de rango y cuál es el límite.

---

### Historia de usuario 3 - Verificar la capacidad de carga antes de imprimir (Prioridad: P3)

Antes de gastar filamento, el usuario (o quien revisa el diseño) quiere comprobar que la pieza
soporta el peso del taladro con margen de seguridad, en especial cuando ha aumentado la profundidad o
reducido el espesor. Para ello dispone de una validación estructural documentada con la carga, las
fijaciones, el material y los criterios de aceptación.

**Por qué esta prioridad**: el soporte trabaja en voladizo y está sometido a carga permanente; la
validación reduce el riesgo de rotura o fluencia, pero la pieza por defecto ya está dimensionada con
margen, por lo que es secundaria frente a poder fabricarla y adaptarla.

**Prueba independiente**: se sigue la guía de validación estructural con la configuración por defecto
y se comprueba que los resultados (tensión máxima y desplazamiento en el borde frontal) cumplen los
criterios de aceptación definidos.

**Escenarios de aceptación**:

1. **Dado** el diseño por defecto en el material recomendado, **cuando** se aplica la carga de diseño
   de 25 N, **entonces** la tensión máxima no supera un tercio del límite del material (factor de
   seguridad ≥ 3) y el desplazamiento del borde frontal no supera 1 mm.
2. **Dado** un resultado que no cumple los criterios, **cuando** se consulta la guía, **entonces**
   esta indica qué parámetros conviene ajustar (espesor, refuerzos, profundidad) antes de imprimir.

---

### Casos límite

- **Ranura demasiado ancha para el ancho de la pieza**: si el material que queda a cada lado de la
  ranura es inferior al mínimo resistente, la generación debe rechazarse con un mensaje explicativo.
- **Tornillo demasiado grande para la placa trasera**: si el avellanado de la cabeza no cabe con el
  margen mínimo al borde, o atraviesa el espesor de la placa, la generación debe rechazarse.
- **Profundidad insuficiente**: si la profundidad no deja holgura entre el cuerpo del taladro
  (centro de la ranura) y la pared, la generación debe rechazarse.
- **Profundidad muy grande**: al aumentar el voladizo crece el momento sobre los tornillos superiores;
  por encima del rango validado la guía debe exigir repetir la validación estructural.
- **Tornillo muy pequeño**: diámetros por debajo de 3 mm no se admiten por insuficiente resistencia
  al arranque en la pared.
- **Taladro con portabrocas más ancho que la ranura**: el usuario debe poder ampliar la ranura por
  parámetro; la guía indica cómo medir el portabrocas para elegir el valor.
- **Valores no numéricos, negativos o cero**: se rechazan con mensaje.

## Requisitos *(obligatorio)*

### Requisitos funcionales

**Geometría y uso**

- **FR-001**: El diseño DEBE producir una pieza única formada por una placa trasera de fijación a
  pared y una bandeja horizontal en voladizo, unidas por refuerzos laterales (cartelas).
- **FR-002**: La bandeja DEBE tener una ranura en forma de U, abierta hacia el frente y centrada en
  el ancho, por la que pasa el portabrocas del taladro mientras el cuerpo del taladro apoya sobre la
  bandeja.
- **FR-003**: La entrada de la ranura y las aristas de contacto con el taladro DEBEN estar
  redondeadas o achaflanadas para guiar la inserción y no rayar la herramienta.
- **FR-004**: La placa trasera DEBE incluir orificios pasantes para la fijación a pared con
  avellanado para cabeza plana, de modo que la cabeza del tornillo quede enrasada o por debajo de la
  superficie.

**Parámetros ajustables**

- **FR-005**: El usuario DEBE poder ajustar como mínimo estos parámetros, con estos valores por
  defecto y rangos admitidos:

  | Parámetro | Por defecto | Rango admitido |
  |-----------|-------------|----------------|
  | Ancho de la pieza | 80 mm | 50 – 150 mm |
  | Profundidad (vuelo de la bandeja desde la pared) | 100 mm | 60 – 160 mm |
  | Diámetro nominal del tornillo | 5 mm | 3 – 8 mm |
  | Ancho de la ranura del portabrocas | 46 mm | 30 – 60 mm |
  | Espesor de bandeja y placa trasera | 6 mm | 4 – 10 mm |
  | Altura de la placa trasera | 70 mm | 50 – 120 mm |
  | Holgura de paso del tornillo | 0,4 mm | 0,2 – 1,0 mm |

- **FR-006**: Todas las dimensiones de la pieza DEBEN derivarse de los parámetros declarados; cambiar
  un parámetro NO DEBE requerir editar la geometría.
- **FR-007**: El diámetro de los orificios de fijación DEBE ser igual al diámetro nominal del tornillo
  más la holgura de paso, y el diámetro del avellanado DEBE calcularse a partir del diámetro nominal
  (cabeza plana estándar, 90°).
- **FR-008**: La ranura DEBE permanecer centrada en el ancho y su centro DEBE situarse a una distancia
  de la pared suficiente para que el cuerpo del taladro no toque la pared ni la placa trasera.
- **FR-009**: Los orificios de fijación DEBEN ubicarse en la parte alta de la placa trasera, por
  encima de la bandeja, separados horizontalmente lo máximo posible respetando un margen al borde de
  al menos un diámetro de cabeza de tornillo.

**Validación de parámetros**

- **FR-010**: La generación DEBE rechazar, con un mensaje que identifique el parámetro y su límite,
  cualquier valor fuera de rango y cualquier combinación incoherente: material lateral junto a la
  ranura inferior a 2 veces el espesor, avellanado sin margen al borde o más profundo que la placa,
  y profundidad que no deje holgura entre la ranura y la pared.

**Manufactura**

- **FR-011**: Con los valores por defecto, la pieza DEBE poder imprimirse en impresora de filamento
  (FDM) sin material de soporte, con voladizos no superiores a 45° en la orientación recomendada.
- **FR-012**: Ninguna sección de la pieza DEBE tener menos de 1,2 mm de espesor (3 líneas de
  extrusión de 0,4 mm).
- **FR-013**: La pieza DEBE entregarse como archivo de malla imprimible que corresponda exactamente
  a los valores de parámetros documentados; si los parámetros cambian, el archivo DEBE regenerarse.

**Validación estructural**

- **FR-014**: El diseño por defecto DEBE validarse estructuralmente frente a una carga de diseño de
  2,5 kg (≈ 25 N) aplicada sobre la cara superior de la bandeja, comprobando además el caso pésimo
  con la carga concentrada en el borde frontal (labios), con factor de seguridad 3, la placa
  trasera fijada en los orificios de los tornillos y apoyada contra la pared, y el material
  recomendado.
- **FR-015**: La validación DEBE documentar el material asignado, las fijaciones, las cargas, los
  resultados (tensión máxima y desplazamiento del borde frontal) y los criterios de aceptación.

**Documentación**

- **FR-016**: DEBE entregarse una guía de producción con: orientación de impresión, relleno,
  perímetros, soportes, adherencia, material recomendado, lista de materiales (tornillos y tacos
  según el diámetro por defecto) e instrucciones paso a paso de instalación en pared.
- **FR-017**: La guía DEBE explicar cómo medir el portabrocas y el cuerpo del taladro para elegir el
  ancho de ranura y la profundidad, y cuándo es necesario repetir la validación estructural.

### Entidades clave

- **Conjunto de parámetros del soporte**: valores que definen la pieza (ancho, profundidad, diámetro
  de tornillo, ancho de ranura, espesor, altura de placa, holgura); cada uno con valor por defecto,
  rango admitido y unidad (mm).
- **Taladro soportado**: herramienta que cuelga del soporte; se caracteriza por el diámetro exterior
  del portabrocas (debe pasar por la ranura), el diámetro del cuerpo/caja de engranajes (debe apoyar
  sobre la bandeja) y su peso con batería (carga).
- **Tornillería de fijación**: tornillos de cabeza plana avellanada del diámetro nominal elegido y
  sus tacos de pared; cantidad, longitud y tipo se recogen en la lista de materiales.
- **Pieza fabricada**: resultado imprimible derivado de un conjunto de parámetros concreto.
- **Guía de producción y validación**: documentos que acompañan a la pieza (impresión, instalación,
  validación estructural).

## Criterios de éxito *(obligatorio)*

### Resultados medibles

- **SC-001**: La pieza por defecto se imprime sin material de soporte y sin fallos de impresión en el
  primer intento siguiendo la guía.
- **SC-002**: La pieza por defecto, instalada en pared, sostiene un taladro de 2,5 kg durante al
  menos 7 días sin grietas, holgura en los tornillos ni flecha del borde frontal superior a 1 mm.
- **SC-003**: La validación estructural del diseño por defecto muestra un factor de seguridad ≥ 3
  respecto al límite del material y un desplazamiento del borde frontal ≤ 1 mm bajo la carga de
  diseño.
- **SC-004**: Para cualquier combinación de parámetros dentro de rango, las cotas medidas en la pieza
  generada coinciden con los valores introducidos con una desviación ≤ 0,1 mm en el modelo.
- **SC-005**: El 100 % de las combinaciones de parámetros inválidas descritas en los casos límite se
  rechazan con un mensaje que identifica el parámetro.
- **SC-006**: Un usuario puede adaptar el soporte a su taladro (medir, cambiar parámetros y regenerar)
  en menos de 10 minutos, sin editar la geometría.
- **SC-007**: Un usuario sin conocimiento previo del diseño instala el soporte en pared siguiendo la
  guía en menos de 15 minutos, y cuelga o retira el taladro con una mano en menos de 3 segundos.

## Supuestos

- El taladro de referencia es un taladro atornillador inalámbrico tipo pistola, con portabrocas de
  hasta ~44 mm de diámetro exterior, cuerpo/caja de engranajes de más de 50 mm y peso con batería de
  hasta 2,5 kg; taladros más pesados (p. ej., percutores con cable de más de 2,5 kg) quedan fuera del
  rango validado.
- El taladro cuelga con el portabrocas hacia abajo y la empuñadura orientada hacia el frente o hacia un
  lado (no hacia la pared), por lo que la profundidad solo debe dejar holgura para el cuerpo.
- La fijación por defecto es con 2 tornillos de cabeza plana avellanada de 5 mm de diámetro y tacos
  adecuados al tipo de pared; la elección del taco según la pared (ladrillo, hormigón, pladur) la
  indica la guía, pero queda fuera del alcance de la pieza.
- El material recomendado por defecto es PETG (mejor resistencia a fluencia bajo carga permanente
  que el PLA); el PLA se admite como alternativa para uso en interiores a temperatura ambiente.
- La impresora objetivo es una FDM doméstica con boquilla de 0,4 mm y cama de al menos 180 × 180 mm.
- Quedan fuera del alcance: portabrocas/puntas adicionales, compartimentos para baterías o cargador,
  y soportes para varias herramientas; podrán abordarse en funcionalidades posteriores.
- Las herramientas, formatos y estructura de carpetas los fija la constitución del proyecto
  (`.specify/memory/constitution.md`), que exige el pipeline diseño → validación → exportación →
  documentación; esta especificación no los redefine.
