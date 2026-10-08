# Modelo de datos (Fase 1): Caja con tapa a presión para 4 pilas AA

Prefijo de los archivos: `caja_pilas`. Convención de ejes del conjunto: origen en la esquina inferior
de la caja, X a lo largo de la fila de pilas, Y a lo largo del eje de cada pila, Z hacia arriba.

## Entidad 1. Parámetros públicos (`src/caja_pilas_parametros.scad`)

| Parámetro | Por defecto | Rango | Uso |
|---|---|---|---|
| `cantidad_pilas` | 4 | 1 – 10 | Alojamientos en la fila |
| `diametro_pila` | 14.5 | 8 – 20 | Diámetro máximo de la pila (R1) |
| `largo_pila` | 50.5 | 30 – 70 | Largo máximo de la pila (R1) |
| `espesor_pared` | 2.0 | 1.6 – 4 | Paredes de la caja |
| `espesor_piso` | 2.0 | 1.2 – 4 | Piso de la caja y placa de la tapa |
| `espesor_tabique` | 1.2 | 1.2 – 3 | Tabiques entre alojamientos |
| `alto_tabique` | 10 | 4 – 20 | Alto de los tabiques sobre el piso (R5) |
| `radio_esquina` | 3 | 1 – 6 | Esquinas verticales exteriores |
| `alto_pollera` | 8 | 5 – 12 | Pollera de la tapa (R3, R4) |
| `espesor_pollera` | 1.2 | 1.2 – 2 | Espesor de la pollera y de la pestaña |
| `ancho_pestana` | 20 | 10 – 40 | Ancho de cada pestaña |
| `saliente_reborde` | 0.5 | 0.3 – 0.8 | Cuánto sobresale el reborde de la pestaña |
| `ancho_muesca` | 16 | 10 – 25 | Muesca de apertura (R6) |
| `profundidad_muesca` | 2.5 | 1.5 – 5 | Muesca de apertura (R6) |

Constantes en `[Hidden]`: `$fn = 64`, `eps = 0.01`, `chaflan_cama = 0.6`, `plano_reborde = 0.4`
(cara plana del trapecio), `ranura_pestana = 1.0` (ranuras a los lados de la pestaña),
`distancia_reborde_punta = 1.0`, `deformacion_admisible = 0.015` (PETG, R4), `modulo_material = 2000`.

Del perfil de impresora: `holgura("suelto")` para los alojamientos y `holgura("justo")` para la
pollera; `espesor_min_pared`, `espesor_min_piso` y `cama_util()` para las validaciones.

## Entidad 2. Derivados

| Derivado | Fórmula | Valor por defecto |
|---|---|---|
| `ancho_alojamiento` | `diametro_pila + holgura("suelto")` | 14,9 |
| `largo_alojamiento` | `largo_pila + holgura("suelto")` | 50,9 |
| `interior_x` | `cantidad_pilas·ancho_alojamiento + (cantidad_pilas − 1)·espesor_tabique` | 63,2 |
| `interior_y` | `largo_alojamiento` | 50,9 |
| `exterior_x`, `exterior_y` | interior + 2·`espesor_pared` | 67,2 × 54,9 |
| `alto_zona_pilas` | `ancho_alojamiento` | 14,9 |
| `alto_caja` | `espesor_piso + alto_zona_pilas + alto_pollera` | 24,9 |
| `alto_tapa` | `espesor_piso + alto_pollera` | 10,0 |
| `holgura_pollera` | `holgura("justo") / 2` (por lado) | 0,125 |
| `flecha_pestana` | `saliente_reborde − holgura_pollera` | 0,375 |
| `largo_pestana` | `alto_pollera − distancia_reborde_punta` | 7,0 |
| `deformacion_pestana` | `1,5·espesor_pollera·flecha_pestana / largo_pestana²` | 0,0138 |
| `juego_vertical_pila` | `holgura("suelto") + alto_pollera` | 8,4 |
| `profundidad_ranura` | `saliente_reborde` | 0,5 |
| `z_reborde` | altura del centro del reborde/ranura medida desde el borde superior de la caja: `alto_pollera − distancia_reborde_punta` | 7,0 |

## Entidad 3. Reglas de validación (`assert`)

| Regla | Condición | Mensaje (resumen) |
|---|---|---|
| V-01 | `espesor_pared − profundidad_ranura ≥ espesor_min_pared` | la ranura deja la pared más fina que el mínimo |
| V-02 | `espesor_piso ≥ espesor_min_piso`; `espesor_tabique`, `espesor_pollera ≥ espesor_min_pared` | espesor menor que el mínimo FDM |
| V-03 | `exterior_x`, `exterior_y` dentro de `cama_util()` y `alto_caja ≤ cama[2]` | no entra en la cama |
| V-04 | `flecha_pestana > 0` | el reborde no engancha: es menor que la holgura de la pollera |
| V-05 | `deformacion_pestana ≤ deformacion_admisible` | la pestaña se rompe o se deforma al cerrar |
| V-06 | `alto_tabique > juego_vertical_pila` y `alto_tabique < alto_zona_pilas` | la pila puede saltar el tabique / el tabique choca con la pollera |
| V-07 | `ancho_pestana + 2·ranura_pestana ≤ interior_x − 2·radio interior` | la pestaña no entra en la pared larga |
| V-08 | `ancho_muesca ≤ interior_y − 2` y `profundidad_muesca < alto_pollera − distancia_reborde_punta` | la muesca no entra o corta la zona del encastre |
| V-09 | `saliente_reborde + plano_reborde/2 < distancia_reborde_punta` | el reborde no entra en la punta de la pestaña |

## Entidad 4. Piezas

| Pieza | Archivo | Orientación de impresión | Caja envolvente esperada |
|---|---|---|---|
| Caja | `src/caja_pilas_caja.scad` | Abertura hacia arriba | 67,2 × 54,9 × 24,9 mm |
| Tapa | `src/caja_pilas_tapa.scad` | Cara exterior sobre la cama | 67,2 × 54,9 × 10,0 mm (reborde incluido, dentro del contorno) |
| Ensamblaje | `src/caja_pilas_ensamblaje.scad` | No se exporta | 67,2 × 54,9 × 26,9 mm cerrada |

## Entidad 5. Unión

| Unión | Piezas | Tipo | Holgura |
|---|---|---|---|
| U-01 | Pollera de la tapa en la boca de la caja | Encastre a presión con 2 pestañas | `holgura("justo")` en el contorno; interferencia del reborde = `flecha_pestana` |

## Entidad 6. Lista de materiales

Solo filamento PETG: ≈ 37 g las dos piezas según el volumen de los STL (caja ≈ 25 g, tapa ≈ 12 g); el CSV redondea a 40 g. Las pilas no forman parte del
diseño.

## Entidad 7. Pasos de armado (tabla `pasos` del ensamblaje)

| Paso | Elementos | Desplazamiento |
|---|---|---|
| 1. Colocar las pilas | caja (contexto), pilas | Desde arriba |
| 2. Cerrar la tapa | caja y pilas (contexto), tapa | Desde arriba |
| 3. Abrir la caja | — | Sin vista |
