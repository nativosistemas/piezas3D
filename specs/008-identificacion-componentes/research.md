# Investigación: Identificación de componentes en el visor 3D

## R1. Dónde se declaran los nombres

- **Decisión**: en el ensamblaje del diseño, en una lista opcional `nombres_elementos = [[elemento,
  nombre, tipo], …]` escrita junto a `elementos`.
- **Motivo**: el ensamblaje ya es la fuente única de todo lo que muestra el visor (pasos, colores,
  simulación). El nombre describe lo que el ensamblaje dibuja (un elemento puede agrupar varias
  piezas iguales), así que va al lado del catálogo.
- **Alternativas**: una columna `elemento` en `docs/<diseño>_bom.csv` (descartada: la lista de
  materiales no tiene las piezas impresas, un renglón agrupa varios elementos, p. ej. los cuatro 608
  son cuatro elementos, y obligaría al generador del visor a leer otro archivo); una función
  `nombre_elemento(e)` como `color_elemento(e)` (descartada: una función no permite comprobar que
  cubre todo el catálogo ni detectar nombres de elementos que no existen).

## R2. Cómo sale el texto de OpenSCAD

- **Decisión**: una línea de `echo` por elemento, `NOMBRE;<elemento>;<tipo>;<nombre>`, con el nombre
  al final. El generador la lee con `^ECHO: "NOMBRE;([^;]+);([^;]+);(.*)"$`.
- **Motivo**: probado en OpenSCAD 2021.01: `echo(str(...))` no escapa las comillas del texto. Con el
  nombre al final, la expresión toma todo lo que hay hasta la última comilla, así que el nombre
  puede tener `;`, `"`, `×`, `<`, `&` y acentos. Volcar la lista entera con `str(lista)` (como
  `PASOS;`) rompería el JSON con cualquier comilla.
- **Alternativas**: prohibir las comillas en los nombres (descartada: limita sin necesidad).

## R3. Formato de los datos incrustados

- **Decisión**: cada `elementos[e]` suma `nombre` y `tipo` (`"impresa"` o `"comprada"`) solo si el
  ensamblaje declara la lista. `VERSION` pasa de 2 a 3.
- **Motivo**: un visor de versión 2 no tiene los campos: subir la versión obliga a regenerar, así
  `--comprobar` no da por bueno un visor sin nombres. Los nombres viven en el ensamblaje, que ya está
  en la huella: cambiar un nombre vuelve a exportar las mallas (≈ 1 min en el puntero láser), un
  costo aceptable frente a separar la huella en dos.
- **Alternativas**: un diccionario `nombres` aparte en la raíz de los datos (descartada: la página
  ya recorre `elementos` y así cada elemento lleva todo lo suyo).

## R4. Cómo se elige la pieza señalada

- **Decisión**: `THREE.Raycaster` desde la cámara por el punto señalado, contra la lista de mallas de
  pieza visibles en el modo actual (en Armado, las del catálogo visibles; en Funcionamiento, las
  rígidas y el fotograma visible de cada deformable). De los cortes, gana el más cercano entre las
  opacas; si no hay opacas, el más cercano entre las atenuadas. El haz, el halo, las marcas de giro y
  las flechas no están en la lista.
- **Motivo**: lo atenuado se ve a través (opacidad 0,22); si ganara siempre el primer corte, las
  piezas nuevas de un paso quedarían tapadas por el contexto que las rodea. Una lista explícita evita
  identificar ayudas visuales.
- **Rendimiento**: three.js descarta primero por esfera envolvente; con 49 mallas de ≈ 3 MB en total
  el cálculo cabe holgado en un cuadro. Se calcula como máximo una vez por cuadro (el movimiento del
  puntero solo marca que hay que recalcular) y, mientras algo se mueve (animación del paso o modo
  automático) con el puntero quieto, se recalcula en cada cuadro para que la etiqueta no nombre una
  pieza que ya se fue (caso límite de la especificación).

## R5. Cómo se resalta

- **Decisión**: color emisivo del material (`emissive` = acento del visor, intensidad ≈ 0,35) y, si la
  pieza está atenuada, opacidad temporal 0,6. Al soltar se vuelven los valores guardados.
- **Motivo**: cada malla tiene su propio material, así que cambiarlo no afecta a otras; `emissive` no
  lo usa nada más en el visor, así que restaurarlo no pisa otro estado (FR-010). Un contorno
  (`OutlinePass`) exigiría post-procesado y otro módulo incrustado.
- **Alternativas**: cambiar el color base (descartada: confunde con el color real de la pieza); caja
  envolvente dibujada (descartada: tapa piezas vecinas en zonas densas como la tornillería).

## R6. Puntero, toque y arrastre

- **Decisión**: con mouse (`pointerType === "mouse"`), seleccionar al mover sin botones apretados y
  soltar al salir del lienzo. Con tacto o lápiz, seleccionar en un toque (bajar y subir en < 500 ms y
  < 6 px); un toque en el fondo suelta. El evento `start` de `OrbitControls` (empieza a girar,
  acercar o desplazar) suelta y no deja seleccionar hasta que termina.
- **Motivo**: cumple FR-006, FR-007 y FR-009 sin pelear con los controles de la cámara, que usan los
  mismos eventos.

## R7. Etiqueta

- **Decisión**: un `div` posicionado dentro de `#escena`, a 14 px del puntero (o del toque),
  corrido para no salirse del lienzo; muestra el nombre en negrita y debajo el tipo con su símbolo
  ("🖨 Impresa" / "🛒 Comprada"). Se escribe con `textContent` (FR-011). Sin la lista de nombres
  muestra el identificador legible y no muestra tipo. La misma marca de tipo va en la lista del
  paso.
- **Motivo**: texto HTML legible a cualquier escala, sin texturas; `textContent` no interpreta el
  nombre como HTML.

## R8. Resaltar desde la lista del paso (FR-016)

- **Decisión**: cada renglón de "Piezas de este paso" lleva el elemento en un atributo `data-e`; al
  pasar el puntero, enfocarlo o tocarlo, se resalta la pieza con el mismo mecanismo de R5 (sin
  etiqueta: el nombre ya está en el renglón).
- **Motivo**: relaciona cada nombre con su pieza sin buscarla en la escena; reutiliza el resalte.

## R9. Tipos

- **Decisión**: dos tipos, `impresa` y `comprada`. Lo cortado o armado a mano que figura en la lista
  de materiales (cable, correa, lastre de tuercas) es `comprada`.
- **Motivo**: es la distinción que necesita la persona (buscar entre las impresiones o entre lo
  comprado). Un tercer tipo no cambia esa búsqueda.
