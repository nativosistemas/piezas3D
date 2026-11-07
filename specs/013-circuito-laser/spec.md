# Especificación de Funcionalidad: Circuito del láser en el visor 3D

**Rama de la funcionalidad**: `013-circuito-laser`

**Creada**: 2026-10-19

**Estado**: Implementada (pendiente: prueba interactiva en el navegador)

**Amplía**: [005-visor-armado-3d](../005-visor-armado-3d/spec.md),
[008-identificacion-componentes](../008-identificacion-componentes/spec.md) y
[011-vista-cableado](../011-vista-cableado/spec.md)

**Entrada**: Descripción del usuario: "Botón «Circuito del láser» en el visor 3D del puntero láser
estelar (002). En el modo Cableado, un botón muestra el recorrido de la energía hasta el láser:
resalta la pila falsa, los hilos rojo y negro, y las piezas metálicas que conducen (tornillo M3 × 8
de cabeza alomada y su tuerca M3 en la pila falsa = contacto positivo; prisionero M3 × 12 de punta
cónica con su tuerca y el ojal del hilo negro en la tapa trasera = contacto negativo que muerde el
tubo; terminales de ojal M3 de los dos hilos; el tubo metálico del láser como retorno), y atenúa o
hace transparente todo lo demás para que se vean las piezas que quedan adentro del tubo. Hoy esas
piezas metálicas no están modeladas en src/puntero_laser_ensamblaje.scad: hay que agregarlas como
elementos con nombre y tipo «comprada» (paso 14 de la guía, captura del paso 14 regenerada). Debe ser
genérico en el generador del visor: el ensamblaje declara uno o más circuitos (nombre, elementos y
cables) y el visor muestra un botón por circuito. Se debe poder abrir directo con un parámetro de la
URL para revisarlo con capturas."

## Escenarios de usuario y pruebas *(obligatorio)*

### Historia de usuario 1 - Ver por dónde llega la energía al láser (Prioridad: P1)

Una persona preparó el láser (paso 14) y no entiende cómo le llega la corriente si la pila es de
plástico. En el visor, en el modo Cableado, toca «Circuito del láser». Todo lo que no conduce se
vuelve casi transparente y quedan a la vista, en color, los hilos rojo y negro, la pila falsa, el
tornillo del contacto positivo con su tuerca, el prisionero del negativo con su tuerca, los dos
ojales y el tubo del láser. Ve que el hilo rojo atraviesa la pila y termina bajo la cabeza del
tornillo, y que el negro termina en el prisionero que muerde el tubo.

**Por qué esta prioridad**: es el pedido. Hoy las piezas metálicas no existen en el modelo y la pila
queda escondida adentro del tubo opaco del láser.

**Prueba independiente**: se abre el visor en el modo Cableado, se toca el botón y se comprueba que
se ven todas las piezas del circuito, incluidas las que están adentro del tubo, y que el resto quedó
atenuado.

**Escenarios de aceptación**:

1. **Dado** el modo Cableado del visor del puntero láser, **cuando** se mira el panel, **entonces**
   hay un botón «Circuito del láser» con una línea que dice qué muestra.
2. **Dado** el botón, **cuando** se toca, **entonces** quedan resaltadas en color todas las piezas y
   los cables del circuito, y todo lo demás queda atenuado (transparente y sin color).
3. **Dado** el circuito resaltado, **cuando** se mira la cola del láser, **entonces** se ven a través
   del tubo la pila falsa, el tornillo, su tuerca y el ojal del hilo rojo.
4. **Dado** el circuito resaltado, **cuando** se sigue el hilo rojo, **entonces** se lo ve entrar por
   la ventana de la tapa trasera, atravesar la pila y terminar en el ojal bajo el tornillo; y el negro
   termina en el ojal del prisionero del negativo.
5. **Dado** el circuito resaltado, **cuando** se toca de nuevo el botón (o se elige otro modo),
   **entonces** el modo Cableado vuelve a como estaba.
6. **Dado** el circuito resaltado, **cuando** se toca «Vista inicial», **entonces** la cámara encuadra
   la cola del láser, donde están los contactos.

---

### Historia de usuario 2 - Saber qué hace cada pieza del circuito (Prioridad: P2)

Con el circuito a la vista, la persona pasa el puntero (o toca) el tornillo y aparece «Tornillo M3 × 8
cabeza alomada: contacto positivo de la pila falsa». En el panel hay una lista con las piezas del
circuito en el orden en que pasa la corriente, separadas por etapas, del power bank («Power bank e interruptor») hasta «Positivo (+) en el láser»
y «Negativo (−) en el láser», y al
señalar un renglón se resalta su pieza.

**Por qué esta prioridad**: ver las piezas sirve poco si no se sabe qué es cada una; el tornillo y el
prisionero son chicos y se parecen.

**Prueba independiente**: se señala cada pieza del circuito en la escena y cada renglón de la lista, y
en todos los casos aparece el nombre correcto.

**Escenarios de aceptación**:

1. **Dado** el circuito resaltado, **cuando** se señala una pieza del circuito, **entonces** aparece
   su nombre, igual que en el modo de armado (feature 008).
2. **Dado** el panel con el circuito resaltado, **cuando** se mira la lista, **entonces** están todas
   las piezas y cables del circuito, en sus grupos y en el orden del recorrido.
3. **Dado** un renglón de la lista, **cuando** se señala o se toca, **entonces** se resalta esa pieza
   en la escena.

---

### Historia de usuario 3 - Abrirlo directo y que sirva en cualquier diseño (Prioridad: P3)

Quien mantiene el diseño quiere revisar el circuito con una captura sin tocar botones, y declarar en
otro diseño un circuito propio (por ejemplo, el de la caja de pilas) sin cambiar el visor.

**Por qué esta prioridad**: sin abrirlo directo no se puede revisar con las capturas del Edge sin
ventana (skill `web-armado`); y que sea genérico evita repetir trabajo en el próximo diseño.

**Prueba independiente**: se abre el visor con el parámetro del circuito en la dirección y la captura
muestra el circuito resaltado; se declara un circuito con una pieza inexistente y la generación falla
nombrándola.

**Escenarios de aceptación**:

1. **Dado** la dirección del visor con el modo Cableado y el nombre del circuito, **cuando** se abre,
   **entonces** el visor arranca con ese circuito resaltado.
2. **Dado** un ensamblaje que declara dos circuitos, **cuando** se genera el visor, **entonces** hay
   un botón por circuito y solo uno puede estar resaltado a la vez.
3. **Dado** un circuito que nombra una pieza o un cable que no existe en el ensamblaje, **cuando** se
   genera, **entonces** la generación falla y lo nombra.
4. **Dado** un diseño sin circuitos declarados, **cuando** se genera, **entonces** el modo Cableado
   queda como hoy, sin botón.

---

### Casos límite

- **Piezas adentro de otras**: la pila, el tornillo, la tuerca y el ojal rojo están dentro del tubo
  del láser, que también es parte del circuito. El tubo se muestra en color pero translúcido, para que
  se vea lo de adentro.
- **Piezas metálicas chicas**: el tornillo (Ø 7 mm de cabeza), las tuercas y los ojales son chicos; la
  lista del panel es la forma segura de señalarlos, sobre todo en el celular.
- **Resorte del cabezal**: es parte del láser comprado y no se modela por separado; el punto de
  contacto se ve porque la cabeza del tornillo llega hasta donde apoyaba la batería.
- **Prisionero sin función eléctrica**: de los 2 prisioneros de la tapa trasera solo uno es el
  contacto negativo; el otro (con contratuerca) se modela, pero no es parte del circuito.
- **El cable gira con el láser**: el modo Cableado muestra el aparato quieto en reposo (feature 011);
  el circuito también.
- **Modos Armado y Funcionamiento**: las piezas nuevas aparecen en el paso 14 del armado y giran con
  el láser en Funcionamiento, como el resto de la cola del láser.
- **Atenuar las piezas**: mientras el circuito está resaltado, la casilla no cambia nada; al soltarlo,
  vuelve a valer lo que diga la casilla.
- **Tamaño del visor**: las piezas nuevas suman mallas; el visor sigue dentro del límite de la
  feature 005.

## Requisitos *(obligatorio)*

### Requisitos funcionales

- **FR-001**: El ensamblaje del puntero láser DEBE modelar, en su posición final y como elementos con
  nombre y tipo «comprada», el tornillo M3 × 8 de cabeza alomada y la tuerca M3 del contacto positivo,
  los 2 prisioneros M3 × 12 de la tapa trasera con sus 2 tuercas M3 y los 2 terminales de ojal M3 (del
  hilo rojo en el tornillo y del negro en el prisionero del negativo).
- **FR-002**: Las piezas nuevas DEBEN entrar en el paso 14 del armado, con su desplazamiento de
  entrada, y la captura del paso 14 DEBE regenerarse y revisarse.
- **FR-003**: El ensamblaje DEBE comprobar que las piezas nuevas no choquen con la pila, la tapa
  trasera ni el tubo, salvo el contacto previsto (cabeza del tornillo con el ojal, punta del
  prisionero con el tubo).
- **FR-004**: El hilo rojo DEBE dibujarse completo hasta su ojal: desde la ventana de la tapa
  trasera, por la ranura del escalón y la de la pila, por el agujero axial de la pila hasta la cara
  delantera; el negro, desde la grapa hasta el ojal del prisionero del negativo.
- **FR-005**: El ensamblaje DEBE poder declarar uno o más circuitos, cada uno con un identificador, un
  nombre, una descripción de una línea, sus piezas y cables en grupos con título (por ejemplo,
  positivo y negativo) en el orden del recorrido, las piezas que se muestran translúcidas porque
  contienen a otras y las piezas que encuadra la vista inicial.
- **FR-006**: El modo Cableado DEBE mostrar un botón por circuito declarado; al tocarlo resalta en
  color las piezas y cables del circuito y atenúa todo lo demás; al tocarlo de nuevo, vuelve al estado
  anterior. Solo un circuito puede estar resaltado a la vez.
- **FR-007**: Una pieza del circuito que contiene a otra del mismo circuito DEBE mostrarse
  translúcida y en color, para que se vea lo de adentro.
- **FR-008**: Con un circuito resaltado, el panel DEBE listar sus piezas y cables en sus grupos;
  señalar un renglón resalta su pieza y señalar una pieza muestra su nombre.
- **FR-009**: El visor DEBE poder abrirse con un circuito resaltado desde un parámetro de la
  dirección, junto con el modo Cableado.
- **FR-010**: La generación DEBE fallar, nombrando el problema, si un circuito declara una pieza o
  un cable inexistente, si repite un identificador o si queda vacío.
- **FR-011**: Un diseño sin circuitos declarados DEBE generar el modo Cableado igual que hoy.
- **FR-012**: El puntero láser DEBE declarar el circuito «Circuito del láser» con todo el camino de
  la energía, del power bank al láser, por etapas: «Power bank e interruptor», «Barra de distribución», «Relé: la llave del láser (COM → NA)», «Control del relé», «Regulador a 3,7 V y cable del láser», «Positivo (+) en el láser» y «Negativo (−) en el láser». Cada pieza aparece una sola vez aunque
  lleve los dos polos. La vista inicial encuadra del power bank a la cola del láser. (Ampliado el
  2026-10-20 a pedido del usuario: al principio empezaba en la salida del regulador.)
- **FR-013**: La guía (paso 14, lista de materiales) y la web DEBEN seguir coincidiendo con el modelo:
  las piezas nuevas ya figuran en la lista de materiales, así que solo cambian la captura y el visor.

### Entidades clave

- **Circuito**: un recorrido eléctrico que se quiere enseñar. Tiene identificador, nombre,
  descripción, grupos de piezas y cables (en el orden del recorrido), piezas translúcidas y piezas
  de su encuadre inicial.
- **Pieza conductora**: un elemento comprado del ensamblaje (tornillo, tuerca, prisionero, ojal) que
  lleva la corriente; se identifica como cualquier otro elemento (feature 008).

## Criterios de éxito *(obligatorio)*

### Resultados medibles

- **SC-001**: Desde el visor abierto en el modo Cableado, se llega a ver el circuito completo del
  láser con un solo toque.
- **SC-002**: Con el circuito resaltado, cada pieza del circuito (pila falsa, tornillo, tuercas,
  ojales, prisionero y láser) se identifica por su nombre señalándola en la escena o en la lista, sin
  desarmar nada.
- **SC-003**: Una persona que no conoce el diseño puede explicar, después de mirar el circuito, por
  dónde entra el positivo y por dónde vuelve el negativo.
- **SC-004**: Una captura sin ventana con el parámetro del circuito muestra el circuito resaltado
  igual que tocando el botón.
- **SC-005**: Declarar un circuito en otro diseño no requiere cambiar el visor ni el generador.

## Supuestos

- El circuito muestra todo el camino, del power bank al láser, incluido el control del relé (ESP32,
  GPIO 23 y la resistencia de 10 kΩ), porque la persona quiere ver dónde están el relé y la
  resistencia y qué papel cumplen. El ESP32 y el power bank se ven translúcidos para no tapar los
  cables ni la cola del láser.
- Las piezas nuevas se modelan simplificadas (cabeza y vástago del tornillo, hexágono de la tuerca,
  ojal plano), con las medidas de la tornillería que ya usa el diseño; no se modelan roscas.
- El tubo del láser representa el retorno negativo; no se separa del resto del láser comprado.
- Las piezas nuevas ya están en `docs/puntero_laser_bom.csv` (tornillería M3 y terminales de ojal):
  no cambian la lista de materiales ni los precios.
- El botón vive solo dentro del visor; la web de armado no cambia (el enlace «Ver el cableado» ya
  lleva al modo).
