# Investigación (fase 0): Marcas de orientación y de altura del puntero láser

Medidas del diseño actual tomadas con `echo` sobre `src/puntero_laser_parametros.scad` (valores por
defecto):

| Medida | Valor | Qué es |
|---|---|---|
| `diametro_apoyo_tripode` | 72 mm | cilindro lateral de la base, de z = 1 a `z_cuerpo_base_sup` = 44,7 mm |
| `ancho_ventana` | 24 mm | ventana de la llave en la base, hacia −Y |
| `z_plataforma_inf` | 66,5 mm | cara inferior de la plataforma |
| `y_plat1` | 96,2 mm | borde +Y de la plataforma |
| `d_exterior_conducida` | 50,4 mm | polea de altura de 80 dientes; con la pestaña, radio 26,2 mm |
| `x_cara_ext_brazo` / `x_ext_polea_alt` | 32,2 / 72,2 mm | cara exterior del brazo del motor / cara exterior de la polea: hay 40 mm entre las dos |
| `altura_eje` (brazo) / `alto_brazo` | 109,5 / 126,5 mm | eje del 608 y largo del brazo, en su sistema de impresión |
| `distancia_centros` | 46 mm | eje de altura a eje del motor, hacia abajo |
| `r_aligerado` | 15,9 mm | 6 aligerados de Ø 8 mm en la polea, a 30° + k·60° |
| `angulo_altura_min` / `max` | −10° / 95° | recorrido de altura |

## R1. La escala no puede grabarse directamente en la polea: disco con el cero regulable

**Problema**: la polea va enchavetada a la cabeza del perno M8 por el hexágono, y el perno se enrosca
en la tuerca del muñón de la cuna hasta apretar el paquete (polea, aro del 608, muñón). El ángulo de la
polea respecto de la cuna queda donde termina de apretarse el perno, más un escalón de 60° según cómo
se calce la cabeza en el hexágono. Una escala grabada en la polea tendría el cero corrido hasta ±30°,
distinto en cada aparato.

**Decisión**: la escala va grabada en un **disco de la escala** (pieza impresa nueva,
`puntero_laser_disco_escala.scad`). Es un anillo plano que apoya sobre la cara exterior de la polea y se
fija con 2 tornillos M3 × 8 autorroscantes con arandela, que pasan por 2 **ranuras en arco** del disco
y entran en 2 agujeros guía nuevos de la polea.

- Los agujeros guía van a `r_aligerado`, a 0° y 180°, entre aligerados. La pared hasta cada aligerado
  es de ≈ 2,9 mm, y la polea tiene ahí 10 mm de espesor macizo.
- Las ranuras permiten girar el disco ±32° y cubren el ±30° que deja el hexágono.
- El cero se pone **una sola vez** al armar (R6): se aflojan los 2 tornillos, se gira el disco y se
  aprietan.
- El agujero central del disco deja pasar una llave tubo de 13 mm para la cabeza del perno, así que se
  puede reapretar el perno sin sacar el disco.
- El disco se imprime plano, con la escala hacia arriba, así que el grabado sale nítido. Sobre la cama de
  la polea saldría peor por el aplastamiento de la primera capa. Conviene imprimirlo en un color claro
  para leerlo de noche.

**Alternativas descartadas**:
- Grabar la escala en la polea: cero arbitrario (el problema de arriba).
- Ajustar el cero con el apriete del perno: cambia la precarga del 608.
- Aguja de índice regulable en vez de disco regulable: necesita una pieza deslizante sobre un arco de
  ±16 mm en el brazo y es más difícil de fijar.
- Escala en el brazo y aguja en la cuna: la cara interior del brazo queda tapada por la cuna y el láser,
  y la aguja barrería contra el brazo en los ángulos bajos.
- Cubo de la polea graduado: Ø 14 mm, con rayas cada 1,8 mm. No se lee.

## R2. Aguja de índice de altura: columna integrada en el brazo del motor, a las 12

**Decisión**: el brazo del motor suma una **oreja** en su perfil 2D, por encima del alojamiento del 608.
Desde la cara exterior de la oreja sube una **aguja**, una columna de 4 × 5 mm que llega hasta el plano
de la cara del disco de la escala (`x_ext_polea_alt + espesor_disco_escala`). Así la punta queda en el
mismo plano que la escala y no hay paralaje.

- **Posición**: arriba del eje (las 12), con su cara interior a `r_brida + holgura_aguja` (2,5 mm).
  La correa abraza la polea por arriba, porque el motor está abajo. Su cara exterior queda a ≈ 26,6 mm
  del eje, así que la aguja la libra por ≈ 2,1 mm.
- **Forma**: la punta de la aguja tiene un bisel en V hacia el eje para leer la raya.
- **Impresión**: la aguja se imprime vertical, como los pilares del motor, porque el brazo se imprime
  con la cara exterior hacia arriba.
- **Tamaño**: el brazo pasa de 126,5 a ≈ 143 mm de largo, dentro de la cama.
- **Variantes**: solo cambia la variante «motor»; la variante «cable» queda igual.

**Alternativas descartadas**:
- Índice a las 3 o las 9: el brazo es angosto a la altura del eje, así que igual hace falta una oreja,
  y queda a 1 o 2 mm de la correa en la zona donde esta deja la polea.
- Índice en el carro del motor: el tensor lo corre ±3 mm, lo que da ±2° de error, y además está detrás
  de la correa.
- Raya en el brazo sin aguja: el brazo queda 40 mm detrás de la polea. La paralaje es de varios grados
  y la polea tapa el brazo dentro de su radio.

## R3. Letras «S» y «O» en la base

**Decisión**: «S» en la cara +Y y «O» en la cara +X del cilindro de apoyo de la base (r = 36 mm),
grabadas 0,6 mm.

- **Profundidad pareja**: se logra intersecando el texto, extruido en sentido radial, con una cáscara
  entre r = 35,4 y r = 36 + eps.
- **Tipografía**: «Liberation Sans:style=Bold» de 10 mm (OpenSCAD 2021.01 la encuentra en este entorno;
  se probó).
- **Línea de referencia**: debajo de cada letra va una línea vertical de 1,2 mm de ancho, que es la que
  se alinea con el índice de la plataforma.
- **Orientación del conjunto**: con el láser apuntando a +Y, el sur queda en +Y. Visto desde arriba, el
  sentido horario desde +Y lleva a +X, así que el oeste queda en +X y el este en −X.
- **Impresión**: la base se imprime parada, así que las letras quedan en paredes verticales y salen
  nítidas.
- **Interferencias**: la ventana de la llave está en −Y (el norte) y no toca ninguna letra. La correa de
  azimut está en z = 55,5 a 62,5, por encima de las letras.

**Alternativas descartadas**:
- Flecha que apunta hacia afuera: en una cara vertical no se puede dibujar una flecha radial. La línea
  vertical marca la dirección con más precisión.
- Letras en el cono superior de la base: quedan tapadas por la plataforma y la correa.
- Sumar «N» y «E»: no se pidieron, y la «N» caería sobre la ventana.

## R4. Índice de azimut en el borde +Y de la plataforma

**Decisión**: una raya vertical grabada en la cara del borde +Y de la plataforma, en x = 0, más un
triángulo grabado en la cara superior junto al borde, que apunta hacia afuera. La plataforma se imprime
con la cara inferior sobre la cama, así que la raya cae en una pared vertical.

- **Paralaje**: el índice está a r ≈ 96 mm y la línea de la «S» a r = 36 mm. Mirando desde el frente a
  50 cm, un corrimiento de 2 cm del ojo da ≈ 1,5° de error. La guía indica agacharse frente al
  aparato, a la altura de la base.
- **Error total**: con la brújula (±2 a 3°), el margen es de ±5° (SC-002). Alcanza para la posición de
  partida, porque la precisión la da la alineación con 2 estrellas.

**Alternativas descartadas**:
- Aguja colgante junto a la base: la plataforma se imprime boca abajo, así que la aguja haría falta
  imprimirla aparte. Además, en +Y chocaría con la polea del motor de azimut y con su recorrido de
  tensado (±3 mm).
- Índice en otra dirección que no sea la del láser: obligaría a explicar que el láser apunta a otro lado
  que el índice.

## R5. Convención de azimut del aparato y del visor

**Decisión**: la posición modelada (láser hacia +Y) es el **sur, azimut 180°**. En el ensamblaje, la
articulación `azimut` pasa a tener `reposo = 180` (el visor ya gira `valor − reposo`, contrato 007).

- Los objetivos de demostración, «Norte bajo» en 0°, «Este» en 90°, etc., quedan en grados de brújula
  y ahora apuntan de verdad al norte y al este según las letras de la base.
- Con el eje [0, 0, −1], un azimut positivo es horario visto desde arriba, como en la guía (5.1).

**Alternativa descartada**: dejar `reposo = 0`. El visor mostraría «Norte» apuntando a la «S».

## R6. Cómo se pone el cero de la escala

**Decisión** (sección de puesta a punto de la guía):

1. Apoyar la base sobre una mesa (con el trípode, nivelado) y apuntar el haz a una pared a 2 o 3 m.
2. Subir o bajar el láser hasta que el punto quede a la altura del eje de altura sobre la mesa. Esa
   altura es `z_eje_altura`, ≈ 180 mm sobre la cara de apoyo, y la guía la da.
3. Aflojar los 2 tornillos del disco, girarlo hasta que su 0° quede frente a la aguja y apretar.

Con 5 mm de error a 3 m, el cero queda a ≈ 0,1°. Solo hace falta una cinta métrica, sin nivel ni app.
La guía da también la alternativa de una app de inclinación apoyada en la cuna.

## R7. Escala: ángulos y sentido

**Decisión**:

- **Rayas**: 7 rayas, de 0° a 90° cada 15°. Las de 0°, 45° y 90° son más largas (desde r = 19 mm); las
  demás, desde r = 21,5 mm. Todas llegan al borde (r = 26,2 mm) y tienen 1 mm de ancho y 0,6 mm de
  profundidad.
- **Sin números**: no entran sin tocar las ranuras. Las rayas largas cada 45° alcanzan para contar.
- **Sentido**: la polea gira con la cuna, con `rotate([angulo_altura, 0, 0])` en el conjunto. Una
  marca que está arriba se va hacia −Y cuando el láser sube, así que la raya de un ángulo `a` va a `a`
  grados de la vertical, hacia +Y, con el láser a 0° y el disco con el cero puesto.
- **Comprobación**: el ensamblaje comprueba que cada raya, girada con la articulación hasta su ángulo,
  cae frente a la aguja (M-08).

## R8. Brújula y declinación magnética

**Decisión** (la guía, sección nueva de puesta en estación):

- **Celular**: la manera más fácil es una app de brújula configurada en «norte verdadero» o
  «geográfico», que ya corrige la declinación.
- **Brújula magnética**: el rumbo magnético del sur verdadero es 180° − D, con la declinación D positiva
  al este y negativa al oeste. Por ejemplo, con D = −8° se apunta a 188°.
- **Valor de la declinación**: se consulta para el lugar en el calculador de la NOAA (modelo WMM). El
  signo y los valores de ejemplo se verifican en esa fuente al escribir la guía, con fecha, como pide la
  constitución para los datos externos.
- **Imanes de los motores**: el rumbo se toma a más de 50 cm del aparato, sobre un objeto lejano, y
  después se alinea la «S» con ese objeto girando la cabeza del trípode, sin desenroscar la base.

## R9. Simulación FEM: no aplica

Los cambios no agregan cargas:

- **Grabados**: tienen 0,6 mm y están en zonas sin esfuerzo (pared lateral de la base, borde de la
  plataforma, disco).
- **Aguja**: solo carga su propio peso.
- **Disco**: no transmite par, porque el par sigue pasando por el hexágono del perno.
- **Agujeros guía de la polea**: quedan en la zona de aligerados, con ≥ 2,9 mm de pared hasta cada
  aligerado. El momento de la correa (28BYJ-48, ≈ 0,03 N·m × 4) es menor que 0,15 N·m, y la tensión
  sobre ese disco es despreciable.
- **Masa**: el disco suma ≈ 3 g a la parte que gira en altura, del lado del motor y sobre el eje, así
  que no cambia el equilibrio, que depende de la posición del láser en la cuna.

## R10. Visor, vistas explotadas y lista de materiales

**Decisión**:

- **Elementos nuevos del ensamblaje**: `disco_escala` (impresa, color claro) y `tornillos_disco` (2 ×
  M3 × 8 con arandela).
- **Movimiento**: los dos van en `elementos_altura` y en `grupo_horquilla`, para que giren con la cuna.
- **Paso de armado**: se suman al paso de la polea de altura, con los tornillos sin apretar. El cero se
  pone en la puesta a punto (R6).
- **Lista de materiales**: un renglón nuevo, 2 × tornillo M3 × 8 + 2 × arandela M3 para el disco de la
  escala, sin precio, como los demás tornillos.
- **Regeneración**:
  - Las STL de la base, la plataforma, el brazo del motor y la polea, más la nueva del disco.
  - Todas las vistas explotadas, porque la base aparece desde el paso 1.
  - La captura del conjunto.
  - El visor y la web.
