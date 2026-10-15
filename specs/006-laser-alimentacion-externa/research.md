# Investigación (Fase 0): Láser alimentado desde el power bank

**Funcionalidad**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md) | **Modifica**:
[002 research.md](../002-puntero-laser-estelar/research.md)

Las cotas actuales salen del `echo` de `src/puntero_laser_parametros.scad` con los valores por
defecto: `l_trasero` = 95 mm, `altura_eje` = 109,3 mm, `alto_brazo` = 126,3 mm, columna A de placas
de 79,4 mm, columna B de 114,4 mm y plataforma de 194,3 × 165,9 mm (máx. 196).

## R1. Cadena de alimentación del láser

**Decisión**: power bank 5 V → interruptor general → **relé (COM → NA)** → **regulador reductor
MP1584EN** ajustado a 3,7 V → 2 hilos de silicona 2 × 26 AWG → pila falsa (+) y tapa trasera (−).

**Motivos**:

- El relé en la línea de 5 V corta también el consumo en reposo del regulador (FR-001).
- El MP1584EN acepta 4,5–28 V de entrada y da hasta 3 A. A 5 V → 3,7 V trabaja con un ciclo de
  ≈ 74 %, lejos de su límite. Mide 22 × 17 × 4 mm y es el módulo ajustable más común en las tiendas
  locales.
- El contacto NA hace que el relé sin energía deje el láser apagado (FR-003).

**Alternativas descartadas**:

- **Mini-360**: más chico (17 × 11 mm), pero da 1,8 A y su preset es más delicado de ajustar. Sirve
  igual: el parámetro `regulador_*` lo admite.
- **LDO de 3,3 V (AMS1117)**: no se ajusta. A 3,3 V el láser verde puede quedar débil o no arrancar,
  y disipa 0,85 W.
- **5 V directos**: superan los 4,2 V de una 18650 cargada y pueden quemar el driver o el diodo.
- **Relé después del regulador**: deja el regulador siempre alimentado y no mejora nada.

## R2. Láser apagado con el ESP32 apagado (FR-003, FR-003a)

**Decisión**: se mantiene el GPIO23, activo en nivel alto, con el láser en el contacto NA. Se agrega
una **resistencia de 10 kΩ entre IN y GND** del módulo relé, soldada en sus pines o en el cable
Dupont.

| Estado del ESP32 | GPIO23 | Entrada IN | Relé | Láser |
|---|---|---|---|---|
| Sin energía (interruptor abierto) | — | — | Sin energía | Apagado |
| Arranque o reinicio | Alta impedancia | 0 V por la resistencia de 10 kΩ | Abierto | Apagado |
| Sin programa o sueño profundo | Alta impedancia | 0 V | Abierto | Apagado |
| Cable de control suelto | — | 0 V | Abierto | Apagado |
| Firmware ordena encender | 3,3 V | 3,3 V | Cerrado | Encendido |

- El GPIO23 no es pin de arranque (0, 2, 5, 12, 15) ni cambia de estado durante el arranque, así que
  no produce destellos.
- El ESP32, los drivers y el relé salen de la misma línea, así que no hay un estado con el relé
  alimentado y el ESP32 sin energía. Programar el ESP32 por USB con el interruptor abierto deja el
  relé sin energía.
- **Límite del hardware**: un ESP32 colgado con el GPIO23 en alto es indistinguible de una orden de
  encendido. Lo cubre el firmware con un *watchdog* y el apagado automático a los 30 s del contrato
  de la 002. Se agrega al [contrato de firmware](contracts/interfaz_firmware.md).

## R3. Contacto negativo: prisionero de punta cónica en la tapa

**Decisión**: el negativo vuelve por un **prisionero M3 × 10 de punta cónica (DIN 914)** que
atraviesa la pared de la tapa impresa y muerde la zona roscada del tubo. Por fuera lleva el
terminal de ojal del hilo negativo, apretado con una tuerca M3 que hace de contratuerca. El segundo
prisionero, igual y opuesto, solo fija la tapa.

**Motivos**:

- La punta cónica atraviesa un anodizado fino y da una presión de contacto alta y estable. Resuelve
  el caso límite del tubo anodizado sin depender del borde trasero.
- Los mismos 2 prisioneros fijan la tapa contra el empuje del resorte (FR-009). La pila falsa queda
  con un solo cable y un solo contacto.

**Alternativas descartadas**:

- **Arandela contra el borde trasero del tubo**: el resorte empuja la pila falsa hacia atrás y
  separa la arandela del borde; la presión de contacto depende de cuánto se empuje la tapa al
  ajustarla. Además falla si el borde está anodizado.
- **Reusar el resorte de la tapa original**: hay que desarmarla y el resorte queda contra plástico.
- **Hilo negativo pegado o soldado al tubo**: el aluminio no se suelda y el pegamento conductor se
  despega con la humedad.

## R4. Pila falsa

**Decisión**: cilindro impreso de Ø `diametro_hueco_bateria` − 2 × `holgura("suelto")`, impreso de
pie. El largo hace que, apoyada en la tapa, el contacto comprima el resorte del cabezal
`compresion_resorte` = 2 mm.

- **Contacto positivo**: tornillo M3 × 8 de cabeza alomada (ISO 7380) en el centro de la cara
  delantera, roscado en una tuerca M3 embutida por una ranura lateral. El terminal de ojal del hilo
  positivo queda apretado bajo la cabeza.
- **Cable**: el hilo baja por un agujero axial de Ø 2,4 mm descentrado 5 mm y sale por una ranura
  radial en la cara trasera. Al cerrar la tapa se gira la pila falsa hasta alinear esa ranura con la
  ventana de la tapa.
- **Polaridad**: la cabeza del tornillo va donde iba el **+** de la batería. La guía pide confirmar
  la orientación de la batería original y respetar los colores: rojo +, negro −.

**Alternativa descartada**: contacto de chapa doblada. Necesita herramienta y se deforma con el
resorte; el tornillo es una pieza de ferretería.

## R5. Tapa trasera impresa con lastre

**Decisión**: funda impresa **de pie, con la cara trasera sobre la cama**, en 3 tramos de atrás hacia
adelante:

1. **Piso trasero** cerrado de 1,6 mm.
2. **Alojamiento hexagonal del lastre**: `tuercas_lastre_tapa` × tuerca M10 (17 mm entre caras, 8 mm
   de alto, ≈ 11 g), a presión con `holgura("presion")` y una gota de cianoacrilato.
3. **Funda** de Ø `diametro_zona_tapa` + 2 × `holgura("deslizante")`, de `largo_zona_tapa` de largo,
   que calza sobre la zona roscada del tubo. El paso del hexágono a la funda forma el **escalón** donde
   apoya el borde del tubo, y la pila falsa apoya sobre la última tuerca.

La funda lleva:

- 2 resaltes con los prisioneros de R3 (M3 × 12: con 10 mm no alcanzaba para el ojal y la
  contratuerca), a `angulo_cable` + 45° = 195° (el negativo, fuera de la ventana) y a 15°, con chaflán
  de 45° por debajo.
- Una **ranura radial en el escalón** y una **ventana** a 150° para el hilo positivo, que pasa bajo
  el borde del tubo. Así el cable sale por el costado sin doblez por detrás (FR-009).
- **Sin brida**: el alivio de tensión lo da la grapa (R6), que aprieta los 2 hilos sobre el tubo, el
  mismo cuerpo rígido que la tapa. Una oreja con paso de brida no entraba en una funda de 12 mm.

**Por qué lleva lastre (decisión clave)**: sacar la batería corre el centro de masa hacia adelante.
Con las masas supuestas, momentos desde el extremo trasero:

| Caso | Masa | Distancia del extremo trasero al centro de masa | `altura_eje` | `alto_brazo` | Flexión lateral (caso R10 de la 002) |
|---|---|---|---|---|---|
| 002, con batería | 180 g | 95,0 mm | 109,3 mm | 126,3 mm | 0,089° |
| Sin lastre (tapa de 7,6 mm) | 141,2 g | 97,9 mm | 112,4 mm | 129,4 mm | ≈ 0,096° ✅ (justo) |
| **2 tuercas M10** (tapa de 17,75 mm) | 166,9 g | 92,7 mm | 109,3 mm | 126,3 mm | 0,089° ✅ |

> **Corrección de la implementación**: la primera estimación de este cuadro suponía una tapa de 20 mm
> también sin lastre y daba 142 mm de brazo (0,127°). Sin tuercas, la tapa mide solo 7,6 mm, así que
> la cola crece menos y el criterio se cumple igual, aunque sin margen. El lastre se mantiene por
> defecto porque deja la geometría **idéntica a la 002** (`altura_eje` cambia 0,003 mm): los brazos,
> la base y la polea ya impresos siguen sirviendo, y la flexión queda con margen.

La flexión escala con `alto_brazo`³. El criterio de 0,1° de la 002 se cumple hasta
`alto_brazo` ≈ 131 mm. Con 2 tuercas, el resto del aparato no cambia y la justificación sin FEM de la
002 sigue valiendo.

**Alternativas descartadas**:

- **Sin lastre**: es válido (`tuercas_lastre_tapa = 0`), pero alarga los brazos 3 mm, obliga a
  reimprimir la horquilla, la base y la polea, y deja la flexión al límite.
- **Lastre dentro de la pila falsa**: está a 52 mm del extremo y no a 8 mm. Haría falta el doble de
  masa (≈ 51 g) y no entra.
- **Tapa con rosca impresa**: la rosca del 303 es fina y metálica, y una rosca impresa a esa escala
  no ajusta de forma fiable.
- **Imprimir con la funda sobre la cama**: el piso quedaría como puente de 30 mm.

**Aviso nuevo**: si `alto_brazo` > 131 mm, el generador avisa con `echo("AVISO: …")` que hay que
repetir el cálculo R10. No es un `assert`, para no rechazar las variantes de la 002 con láseres
largos.

## R6. Recorrido del cable: canaleta a 150° en la cuna

**Decisión**: el cable sale de la tapa a 150° en el sistema de impresión de la cuna, es decir del lado
−X y 30° por debajo de la horizontal. Pasa por **1 grapa** sobre el láser y entra en una **canaleta
exterior de la cuna** en ese mismo ángulo, desde el borde trasero hasta 2 mm antes del muñón −X. De
ahí baja al agujero del brazo cable, 22 mm por debajo del eje, con el bucle de 40 mm de siempre.

**Motivos**:

- **Abajo (90°) no**: el anillo trasero de colimación tiene un prisionero justo a 90°. **Arriba
  (270°) no**: está la ventana del pulsador y el anillo delantero tiene un prisionero a 270°.
- **A 150°**: queda a 60° de los prisioneros a 90° y 210° del anillo trasero, y del lado del brazo
  cable, donde está el agujero.
- La canaleta es un resalte radial de `radio_exterior_cuna` a `radio_exterior_cuna` +
  `sobre_anillo_colim` = 23,5 mm, igual que los anillos, así que el barrido no cambia. Con 2,5 mm de
  ancho de ranura y paredes de 1,2 mm, queda a 4,8 mm del brazo (x = −20,4 frente a −25,2).
- Se imprime con la cuna de pie: es un nervio vertical. Lleva 3 puentes cerrados de 2,5 mm de luz
  por donde se enhebra el cable antes de conectarlo.
- Se elimina la `ranura_cable` actual (delante del muñón −X): con el cable por fuera ya no hace falta
  pasar del interior del tubo al exterior.

**Holgura del equilibrado**: entre el frente de la tapa y el borde trasero de la cuna quedan
`l_trasero` − `largo_tapa_fuera` − `largo_zona_tapa` − `largo_tubo_cuna`/2 ≈ 96,7 − 17,9 − 12 − 50 =
13,0 mm con los valores finales. Ahí van la grapa (5 mm) y un bucle chico que permite correr el
láser ±3,5 mm para equilibrarlo. Se valida con un assert (V-19): hueco ≥ ancho de la grapa + 2 × 3,5
mm.

**Alternativas descartadas**:

- **Por dentro de la cuna**: la holgura es de 2 mm y los prisioneros de colimación aplastarían el
  cable (lo dice la spec).
- **Canaleta tallada en la pared**: deja 1 mm de pared, menos que el mínimo de 1,2 mm.
- **Cable suelto desde la cola hasta el brazo**: la cola barre un radio de ≈ 97 mm y el cable se
  enreda.

## R7. Sección y largo del cable

**Decisión**: se mantiene el **cable de silicona de 2 × 26 AWG**, ahora de **60 cm**.

- Caída de tensión con 0,5 A, el peor caso de un 303 verde: 2 × 0,6 m × 0,134 Ω/m × 0,5 A =
  **0,08 V** < 0,1 V (FR-005).
- Con 24 AWG daría 0,05 V, pero el cable es más grueso (Ø ≈ 1,7 mm) para el canal del brazo (3 mm) y
  la canaleta. El generador calcula la caída como derivado y la comprueba con un assert.

## R8. Regulador en la plataforma

**Decisión**: el regulador va en un **tercer soporte de la columna A**, después de los 2 ULN2003,
con la misma forma de soporte con labio que las demás placas. La columna A pasa de 79,4 a
2 × 38,7 + 25,7 + 2 × 2 = 107,1 mm, menos que los 114,4 mm de la columna B. Por eso **la plataforma y
la tapa de la electrónica no cambian de tamaño**: la columna A se centra en el mismo rango que la B.

**Alternativa descartada**: ponerlo en el hueco del cable sobrante. Mezcla un módulo con un preset
ajustable con cables sueltos, y ese hueco es justo de 40 × 25 mm.

## R9. Consumo y power bank

Desde los 5 V: motores, ESP32 y relé ≈ 0,75 A (002), más el regulador ≈ 3,7 V × 0,5 A / (0,9 ×
5 V) ≈ 0,41 A, en total **≈ 1,16 A**, por debajo de los 2 A del power bank. Con el láser apagado, el
consumo vuelve al de la 002 y se mantiene la advertencia sobre power banks que se apagan con poco
consumo.

## R10. Simulación: no aplica

| Pieza | Carga | Cálculo | Resultado |
|---|---|---|---|
| Tapa: 2 prisioneros M3 en plástico | Resorte ≤ 10 N | Corte de la rosca en PETG: 2 × π × 2,6 × 4 mm × 0,5 × 20 MPa ≈ 650 N | Factor > 60 ✅ |
| Tapa: escalón de apoyo del borde | 10 N sobre un anillo de ≈ 80 mm² | σ ≈ 0,13 MPa | Despreciable ✅ |
| Pila falsa a compresión | 10 N sobre Ø 17,7 mm | σ ≈ 0,04 MPa | Despreciable ✅ |
| Brazos con el láser nuevo | Masa ≈ 161 g < 180 g; `alto_brazo` ≈ 128 mm | Escalado del caso lateral R10 de la 002 | 0,093° < 0,1° ✅ |

## R11. Medidas supuestas y cómo medirlas

| Parámetro | Supuesto | Cómo se mide |
|---|---|---|
| `diametro_hueco_bateria` | 18,5 mm | Diámetro interior del tubo, sin la batería |
| `profundidad_hueco_bateria` | 65 mm | Varilla del calibre desde el borde trasero hasta el contacto del cabezal, sin comprimir el resorte |
| `diametro_zona_tapa` | 30 mm | Diámetro exterior de la rosca donde enroscaba la tapa |
| `largo_zona_tapa` | 12 mm | Largo de esa rosca |
| `largo_tapa_original` | 20 mm | Cuánto sobresale la tapa original del borde del tubo |
| `masa_bateria_g` / `masa_tapa_original_g` | 45 g / 20 g | Balanza de cocina |
| `distancia_trasera_centro_masa_nueva` | 0 (se calcula) | Con la pila falsa y la tapa puestas: punto de equilibrio sobre un borde, desde el extremo trasero de la tapa |
