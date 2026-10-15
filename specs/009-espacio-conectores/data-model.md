# Modelo de datos: Espacio para conectores y cableado

Todo vive en `src/puntero_laser_parametros.scad` salvo lo indicado. Valores y motivos:
[research.md](research.md).

## 1. Parámetros nuevos (`/* [Conectores y cables] */`, editables)

| Parámetro | Defecto | Rango | Qué es |
|---|---|---|---|
| `alto_tira_pines` | 2.5 | 2–3.5 | Plástico de la tira de pines macho |
| `largo_dupont` | 14 | 10–20 | Cuerpo del Dupont hembra recto (medir) |
| `diametro_cable_dupont` | 1.4 | 1–2 | Cable de un Dupont |
| `radio_curva_cable` | 5 | 3–10 | Radio mínimo de curva del cable (al eje) |
| `alto_enchufe_motor` | 13 | 9–18 | Enchufe JST del 28BYJ-48 conectado, sobre la PCB |
| `pines_por_lado_esp32` | 19 | 15–20 | Pines de cada fila del ESP32 (19 = 38 pines) |
| `ancho_enchufe_usb` / `alto_enchufe_usb` | 11 / 7.5 | 8–14 / 5–10 | Funda del enchufe USB (medir) |
| `largo_cable_motor` | 230 | 150–400 | Cable de fábrica del 28BYJ-48 (medir) |

Constantes (Hidden): `holgura_conector = 1`, `holgura_techo_tapa = 2`, `holgura_usb = 0.75`,
`reserva_cable_motor = 20`, `paso_pines = 2.54`, `separacion_filas_esp32 = 25.4`.

## 2. Derivadas

| Derivada | Fórmula |
|---|---|
| `curva_cable` | `radio_curva_cable + diametro_cable_dupont` |
| `alto_dupont_conectado` | `alto_tira_pines + largo_dupont + curva_cable` |
| `elevacion_esp32` | `alto_dupont_conectado + holgura_conector` (pasa de parámetro a derivada) |
| `alto_conectores_arriba` | `alto_soporte_placa + espesor_pcb + alto_dupont_conectado` |
| `alto_esp32_total` | `elevacion_esp32 + espesor_pcb + alto_modulo_esp32` (sin cambios) |
| `alto_interior_tapa` | `max(altura_placas, alto_conectores_arriba, alto_esp32_total) + holgura_techo_tapa` |
| `largo_cable_alt`, `largo_cable_az` | `largo_polilinea(recorrido)` de cada motor |

## 3. Volúmenes de conector (ensamblaje, elemento `conectores`)

Cajas en coordenadas del conjunto, `[x0, y0, z0, x1, y1, z1, nombre]`:

| Volumen | Planta | Altura (sobre la cara superior de la plataforma) |
|---|---|---|
| Dupont ULN2003 altura / azimut | planta de la placa | de la PCB a `alto_conectores_arriba` |
| Dupont relé | planta de la placa | idem |
| Enchufe de cada motor | planta de la placa | de la PCB a `+ alto_enchufe_motor + curva_cable` (queda dentro del anterior) |
| Dupont ESP32, fila −X y fila +X | franja de `paso_pines + curva_cable` hacia el centro, largo `pines_por_lado_esp32 × paso_pines` centrado | de `elevacion_esp32 − alto_dupont_conectado` a `elevacion_esp32` |
| Enchufe USB | `ancho_enchufe_usb` centrado en el ESP32, desde su borde −Y hasta afuera de la pared de la tapa | `alto_enchufe_usb` centrado en el conector |

## 4. Validaciones nuevas

| Código | Regla | Mensaje (resumen) |
|---|---|---|
| V-22 | Volúmenes de arriba y del ESP32 bajo el interior de la tapa | `largo_dupont=…: el conector de <placa> toca el techo de la tapa` |
| V-23 | Franjas del ESP32 sobre la plataforma con `holgura_conector` | `largo_dupont=…: los Dupont del ESP32 tocan la plataforma` |
| V-24 | Franjas del ESP32 sin tocar los apoyos de las esquinas del soporte | `pines_por_lado_esp32=…: los Dupont del ESP32 tocan los apoyos del soporte` |
| V-25 | Enchufe USB dentro de la abertura con `holgura_usb` y abertura bajo el techo | `ancho_enchufe_usb=…: el enchufe USB no pasa por la abertura de la tapa` |
| V-26 | `largo_cable_<motor> + reserva ≤ largo_cable_motor` | `largo_cable_motor=…: el cable del motor de <eje> no llega (faltan … mm)` |

Las comprobaciones existentes siguen vigentes, en particular la de la tapa contra el carro y el
motor de altura (ensamblaje) y las de cama.
