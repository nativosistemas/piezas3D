# Modelo de datos: Vista de cableado (011)

Las decisiones están en [research.md](research.md). Este documento fija los campos.

## 1. En el ensamblaje (OpenSCAD)

### 1.1 `cables`: un cable por renglón de la Tabla de cables de la guía

```text
[id, desde, hasta, función, grupo, hilos, diámetro, recorrido, extremos, largo_comprado, elemento]
```

| Campo | Tipo | Regla |
|---|---|---|
| `id` | texto | Único, `snake_case` (p. ej. `"sen_az_in1"`). No puede coincidir con un elemento |
| `desde` | texto | Componente y pin de origen, **igual** a la columna Desde de la guía (p. ej. `"ESP32 GPIO 16"`) |
| `hasta` | texto | Componente y pin de destino, igual a la columna Hasta (p. ej. `"ULN2003 azimut IN1"`) |
| `función` | `"+5V"`, `"GND"` o `"señal"` | Define el color si `hilos` no lo fija |
| `grupo` | texto | Uno de `grupos_cableado` (§1.3) |
| `hilos` | lista de colores | 1 o más nombres de color de OpenSCAD. +5 V = `["Red"]`, GND = `["Black"]`; motor: 5 colores; vacía si `elemento` |
| `diámetro` | mm > 0 | De cada hilo (`diametro_cable_dupont`, `d_hilo`, …) |
| `recorrido` | lista de `[x, y, z]` o `undef` | ≥ 2 puntos, en el conjunto en reposo; primer punto en el pin de `desde`. Si hay `elemento`, es el tramo fijo y termina donde empieza el elemento |
| `extremos` | `[tipo_desde, tipo_hasta]` | Cada uno, un tipo de `conectores_cableado` (§1.4) |
| `largo_comprado` | mm o `undef` | Largo del cable que se compra (200 Dupont, `largo_cable_motor`). `undef`: se corta de un rollo y no se limita |
| `elemento` | texto o `undef` | Elemento del catálogo que dibuja el tramo del cable que se mueve (`"cable_laser"`). Un cable tiene recorrido, elemento o los dos |

Derivados (no se declaran, los calcula la biblioteca): `largo = largo_polilinea(recorrido)` más el largo
que `largo_elementos_cableado` declara para su elemento, y
`nombre = str(tipo legible del cable, ": ", desde, " → ", hasta)`. El tipo legible es «Dupont» si los
dos extremos son Dupont, «Cable del motor» si son JST, «Cable USB» si uno es USB, y «Cable» en otro
caso.

### 1.2 `obstaculos_cableado`: cajas que ningún cable puede atravesar

```text
[nombre, mín [x, y, z], máx [x, y, z], componente]
```

`componente` es el texto con el que empiezan `desde` y `hasta` de los cables que nacen en él (p. ej.
`"ULN2003 azimut"`). Esos cables pueden tocarlo en su primer o su último tramo. `""` si no es un
componente con pines (plataforma, soportes, motores, power bank).

Las paredes y el techo de la tapa son obstáculos (componente `""`). Sus aberturas se declaran en
`pasos_tapa_cableado = [[nombre, mín, máx]]` (el conducto y las entradas de los motores): una muestra
dentro de un paso no choca con nada. Los motores no son obstáculos: sus cables nacen en ellos y el
tramo de afuera es el de la 009.

### 1.3 `grupos_cableado`: orden de la lista del visor

```text
[[grupo, título]]
```

Ejemplo: `["barra_5v", "Barra de distribución: +5 V"]`. El orden es el de la Tabla de cables de la
guía.

### 1.4 `conectores_cableado`: forma de cada tipo de extremo

```text
[tipo, [ancho, alto, largo], color]
```

| Tipo | Medidas por defecto | Color | Sale de |
|---|---|---|---|
| `dupont` | `paso_pines` × `paso_pines` × `largo_dupont` | Black | 009 |
| `jst` | 12,5 × 6 × `alto_enchufe_motor` | White | 009 |
| `usb` | 0 × 0 × 0 (no se dibuja) | — | el enchufe es el elemento `enchufe_usb` |
| `bornera` | 3 × 3 × 3 | RoyalBlue | constante con nombre |
| `soldadura` | 2 × 2 × 2 | Silver | constante con nombre |
| `pila_falsa` | 0 × 0 × 0 (no se dibuja) | — | la pila falsa ya es un elemento |

El conector se orienta según la dirección del primer (o último) tramo y se apoya en el pin.

### 1.5 Opcionales del modo

| Lista | Por defecto | Puntero láser |
|---|---|---|
| `transparentes_cableado` | `[]` | `["tapa"]` |
| `ocultos_cableado` | `[]` | `["conectores"]` |
| `reserva_cable` | `0` | `10` (mm sin tensar en cada cable comprado) |
| `radio_curva_cableado` | `0` | `radio_curva_cable` |
| `largo_elementos_cableado` | `[]` | `[["cable_laser", ≈ 104]]` |

### 1.6 Elementos nuevos del catálogo

| Elemento | Nombre (008) | Tipo | Paso | Geometría |
|---|---|---|---|---|
| `interruptor` | `Interruptor de palanca miniatura con rosca M6 (tipo MTS-102)` | comprada | 16 | Cuerpo de `alto_interruptor`, buje de `d_interruptor` y palanca, en `x_interruptor`, `y_interruptor` |
| `resistencia_rele` | `Resistencia de 10 kΩ 1/4 W, entre IN y GND del relé` | comprada | 16 | Cuerpo cilíndrico y dos patas a los pines IN y GND del relé |
| `enchufe_usb` | `Cable USB-A con salida a bornes (o cable USB cortado): enchufe en el power bank` | comprada | 17 | Funda de `ancho_enchufe_usb` × `alto_enchufe_usb` × `largo_funda_usb` en el puerto del power bank, con su alivio de tracción; de ahí nacen los hilos rojo (+5 V) y negro (GND) |

### 1.7 Pines

Constantes con nombre en la sección de parámetros del ensamblaje: `pines_esp32`, `pines_uln2003`,
`pines_rele`, `pines_regulador` y `pines_barra_cableado`. Cada una es una lista
`[nombre_del_pin, [x, y] local, sentido]`, donde `sentido` es +1 si el conector sale hacia arriba y −1
si sale hacia abajo. Hay una función `pin(componente, nombre)` que devuelve `[x, y, z]` en el conjunto.
Valores y orientación: [research.md](research.md#r4-dónde-está-cada-pin).

## 2. En la guía (`docs/puntero_laser_guia.md`, sección 5.4)

**Tabla de cables**, después de la tabla de pines de la barra. Formato:
[contracts/guia.md](contracts/guia.md).

| Columna | Contenido |
|---|---|
| N.º | 1, 2, 3… en el orden de los grupos |
| Desde | Igual al campo `desde` |
| Hasta | Igual al campo `hasta` |
| Conectores | Texto libre (p. ej. «Dupont hembra / Dupont hembra») |
| Largo | El que informa el ensamblaje, redondeado a 5 mm (p. ej. «≈ 75 mm») |

## 3. En el visor (`datos.cableado`, versión 4)

```json
{
  "grupos": [{"id": "barra_5v", "titulo": "Barra de distribución: +5 V"}],
  "cables": [{
    "id": "sen_az_in1", "nombre": "Dupont: ESP32 GPIO 16 → ULN2003 azimut IN1",
    "grupo": "esp32_az", "hilos": ["DodgerBlue"], "diametro": 1.4,
    "recorrido": [[x, y, z]], "extremos": ["dupont", "dupont"], "largo": 74.2
  }, {
    "id": "hilos_laser", "nombre": "Cable: Regulador OUT± → Láser (pila falsa y tapa trasera)",
    "grupo": "motores_laser", "hilos": ["Red", "Black"], "recorrido": [[x, y, z]],
    "elemento": "cable_laser", "largo": 412.1
  }],
  "conectores": {"dupont": {"medidas": [2.54, 2.54, 14], "color": "Black"}},
  "radio_curva": 5,
  "transparentes": ["tapa"],
  "ocultos": ["conectores"]
}
```

- Puntos redondeados a 0,1 mm.
- `largo`: el derivado de §1.1. Cada cable lleva además `desde`, `hasta` y `funcion`.
- Si el ensamblaje no declara `cables`, no hay clave `cableado` (el visor y la web quedan como antes).

## 4. Validaciones

| Código | Dónde | Regla | Mensaje |
|---|---|---|---|
| C-01 | `armado_comun.scad` | Forma de cada cable (11 campos, tipos de §1.1), `id` único y distinto de los elementos (por eso los cables de los motores son `cable_motor_az` y `cable_motor_alt`, y el del láser `hilos_laser`) | `cables: '<id>' <qué campo> …` |
| C-02 | `armado_comun.scad` | `grupo` en `grupos_cableado`; cada tipo de `extremos` en `conectores_cableado`; `elemento` en `elementos` | `cables: '<id>' usa el grupo / conector / elemento desconocido '<x>'` |
| C-03 | `armado_comun.scad` | Ningún tramo atraviesa un obstáculo (las paredes de la tapa incluidas) fuera de un paso (§1.2) | `cables: '<id>' atraviesa <obstáculo> cerca de [x, y, z]` |
| C-04 | `armado_comun.scad` | `largo + reserva ≤ largo_comprado` (reemplaza a la V-26) | `cables: '<id>' mide <L> mm y el cable comprado <C> mm (faltan <F> mm)` |
| C-05 | `generar_visor.py` | Mismos pares (desde, hasta) en la guía y en el ensamblaje | `La Tabla de cables de la guía tiene «<desde> → <hasta>» y el ensamblaje no` (y al revés) |
| C-06 | `generar_visor.py` | Cada cable con recorrido tiene ≥ 2 puntos, y cada referencia a un elemento existe en el visor | `El cable '<id>' no tiene recorrido` / `… referencia el elemento '<e>', que no está en el visor` |
