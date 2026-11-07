# Modelo de datos: Circuito del láser en el visor 3D

**Funcionalidad**: [spec.md](spec.md) | **Investigación**: [research.md](research.md)

## 1. Constantes nuevas (`src/puntero_laser_parametros.scad`, junto a `espesor_ojal`)

| Nombre | Valor | Qué es |
|---|---|---|
| `d_ext_ojal` | 6 | Diámetro exterior del aro del terminal de ojal M3 |
| `d_int_ojal` | 3.2 | Agujero del aro |
| `ancho_lengueta_ojal` | 3 | Ancho de la lengüeta (el caño se corta y el hilo se suelda en ella; research R3) |

Comprobación nueva (V-30), en el mismo archivo:

| Id | Condición | Mensaje |
|---|---|---|
| V-30 | `descentrado_hilo_pila + ancho_lengueta_ojal/2 ≤ d_pila_falsa/2 − 0.5` y `d_ext_ojal/2 ≤ d_pila_falsa/2 − 0.5` | `"diametro_hueco_bateria=…: el ojal del contacto positivo no entra en la cara de la pila falsa"` |

## 2. Elementos nuevos del ensamblaje (`src/puntero_laser_ensamblaje.scad`)

Todos de tipo `comprada` y en `elementos_altura` (giran con el láser).

| Elemento | Color | Nombre en el visor | Paso 14: desplazamiento |
|---|---|---|---|
| `tornillo_contacto` | Silver | Tornillo M3 × 8 mm cabeza alomada (ISO 7380): contacto positivo de la pila falsa | `120*v_laser` (con la pila) |
| `tuerca_contacto` | DarkGray | Tuerca M3 del contacto positivo (embutida en la pila falsa) | `120*v_laser` |
| `ojal_positivo` | Goldenrod | Terminal de ojal M3 del hilo rojo, bajo la cabeza del tornillo | `120*v_laser` |
| `hilo_rojo_pila` | Red | Hilo rojo (+): de la ventana de la tapa al ojal, por dentro de la pila falsa | `120*v_laser` |
| `prisionero_negativo` | Silver | Prisionero M3 × 12 mm punta cónica (DIN 914): contacto negativo, muerde la rosca del tubo | `60*v_laser + 20*radial(neg)` |
| `tuerca_negativo` | DarkGray | Tuerca M3 que aprieta el ojal del hilo negro | `60*v_laser + 30*radial(neg)` |
| `ojal_negativo` | Goldenrod | Terminal de ojal M3 del hilo negro, en el prisionero del negativo | `60*v_laser + 30*radial(neg)` |
| `hilo_negro_tapa` | Black | Hilo negro (−): de la salida del cable al ojal del prisionero | `60*v_laser + 30*radial(neg)` |
| `prisionero_fijacion` | Silver | Prisionero M3 × 12 mm punta cónica + contratuerca M3: fijación de la tapa trasera | `60*v_laser + 20*radial(fij)` |

`radial(a)` es el vector unitario, en el conjunto, que sale del eje del láser hacia el ángulo `a` del
sistema de la tapa (`neg = angulo_cable + desfase_prisionero_tapa`, `fij = neg + 180`).

En el **paso 15** los 9 entran con `150*v_laser`, sin resaltar, como la pila y la tapa.

## 3. Lista `circuitos` (contrato: [contracts/ensamblaje.md](contracts/ensamblaje.md))

```text
[id, nombre, descripción, grupos, translúcidos, encuadre]
grupos = [[título, [miembro, …]], …]     miembro = elemento del catálogo o id de un cable
```

Circuito del puntero láser:

| Campo | Valor |
|---|---|
| id | `laser` |
| nombre | Circuito del láser |
| descripción | Todo el camino de la energía: del power bank pasa por el interruptor, la barra y el relé (que maneja el ESP32) al regulador, y de ahí al láser: el positivo entra por el tornillo de la pila falsa y el negativo vuelve por el tubo. |
| grupos | «Power bank e interruptor»: `powerbank`, `enchufe_usb`, `usb_5v`, `interruptor`, `interruptor_barra`, `usb_gnd` · «Barra de distribución»: `barra`, `v5_rele_com`, `gnd_regulador` · «Relé: la llave del láser (COM → NA)»: `placa_rele`, `rele_regulador` · «Control del relé»: `placa_esp32`, `sen_rele`, `resistencia_rele`, `v5_rele_vcc`, `gnd_rele` · «Regulador a 3,7 V y cable del láser»: `regulador`, `hilos_laser` · «Positivo (+) en el láser»: `hilo_rojo_pila`, `ojal_positivo`, `tornillo_contacto`, `tuerca_contacto`, `pila_falsa` · «Negativo (−) en el láser»: `laser`, `prisionero_negativo`, `ojal_negativo`, `tuerca_negativo`, `hilo_negro_tapa` |
| translúcidos | `powerbank`, `placa_esp32`, `laser`, `pila_falsa` |
| encuadre | `powerbank`, `barra`, `placa_rele`, `regulador`, `pila_falsa`, `tapa_trasera` (todo el camino) |

(El láser va en el negativo porque su tubo es el retorno; su lugar en la lista dice «del cabezal al
tubo».)

## 4. Datos del visor (versión 5)

`cableado.circuitos` (solo si el ensamblaje los declara):

```json
[{"id": "laser", "nombre": "Circuito del láser", "descripcion": "…",
  "grupos": [{"titulo": "Power bank e interruptor", "miembros": ["powerbank", "enchufe_usb", …]}, …],
  "translucidos": ["powerbank", "placa_esp32", "laser", "pila_falsa"],
  "encuadre": ["powerbank", "barra", "placa_rele", "regulador", "pila_falsa", "tapa_trasera"]}]
```

## 5. Validaciones

| Id | Dónde | Falla cuando | Mensaje |
|---|---|---|---|
| C-07 | `armado_comun.scad` | un circuito está mal formado, repite id, está vacío o nombra un miembro que no es elemento ni cable, un elemento oculto o el tramo de un cable; un translúcido no es miembro; el encuadre nombra algo que no es elemento ni cable | `circuitos: …` nombrando el circuito y el miembro |
| C-08 | `generar_visor.py` | un miembro no está en los datos del visor | `El circuito '<id>' nombra '<miembro>', que no está en el visor` |
| V-30 | `puntero_laser_parametros.scad` | ver §1 | ver §1 |
