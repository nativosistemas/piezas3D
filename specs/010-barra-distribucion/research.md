# Investigación: Barra de distribución de alimentación

Medidas tomadas de `src/puntero_laser_parametros.scad` con los valores por defecto (eco de un archivo
de prueba que incluye los parámetros). Coordenadas en mm, con el origen en el eje de azimut y Z
medido desde la cara superior de la plataforma.

| Zona | X | Y |
|---|---|---|
| Columna A: ULN2003 de altura, ULN2003 de azimut y regulador | 44,7 … 80,4 (35,7 de ancho) | −53,55 … 53,55 |
| Soporte del regulador (17 mm + 2 × 1,85 de pared y holgura) | 44,7 … 65,4 | 27,85 … 53,55 |
| Columna B: ESP32 y relé | 82,4 … 114,1 | −57,2 … 57,2 |
| Hueco del cable sobrante, con el interruptor en su borde +X | 44,7 … 114,1 | 59,2 … 84,2 |
| Tapa (interior de 31,5 mm; 33,5 mm de alto en total) | 42,45 … 116,35 | −59,45 … 86,45 |

## R1. Dónde va la barra

**Decisión**: en la franja libre de la columna A, al lado (+X) del regulador: de X = 67,4 a 80,4
(13,0 mm) y de Y = 27,85 a 57,2 (29,35 mm). Esa franja va desde el comienzo del regulador hasta el
final de la columna B, que es más larga.

**Motivo**: el regulador mide 17 mm de ancho y la columna, 35,7 mm, porque es la de los ULN2003. A su
lado quedan 13 mm sin usar que la tapa ya cubre. Si la barra va ahí, la tapa, el hueco del sobrante y
el tamaño de la plataforma quedan iguales: cambia solo la plataforma, porque se agrega un soporte. La
barra queda además entre las placas que alimenta: tiene a los dos ULN2003 por −Y, al relé y al ESP32
por +X y al regulador por −X.

**Alternativas descartadas**:
- *Hueco del cable sobrante*: con una barra de ≈ 30 × 20 mm, el hueco queda en menos de los
  40 × 25 mm que exige la comprobación existente. Para que siga cumpliendo habría que alargar la tapa
  y la plataforma en Y, lo que cambia la masa, el centro de masa y 2 STL.
- *Columna B, después del relé*: le quedan 0 mm (es la columna que fija el largo).
- *Montaje vertical en la pared de la tapa*: la barra quedaría colgada de la tapa, y al sacar la tapa
  se tirarían los Dupont.

## R2. Tamaño de la placa y disposición de los pines

**Decisión**: un trozo de placa perforada de paso 2,54 mm de **3 × 10 agujeros (7,6 × 25,4 mm)**, con
una tira de pines macho en cada columna de los costados y la columna del medio vacía:

```text
agujero:   1    2    3    4    5    6    7    8    9   10
+5 V   :  [ ]  P1   P2   P3   P4   P5   P6   E+   ·   [ ]      P = pin macho, E = entrada soldada
medio  :   ·    ·    ·    ·    ·    ·    ·    ·    ·    ·      [ ] = esquina sobre el apoyo del soporte
GND    :  [ ]  P1   P2   P3   P4   P5   P6   E−   ·   [ ]
```

- **6 pines por tira**: 5 destinos más 1 de reserva (FR-001).
- **Agujeros 1 y 10 libres**: quedan sobre los apoyos de las esquinas del soporte (2 × 2 mm; con
  los 3 × 3 mm de las otras placas, la soldadura del agujero 2 quedaba pegada al apoyo). Una
  soldadura ahí no deja apoyar la placa.
- **Agujero 8, entrada**: ahí se sueldan el hilo que viene del interruptor y la masa del power bank.
  El agujero 9 separa esa soldadura del apoyo.
- **Columna del medio vacía**: deja 5,08 mm entre las dos tiras. Así un puente de estaño no las une,
  y entran dos filas de Dupont de 2,54 mm.
- Huella con el soporte: 7,6 + 2 × 1,85 = 11,3 mm (en una franja de 13,0) por 25,4 + 3,7 = 29,1 mm
  (en una de 29,35). Queda 1,7 mm de margen en X y 0,25 mm en Y. Hacia +Y la barra no llega a otra
  placa sino al hueco del sobrante, que la validación aleja con `holgura_zonas`.
- El largo y el ancho de la placa son parámetros (`barra_largo`, `barra_ancho`). Por defecto valen
  `(pines_barra + 4) × paso_pines` y `3 × paso_pines`. La validación exige que la placa sea al menos
  así de grande para los pines que tiene.

**Motivo**: los ≈ 30 × 20 mm de la descripción eran una estimación. La franja libre mide 13 mm, así
que la placa tiene que ser angosta. Con 3 agujeros de ancho, igual entran las dos tiras con su
separación.

**Alternativas descartadas**:
- *Placa de tiras (veroboard)*: trae las pistas ya unidas, pero cuesta más conseguirla. Además hay
  que cortar pistas y no cambia el espacio ocupado.
- *2 agujeros de ancho*: las dos tiras quedarían a 2,54 mm y un puente de estaño las uniría
  fácilmente.

## R3. Cómo se unen los pines de cada tira

**Decisión**: en la cara de abajo, un hilo de cobre desnudo y estañado a lo largo de cada tira,
soldado a cada pin y a la entrada. Sale de pelar un cable Dupont que sobra (el paquete trae 40 y se
usan 19). Al final se prueba con el multímetro (FR-007).

**Motivo**: por la barra pasa toda la corriente del aparato, ≈ 1,16 A según la guía (sección 5.4).
Un hilo continuo la aguanta con margen. Los puentes de estaño entre islas sueltas se quiebran o
quedan con soldadura fría. Como el hilo sale de un Dupont que sobra, no hay que comprar nada.

## R4. Entrada de la alimentación

**Decisión**:
- **+5 V**: el hilo rojo del cable USB va a una pata del interruptor. Un trozo de **10 cm de cable de
  silicona rojo de 26 AWG** va de la otra pata a la entrada E+ de la barra.
- **GND**: el hilo negro del cable USB va directo a la entrada E−.
- El cable de silicona de la lista de materiales pasa de 60 a **70 cm**. Se vende por metro, así que
  el paquete que se compra es el mismo.
- Cada soldadura del interruptor y de los hilos del cable USB se aísla con **termocontraíble**.

**Motivo**: un hilo Dupont, de 28 AWG, queda justo para 1,16 A. El de 26 AWG aguanta ≈ 2,2 A en un
equipo cerrado. Ese tramo mide 10 cm y hace caer ≈ 0,02 V, que no importa.

## R5. Destinos sin pines macho

**Decisión**:

| Tira | Pin | Destino | Conexión |
|---|---|---|---|
| +5 V | 1 | ESP32 VIN | Dupont hembra-hembra |
| +5 V | 2 | ULN2003 azimut + | Dupont hembra-hembra |
| +5 V | 3 | ULN2003 altura + | Dupont hembra-hembra |
| +5 V | 4 | Relé VCC | Dupont hembra-hembra |
| +5 V | 5 | Relé COM (bornera) | Dupont con un extremo cortado y pelado, apretado en la bornera |
| +5 V | 6 | Reserva (p. ej., la resistencia de carga de 100 Ω de la sección 5.4) | — |
| GND | 1 | ESP32 GND | Dupont hembra-hembra |
| GND | 2 | ULN2003 azimut − | Dupont hembra-hembra |
| GND | 3 | ULN2003 altura − | Dupont hembra-hembra |
| GND | 4 | Relé GND | Dupont hembra-hembra |
| GND | 5 | Regulador IN− (pad) | Dupont con un extremo cortado, soldado al pad y aislado con termocontraíble |
| GND | 6 | Reserva | — |

La resistencia de 10 kΩ queda soldada entre IN y GND del relé, como ahora. Se usan 10 Dupont para la
alimentación y 9 para las señales: 19 de los 40 del paquete.

**Motivo**: todos los destinos se conectan igual (un Dupont por pin), así que se pueden desconectar
desde la barra. Solo se suelda el pad del regulador, que ya se soldaba por IN+ y OUT±.

## R6. Lista de materiales y precios

**Decisión**:
- **Componentes nuevos**:
  - Placa perforada (placa experimental) de paso 2,54 mm: se corta un trozo de 3 × 10 agujeros.
  - Tira de pines macho 1 × 40 de paso 2,54 mm: se cortan 2 tiras de 6.
  - Tubo termocontraíble de 2 a 3 mm de diámetro, de unos 20 cm.
- **Cambio**: el cable de silicona pasa de 60 a 70 cm.
- **Herramientas** (van en la guía y no en la lista de materiales, porque no se gastan): soldador de
  30 a 40 W, estaño de 0,8 mm con resina y el multímetro que ya pide la guía.
- **Precios**: se buscan y se verifican en la página de la tienda en la fase 5 (`web-armado`), con
  tienda, enlace y fecha. Si no se pueden verificar, quedan vacíos y la web indica que el total es
  parcial (constitución, principio V).

## R7. Simulación FEM

**Decisión**: **no aplica**. El soporte de la barra es igual al de las otras placas (postes en L con
labio) y solo recibe la fuerza de enchufar un Dupont: unos 5 N, hacia abajo, sobre los apoyos. No
cambia nada del camino de carga: ni la placa nervada, ni los brazos, ni los pernos.

## R8. Guía, pasos de armado, vistas y visor

**Decisión**:
- **Se mantienen los 19 pasos de armado**. La barra entra así:
  - **Paso 16 (Electrónica)**: armar la barra en el banco, probarla con el multímetro y encajarla en
    su soporte junto con las demás placas. Su vista explotada la muestra bajando.
  - **Paso 17 (Cableado)**: los Dupont de la barra se suman al volumen transparente "conectores".
  - **Sección 5.4**: la tabla de pines de R5, el esquema con la barra y el procedimiento de armado y
    prueba.
- **Primeros pasos**: se agregan las herramientas de soldadura.
- **Ensamblaje**: un elemento nuevo, `barra`, que figura como pieza comprada en la tabla de
  identificación del visor (008).

**Motivo**: agregar un paso renumeraría las referencias de la guía, de la tabla `pasos` (que exige
19) y de la web. La barra es una placa más del paso 16.

## R9. Qué archivos cambian

- **Cambia**: `puntero_laser_plataforma_azimut.stl`, por el soporte nuevo.
- **No cambian**: las otras 12 STL. La tapa queda igual porque Y del sobrante sale de
  `max(fin del regulador, fin del relé, fin de la barra)`, y con los valores por defecto manda el
  relé.
- **Zona del regulador**: hoy ocupa el ancho de toda la columna. Se achica a su soporte real para que
  la comprobación de zonas (V-08) no la vea solapada con la barra. Eso no cambia la geometría.
- **Masa**: se suman ≈ 3 g por la barra con sus pines y la soldadura, en su posición; el centro de
  masa casi no se mueve.
