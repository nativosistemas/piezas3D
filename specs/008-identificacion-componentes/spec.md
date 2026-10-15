# Especificación de Funcionalidad: Identificación de componentes en el visor 3D

**Rama de la funcionalidad**: `008-identificacion-componentes`

**Creada**: 2026-10-15

**Estado**: Implementada (pendiente en un navegador real: prueba a mano con mouse y en celular,
SC-003 y SC-004)

**Amplía**: [005-visor-armado-3d](../005-visor-armado-3d/spec.md) y
[007-simulacion-funcionamiento](../007-simulacion-funcionamiento/spec.md)

**Entrada**: Descripción del usuario: "¿Se le puede poner nombre a los componentes que no se imprimen
para una mejor identificación en la web?". Propuesta acordada (los tres puntos):
(1) nombre visible por elemento: cada ensamblaje puede declarar una lista opcional que asigna a cada
elemento del catálogo un nombre legible (p. ej. "608_base_sup" → "Rodamiento 608ZZ (base,
superior)"); el visor lo usa en la lista "Piezas de este paso" y donde hoy muestra el identificador;
sin nombre se mantiene el comportamiento actual (identificador con `_` como espacios), así los
diseños existentes no se rompen. (2) Distinguir lo impreso de lo comprado: cada elemento indica si es
una pieza impresa o un componente comprado (rodamientos, tornillería, motores, electrónica) y el
visor lo marca en la lista del paso. (3) Identificación en la escena 3D: al pasar el puntero (o tocar
en una pantalla táctil) sobre una pieza visible, se resalta y aparece una etiqueta con su nombre y su
tipo, en el modo Armado y en el modo Funcionamiento. Se aplica a los dos diseños con visor (puntero
láser estelar 002 y caja de pilas AA 004), se regeneran sus webs y se actualizan los contratos del
visor y del ensamblaje.

## Escenarios de usuario y pruebas *(obligatorio)*

### Historia de usuario 1 - Saber qué es cada pieza del paso (Prioridad: P1)

Una persona arma el puntero láser siguiendo el visor 3D. En un paso aparecen tres piezas nuevas; la
lista "Piezas de este paso" hoy dice "608 base sup", "perno az" y "autoblocante az", que solo
entiende quien escribió el ensamblaje. Con esta funcionalidad la lista dice "Rodamiento 608ZZ (base,
superior)", "Perno M8 × 50 (eje de azimut)" y "Tuerca autoblocante M8 (eje de azimut)", con los
mismos nombres que la lista de materiales, y la persona sabe qué buscar entre lo que compró.

**Por qué esta prioridad**: es el pedido original. Sin nombres claros, el visor muestra dónde va cada
pieza pero no cuál es, y la tornillería se confunde fácilmente.

**Prueba independiente**: con solo esta historia, una persona que no conoce el diseño recorre los
pasos del visor y, para cada pieza nueva, encuentra el renglón que le corresponde en la lista de
materiales sin ver el código.

**Escenarios de aceptación**:

1. **Dado** un diseño cuyo ensamblaje declara nombres, **cuando** la persona abre un paso que agrega
   piezas, **entonces** la lista del paso muestra el nombre declarado de cada pieza, no su
   identificador.
2. **Dado** un diseño cuyo ensamblaje no declara nombres, **cuando** se genera el visor, **entonces**
   el visor se genera sin errores y la lista muestra el identificador con los `_` como espacios,
   como antes.
3. **Dado** un ensamblaje que declara nombres, **cuando** a un elemento del catálogo le falta el
   nombre o hay un nombre para un elemento que no está en el catálogo, **entonces** la generación
   del visor falla con un mensaje que nombra el elemento.

---

### Historia de usuario 2 - Distinguir lo que se imprime de lo que se compra (Prioridad: P2)

Mientras arma, la persona ve en la lista de cada paso si la pieza es una de las que imprimió o un
componente comprado. Así sabe si tiene que buscarla entre las impresiones o entre la tornillería y la
electrónica.

**Por qué esta prioridad**: amplía la utilidad de los nombres con un dato que la persona necesita en
cada paso y que hoy solo se deduce del color o de la guía.

**Prueba independiente**: en cada paso del puntero láser, la persona dice qué piezas son impresas y
cuáles compradas mirando solo la lista del paso, y acierta en todas.

**Escenarios de aceptación**:

1. **Dado** un ensamblaje que declara el tipo de cada elemento, **cuando** la persona abre un paso,
   **entonces** cada pieza de la lista lleva una marca de "impresa" o "comprada", distinguible sin
   depender solo del color.
2. **Dado** un elemento sin tipo declarado (diseño sin la lista), **cuando** se muestra, **entonces**
   aparece sin marca de tipo.

---

### Historia de usuario 3 - Identificar una pieza señalándola en la escena 3D (Prioridad: P3)

La persona ve una pieza en la escena 3D y no sabe qué es: un tornillo chico, una placa, una tuerca
del lastre. Pasa el puntero por encima (o la toca en el teléfono) y la pieza se resalta y aparece una
etiqueta con su nombre y su tipo. Funciona tanto en el modo Armado (piezas nuevas y las ya armadas
que se ven de contexto) como en el modo Funcionamiento, mientras el aparato se mueve.

**Por qué esta prioridad**: es lo que más ayuda con piezas chicas o tapadas, pero depende de que
existan los nombres (historia 1) y la lista del paso ya cubre lo esencial.

**Prueba independiente**: en el modo Funcionamiento del puntero láser, la persona señala diez piezas
elegidas al azar, entre ellas tornillería chica, y la etiqueta nombra correctamente cada una.

**Escenarios de aceptación**:

1. **Dado** el visor en cualquier modo, **cuando** la persona pasa el puntero sobre una pieza
   visible, **entonces** esa pieza se resalta y aparece cerca del puntero una etiqueta con su nombre
   y su tipo; al salir de la pieza, el resalte y la etiqueta desaparecen.
2. **Dado** una pantalla táctil, **cuando** la persona toca una pieza sin arrastrar, **entonces** se
   resalta y aparece su etiqueta; al tocar el fondo o mover la vista, desaparecen.
3. **Dado** que una pieza tapa a otra, **cuando** la persona señala ese punto, **entonces** se
   identifica la pieza que se ve adelante, no la que está detrás.
4. **Dado** una pieza oculta o invisible en el paso actual, **cuando** la persona señala su lugar,
   **entonces** no se identifica.
5. **Dado** que la persona arrastra para girar la vista, **cuando** suelta, **entonces** no queda
   ninguna pieza seleccionada por ese arrastre.
6. **Dado** el modo Armado, **cuando** la persona pasa el puntero (o toca) un renglón de la lista
   "Piezas de este paso", **entonces** esa pieza se resalta en la escena.

---

### Casos límite

- Un elemento que agrupa varias piezas iguales (p. ej. los cuatro tornillos del pie, o las placas
  electrónicas): se identifica como un solo elemento y su nombre lo dice (p. ej. "Tornillos M3 × 12
  del pie (4)").
- El haz del láser del modo Funcionamiento no es una pieza: no se identifica ni tapa a las piezas de
  detrás.
- Piezas atenuadas (lo ya armado en el modo Armado, las transparentes del modo Funcionamiento): se
  ven a través, así que en un punto donde hay una pieza opaca, aunque esté detrás, se identifica la
  opaca; la atenuada se identifica donde no hay ninguna opaca.
- Un elemento que solo existe en la simulación (no aparece en ningún paso): también lleva nombre y
  tipo.
- Nombres con caracteres especiales (`×`, `<`, `&`, comillas, acentos): se muestran tal cual, sin
  romper la página.
- Señalar durante la animación de un paso o durante el modo automático: la etiqueta sigue a la pieza
  o desaparece, pero nunca nombra una pieza equivocada.
- Un elemento declarado con un tipo distinto de impresa o comprada: la generación falla con un
  mensaje claro.

## Requisitos *(obligatorio)*

### Requisitos funcionales

- **FR-001**: El ensamblaje de un diseño DEBE poder declarar, en una lista opcional y junto al
  catálogo de elementos, un nombre legible y un tipo (impresa o comprada) para cada elemento.
- **FR-002**: Si la lista está declarada, DEBE cubrir todos los elementos del catálogo y solo esos;
  la generación del visor DEBE fallar nombrando cada elemento sin nombre, cada nombre sin elemento y
  cada tipo inválido.
- **FR-003**: Si la lista no está declarada, el visor DEBE generarse y comportarse como hasta ahora
  (identificador con `_` como espacios y sin marca de tipo).
- **FR-004**: El visor DEBE mostrar el nombre declarado en todos los lugares donde hoy muestra el
  identificador de un elemento.
- **FR-005**: La lista "Piezas de este paso" DEBE marcar cada pieza como impresa o comprada con un
  texto o símbolo, no solo con un color.
- **FR-006**: Al señalar una pieza visible en la escena 3D (puntero encima o toque sin arrastre), el
  visor DEBE resaltarla y mostrar una etiqueta con su nombre y su tipo, en el modo Armado y en el
  modo Funcionamiento.
- **FR-007**: El resalte y la etiqueta DEBEN desaparecer al dejar de señalar la pieza (puntero fuera,
  toque en el fondo, cambio de paso o de modo).
- **FR-008**: Solo DEBEN poder identificarse las piezas visibles en ese momento, y DEBE identificarse
  la más cercana a la vista en el punto señalado, con prioridad de las opacas sobre las atenuadas
  (que se ven a través); el haz del láser y las ayudas visuales (flechas,
  marcas de giro) NO DEBEN identificarse.
- **FR-009**: Girar, acercar o desplazar la vista NO DEBE dejar piezas seleccionadas ni mostrar
  etiquetas durante el arrastre.
- **FR-010**: El resalte NO DEBE cambiar los colores ni la transparencia de la pieza de forma
  permanente: al quitarlo, la pieza vuelve a verse como antes.
- **FR-011**: Los nombres DEBEN mostrarse tal como están escritos, incluidos acentos y caracteres
  especiales, sin que puedan romper la página.
- **FR-012**: El ensamblaje del puntero láser estelar y el de la caja de pilas AA DEBEN declarar
  nombre y tipo de todos sus elementos; los nombres de lo comprado DEBEN coincidir con la
  descripción de la lista de materiales de cada diseño (pueden agregar dónde va la pieza).
- **FR-013**: Las webs y los visores de los dos diseños DEBEN regenerarse, y la comprobación de la
  web DEBE seguir pasando sin errores.
- **FR-014**: El visor DEBE seguir funcionando sin internet ni servidor, en un solo archivo.
- **FR-015**: Los contratos del ensamblaje y del visor DEBEN documentar la nueva lista opcional y el
  comportamiento de identificación; la skill del diseño de varias piezas DEBE indicar cómo
  declararla.
- **FR-016**: En el modo Armado, señalar un renglón de la lista "Piezas de este paso" DEBE resaltar
  esa pieza en la escena.

### Entidades clave

- **Elemento**: cada cosa que el ensamblaje dibuja por separado (una pieza impresa, un componente
  comprado o un grupo de componentes iguales). Ya tiene identificador, color y geometría; suma un
  nombre legible y un tipo.
- **Tipo de elemento**: impresa (sale de un STL de `exports/`) o comprada (figura en la lista de
  materiales).

## Criterios de éxito *(obligatorio)*

### Resultados medibles

- **SC-001**: El 100 % de los elementos del puntero láser y de la caja de pilas tienen nombre y tipo
  declarados, y ninguna lista de pasos del visor muestra un identificador interno.
- **SC-002**: Cada pieza comprada que muestra el visor se puede relacionar con un renglón de la lista
  de materiales por su nombre, sin abrir el código.
- **SC-003**: Al señalar una pieza, la etiqueta aparece en menos de un cuarto de segundo, también
  durante el modo automático del puntero láser.
- **SC-004**: En una prueba de diez piezas elegidas al azar en el modo Funcionamiento, la etiqueta
  nombra correctamente las diez.
- **SC-005**: Un diseño sin la lista nueva genera su visor sin cambios visibles respecto de la
  versión anterior.

## Supuestos

- Los dos tipos (impresa y comprada) alcanzan: lo que se fabrica a mano o se corta (cable, correa,
  lastre de tuercas) se trata como comprado porque está en la lista de materiales.
- La web de componentes (`index.html`) ya usa las descripciones de la lista de materiales; esta
  funcionalidad solo cambia el visor 3D. Vincular cada pieza del visor con su renglón de precio
  queda fuera de alcance.
- Las capturas PNG de las vistas explotadas no muestran nombres; no cambian.
- El resalte es un cambio de aspecto temporal (p. ej. un tono de realce) elegido en el plan; no hace
  falta una lista aparte de piezas seleccionables.
- No se requiere enmendar la constitución: el visor ya es obligatorio y esta funcionalidad lo amplía
  dentro de sus reglas.
