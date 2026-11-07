# Investigación: Circuito del láser en el visor 3D

**Funcionalidad**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

## R1. Cómo se modelan las piezas conductoras

**Decisión**: 9 elementos nuevos en el catálogo de `src/puntero_laser_ensamblaje.scad`, dibujados como
volúmenes simplificados, igual que la tornillería que ya tiene el ensamblaje (`tornillo_m3()`,
`tuerca()`):

| Elemento | Qué es | Pieza de la lista de materiales |
|---|---|---|
| `tornillo_contacto` | Tornillo M3 × 8 de cabeza alomada (ISO 7380): cabeza Ø 5,7 × 1,65 y vástago | Tornillería M3, contacto positivo |
| `tuerca_contacto` | Tuerca M3 embutida en la pila falsa | ídem |
| `ojal_positivo` | Terminal de ojal M3 del hilo rojo, entre la cara de la pila y la cabeza del tornillo | Terminal de ojal M3 |
| `hilo_rojo_pila` | Tramo del hilo rojo de la ventana de la tapa al ojal, por dentro de la pila | Cable de silicona 2 × 26 AWG |
| `prisionero_negativo` | Prisionero M3 × 12 de punta cónica que muerde el tubo | Prisionero M3 × 12 + tuerca |
| `tuerca_negativo` | Tuerca M3 que aprieta el ojal negro contra el resalte | ídem |
| `ojal_negativo` | Terminal de ojal M3 del hilo negro | Terminal de ojal M3 |
| `hilo_negro_tapa` | Tramo del hilo negro de la salida del cordón al ojal del prisionero | Cable de silicona 2 × 26 AWG |
| `prisionero_fijacion` | El otro prisionero (a 180°) con su contratuerca: solo fija la tapa | Prisionero M3 × 12 + tuerca |

**Razón**: el visor identifica, resalta y lista **elementos** (feature 008); cada pieza que la persona
tiene que reconocer necesita el suyo. El tornillo y su tuerca van separados porque en la lista del
circuito cumplen papeles distintos (la cabeza es el contacto; la tuerca lo sostiene). El prisionero
de fijación se modela para que la tapa no se vea con un solo prisionero, pero no es parte del
circuito.

Los dos tramos de hilo son elementos rígidos que giran con el láser. El cordón `cable_laser` es un
deformable (feature 007) que empieza en la ventana de la tapa; los tramos nuevos siguen desde ahí y
no lo cambian.

**Alternativas descartadas**:
- *Un solo elemento «contactos»*: no deja nombrar cada pieza ni seguir el orden del recorrido.
- *Dibujar los tramos de hilo como cables del modo Cableado*: un cable de la 011 es un renglón de la
  Tabla de cables (C-05, de pin a pin). Estos tramos son la continuación de un cable que ya está en
  la tabla, no conexiones nuevas.
- *Modelar el resorte del cabezal*: es parte del láser comprado y no se ve en el armado; el punto de
  contacto ya se entiende por la cabeza del tornillo.

## R2. Dónde va cada pieza (posiciones relativas)

**Decisión**: todo se ubica con las mismas transformaciones con que el ensamblaje ya coloca la pila
falsa y la tapa trasera, con las cotas de `puntero_laser_parametros.scad`:

- **Pila** (sistema de impresión de la pila: cara trasera en z = 0, delantera en `largo_pila_falsa`,
  agujero del hilo sobre +X): la cabeza del tornillo apoya sobre el ojal, que apoya en la cara
  delantera; la punta del vástago queda a `prof_agujero_tornillo` de la cara; la tuerca, a
  `prof_tuerca_contacto` de la cara, centrada en su ranura.
- **Tapa** (su sistema: cara trasera en z = 0, prisioneros a `z_prisioneros_tapa`, el del negativo a
  `angulo_cable + desfase_prisionero_tapa` y el de fijación a +180°): el prisionero es radial, con la
  punta en el radio de la rosca del tubo (`r_funda_int − holgura("deslizante")`) y
  `largo_prisionero_tapa` hacia afuera. El ojal apoya en la cara del resalte
  (`r_funda_ext + espesor_resalte_prisionero`) y la tuerca, sobre el ojal.
- **Hilo rojo**: sale del cordón en la ventana, va bajo el borde del tubo por la ranura del escalón
  (a media profundidad de la ranura), sube a la ranura de la cara trasera de la pila, recorre el
  agujero axial (`descentrado_hilo_pila` sobre `angulo_cable`) y termina sobre la lengüeta del ojal.
- **Hilo negro**: sale del mismo punto, rodea la tapa por fuera del resalte hasta el ángulo del
  prisionero del negativo y termina en la lengüeta del ojal negro.

**Razón**: el Principio I pide posiciones relativas a otros elementos, y así un cambio de
`angulo_cable`, del lastre o del láser mueve todo junto.

## R3. El terminal de ojal en la cara de la pila

**Hallazgo**: un terminal de ojal M3 comercial mide unos 14 a 17 mm de largo (aro de Ø 5,5–6 mm más
cuello y caño de crimpar). Sobre la cara delantera de la pila (Ø 17,7 mm), con el aro centrado en el
tornillo, el caño llega a ~13 mm del eje y choca con la pared del tubo, que está a 9,25 mm y es el
**negativo**: con un caño desnudo, eso es un cortocircuito.

**Decisión**: el modelo dibuja el ojal positivo como **aro + lengüeta corta** que llega hasta el
agujero del hilo (`descentrado_hilo_pila`), con una comprobación (`assert`) de que el aro y la
lengüeta quedan dentro de la cara de la pila con 0,5 mm de margen. La guía (paso 14) pasa a decir
que el caño del terminal se corta y el hilo se suelda a la lengüeta, que es una de las dos opciones
que ya da («crimpar o soldar»).

**Razón**: el modelo tiene que mostrar el armado que funciona, no uno que hace cortocircuito. Es un
cambio de una frase en la guía, sin piezas ni compras nuevas.

**Alternativas descartadas**:
- *Dibujar el terminal entero*: mostraría un armado que toca el tubo.
- *Correr el agujero del hilo para que el caño entre*: no entra en ningún ángulo; la cara es más
  chica que el terminal.

**Medidas del ojal** (constantes nuevas en `puntero_laser_parametros.scad`, junto a `espesor_ojal`):
`d_ext_ojal = 6`, `d_int_ojal = 3.2` y `ancho_lengueta_ojal = 3`.

## R4. Cómo se declara un circuito

**Decisión**: lista opcional nueva `circuitos` en el ensamblaje, leída por `armado_comun.scad` con
`is_undef` como las demás:

```text
circuitos = [[id, nombre, descripción, grupos, translúcidos, encuadre], …]
grupos    = [[título, [elemento o cable, …]], …]   // en el orden del recorrido
```

Un miembro es un elemento del catálogo o el id de un cable. Un elemento que es el tramo móvil de un
cable (`cable_laser` de `hilos_laser`) se nombra por su cable: en el modo Cableado, sus mallas son
del cable.

**Razón**: es el mismo patrón de las listas opcionales de la 007, la 008 y la 011 (datos en el
ensamblaje, validación en la biblioteca, salida por `echo`), así que no cambia nada para los diseños
que no la usan (FR-011) y otro diseño declara su circuito sin tocar el visor (SC-005).

**Alternativas descartadas**:
- *Detectar solo las piezas que contienen a otras* para hacerlas translúcidas: exige intersecar
  mallas en el navegador; declararlas es una línea y es explícito.
- *Grupos fijos «positivo» y «negativo»*: el par de hilos del regulador a la cola es de los dos
  polos; un título por grupo lo resuelve y sirve para otros circuitos.

## R5. Cómo se ve en el visor

**Decisión**: en el panel del modo Cableado, debajo del texto, una fila con un botón por circuito
(`aria-pressed`). Al activarlo:

- Las mallas del circuito conservan su color: opacas, o translúcidas (opacidad 0,25) si están en
  `translúcidos`.
- Todas las demás mallas del modo (piezas y cables) pasan a gris claro con opacidad 0,08 y sin
  escribir profundidad.
- La lista de cables se oculta y en su lugar aparece la descripción del circuito y la lista de sus
  grupos (nombre de cada elemento o cable, con su muestra de color). Señalar un renglón resalta la
  pieza, como en la lista de cables.
- La casilla «Atenuar las piezas» queda deshabilitada.
- «Vista inicial» encuadra la caja de los elementos de `encuadre`, desde la dirección del modo.

Al soltarlo (o al cambiar de modo y volver), cada malla vuelve a su color, la lista de cables vuelve
y se aplica de nuevo la casilla. `soltar()` deja la opacidad en la del estado de la malla (guardada
en el material) y no en la de armado, para que señalar una pieza no rompa la atenuación del circuito.

Se abre directo con `?modo=cableado&circuito=<id>` (también con `#cableado`). Combinado con
`&senalar=<elemento>`, sirve para las capturas de revisión.

**Razón**: reutiliza el resalte, la etiqueta y la lista de la 008 y la 011; el gris casi invisible
deja ver la cola del láser a través de la cuna, la horquilla y la tapa trasera.

## R6. Validaciones

**Decisión**:

- En `armado_comun.scad` (`comprobar_circuitos()`), con mensajes en español: forma de cada circuito
  (6 campos, textos no vacíos y sin `;`), id no repetido, al menos un grupo con al menos un miembro,
  cada miembro es un elemento o un cable, ningún elemento repetido en el mismo circuito, ningún
  elemento oculto en el modo Cableado ni tramo de un cable, `translúcidos` incluidos en los
  miembros y `encuadre` formado por elementos o cables (puede incluir piezas que no son del circuito,
  como la tapa trasera, para encuadrar la zona). Exigir `cables` declarados (sin modo Cableado no hay botón).
- En `generar_visor.py`: cada miembro de un circuito existe en los datos del visor (elemento con
  malla o cable); si no, falla nombrándolo (C-07).
- En el ensamblaje: los `assert` de R3 (ojal dentro de la cara de la pila) y que la cabeza del
  tornillo llegue al fondo del hueco con el resorte comprimido (la cuenta de `largo_pila_falsa`, ya
  existente, se vuelve a verificar con la geometría del ojal y la cabeza).

## R7. Pasos de armado y capturas

**Decisión**:
- **Paso 14**: el tornillo, la tuerca, el ojal rojo y el tramo de hilo rojo entran con la pila
  falsa (mismo desplazamiento: se arman antes de meterla). Los prisioneros entran en dirección
  radial, después de la tapa, y la tuerca y el ojal negro y su tramo de hilo, más afuera. Se
  regenera `docs/img/puntero_laser_paso_14.png` y se revisa.
- **Paso 15**: los elementos nuevos acompañan al láser cuando entra en la cuna, como la pila y la
  tapa.
- **Simulación**: los 9 elementos se suman a `elementos_altura` (giran con el láser).

## R8. Tamaño y versión del visor

**Decisión**: el formato de datos pasa a la versión 5 (circuitos en `cableado`). Las 9 mallas son
chicas (cilindros y hexágonos de 32 lados): se estima menos de 0,15 MB sobre los 3,9 MB actuales.

## R9. Simulación FEM

**No aplica**: no hay piezas impresas nuevas ni cargas nuevas. La tornillería ya estaba contada en la
masa del láser convertido (`masa_tapa_trasera_g` suma 2 g por los prisioneros con tuerca).
