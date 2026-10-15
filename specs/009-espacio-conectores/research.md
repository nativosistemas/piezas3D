# Investigación: Espacio para conectores y cableado del puntero láser

Medidas del diseño actual (echo de `src/puntero_laser_parametros.scad`, valores por defecto):
`alto_tapa = 27,6` mm (interior 25,6), `elevacion_esp32 = 15`, `altura_placas = 18`, apoyo de las
placas bajas a 3 mm, PCB de 1,6 mm. Límite de la tapa por el carro y el motor de altura (assert del
ensamblaje): `alto_tapa + 2 ≤ 36,34` → `alto_tapa ≤ 34,34` mm.

## R1. Medidas de los conectores (valores por defecto)

| Conector | Medida | Valor | Fuente |
|---|---|---|---|
| Tira de pines 2,54 mm | alto del plástico | 2,5 mm | estándar de las tiras macho |
| Pin macho | largo fuera del plástico | 6 mm | idem |
| Dupont hembra recto | largo del cuerpo | 14 mm | carcasa estándar de 2,54 mm (13,5–14,5) |
| Cable Dupont (26 AWG) | diámetro | 1,4 mm | |
| Curva del cable | radio mínimo (al eje) | 5 mm | ≈ 3,5 × diámetro; no fuerza el engarce |
| Enchufe JST-XH 5 pines del 28BYJ-48, conectado | alto sobre la PCB | 13 mm | base de 7 mm más el enchufe |
| Cable del 28BYJ-48 | largo de fábrica | 230 mm | valor conservador (se venden de 230 a 250 mm) |
| Enchufe micro-USB con funda | ancho × alto | 11 × 7,5 mm | fundas típicas de los cables de datos |

- **Decisión**: parámetros en la sección `/* [Conectores y cables] */` con el aviso de medirlos.
- **Motivo**: son los valores comunes; los que más pesan (cuerpo del Dupont, curva) se toman del
  lado conservador.
- **Alternativas**: un enchufe USB-C (≈ 12,5 × 6,5): queda cubierto si la persona cambia el parámetro;
  la abertura de la tapa sale del enchufe (R5), así que crece sola.

## R2. Espacio sobre una placa con Dupont hacia arriba

Altura del volumen sobre la plataforma = apoyo + PCB + tira + cuerpo del Dupont + curva
(`radio_curva + diametro_cable`) = 3 + 1,6 + 2,5 + 14 + 6,4 = **27,5 mm**.

- La curva se cuenta entera arriba del conector: el cable sale vertical y tiene que doblar para ir de
  costado. La holgura con el techo de la tapa es aparte (R4).
- Se aplica a los ULN2003 (entradas IN1–IN4 y alimentación) y al relé (VCC, GND, IN). El enchufe del
  motor (JST, 13 + 6,4 sobre la PCB → 24 mm) y las borneras del relé (cables de costado) quedan por
  debajo: no definen la altura, pero se modelan para las comprobaciones.
- **Simplificación**: el volumen ocupa toda la planta de la placa. No hace falta la posición exacta de
  cada tira (cambia según el fabricante) y del lado conservador no cambia la altura.

## R3. Espacio bajo el ESP32 (pines hacia abajo)

El Dupont entra desde abajo hasta tocar el plástico de la tira. Debajo de la PCB hacen falta
tira + cuerpo + curva + holgura = 2,5 + 14 + 6,4 + 1 = **23,9 mm** → `elevacion_esp32 = 23,9`
(hoy es 15: el conector tocaría la plataforma 9 mm antes).

- **Hacia dónde dobla el cable**: hacia el centro de la placa, por debajo de ella. Hacia afuera
  chocaría con la columna de los ULN2003 (a 2 mm) o con la pared de la tapa. Las dos filas de pines
  están a 25,4 mm; cada curva ocupa 6,4 mm hacia adentro, así que entran las dos.
- **Volumen**: dos franjas a lo largo de las filas (ancho de un Dupont más la curva hacia adentro) y,
  a lo largo, el largo de la fila: 19 pines (ESP32 de 38 pines, el caso más largo) → 48,3 mm de
  55 mm. Se comprueba contra los apoyos de las esquinas del soporte (2,5 mm): sobran ≈ 0,9 mm por
  lado.
- **Armado**: con 24 mm de alto y postes en las esquinas, conectar desde abajo con la placa ya puesta
  es incómodo. La guía indica conectar los Dupont al ESP32 **antes** de encajarlo, con los cables
  doblados hacia el centro.
- **Postes del soporte**: pasan de ≈ 18 a ≈ 27 mm de alto (perfil en L de 1,6 × 5 mm). Al enchufar, la
  fuerza va hacia arriba y la toma el labio superior del soporte; la carga es de unos pocos newtons y
  el pandeo de un poste de PETG de ese largo no es un riesgo. **No hace falta FEM** (Principio III).

## R4. Altura de la tapa

`alto_interior_tapa = max(altura_placas, conectores arriba (27,5), tope del ESP32 (23,9 + 1,6 + 4 =
29,5)) + holgura_techo`.

- **Decisión**: `holgura_techo = 2` mm, en lugar del `+ 5` fijo de hoy, que no tenía justificación y
  ahora no entra. Interior = 31,5 → `alto_tapa = 33,5` mm (≤ 34,34: margen de 0,84 mm con el carro
  de altura).
- **Motivo**: con `+ 5` la tapa mediría 36,5 y chocaría con el carro (lo detecta el assert existente).
  Los 2 mm cubren la tolerancia del PCB y del módulo.
- **Si no entrara** (conectores más largos que los de por defecto): falla el assert de la tapa contra
  el carro con su mensaje; se reporta el conector que manda (R6).
- **Alternativa descartada**: subir el eje de altura o el carro (cambia la horquilla, las correas y la
  FEM implícita del brazo: mucho más alcance que esta corrección).

## R5. Acceso USB

- **Decisión**: la abertura de la tapa (hoy de 12 × 9 mm fijos, desde `elevacion_esp32 − 2`) se
  calcula desde el enchufe: ancho = enchufe + 2 × 0,75; alto = enchufe + 2 × 0,75; centrada en el
  conector del ESP32 (sobre la PCB, a 1,3 mm de su cara), con la punta de gota de abajo para imprimir
  sin soporte.
- **Comprobación**: la abertura queda bajo el techo (`z_sup_abertura ≤ alto_interior_tapa`) y el
  enchufe no toca sus bordes.

## R6. Largo de los cables de los motores

Recorridos por la guía (sección 3, tabla de recorridos), como polilíneas de puntos del diseño:

- **Motor de altura**: va en el brazo (gira en azimut con las placas, no en altura), así que el largo
  no depende del ángulo de altura. Salida del cable en el motor → canal de la cara exterior del brazo
  motor hasta la plataforma → entra a la tapa → enchufe del ULN2003 de altura.
- **Motor de azimut**: motor → puente de la brida → entrada de la pared −X de la tapa → enchufe del
  ULN2003 de azimut.
- Estimación a mano: ≈ 145 y ≈ 165 mm frente a 230 mm. Con una **reserva de 20 mm** (enchufe y curva
  dentro de la tapa), sobran > 40 mm.
- **Decisión**: función `largo_polilinea()` y `assert` por motor; el echo del diseño informa los dos
  largos y la reserva (para la guía).

## R7. Volúmenes en el ensamblaje y en el visor

- **Decisión**: un elemento `conectores` del ensamblaje (tipo `"comprada"`, nombre "Cables Dupont y
  enchufes (espacio reservado)"), dibujado como cajas: arriba de los ULN2003 y el relé, las franjas
  bajo el ESP32, los enchufes de los motores y el USB. Aparece en el paso 17 (cableado) del visor, en
  transparente, y entra en las comprobaciones de choque del ensamblaje.
- **Comprobaciones**: contra la tapa (interior), la plataforma (z ≥ cara superior + holgura), los
  apoyos del soporte del ESP32 y la placa vecina, con zonas en planta como las de
  `zonas_componentes` (mismo estilo de `solapan`).
- **No se exporta** como pieza (FR-011): no tiene archivo de pieza; el visor lo trae del catálogo.

## R8. Qué cambia en las piezas

| Pieza | Cambio | STL |
|---|---|---|
| Plataforma de azimut | Postes del soporte del ESP32 más altos | Cambia |
| Tapa de la electrónica | Más alta (27,6 → 33,5 mm) y abertura USB más alta | Cambia |
| Resto | Nada (`alto_tapa` solo lo usan la tapa y los asserts) | Igual |

Masa: la tapa suma ≈ 6 mm de pared; el echo del diseño recalcula la masa y el centro de masa.
