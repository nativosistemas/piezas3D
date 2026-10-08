# Especificación de Funcionalidad: Visor 3D de armado paso a paso

**Rama de la funcionalidad**: `005-visor-armado-3d`

**Creada**: 2026-10-08

**Estado**: Implementada (pendiente la prueba en un celular real: quickstart, escenario 7)

**Entrada**: Descripción del usuario: "Visor 3D de armado paso a paso como parte de la fase 5 (web de
armado) del pipeline de piezas3D, para todos los diseños de varias piezas con ensamblaje. A partir de
la tabla de pasos del _ensamblaje.scad (elementos, desplazamiento de la vista explotada, resaltar,
origen opcional) y del catálogo elemento(e), generar un visor 3D interactivo donde las piezas de cada
paso se animan desde su posición explotada hasta su lugar final; lo ya armado se ve transparente; se
puede girar, acercar, avanzar y retroceder pasos, repetir y recorrer la animación con un deslizador;
muestra el título y el texto del paso de la guía y la lista de piezas. Debe generarse automáticamente
con scripts/generar_web.py (sin trabajo manual por diseño), funcionar abriendo el archivo local (sin
servidor), en computadora y celular. Prototipo validado con el puntero láser (pasos 5–8): exporta cada
elemento con OpenSCAD (parámetro solo_elemento), mallas incrustadas en el HTML (1,1 MB para 15
piezas), three.js. Decisiones abiertas: three.js incluido en el repositorio para funcionar sin
internet o desde CDN; visor dentro de la web de armado o página aparte; gestos además de traslaciones
(giros como enroscar la polea); límite de tamaño con todos los pasos; realidad aumentada sobre la mesa
en Android (WebXR) como extra opcional."

## Aclaraciones

### Sesión 2026-10-08

- P: ¿Dónde va el visor respecto de la web de armado? → R: En una página aparte, junto a la web,
  enlazada desde ella y desde cada paso. La web sigue liviana y con las capturas para imprimir.
- P: ¿La realidad aumentada sobre la mesa (Android) entra en esta funcionalidad? → R: No; queda para
  una funcionalidad posterior, cuando el visor esté andando.
- P: ¿El visor es obligatorio para todo diseño de varias piezas? → R: Sí. Se enmienda la constitución
  (Principio V y puerta 5) y la comprobación de la puerta 5 lo exige.

## Escenarios de usuario y pruebas *(obligatorio)*

### Historia de usuario 1 - Seguir el armado en 3D, paso a paso (Prioridad: P1)

Una persona que nunca vio el diseño tiene las piezas impresas y los componentes sobre la mesa. Abre
el visor de armado y ve el primer paso: las piezas que se colocan en ese paso aparecen en color,
separadas, y se deslizan hasta su lugar siguiendo el mismo recorrido que tienen en la mano. Lo que ya
estaba armado se ve transparente. Gira la vista para mirar desde abajo, acerca para ver dónde entra
una tuerca, repite el movimiento, lo frena en la mitad con un deslizador y pasa al paso siguiente
cuando lo terminó. Al lado de la vista lee el título y el texto del paso de la guía y la lista de
piezas nuevas.

**Por qué esta prioridad**: es el valor central de la funcionalidad. Las capturas fijas muestran el
principio y el final de cada movimiento; el visor muestra el recorrido y deja mirar desde cualquier
lado, que es lo que resuelve las dudas de armado ("¿por dónde entra la tuerca?", "¿los brazos van
fijos?").

**Prueba independiente**: se genera el visor del puntero láser y una persona que no participó del
diseño arma la horquilla (pasos 5 a 8) guiándose solo con el visor; identifica en cada paso qué piezas
se colocan, por dónde entran y en qué orden.

**Escenarios de aceptación**:

1. **Dado** un diseño con su visor generado, **cuando** la persona lo abre, **entonces** ve el paso 1
   con su número, título y texto de la guía, y las piezas de ese paso se mueven desde su posición
   separada hasta su lugar.
2. **Dado** un paso mostrado, **cuando** la persona avanza o retrocede, **entonces** el visor muestra
   el paso elegido, las piezas de los pasos anteriores quedan en su lugar y en transparente, y las de
   pasos posteriores no aparecen.
3. **Dado** un paso en el que una pieza entra en otra que también se mueve (por ejemplo, una tuerca
   que entra de costado en un brazo que baja), **cuando** se reproduce el paso, **entonces** primero la
   pieza entra en la que la recibe y después las dos llegan juntas a su lugar.
4. **Dado** cualquier momento de la animación, **cuando** la persona mueve el deslizador, **entonces**
   las piezas se ubican en ese punto del recorrido y quedan quietas hasta que pida repetir o cambie de
   paso.
5. **Dado** el visor abierto, **cuando** la persona arrastra, pellizca o usa la rueda, **entonces** la
   vista gira, se acerca o se desplaza, y un control la devuelve a la vista inicial.
6. **Dado** un paso sin piezas nuevas (cableado, puesta a punto), **cuando** se lo muestra,
   **entonces** se ve el texto del paso con el conjunto armado hasta ese momento, sin animación.
7. **Dado** un diseño cuyas partes se arman por separado y se unen después (subconjuntos), **cuando**
   se muestra un paso de un subconjunto, **entonces** solo aparece lo ya armado de ese subconjunto,
   con el mismo criterio que las capturas de la guía.

---

### Historia de usuario 2 - El visor sale solo para cualquier diseño (Prioridad: P1)

Quien diseña termina la guía de un diseño nuevo de varias piezas, con su ensamblaje y su tabla de
pasos, y genera la web de armado como siempre. El visor sale con ella, sin preparar nada a mano para
ese diseño. Si después cambia un parámetro o un paso de la guía, vuelve a generar y el visor queda al
día; la comprobación de la puerta 5 avisa si se olvidó de hacerlo.

**Por qué esta prioridad**: si cada diseño necesitara trabajo propio, el visor quedaría solo en el
puntero láser. Que salga del mismo ensamblaje que ya alimenta las capturas lo hace gratis para todos
los diseños futuros y garantiza que el visor y las capturas no se contradigan.

**Prueba independiente**: se generan las webs del puntero láser y de la caja de pilas sin tocar nada
específico de cada diseño; los dos visores muestran todos sus pasos, con las mismas piezas y
direcciones que sus capturas.

**Escenarios de aceptación**:

1. **Dado** un diseño con ensamblaje y tabla de pasos, **cuando** se genera la web de armado,
   **entonces** también se genera su visor, que muestra todos los pasos de la guía en el mismo orden.
2. **Dado** un visor generado, **cuando** se compara cada paso con su captura de la guía, **entonces**
   aparecen las mismas piezas, en los mismos colores y desplazadas en la misma dirección.
3. **Dado** un diseño cuyo ensamblaje o guía cambió después de generar el visor, **cuando** se corre
   la comprobación de la puerta 5, **entonces** falla e indica que el visor está desactualizado.
4. **Dado** un diseño de una sola pieza o sin tabla de pasos, **cuando** se genera la web, **entonces**
   no se genera visor, la web no lo enlaza y no hay error.
5. **Dado** un elemento de la tabla que no se puede exportar, **cuando** se genera el visor,
   **entonces** la generación se detiene con un mensaje que nombra el elemento y el paso.

---

### Historia de usuario 3 - Giros además de desplazamientos (Prioridad: P3)

Algunos pasos no se entienden solo con un desplazamiento: la polea de altura se enrosca girándola, un
perno se atornilla, una tapa gira hasta trabar. Quien diseña declara en la tabla de pasos que esa
pieza, además de desplazarse, gira alrededor de un eje, y el visor lo muestra.

**Por qué esta prioridad**: mejora la claridad de pocos pasos por diseño; la gran mayoría se entiende
con el desplazamiento recto, que ya cubren las historias 1 y 2.

**Prueba independiente**: se declara el giro de la polea de altura del puntero láser en su paso y el
visor la muestra girando mientras avanza hasta su lugar; los demás pasos no cambian.

**Escenarios de aceptación**:

1. **Dado** un elemento con un giro declarado en su paso, **cuando** se reproduce el paso, **entonces**
   la pieza gira el ángulo declarado alrededor del eje declarado mientras llega a su lugar.
2. **Dado** un diseño sin giros declarados, **cuando** se genera el visor, **entonces** se comporta
   igual que sin esta historia.
3. **Dado** un giro declarado, **cuando** se generan las capturas de la guía, **entonces** las capturas
   no cambian.

---

### Casos límite

- **Pieza dentro de otra**: la pieza que la contiene ya está en transparente (lo armado) o se mueve
  en transparente si el paso la declara sin resaltar; la pieza interior tiene que verse.
- **Elemento que se mueve sin resaltar**: un subconjunto ya armado que se mueve entero (la horquilla
  que baja a la plataforma) se anima en transparente junto con las piezas nuevas.
- **Paso con un desplazamiento nulo**: la pieza aparece en su lugar, sin movimiento, y en el color que
  indique la tabla.
- **Pasos de la guía y de la tabla que no coinciden** en cantidad u orden: la generación se detiene
  con un mensaje, igual que hoy las capturas.
- **Diseño muy grande** (muchas piezas o piezas con mucho detalle): si el visor supera el tamaño
  máximo, la generación lo informa con el tamaño de cada pieza, para poder simplificar antes de
  publicar.
- **Navegador sin soporte de gráficos 3D**: el visor muestra un mensaje y un enlace a la web de
  armado con las capturas.
- **Celular angosto (360 px)**: la vista 3D queda arriba y el texto del paso abajo, sin desplazamiento
  horizontal; los controles se pueden tocar con el dedo.
- **Elementos que dependen de un ángulo de vista** (por ejemplo, la cuna inclinada del puntero láser):
  se muestran en el mismo ángulo que las capturas.

## Requisitos *(obligatorio)*

### Requisitos funcionales

**Generación**

- **FR-001**: El sistema DEBE generar el visor de todo diseño que tenga ensamblaje con tabla de pasos,
  con el mismo comando que genera la web de armado y sin ningún archivo ni ajuste propio del diseño.
- **FR-002**: Las piezas, sus posiciones finales, colores, desplazamientos, el origen de la entrada,
  si se resaltan y los subconjuntos DEBEN salir del ensamblaje del diseño, la misma fuente que usan
  las capturas de la guía.
- **FR-003**: El número, título y texto de cada paso DEBEN salir de la guía de producción.
- **FR-004**: La generación DEBE detenerse con un mensaje claro si un elemento no se puede exportar
  (nombrando el elemento y el paso) o si la guía y la tabla de pasos no coinciden.
- **FR-005**: La generación DEBE informar el tamaño del visor y DEBE fallar si supera el máximo
  (supuesto: 10 MB por diseño), indicando las piezas que más pesan.
- **FR-006**: El visor DEBE poder usar una versión simplificada de las curvas de cada pieza, sin
  cambiar los archivos de impresión.
- **FR-007**: La comprobación de la puerta 5 DEBE fallar si el visor no corresponde al ensamblaje y a
  la guía actuales.
- **FR-008**: Las capturas de la guía DEBEN seguir generándose igual: el visor las complementa, no las
  reemplaza (la guía impresa las necesita).

**Visualización y animación**

- **FR-009**: El visor DEBE mostrar todos los pasos de la guía, en orden, con su número, título,
  texto y la lista de piezas nuevas con nombres legibles.
- **FR-010**: En cada paso, las piezas del paso DEBEN moverse desde su posición separada hasta su
  lugar final; las resaltadas, en su color, y las no resaltadas, en transparente.
- **FR-011**: Una pieza con origen declarado DEBE moverse en dos tramos: primero hasta la pieza que la
  recibe y después junto con ella hasta el lugar final.
- **FR-012**: Lo ya armado del mismo subconjunto DEBE verse transparente en su lugar; las piezas de
  pasos posteriores y las de subconjuntos todavía no unidos NO DEBEN verse.
- **FR-013**: Un paso sin piezas nuevas DEBE mostrar su texto y el conjunto armado hasta ese momento.
- **FR-014**: El visor DEBE mostrar las piezas con un aspecto que permita distinguir caras y bordes
  (iluminación y sombreado), y las piezas transparentes no DEBEN tapar a las opacas que están detrás.

**Interacción**

- **FR-015**: La persona DEBE poder pasar al paso siguiente o al anterior, ir directo a un paso,
  repetir el movimiento y recorrerlo con un deslizador que lo deja quieto en el punto elegido.
- **FR-016**: La persona DEBE poder girar, acercar y desplazar la vista con mouse, teclado o tacto, y
  volver a una vista inicial que encuadra todo lo que se ve en el paso actual (lo ya armado y las
  piezas nuevas, en su lugar y separadas).
- **FR-017**: Al cambiar de paso, el movimiento DEBE reproducirse solo una vez; la vista que eligió la
  persona NO DEBE cambiar, salvo que las piezas del paso nuevo queden fuera de cuadro: en ese caso se
  reencuadran conservando el ángulo de la vista.

**Acceso**

- **FR-018**: El visor DEBE funcionar abriendo el archivo desde el disco, sin servidor y sin conexión
  a internet.
- **FR-019**: El visor DEBE funcionar en los navegadores actuales de computadora y de celular, desde
  360 px de ancho, sin desplazamiento horizontal.
- **FR-020**: El visor DEBE ser una página aparte, junto a la web de armado; la web DEBE enlazarlo
  al principio de las instrucciones y desde cada paso, abriéndolo en ese paso.
- **FR-021**: Si el navegador no puede mostrar gráficos 3D, el visor DEBE decirlo y enlazar a la web
  de armado con las capturas.

**Extras y documentación**

- **FR-022**: La tabla de pasos DEBE poder declarar, de forma opcional, un giro por elemento (eje y
  ángulo) que el visor muestra y las capturas ignoran (historia 3).
- **FR-023**: El visor DEBE ser obligatorio para todo diseño con ensamblaje y tabla de pasos: la
  constitución (Principio V y puerta 5) DEBE enmendarse para exigirlo, y la comprobación de la
  puerta 5 DEBE fallar si falta.
- **FR-024**: Las instrucciones del proyecto para diseños de varias piezas y para la web de armado
  DEBEN explicar lo que un diseño necesita para tener visor y cómo revisarlo.

### Entidades clave

- **Paso de armado**: una instrucción de la guía (número, título, texto) con la lista de elementos
  que intervienen. Puede no tener elementos.
- **Elemento**: una pieza impresa, un componente comprado o un grupo de tornillos, con nombre, color y
  posición final en el conjunto.
- **Movimiento de un elemento en un paso**: desplazamiento desde la posición separada, si se resalta,
  origen opcional (la pieza que lo recibe) y giro opcional.
- **Subconjunto**: grupo de elementos que se arma por separado hasta un paso de unión.
- **Visor**: lo que se genera por diseño: las piezas, los pasos y sus movimientos, listo para abrir.

## Criterios de éxito *(obligatorio)*

### Resultados medibles

- **SC-001**: Los dos diseños con ensamblaje del proyecto (puntero láser y caja de pilas) tienen su
  visor generado con un solo comando y sin ninguna edición propia del diseño.
- **SC-002**: En el 100 % de los pasos, el visor muestra las mismas piezas, colores y direcciones de
  entrada que la captura correspondiente de la guía.
- **SC-003**: Una persona que no conoce el diseño identifica, para cada uno de los pasos 5 a 8 del
  puntero láser, qué piezas se colocan y por dónde entran, en menos de 30 segundos por paso.
- **SC-004**: El visor muestra el primer paso en menos de 5 segundos en una computadora común y en
  menos de 10 segundos en un celular de gama media, sin conexión a internet.
- **SC-005**: El visor completo del puntero láser (18 pasos) pesa 10 MB o menos.
- **SC-006**: Si se cambia un parámetro o un paso de la guía y no se regenera, la comprobación de la
  puerta 5 lo detecta en el 100 % de los casos.
- **SC-007**: La animación se ve continua, sin saltos, en una computadora común y en un celular de
  gama media.

## Supuestos

- Los diseños de varias piezas ya siguen la convención de la skill `disenio-multipieza`: un catálogo
  de elementos en su posición final y una tabla de pasos con desplazamiento, resaltado, origen y
  subconjuntos. El visor no agrega datos obligatorios a esa convención; el giro es opcional.
- Todo lo que el visor necesita viaja con el diseño (piezas y motor de visualización), para que
  funcione sin internet; el costo es un archivo más grande.
- Tamaño máximo por diseño: 10 MB. El prototipo pesó 1,1 MB con 15 piezas y curvas simplificadas.
- Los movimientos son rectos salvo que el paso declare un giro.
- La vista inicial muestra el diseño desde arriba y en diagonal, como las capturas.
- Los elementos que dependen de un ángulo de vista (la cuna del puntero láser) se muestran en el
  ángulo que usa el ensamblaje para las capturas.
- El idioma del visor es el español, como el resto del proyecto.
- El prototipo de `.tools/tmp/visor_3d/` (pasos 5 a 8 del puntero láser) validó que la idea es
  factible y es el punto de partida; el ensamblaje del puntero láser ya puede entregar cada pieza
  por separado y los datos de sus pasos.
- Fuera del alcance: la realidad aumentada sobre la mesa (queda para una funcionalidad posterior) y
  el reconocimiento de las piezas reales con la cámara.
