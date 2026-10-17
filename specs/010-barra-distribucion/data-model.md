# Modelo de datos: Barra de distribución de alimentación

Todo vive en `src/puntero_laser_parametros.scad` salvo lo indicado. Valores y motivos:
[research.md](research.md).

## 1. Parámetros nuevos (`/* [Conectores y cables] */`, editables)

| Parámetro | Defecto | Rango | Qué es |
|---|---|---|---|
| `pines_barra` | 6 | 6–10 | Pines de cada tira de la barra (destinos + reserva) |
| `barra_largo` | 25.4 | 20–36 | Largo del trozo de placa perforada (medir) |
| `barra_ancho` | 7.6 | 7–10 | Ancho del trozo de placa perforada (medir) |

Constantes (Hidden): `destinos_5v = 5`, `destinos_gnd = 5` (sección 5.4 de la guía),
`masa_barra_g = 3` y `pad_soporte_barra = 2` (apoyos de las esquinas más chicos que los de 3 mm de
las otras placas, para dejar libre la soldadura del agujero 2). Se reutilizan `paso_pines`, `espesor_pcb` y `alto_tira_pines` (009).

## 2. Derivadas

| Derivada | Fórmula |
|---|---|
| `x_reg1` | `x_col_a0 + regulador_ancho + 2*(pared_soporte + holgura_encastre)` (borde +X del soporte del regulador) |
| `x_barra0` | `x_reg1 + holgura_zonas` |
| `y_barra0` | `y_reg0` |
| `ancho_soporte_barra` / `largo_soporte_barra` | `barra_ancho` / `barra_largo` `+ 2*(holgura_encastre + pared_soporte)` |
| `y_sob0` | `max(fin del regulador, fin del relé, y_barra0 + largo_soporte_barra) + holgura_zonas` (antes sin la barra) |
| `zona_regulador` | `[x_col_a0, y_reg0, x_reg1, …]` (antes llegaba a `x_col_a1`) |
| `zona_barra` | `[x_barra0, y_barra0, x_barra0 + ancho_soporte_barra, y_barra0 + largo_soporte_barra, altura_placas, "barra"]`, sumada a `zonas_componentes` |

El soporte se dibuja con `soporte_placa(x_barra0, y_barra0, barra_ancho, barra_largo,
alto_soporte_placa, pad_soporte_barra)`, el mismo módulo que usan las otras placas, en
`puntero_laser_plataforma_azimut.scad`.

## 3. Ensamblaje

- **Elemento `barra`**: es una `placa(x_barra0, y_barra0, barra_ancho, barra_largo,
  alto_soporte_placa, …)` con las dos tiras de pines dibujadas. En la tabla de identificación figura
  como "Barra de distribución +5 V / GND (placa perforada)", de tipo "comprada". Aparece en el
  paso 16 con un desplazamiento de `[0, 0, 70]`, como las otras placas.
- **Volumen de los Dupont de la barra** (dentro de `conectores`): ocupa la planta de la placa, desde
  la PCB hasta `alto_conectores_arriba`, como los de los ULN2003 y el relé.
- **Ancla**: el centro de la placa, bajo su apoyo.

## 4. Validaciones nuevas

| Código | Regla | Mensaje (resumen) |
|---|---|---|
| V-27 | `pines_barra ≥ max(destinos_5v, destinos_gnd) + 1` | `pines_barra=…: la barra necesita al menos … pines por tira (… destinos + reserva)` |
| V-28 | `barra_largo ≥ (pines_barra + 4)*paso_pines − 0.5` y `barra_ancho ≥ 3*paso_pines − 0.5` | `barra_largo=…: la placa no tiene lugar para … pines, la entrada y las esquinas libres` |
| V-29 | `x_barra0 + ancho_soporte_barra ≤ x_col_a1` | `barra_ancho=…: la barra no entra al lado del regulador (máx. … mm)` |
| V-08 (existente) | `zona_barra` sin solaparse con otra zona, con `holgura_zonas` | ya nombra las dos zonas |

- **Tapa**: si la barra se alarga más allá del relé, empuja el hueco del sobrante y la tapa crece en
  Y. En ese caso la vigilan las comprobaciones existentes de la tapa y de la cama.
- **Altura**: los Dupont de la barra miden lo mismo que los de los ULN2003, así que V-22 los cubre
  sin cambios.
