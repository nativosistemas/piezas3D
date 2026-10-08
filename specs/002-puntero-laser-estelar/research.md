# Investigación (Fase 0): Puntero láser estelar motorizado (alt-az)

**Funcionalidad**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

Este documento resuelve las incógnitas técnicas del plan. Cada apartado registra la **decisión**, el
**motivo** y las **alternativas descartadas**. Las cifras numéricas se recalculan en
`src/puntero_laser_parametros.scad` a partir de los parámetros, y los `assert` comprueban que siguen
siendo válidas.

Sistema de ejes del conjunto (lo usan todos los documentos):

- **Z**: vertical. El origen está en la cara de apoyo de la base sobre el trípode.
- **Eje de azimut**: coincide con Z.
- **Eje de altura**: paralelo a X, a una altura `z_eje_altura`.
- **Láser a 0° de altura**: apunta hacia +Y.
- **Lado +X**: lado del motor de altura (los dos motores y las poleas).
- **Lado −X**: lado de la electrónica (ESP32, drivers, relé y power bank, bajo la tapa).

---

## R1. Arquitectura de la montura

**Decisión**: montura alt-az de horquilla. Tiene una base fija, una plataforma giratoria sobre 2
rodamientos 608ZZ y una cuna tubular del láser que gira entre dos brazos, con un 608ZZ en cada brazo.
Toda la electrónica y los dos motores viajan en la plataforma.

**Motivo**: es la cinemática más simple para apuntar a cualquier punto del cielo con dos motores. Al
llevar todo en la parte giratoria, ningún cable cruza el eje de azimut, que puede girar sin límite y
sin anillo rozante (FR-007, FR-009). La horquilla permite equilibrar el láser sobre su eje (FR-008).

**Alternativas descartadas**:

- **Montura ecuatorial**: exige alinear con el polo, agrega una pieza de latitud y no mejora el
  apuntado. La alineación con 2 estrellas ya corrige la orientación.
- **Láser en voladizo a un costado de un solo brazo**: el par de desbalance sobre el motor es mayor y
  el brazo se flexiona más.
- **Electrónica en la base fija con anillo rozante**: es más caro, agrega rozamiento y ruido
  eléctrico, y no aporta nada si la alimentación viaja arriba.

---

## R2. División en piezas y motivo de cada corte

**Decisión**: 10 archivos imprimibles (11 piezas físicas).

| # | Pieza | Cant. | Motivo del corte (skill §2) | Se une con | Unión |
|---|-------|-------|------------------------------|------------|-------|
| 1 | `adaptador_tripode` | 1 | Parte fija frente a la móvil; lleva la polea fija de azimut (80T) integrada | Trípode, plataforma | Tuerca 3/8"-16 embebida; 2 × 608ZZ a presión + perno M8 |
| 2 | `plataforma_azimut` | 1 | Parte móvil; aloja la electrónica | Base, brazos, carros, tapa | Perno M8 a través de los 608 de la base; M3 + tuerca embebida |
| 3 | `brazo_horquilla` (variante `motor`) | 1 | Se imprime plano: las capas no trabajan a flexión; los alojamientos del 608 salen redondos | Plataforma, carro de altura, cuna | M3 + tuerca embebida en el pie; 608ZZ a presión |
| 4 | `brazo_horquilla` (variante `cable`) | 1 | Igual que el anterior; lleva el canal del cable del láser | Plataforma, cuna | Igual que el anterior |
| 5 | `cuna_laser` | 1 | Parte móvil; colimación y equilibrado | Brazos (por los 608), polea de altura | Perno M8 con la cabeza embebida; 6 × M3 de colimación |
| 6 | `polea_altitud` | 1 | Parte móvil; impresa plana para que los dientes salgan bien | Cuna (por el perno M8) | Cabeza del perno M8 en un alojamiento hexagonal (chaveta) |
| 7 | `carro_motor` | 2 | Repuesto común y tensor; **el mismo archivo** sirve para los 2 ejes | Motor 28BYJ-48; plataforma o pilares del brazo | M3 autorroscante en las orejas del motor; M3 en ranuras |
| 8 | `separador_azimut` | 1 | Separa los aros interiores de los 2 rodamientos de azimut | Perno M8 | Ajuste deslizante |
| 9 | `tapa_electronica` | 1 | Acceso a la electrónica y al power bank | Plataforma | Encastre con guías + 2 × M3 |
| 10 | `probeta_ajuste_608` | 1 | Auxiliar: calibrar el ajuste a presión antes de imprimir las piezas grandes | — | — |

**Motivo**: cada corte tiene un motivo de la sección 2 de la skill. La polea de azimut se integra en
la base y los pilares del motor de altura se integran en el brazo, para no sumar uniones. El carro del
motor es una sola pieza que se repite en los dos ejes.

**Alternativas descartadas**:

- **Horquilla y plataforma en una sola pieza**: los brazos quedarían impresos de pie, con las capas
  perpendiculares a la flexión, y los alojamientos de los 608 saldrían ovalados.
- **Polea de altura integrada en la cuna**: el brazo queda entre la cuna y el plano de la correa, así
  que la polea tiene que montarse por fuera del brazo.
- **Dos brazos idénticos**: el brazo del motor necesita pilares y el del cable necesita un canal.
  Se usa un solo archivo con dos variantes (`lado = "motor" | "cable"`) y se exportan dos STL.

---

## R3. Transmisión: correa GT2, relación y largo de la correa

**Decisión**:

- **Componentes por eje**: polea motriz comprada GT2 20T de agujero 5 mm, polea conducida impresa
  GT2 80T y correa GT2 cerrada de **200 mm (100 dientes), 6 mm de ancho**. Es la misma en los 2 ejes.
- **Relación**: exacta de 1:4.
- **Distancia entre centros** (fórmula exacta de correa abierta):

  | Dato | Valor |
  |------|-------|
  | Diámetro primitivo de la polea 20T | 12,732 mm |
  | Diámetro primitivo de la polea 80T | 50,930 mm |
  | Distancia teórica entre centros (200 mm) | 45,97 mm |
  | Ajuste del carro | ±3 mm |

  El ajuste de ±3 mm sirve para tensar la correa y absorber la dispersión de largo entre fabricantes.

**Motivo**:

- **Relación exacta**: en una correa dentada la relación depende solo del número de dientes, no del
  diámetro impreso. Por eso no acumula error aunque la polea impresa salga 0,1 mm más chica o más
  grande. Con engranajes impresos, una diferencia de diámetro sí cambia el juego.
- **Largo de correa**: 200 mm es un largo cerrado estándar y barato (200-2GT-6), y da una distancia
  entre centros cómoda. Con 188 mm quedan 39 mm, demasiado juntos para el cuerpo del motor. Con 280 mm
  quedan 88 mm, y la plataforma no entra en la cama.
- **Relación 1:4**: divide por 4 el juego de la caja del motor y la resolución. Una relación mayor
  (100T, Ø 63,7 mm) agranda la plataforma y el brazo, y hace más lento el giro.

**Perfil del diente impreso**: aproximación propia del GT2 (paso 2 mm, profundidad 0,75 mm). Cada
hueco se resta con un círculo de r ≈ 0,555 mm con su centro sobre la línea primitiva, más un
redondeo. El diámetro exterior es el primitivo − 0,508 mm. El parámetro `ajuste_diente_gt2`
(por defecto 0) agranda o achica el hueco para corregir la impresora. El diente se imprime con su
eje vertical, sobre las paredes, y sale nítido con boquilla de 0,4 mm.

**Alternativas descartadas**:

- **Engranajes rectos o en espiga impresos**: no requieren compras, pero tienen más juego
  (0,3–0,5°) y la relación depende de la precisión del diámetro impreso.
- **Polea 20T impresa**: con 20 dientes el error de impresión pesa demasiado. Las poleas de aluminio
  cuestan muy poco.
- **Tornillo sin fin**: no se mueve a mano y tiene poco juego, pero el 28BYJ-48 resulta demasiado
  lento a través de él y la pieza es difícil de imprimir.

---

## R4. Presupuesto de error de apuntado (FR-016, FR-017, SC-003, SC-004)

**Datos del motor**:

- Relación interna real del 28BYJ-48: (32/9)·(22/11)·(26/9)·(31/10) = **63,684:1**.
- Medios pasos por vuelta del motor: 63,684 × 64 = **4075,77**.
- Con la correa 1:4: **16 303,09 medios pasos por vuelta del eje → 45,286 pasos/° → 0,0221°/paso**.

| Fuente | Valor estimado | Cómo se controla |
|--------|----------------|------------------|
| Resolución (cada eje) | 0,022° | Correa 1:4 |
| Juego de la caja del motor (1–3°) ÷ 4 | 0,25–0,75° → **~0,1°** de repetibilidad si se llega siempre desde el mismo sentido | Regla de llegada unidireccional ([contrato de firmware](contracts/interfaz_firmware.md)) |
| Juego de la correa y de los dientes impresos | ~0,1° (cada eje) | Tensor ajustable (FR-006) y `ajuste_diente_gt2` |
| Inclinación de la plataforma por holgura de los 608 de azimut | ≤ 0,1° | 608 a presión, separados ≥ 20 mm y con precarga (R6). Centro de masa cerca del eje (R9) |
| Falta de perpendicularidad entre los ejes de altura y azimut | ≤ 0,25° | Brazos impresos planos que se apoyan en rebajes de la plataforma. Lo absorbe en parte la alineación |
| Colimación residual del haz | ≤ 0,2° | 3 + 3 tornillos M3 en la cuna (R7) |
| Centrado visual del haz en las estrellas de alineación | 0,2–0,3° | Alineación con 2 estrellas ([contrato de firmware](contracts/interfaz_firmware.md)) |
| Flexión de los brazos | < 0,01° | R10 |
| Hora y ubicación | < 0,05° | NTP o GPS en el firmware |
| Relación mal configurada (4096 en lugar de 4075,77) | **1,79° por vuelta del eje** | Constante obligatoria en el contrato de firmware |

**Resultado**:

- **Suma cuadrática**: **≈ 0,50°**.
- **Peor caso (suma lineal)**: **≈ 1,3°**.
- Ambos cumplen el límite de 2° y el objetivo de 1°.
- **Sin llegada unidireccional**, el juego no compensado (0,25–0,75°) sube el peor caso a ≈ 2,0°:
  **no se cumple con margen**. Por eso la regla es obligatoria en el contrato de firmware.

**Alternativas descartadas**: motor conectado directo al eje. Tiene 0,088°/paso y 1–3° de juego sin
dividir, con un total estimado de 2–4°, y **no cumple**.

---

## R5. Disposición en planta y altura del eje de altura

> **Corregido en la implementación.** El motor de azimut va en **+Y** y las placas en **+X**, bajo la
> tapa. Solo el power bank queda en −X. Detalle y motivo en
> [data-model.md, «Cambios introducidos en la implementación»](data-model.md#cambios-introducidos-en-la-implementación).

**Decisión**:

- **Plataforma**: rectangular de hasta **196 × 196 mm**. Entra en 200 × 200 mm con margen; se
  comprueba con `assert`.
- **Zonas**:

  | Zona | Ubicación | Contenido |
  |------|-----------|-----------|
  | Franja central | \|X\| < `semiancho_interior_horquilla` (25 mm por defecto) | Barrido del láser. Nada más alto que 5 mm, salvo el perno M8 central, cuya cabeza va embutida |
  | Brazos | X = ±25 … ±35 mm, Y = ±18 mm | Pie de cada brazo, apoyado en un rebaje |
  | Lado +X | Debajo del motor de altura | Motor de azimut en su carro, a 45,97 mm del eje. Las orejas quedan en dirección Y y el cuerpo hacia afuera (centro del cuerpo en X ≈ 54 mm, 4 mm libres respecto del brazo) |
  | Lado −X, columna exterior (~26 mm) | Junto al borde | Power bank de pie (25 × 100 × 65 mm) |
  | Lado −X, columna interior (~32 mm) | Entre el power bank y el brazo | 2 drivers ULN2003 y el relé. El ESP32 va en la columna exterior, en el tramo de Y que deja libre el power bank |

  Una sola `tapa_electronica` cubre todo el lado −X.

- **Altura del eje de altura sobre la cara superior de la plataforma**:

  ```text
  altura_eje = max(l_trasero, l_delantero) + radio_laser·sin(5°) + holgura_barrido (8 mm) + altura_libre_central (5 mm)
  ```

  Con los valores por defecto da ≈ 110 mm. `l_trasero` y `l_delantero` se miden desde el centro de
  masa del láser, que coincide con el eje cuando el láser está equilibrado.

**Motivo**:

- **Barrido del láser**: el láser equilibrado barre un círculo de radio ≈ 100 mm en el plano YZ
  dentro de la franja central. Solo baja hasta la plataforma cuando apunta al cenit (95°). A −10°, el
  extremo delantero queda 16 mm por debajo del eje: no hay riesgo.
- **Dónde va cada cosa**: fuera de la franja la altura es libre. Por eso la electrónica va a un lado
  y los motores al otro.
- **Equilibrio**: el power bank (~200 g) en −X compensa los motores y la polea en +X (R9).

**Alternativas descartadas**:

- **Subir el eje para poner el power bank debajo del láser**: los brazos crecen a ~150 mm, se
  flexionan más y el aparato queda más inestable.
- **Motor de azimut dentro de la franja central**: el láser choca con el motor al apuntar alto.
- **Correa de 280 mm para alejar el motor**: la plataforma no entra en la cama.

---

## R6. Eje de azimut: rodamientos, perno y unión con el trípode

**Decisión** (de abajo hacia arriba, dentro de `adaptador_tripode`):

1. **Apoyo**: cara plana Ø ≥ 70 mm sobre la cabeza del trípode.
2. **Tuerca del trípode**: **tuerca 3/8"-16 UNC** (14,29 mm entre caras, 8,33 mm de alto) en un
   alojamiento hexagonal que se carga **desde arriba**, con un piso de 4 mm y un agujero de Ø 10,1 mm.
   Al apretar, el tornillo tira de la tuerca contra el piso. El hexágono impide que gire.
3. **Cámara**: aloja la **tuerca autoblocante M8** y la punta del perno. Una **ventana lateral**
   permite meter una llave de 13 mm. La cámara deja 6 mm libres para el tornillo del trípode.
4. **Rodamientos**: dos **608ZZ a presión**, uno cargado desde arriba y otro desde abajo, con un
   resalte central. La **distancia entre las caras exteriores es ≥ 30 mm** (resalte de 16 mm).
   Entre los aros interiores va el `separador_azimut`.
5. **Polea fija**: la **polea GT2 80T** forma parte del extremo superior del cubo, con una pestaña
   inferior (el cuerpo de la base) y otra superior (chaflán de 45°, sin soportes).

**Perno**: **perno M8 × 50** que baja desde la plataforma. La cabeza va embutida en un hexágono de la
cara superior de la plataforma, así que gira con ella y no sobresale. El perno atraviesa el cubo de la
plataforma, que solo toca el aro interior superior, el 608 superior, el separador y el 608 inferior.
Una arandela y la tuerca autoblocante M8 aprietan el aro interior desde abajo. Así se precargan los
aros interiores y desaparece el juego radial interno.

**Ajuste a presión**: el alojamiento mide `22,0 + ajuste_608` (por defecto +0,10 mm, porque las
impresoras FDM suelen achicar los agujeros). Se calibra con la `probeta_ajuste_608`, una pieza con 5
anillos de −0,1 a +0,3 mm, antes de imprimir las piezas grandes.

**Motivo**:

- **Inclinación**: la holgura de un alojamiento impreso (~0,05 mm) sobre una separación de 23 mm
  entre centros de rodamiento da ≤ 0,12° de inclinación. Con los rodamientos juntos (7 mm) serían
  0,4°. Esa inclinación gira con la plataforma y la alineación con estrellas no la corrige por
  completo, por eso es crítica.
- **Precarga**: elimina la holgura radial propia del rodamiento.
- **Tuerca del trípode cargada desde arriba**: si se cargara desde abajo, el propio tornillo la
  sacaría de su alojamiento.

**Alternativas descartadas**:

- **Rodamiento "lazy susan" grande**: es más rígido al vuelco, pero tiene más juego axial y no es
  estándar en tamaño.
- **Rodamiento de bolas impreso con bolillas**: el juego es impredecible.
- **Inserto 3/8"-16**: es menos común que la tuerca.

---

## R7. Cuna del láser: equilibrado, colimación y cable

> **Corregido en la implementación.** La colimación usa **6 prisioneros M3 × 8 roscados** en anillos
> de r = 23,5 mm, sin tuercas. Con tuercas el anillo debía medir r ≈ 25 mm, y los tornillos con cabeza
> sobresalían contra los brazos (a 25,2 mm). El brazo mide 12 mm (ver R10) y el labio del 608 es
> `espesor_brazo − 7`.

**Decisión**:

- **Tubo**: `cuna_laser` es un tubo de interior `diametro_laser + 4` mm (Ø 34 por defecto), pared de
  3 mm y largo de 100 mm, impreso de pie y sin soportes.
- **Colimación**: tiene un **anillo de 3 tornillos M3 a 120°** en cada extremo, con tuercas M3 en
  alojamientos radiales. El láser **se desliza dentro del tubo** para equilibrarlo y se fija con los
  6 tornillos. Moviendo los tornillos se corrige el haz: ±2 mm en una base de 92 mm equivale a ±1,2°
  de corrección.
- **Muñones**: dos muñones laterales en X = ±(radio exterior … `semiancho_interior_horquilla` − 0,5).
  Cada uno tiene un **alojamiento hexagonal para la cabeza del perno M8, abierto hacia el interior del
  tubo**, con 2,2 mm de piso. Los pernos se colocan **antes** que el láser. La cara exterior del muñón
  tiene un anillo Ø 11 mm que solo toca el aro interior del 608.
- **Cable**: ventana opcional `ventana_pulsador` en el tubo para llegar al pulsador del 303, y una
  ranura junto al muñón del lado del cable por donde salen los 2 hilos del relé, cerca del eje.

**Motivo**:

- **Equilibrado**: el 28BYJ-48 tiene poco par (R9). Con el láser equilibrado, el motor trabaja
  descansado y la caja del motor sostiene la posición sin energía (escenario 2 de la US2).
- **Por qué un tubo**: se imprime sin soportes, es rígido y protege el cuerpo del láser.
- **Cable**: los hilos cruzan el eje de altura a < 15 mm de él. En 105° de recorrido se doblan muy
  poco y alcanza con un bucle corto.

**Alternativas descartadas**:

- **Abrazaderas en V con un solo tornillo**: no permiten colimar en dos ejes.
- **Eje pasante M8 a través de la cuna**: cortaría el láser por la mitad.
- **Tuerca M8 dentro del muñón**: no entra sin invadir el interior del tubo. Se resolvió poniendo la
  cabeza adentro y la tuerca afuera.

---

## R8. Eje de altura y montaje del motor de altura

**Decisión**:

- **Brazos**: cada brazo (10 mm de espesor y 36 mm de ancho) lleva un 608ZZ a presión desde la cara
  exterior, con un labio interior de 3 mm (agujero Ø 16, que apoya el aro exterior).
- **Lado del motor**: la pila es tuerca M8 común (en la cuna) | muñón | aro interior del 608 |
  `polea_altitud` (cubo largo Ø 14 que solo toca el aro interior) | **cabeza del perno M8 en el
  hexágono de la polea**. La tuerca en el hexágono de la cuna y la cabeza en el hexágono de la polea
  forman una cadena de chavetas que transmite el par.
  *Corrección posterior (2026-10-07)*: la versión original ponía la cabeza del M8 × 55 en la cuna y la
  tuerca en la polea, pero ese perno (60 mm con la cabeza) no se puede meter desde dentro de un tubo
  de 34 mm. Ahora el perno entra desde afuera, por la polea, y se enrosca en la tuerca del muñón.
  La profundidad del hexágono de la polea ajusta el largo comercial para que la punta quede
  `margen_punta_perno` antes del interior del tubo.
- **Orden de armado**: los anillos de contacto hacen que la cuna mida 60 mm entre brazos que, fijos,
  quedan a 50 mm. La horquilla (brazos + cuna + polea) se arma con los brazos sueltos y después se
  atornilla a la plataforma.
- **Lado del cable**: cabeza M8 (en la cuna) | muñón | aro interior | arandela | tuerca autoblocante.
  Si la distancia entre muñones no coincide con la distancia entre brazos, se compensa con arandelas
  M8.
- **Motor de altura**: va entre el brazo y el `carro_motor`, que se atornilla a **2 pilares
  integrados en el brazo** (de altura = cuerpo del motor + oreja + 1 mm). El eje del motor sale hacia
  afuera, a través del carro, a 45,97 mm por debajo del eje de altura. La polea 80T queda en el mismo
  plano que la 20T gracias al largo del cubo, y un `assert` controla la alineación (±0,5 mm).
- **Tensado**: el carro se desliza ±3 mm en ranuras a lo largo del brazo. Un tornillo M3 de empuje
  lo tensa.

**Motivo**: el eje del 28BYJ-48 sobresale solo ~8 mm de la cara de montaje. No puede atravesar el
brazo (10 mm), y la polea no puede ir dentro de la horquilla porque choca con el barrido del láser.
La única opción limpia es que la polea quede por fuera del brazo, con el motor en pilares.

**Mismo carro en azimut**: el carro se apoya sobre la plataforma, con las orejas encima y el cuerpo
hacia arriba. El eje baja a través del carro y de una abertura alargada de la plataforma (Ø 21 mm)
donde entra el cubo de la polea 20T. Los dientes quedan bajo la plataforma, a la altura de la polea
fija de la base, y un `assert` controla la alineación. Un `assert` también exige al menos 5 mm de eje
dentro del cubo de la polea.

**Alternativas descartadas**:

- **Motor de altura sobre la plataforma con una correa larga hasta el eje**: lleva una correa de
  300 mm con más elasticidad y más juego.
- **Motor directo en el eje**: no cumple la precisión (R4).

---

## R9. Pares y equilibrio de masas

**Masas estimadas**:

| Componente | Masa |
|------------|------|
| Láser con batería | 180 g |
| Cuna | 60 g |
| Power bank | 200 g |
| Motores | 2 × 35 g |
| ESP32, drivers y relé | 45 g |
| Piezas impresas en PETG | ~420 g |
| **Total** | **≈ 0,98 kg** |

**Par de altura**:

| Caso | Valor |
|------|-------|
| Par disponible tras la reducción (34 mN·m × 4 × η 0,9) | **122 mN·m** |
| Desbalance de 10 mm (0,24 kg × 9,81 × 0,010) | 23,5 mN·m → **factor de seguridad 5,2** |
| Desbalance de 20 mm (láser sin equilibrar) | 47 mN·m → factor de seguridad 2,6. Funciona, pero sin margen ante el frío y el aumento del rozamiento, por eso la guía exige equilibrar |

**Par de azimut**:

- Inercia de la plataforma: ≈ 0,0036 kg·m².
- Par para acelerar a 22°/s en 0,5 s: ≈ 3 mN·m.
- Rozamiento de los 608 precargados: < 5 mN·m.
- Total: **< 10 mN·m frente a 122 disponibles**.

**Equilibrio de la plataforma**:

- Lado −X: power bank, placas y tapa, ≈ 305 g a X ≈ −65 mm.
- Lado +X: motores, carros, polea y pilares, ≈ 110 g a X ≈ +55 mm.
- El centro de masa queda a ≈ 14 mm del eje. Produce 0,14 N·m de momento de vuelco y ≈ 6 N de carga
  radial en cada 608: aceptable.
- Se deja un **alojamiento opcional de contrapeso** en +X (por ejemplo, tuercas M8) para llevar el
  centro de masa a menos de 5 mm del eje.

**Velocidad**: el 28BYJ-48 a 5 V funciona con fiabilidad hasta ~900 medios pasos/s (~13 rpm). En el
eje son ~20°/s, así que un giro de 180° tarda unos 9 s. El seguimiento sideral (0,0042°/s) queda muy
por debajo del límite.

---

## R10. Validación estructural (Principio III): **no aplica la simulación FEM**

**Decisión**: no se simula en FreeCAD. Se justifica con el cálculo analítico que sigue, que también
debe figurar en el plan (Puerta 2).

| Caso | Cálculo | Resultado |
|------|---------|-----------|
| Brazo con un golpe lateral de 5 N en la punta (L = 125 mm) | M = 0,625 N·m; W = 36·10²/6 = 600 mm³ | σ ≈ 1,0 MPa frente a ≥ 20 MPa entre capas del PETG → **factor de seguridad > 20** (impreso plano, la flexión va en el plano de las capas) |
| Brazo con el peso de la cuna y el láser (1,5 N por brazo, axial) y la tensión de la correa (≈ 15 N, axial) | δ = F·L/(E·A) = 15·110/(2000·360) | 0,002 mm → error de apuntado < 0,01° |
| Brazo con 1,5 N laterales en un solo brazo (por ejemplo, el cable) | δ = F·L³/(3·E·I), I = 36·10³/12 = 3000 mm⁴ | 0,17 mm → el eje se inclina 0,16° (flecha diferencial ÷ separación entre brazos). **Corregido en T026**: con `espesor_brazo` = 12 da 0,097 mm → 0,089° (< 0,1°) |
| Tornillo 3/8" y base | Carga estática de 10 N | Despreciable |
| Plataforma (placa de 4 mm con nervios) | 10 N repartidos | Despreciable |

**Motivo**: las cargas son de decenas de newtons y las tensiones están más de un orden de magnitud
por debajo del límite del material. El requisito determinante es la **rigidez para la precisión**, y
el cálculo cerrado alcanza para comprobarla. Una simulación FEM no cambiaría ninguna decisión. Si el
usuario agranda mucho el láser (> 400 g) o el largo de los brazos, la guía indica repetir este
cálculo.

**Alternativas descartadas**: simulación FEM de los brazos. Sería posible con las herramientas de
`.tools/`, pero su costo no se justifica para tensiones de ~1 MPa.

---

## R11. Electrónica, cableado y conexiones

**Decisión**:

- **Alimentación**: power bank USB-A → cable USB con salida a bornes → **interruptor general** →
  línea de 5 V a la placa ESP32 (pin 5V/VIN), a los 2 ULN2003 y al relé. Los motores **no** se
  alimentan a través del regulador ni del USB del ESP32.
- **Consumo máximo**: ≈ 0,75 A, con los 2 motores energizados (~240 mA cada uno), el ESP32 con WiFi
  (~200 mA) y el relé (~70 mA). Se pide un power bank de **≥ 2 A**.
- **Pines propuestos**:

  | Componente | GPIO |
  |------------|------|
  | ULN2003 de azimut (IN1–IN4) | 16, 17, 18, 19 |
  | ULN2003 de altura (IN1–IN4) | 25, 26, 27, 33 |
  | Relé | 23 |

  Se evitan los pines de arranque (0, 2, 12 y 15) y los de solo entrada (34–39).
- **Relé**: hay que usar un módulo que **funcione con lógica de 3,3 V**: con disparo por nivel alto,
  o con puente "H/L" en H. Los módulos de 5 V de disparo por nivel bajo con optoacoplador no se apagan
  del todo con 3,3 V. Esto se documenta en la guía.
- **Láser**: el contacto NA del relé se suelda en paralelo al pulsador del 303, con la llave en ON.
  El cable al láser es **bipolar de silicona de 26 AWG** (flexible), con un bucle de 40 mm en el brazo
  del cable.
- **Recorrido de cables**:
  - Los cables de los motores (~25 cm con conector JST) bajan por canales: el de altura por la cara
    exterior del brazo del motor, el de azimut directamente sobre la plataforma.
  - Cruzan la franja central hacia el lado −X por un **conducto elevado** sobre la plataforma
    (≤ 4 mm de alto, paredes de 1,6 mm). No se rebaja la placa, para no dejar un piso de menos de
    1,2 mm (FR-021).
  - El sobrante se enrolla en un hueco bajo la tapa.
  - Ningún cable pasa a menos de 5 mm de una correa o polea; un `assert` controla los canales.
- **Potencia del motor en reposo**: se recomienda desenergizar los motores en reposo. La caja del
  28BYJ-48 sostiene la posición con el láser equilibrado, se calienta menos y la batería dura más. Se
  comprueba en el quickstart (escenario físico).
- **Power bank que se apaga solo**: con el ESP32 en WiFi el consumo es de ~80–120 mA, por encima del
  umbral típico de apagado (~50–70 mA). Si un modelo se apaga, la guía sugiere el modo "baja
  corriente" del power bank o una resistencia de carga de 100 Ω y 0,5 W conectada en ráfagas por un
  GPIO libre.

**Alternativas descartadas**:

- **MOSFET en lugar de relé**: el usuario eligió relé.
- **Pila 18650 integrada**: el usuario eligió power bank.
- **Alimentar los motores desde el pin 3V3 o a través del USB del ESP32**: se producen caídas de
  tensión y reinicios.

---

## R12. Seguridad del láser

**Decisión**: la guía incluye advertencias y el contrato de firmware exige:

- **Apagado automático**: tiempo máximo de encendido continuo de **30 s** (configurable), seguido de
  un enfriamiento de igual duración. Los láseres verdes DPSS baratos se recalientan y pierden potencia.
- **Arranque y fallos**: el láser se apaga al reiniciar, al perder la conexión WiFi y por debajo de
  10° de altura (para no apuntar a personas o al tránsito).
- **Advertencias de la guía**: no apuntar nunca a aeronaves, personas, animales ni vehículos;
  respetar la normativa local sobre punteros láser (potencia y uso); y saber que con frío (< 0 °C)
  el 303 puede no encender.

**Motivo**: los punteros "303" suelen superar los 5 mW (clase 3B en la práctica) y son un riesgo real
para la vista y la aviación.

---

## R13. Material, holguras y tornillería unificada

**Decisión**:

- **Material**: PETG en todas las piezas, por la humedad nocturna y la temperatura dentro de un auto
  al sol. Las poleas, con 4 perímetros.
- **Holguras** (parámetros de `_parametros.scad`):

  | Parámetro | Valor |
  |-----------|-------|
  | `holgura_encastre` | 0,25 mm |
  | `holgura_tornillo_m3` | 0,3 mm (agujero Ø 3,3) |
  | `holgura_tuerca` | 0,2 mm (hexágono M3 de 5,7 mm) |
  | `diametro_autorroscante_m3` | 2,6 mm (85 %) |
  | `holgura_perno_m8` | 0,4 mm (Ø 8,4) |
  | `ajuste_608` | +0,10 mm |
  | `holgura_barrido` | 8 mm |

- **Tornillería**: **M3 en todo el diseño**, salvo el eje de azimut (perno M8 × 50), los ejes de
  altura (M8 × 60 del lado del motor y M8 × 30 del lado del cable) y la tuerca 3/8"-16 del trípode.
- **Placas**: el ESP32, el relé y los ULN2003 se sujetan con **soportes de encastre** (guías con
  labio) dimensionados por parámetro. No llevan tornillos, porque muchas DevKit no tienen agujeros y
  los agujeros de los módulos no son de M3.

**Alternativas descartadas**:

- **PLA**: se ablanda a ~55 °C dentro de un auto.
- **Insertos roscados en caliente**: el diseño no se desarma con frecuencia, así que las tuercas
  embebidas alcanzan.

---

## R14. Organización de archivos y verificación

**Decisión**: se sigue la estructura de la sección 4 de la skill `disenio-multipieza`, con el prefijo
`puntero_laser`.

- **`src/puntero_laser_parametros.scad`**: parámetros compartidos, derivados y `assert` globales. No
  tiene geometría propia.
- **Archivos de pieza**: un `.scad` por pieza con su encabezado estándar. Cada uno hace
  `include <puntero_laser_parametros.scad>`, define `module pieza_<nombre>()` en orientación de
  impresión y llama a `ensamblaje_principal()`.
- **`src/puntero_laser_ensamblaje.scad`**: hace `use <…>` de cada pieza, las coloca en posición con
  la convención de ejes de arriba, dibuja los componentes comprados como volúmenes simplificados
  (motores, poleas 20T, correas, placas, power bank y láser en 3 posiciones: −10°, 45° y 95°) y
  verifica los choques con `assert` sobre las cotas derivadas. No se exporta.
- **Verificación**:
  - Renderizado de cada pieza con `--hardwarnings`.
  - Caja envolvente de cada STL ≤ 200 × 200 mm (con `python3`).
  - Barrido de variantes con `-D`.
  - Casos inválidos que deben fallar.
  - Vista del ensamblaje.
  - Pruebas físicas (banco y cielo).

  No se crea `tests/`, igual que en la funcionalidad 001.

**Alternativas descartadas**: un solo `.scad` con todas las piezas y un selector. Es más difícil de
leer, contradice la skill y obliga a regenerar todo para revisar una pieza.
