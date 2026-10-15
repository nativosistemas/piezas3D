# Investigación: Simulación de funcionamiento en el visor 3D

**Funcionalidad**: [spec.md](spec.md) · **Plan**: [plan.md](plan.md)

Punto de partida: el visor de la funcionalidad 005 ([plan](../005-visor-armado-3d/plan.md)) ya carga
cada elemento del catálogo como una malla separada, en su posición final del conjunto, y lee del
ensamblaje los datos de los pasos con `paso_armado = -1`.

## R1. Girar las mallas del catálogo en vez de exportarlas en otra posición

**Decisión**: la simulación usa las mismas mallas del modo de armado. Cada eje móvil declara su
**reposo**: el ángulo en que el catálogo dibuja sus elementos (en el puntero láser, `angulo_altura`,
45°; el azimut, 0°). El visor gira cada grupo `valor − reposo` alrededor del eje y el punto
declarados.

**Por qué**: una pieza rígida girada desde 45° queda igual que exportada en otro ángulo, así que no
hace falta exportar dos veces ni engordar el archivo; el modo de armado y las capturas no cambian
(FR-004) y la caché por huella sigue sirviendo.

**Descartado**:

- Exportar las piezas móviles con el ángulo en 0°: duplica mallas (las del armado siguen en 45°) o
  cambia la vista del armado.
- Hacer que el catálogo use un ángulo propio de exportación: obliga a tocar cada `elemento(e)`.

**Consecuencia**: el reposo DEBE ser exactamente el ángulo con que se dibuja el catálogo. Se asegura
en el ensamblaje (el reposo se declara con la misma variable, `angulo_altura`) y lo comprueba el
generador (R6).

## R2. Cadena cinemática del puntero láser

Leída de `src/puntero_laser_ensamblaje.scad` y de los parámetros:

| Eje | Elementos | Eje de giro y punto | Rango | Montado en |
|---|---|---|---|---|
| Fijo | `grupo_base` (base, tuerca del trípode, 608 de la base, arandelas, separador, perno y autoblocante de azimut) | — | — | — |
| Azimut | Todo lo que no es fijo ni de altura (plataforma, horquilla, carros, motores, poleas 20T, correas, electrónica, tapa, tornillería) | Z por el origen | Sin límite | — |
| Altura | Cuna, láser, pila falsa, tapa trasera, lastre, grapa, tuerca del muñón, perno del lado cable, perno del lado motor, polea de altura | X por `[0, 0, z_eje_altura]` | −10° … 95° | Azimut |

- El perno del azimut atraviesa la plataforma pero va apretado a la base: queda fijo. Los 608 de los
  brazos y la arandela y autoblocante del lado cable quedan con la horquilla (azimut); el perno del
  lado motor va trabado en el hexágono de la polea de altura, así que gira con ella.
- El rango de altura hoy está escrito como literales (`-10` y `95`) en el barrido V-07
  (`secciones`, `holgura_barrido_zona`) y en el conjunto (`%laser_en(-10)`, `%laser_en(95)`). Se
  pasa a dos constantes, `angulo_altura_min` y `angulo_altura_max`, en `/* [Hidden] */` de los
  parámetros, usadas en esos lugares y en la declaración del eje: un solo lugar para el rango.
  Las STL no cambian (mismos valores).

## R3. Motores y relación de transmisión

- Se ve girar la **polea de 20 dientes** de cada motor (`polea20_az`, `polea20_alt`). La reducción
  interna del 28BYJ-48 y su rotor no se dibujan; el eje de salida está dentro de la malla del motor.
- `relacion_correa = dientes_polea_conducida / dientes_polea_motriz` ya existe en los parámetros
  (80/20 = 4). Se declara con signo:
  - **Altura**: la polea grande gira con la cuna respecto de la horquilla, que es donde va el motor;
    con correa (no engranaje) las dos poleas giran en el mismo sentido: `+relacion_correa`.
  - **Azimut**: la polea grande está fija a la base y el motor viaja con la plataforma. Respecto de
    la plataforma, la polea grande gira `−θ`, así que la 20T gira `−relacion_correa · θ`.
- Regla general: el motor gira **respecto del marco en que está montado**
  `relación × (valor − reposo)` del eje que impulsa. El signo es parte de la declaración.
- Una polea de 20 dientes casi no muestra que gira. El visor le agrega una **marca de giro**: una
  franja de color contrastante sobre su cara, del radio de la malla, que el generador no exporta.
- Dato extra: si el eje declara `pasos_por_grado` (el puntero láser lo tiene, 45,29 medios pasos
  por grado), el visor muestra la posición también en pasos del motor, como el firmware.

## R4. Velocidad máxima

La guía (tabla del firmware) da ≈ 900 medios pasos/s ≈ 20°/s como velocidad máxima fiable. Se
declara en los parámetros `medios_pasos_por_segundo_max = 900` y la velocidad del eje sale de
`medios_pasos_por_segundo_max / pasos_por_grado` (19,9°/s): no se escribe un segundo número. El
modo automático mueve cada eje a su velocidad máxima, de forma independiente (como dos motores con
su propio reloj), con aceleración no modelada (el tramo de arranque del 28BYJ-48 dura décimas de
segundo frente a varios segundos de movimiento; ±10 % de SC-006).

## R5. Elementos que se deforman: el cable del láser

El cable (`cable_laser`) tiene un tramo que viaja con el láser (canaleta, grapa) y otro fijo a la
horquilla (desde el muñón hasta la electrónica). Girarlo entero con la altura lo despegaría del
brazo; dejarlo quieto lo despegaría del láser.

**Decisión**: declararlo **deformable**: el generador lo exporta además en varios valores del eje
de altura (cada 5° de −10° a 95°: 22 mallas, ~40 KB cada una, ≈ 1,2 MB en base64) pasando la
variable del eje por `-D angulo_altura=…`, y el visor muestra la malla del ángulo más cercano. Se
ubica en el marco del eje padre (azimut), así que acompaña al azimut sin otra exportación.

**Descartado**: interpolar vértices (las mallas de distintos ángulos no tienen la misma cantidad de
vértices) y ocultar el cable (FR-014 pide que no desaparezca).

**Para eso** el eje declara el **nombre de su variable** en el ensamblaje (`"angulo_altura"`). Las
correas no se declaran deformables: quedan quietas en su marco (la de altura, en la horquilla; la de
azimut, en la plataforma), como permite la spec.

## R6. Validar los pivotes contra OpenSCAD (SC-002)

Un error de signo o de punto de giro se vería recién en el navegador. Como el eje declara su
variable, el generador puede comprobarlo solo: para cada eje con variable exporta sus elementos
rígidos en los dos extremos del rango (`-D angulo_altura=-10` y `95`), gira las mallas del catálogo
con la misma transformación que usará el visor y compara las cajas envolventes. Falla si alguna
difiere en más de 0,5 mm, nombrando el eje, el elemento y el ángulo.

- Costo: 10 elementos × 2 ángulos = 20 exportaciones a `$fn = 32`, en paralelo, solo cuando cambia
  la huella (con mallas reutilizadas no se repite).
- Comparar cajas y no vértices: el orden de los triángulos de OpenSCAD no es determinista.
- Comprueba a la vez el reposo (R1): si el reposo no fuera el ángulo del catálogo, las cajas no
  coincidirían.
- El azimut no tiene variable (el catálogo no lo dibuja girado): no se comprueba; su eje es Z por el
  origen, y lo cubre la revisión en el navegador.

## R7. Dónde se declaran los datos y cómo viajan

- El ensamblaje define, de forma opcional, cinco listas: `articulaciones`, `motores`, `emisores`,
  `objetivos` y `deformables` (formato en [contracts/ensamblaje.md](contracts/ensamblaje.md)). Se usa
  "articulación" para el grado de libertad y se reserva "eje" para la recta de giro.
- `armado_comun.scad` las lee con `is_undef(…)`: con OpenSCAD 2021.01 y `--hardwarnings`, consultar
  una variable no definida con `is_undef` no avisa (probado), mientras que redefinir una variable sí
  detiene la validación. Así un diseño que no declara nada (la caja de pilas) no cambia.
- Con `paso_armado = -1` la biblioteca agrega líneas `ARTICULACIONES;…`, `MOTORES;…`, `EMISORES;…`,
  `OBJETIVOS;…` y `DEFORMABLES;…` al final de las actuales. `capturas_armado.sh` solo lee `PASO;` y
  no cambia.
- La biblioteca valida con `assert` lo que se puede validar en OpenSCAD (elemento inexistente o
  repetido entre articulaciones y motores, eje nulo, rango invertido, reposo fuera del rango, padre
  inexistente o cadena circular, relación nula, objetivo fuera de rango). El generador agrega las
  validaciones geométricas (R6) y la del tamaño.
- Los datos van al JSON incrustado como un objeto `simulacion` (ausente si no hay articulaciones).
  El formato sube a `version: 2`: una página vieja se regenera sola porque la versión no coincide.
- La huella de la 005 ya incluye todos los `.scad` del diseño y la biblioteca: un cambio en una
  declaración, una relación o un rango hace fallar `--comprobar` sin nada nuevo (FR-008, SC-007).

## R8. Haz del láser

- Un cilindro fino con material emisivo, mezcla aditiva y sin escribir profundidad, más un halo
  (sprite con degradado radial dibujado en un `<canvas>`, sin imágenes externas) en la salida y una
  luz puntual tenue que tiñe las piezas cercanas.
- Largo fijo declarado en el emisor (600 mm en el puntero láser, el doble del aparato), excluido del
  encuadre de la cámara.
- El punto de salida y la dirección se declaran en coordenadas del conjunto con el eje en reposo,
  calculados en el ensamblaje con `en_conjunto(…, angulo_altura)` desde `l_delantero` (la punta del
  láser), así siguen al diseño si cambia el largo del láser.

## R9. Interfaz: dos modos en la misma página

- Pestañas "Armado" y "Funcionamiento" arriba del panel lateral; solo aparecen si hay `simulacion`.
- **Armado**: igual que hoy. **Funcionamiento**: el conjunto completo y opaco (la tapa, si el
  diseño la dibuja transparente en `ensamblaje_principal`, se muestra transparente: se declara con
  una lista opcional `transparentes_simulacion`, por defecto vacía), un deslizador con campo numérico
  por articulación, la lectura de cada motor (grados, vueltas y pasos si hay `pasos_por_grado`), un
  botón por emisor, "Automático", velocidad (×1, ×5, ×20) y "Reposo".
- El paso de armado, su `t` y la cámara se conservan al ir y volver (FR-020).
- Direcciones nuevas para revisar y capturar: `#funcionamiento` y
  `?modo=funcionamiento&altura=95&azimut=30&laser=1` (un parámetro por articulación, con su nombre).
- Teclado en Funcionamiento: `L` enciende o apaga el primer emisor, `A` el modo automático.
- Celular: el panel queda debajo de la vista, como hoy; los deslizadores ocupan todo el ancho.

## R10. Modo automático

Máquina de estados basada en el tiempo real (`reloj.getDelta()`, recortado a 0,1 s por cuadro para
que una pestaña en segundo plano no salte de golpe):

```text
mover (emisores apagados) ──llegó──► apuntar (emisor encendido, 3 s) ──► mover al siguiente
cualquier control manual / salir del modo ──► manual (emisores apagados)
```

- Azimut sin límite: va por el camino más corto y el valor mostrado se normaliza a 0–360°.
- Con rango: va directo (el rango es convexo, no hay atajo posible).
- La velocidad elegida multiplica el avance; con ×5 o ×20 aparece "velocidad no real".
- Los objetivos de demostración del puntero láser: 6 apuntes repartidos en azimut y en altura
  (incluido uno cerca de 90°, el cenit, y otro con cruce de 350° a 10°), con nombres descriptivos
  ("Norte bajo", "Cenit", …). Estrellas reales: funcionalidad posterior (aclaración de la spec).

## R11. Rendimiento y tamaño

- Mallas: las mismas 49 del visor actual + 22 del cable ≈ 2,7 MB + 1,2 MB ≈ 4 MB (≤ 10 MB).
- Girar grupos de three.js no recalcula geometría; el cable cambia de malla visible (las 22 se crean
  al entrar al modo, ocultas). Un celular de gama media mueve esto sin problemas.

## R12. Constitución

No hace falta enmendarla: el Principio V exige el visor y esta funcionalidad lo amplía sin cambiar
la obligación. La convención (cómo declarar articulaciones) es una instrucción de fase y va en la
skill `disenio-multipieza`; la revisión en el navegador, en la skill `web-armado` (Gobernanza: cada
regla en un solo lugar). Las skills están en `.claude/skills/`, que el sandbox no deja escribir: se
editan con las herramientas de edición, no con la terminal.
