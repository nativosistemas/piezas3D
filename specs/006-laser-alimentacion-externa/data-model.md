# Modelo de datos (Fase 1): Láser alimentado desde el power bank

**Plan**: [plan.md](plan.md) | **Investigación**: [research.md](research.md) | **Base**:
[002 data-model.md](../002-puntero-laser-estelar/data-model.md)

Solo se describe lo que cambia o se agrega respecto de la 002. Todo va en
`src/puntero_laser_parametros.scad`.

## Entidad 1: parámetros públicos nuevos (Customizer)

Grupo nuevo `/* [Láser sin batería] */`, después de `[Componentes comprados]`:

| Parámetro | Por defecto | Rango del Customizer | Unidad | Significado |
|---|---|---|---|---|
| `diametro_hueco_bateria` | 18.5 | [16:0.1:22] | mm | Diámetro interior del tubo donde iba la batería |
| `profundidad_hueco_bateria` | 65 | [34:0.5:70] | mm | Del borde trasero del tubo al contacto del cabezal, con el resorte libre |
| `diametro_zona_tapa` | 30 | [20:0.1:40] | mm | Diámetro exterior de la rosca donde enroscaba la tapa original |
| `largo_zona_tapa` | 12 | [8:0.5:20] | mm | Largo de esa rosca |
| `largo_tapa_original` | 20 | [5:0.5:40] | mm | Lo que la tapa original sobresale del borde del tubo |
| `masa_bateria_g` | 45 | [15:1:60] | g | Batería que se quita |
| `masa_tapa_original_g` | 20 | [5:1:40] | g | Tapa original que se quita |
| `tuercas_lastre_tapa` | 2 | [0:1:3] | u | Tuercas M10 de lastre en la tapa impresa |
| `distancia_trasera_centro_masa_nueva` | 0 | [0:1:200] | mm | 0 = se calcula; si no, el valor medido desde el extremo trasero de la tapa impresa |
| `regulador_largo` | 22 | [15:0.5:25] | mm | Largo del módulo reductor (MP1584EN) |
| `regulador_ancho` | 17 | [10:0.5:18] | mm | Ancho del módulo reductor |

Cambia el significado de 2 parámetros de la 002, que no cambian de valor:

- `largo_laser`: es el largo **con la tapa original**, tal como se mide hoy.
- `distancia_trasera_centro_masa` y `masa_laser_g`: corresponden al láser **con batería y tapa
  original**. Son los datos de partida del cálculo.

## Entidad 2: constantes nuevas (`[Hidden]`)

| Constante | Valor | Origen |
|---|---|---|
| `m10_tuerca_ec` / `m10_tuerca_alto` / `masa_tuerca_m10_g` | 17 / 8 / 11 | Tuerca DIN 934 M10 |
| `largo_prisionero_tapa` | 12 | Prisionero DIN 914 M3 × 12, punta cónica (con 10 no entraban el ojal y la contratuerca) |
| `iso7380_m3_cabeza_d` / `_alto` | 5.7 / 1.65 | Tornillo M3 × 8 de cabeza alomada (contacto +) |
| `espesor_ojal` | 0.8 | Terminal de ojal M3 |
| `compresion_resorte` | 2 | Compresión del resorte del cabezal con la pila falsa puesta |
| `d_hilo` | 1.3 | Hilo de silicona de 26 AWG |
| `ohm_por_m_26awg` / `corriente_laser_a` / `largo_cable_laser` | 0.134 / 0.5 / 600 | R7 |
| `angulo_cable` | 150 | Ángulo del cable en el sistema de impresión de la cuna (R6) |
| `ancho_ranura_canaleta` / `prof_canaleta` / `pared_canaleta` / `puentes_canaleta` | 2.8 / 2.8 / 1.2 / 3 | Canaleta de la cuna (2 hilos lado a lado) |
| `piso_tapa_trasera` / `pared_tapa_trasera` / `espesor_resalte_prisionero` / `desfase_prisionero_tapa` | 1.6 / 2.4 / 4 / 45° | Tapa trasera |
| `ancho_grapa` / `pared_grapa` / `abertura_grapa` | 5 / 2 / 100 | Grapa (abertura en grados) |
| `recorrido_equilibrado` | 3.5 | Lo que se puede correr el láser hacia cada lado para equilibrarlo |
| `masa_grapa_g` / `masa_cable_g` | 2 / 4 | Estimadas (la pila falsa y la tapa se calculan por volumen) |
| `alto_brazo_max_flexion` | 131 | Límite del criterio de flexión de 0,1° (R5) |

## Entidad 3: derivados nuevos o que cambian

Sistema de medida: distancias a lo largo del eje del láser, desde el **borde trasero del tubo**,
positivas hacia el frente.

| Derivado | Fórmula |
|---|---|
| `largo_laser_sin_tapa` | `largo_laser − largo_tapa_original` |
| `largo_tapa_fuera` | `piso_tapa_trasera + tuercas_lastre_tapa·m10_tuerca_alto + holgura("presion")` |
| `largo_laser_mod` | `largo_laser_sin_tapa + largo_tapa_fuera` |
| `d_pila_falsa` | `diametro_hueco_bateria − 2·holgura("suelto")` |
| `largo_pila_falsa` | `profundidad_hueco_bateria + compresion_resorte − iso7380_m3_cabeza_alto − espesor_ojal` (cuerpo impreso) |
| `masa_tapa_trasera_g` | volumen × `densidad_petg` (sólida, 100 % de relleno) |
| `masa_laser_mod_g` | `masa_laser_g − masa_bateria_g − masa_tapa_original_g + masa_pila_falsa_g + masa_tapa_trasera_g + tuercas_lastre_tapa·masa_tuerca_m10_g + masa_grapa_g + masa_cable_g` |
| `cm_mod_desde_borde` | Momentos respecto del borde trasero (centro de masa original en `distancia_trasera_centro_masa − largo_tapa_original`, batería en `profundidad_hueco_bateria/2`, tapa original en `−largo_tapa_original/2`, pila falsa en `largo_pila_falsa/2`, lastre en `−largo_tapa_fuera + piso + n·alto/2`, tapa impresa en su centroide, grapa y cable en `largo_zona_tapa + 8`) ÷ `masa_laser_mod_g` |
| `l_trasero` (**cambia**) | `distancia_trasera_centro_masa_nueva > 0 ? ese valor : cm_mod_desde_borde + largo_tapa_fuera` |
| `l_delantero` (**cambia**) | `largo_laser_mod − l_trasero` |
| `r_tapa_trasera` | `diametro_zona_tapa/2 + holgura("deslizante") + pared_tapa_trasera + espesor_resalte_prisionero + m3_tuerca_alto + espesor_ojal` (radio máximo, con la tuerca del negativo) |
| `hueco_equilibrado` | `l_trasero − largo_tapa_fuera − largo_zona_tapa − largo_tubo_cuna/2` |
| `caida_cable_v` | `2·largo_cable_laser/1000·ohm_por_m_26awg·corriente_laser_a` |
| `alto_col_a` (**cambia**) | `2·largo_soporte_uln + largo_soporte_regulador + 2·holgura_zonas` |
| `largo_soporte_regulador` | `regulador_largo + 2·holgura_encastre + 2·pared_soporte` |
| `y_uln_alt0` (**cambia**) | `−alto_col_a/2` (sin cambios de fórmula); el regulador va en `y_uln_az0 + largo_soporte_uln + holgura_zonas` |
| `zona_regulador` | `[x_col_a0, y_reg0, x_col_a1, y_reg0 + largo_soporte_regulador, altura_placas, "regulador"]`, se agrega a `zonas_componentes` |
| `secciones(a)` (**cambia**) | Usa `l_trasero` y `l_delantero` nuevos. Las secciones del tramo `[−l_trasero, −l_trasero + largo_tapa_fuera + largo_zona_tapa]` usan `r_tapa_trasera` en lugar de `diametro_laser/2` |

`altura_eje`, `alto_brazo` y todo lo que depende de ellos se recalculan solos a partir de
`l_trasero` y `l_delantero`.

## Entidad 4: validaciones nuevas (V-15 … V-21)

| Regla | Condición | Mensaje (resumen) |
|---|---|---|
| V-15 | `comprobar_rango` para cada parámetro de la Entidad 1 | "`<parámetro>`=…: fuera de [mín, máx]" |
| V-16 | `diametro_hueco_bateria + 2·espesor_min_pared ≤ diametro_zona_tapa` | "el hueco de la batería no entra en el tubo" |
| V-17 | `m10_tuerca_ec/cos(30) + 2·holgura("presion") + 2·espesor_min_pared ≤ 2·r_funda_ext` y escalón ≥ 1 mm (`diametro_zona_tapa − hueco_hex_esquinas ≥ 2`) o `tuercas_lastre_tapa == 0` | "el lastre no entra en la tapa" / "el borde del tubo no tiene dónde apoyar" |
| V-18 | `espesor_resalte_prisionero + pared_tapa_trasera + holgura("deslizante") + m3_tuerca_alto + espesor_ojal + 1 ≤ largo_prisionero_tapa` (4 + 2,4 + 0,3 + 2,4 + 0,8 + 1 = 10,9 ≤ 12) | "el prisionero del negativo no alcanza para el ojal y la tuerca" |
| V-19 | `hueco_equilibrado ≥ ancho_grapa + 2·recorrido_equilibrado` | "la tapa queda a … mm de la cuna: no hay lugar para la grapa y el equilibrado" |
| V-20 | `caida_cable_v < 0.1` | "el cable de … mm hace caer … V (máx. 0,1 V)" |
| V-21 | `regulador_largo ≥ regulador_ancho` y `regulador_ancho + 2·holgura_encastre + 2·pared_soporte ≤ ancho_col_a` | "el regulador no entra en la columna de los ULN2003" |
| Aviso | `alto_brazo > alto_brazo_max_flexion` → `echo("AVISO: …")` | "repetir el cálculo de flexión R10 (research de la 006)" |

V-07 (barrido) y la comprobación de la plataforma (≤ 196 mm) de la 002 siguen vigentes con los
derivados nuevos.

## Entidad 5: piezas

| Pieza | Archivo | Estado | Orientación de impresión | Uniones |
|---|---|---|---|---|
| Pila falsa | `puntero_laser_pila_falsa.scad` | **Nueva** | De pie, cara trasera sobre la cama | U-13: tornillo ISO 7380 M3 × 8 en tuerca M3 embutida (contacto +) |
| Tapa trasera | `puntero_laser_tapa_trasera.scad` | **Nueva** | De pie, piso trasero sobre la cama | U-14: funda deslizante sobre la rosca del tubo + 2 prisioneros DIN 914; U-15: tuercas M10 a presión |
| Grapa del cable | `puntero_laser_grapa_cable.scad` | **Nueva** | Plana (perfil 2D extruido) | U-16: anillo abierto a presión sobre el tubo del láser (`holgura("presion")`) |
| Cuna del láser | `puntero_laser_cuna_laser.scad` | **Cambia** | Igual | Agrega `canaleta_cable()` a 150°; quita `ranura_cable()` |
| Plataforma de azimut | `puntero_laser_plataforma_azimut.scad` | **Cambia** | Igual | Agrega el soporte del regulador en la columna A |
| Brazos, polea de altura, base | — | Se regeneran | Igual | Cambian solo por `altura_eje` (+ ≈ 1,7 mm) |
| Ensamblaje | `puntero_laser_ensamblaje.scad` | **Cambia** | No se exporta | Elementos nuevos `pila_falsa`, `tapa_trasera`, `lastre`, `grapa`, `regulador`; láser dibujado como tubo sin tapa + tapa impresa; tabla de pasos de 18 → 19 |

STL: de 10 a **13**.

## Entidad 6: lista de materiales (`docs/puntero_laser_bom.csv`)

| Cambio | Renglón |
|---|---|
| Agregar | 1 × Módulo reductor MP1584EN (o mini-360) ajustable |
| Agregar | 1 × Resistencia de 10 kΩ 1/4 W (IN → GND del relé) |
| Agregar | 2 × Prisionero M3 × 12 punta cónica (DIN 914) + 2 tuercas M3: tapa trasera y contacto negativo |
| Agregar | 1 × Tornillo M3 × 8 cabeza alomada (ISO 7380) + 1 × tuerca M3: contacto positivo de la pila falsa |
| Agregar | 2 × Terminal de ojal M3 para cable de 26 AWG |
| Agregar | 2 × Tuerca M10 (DIN 934): lastre de la tapa trasera |
| Cambiar | Cable de silicona 2 × 26 AWG: de 40 a 60 cm, nota "regulador → láser" |
| Cambiar | Láser 303: nota "la batería y la tapa original se guardan" |
| Cambiar | Filamento: se suman las 3 piezas nuevas (estimado del laminador) |

Los precios nuevos se buscan en la fase 5 y quedan vacíos si no se pueden verificar.

## Entidad 7: pasos de armado (cambios en la tabla `pasos`)

| Paso | Cambio |
|---|---|
| 14 nuevo, "Preparar el láser" | Sacar la batería y la tapa original; poner la pila falsa; tuercas M10 en la tapa; tapa con sus 2 prisioneros; ojal negativo con contratuerca; brida; grapa. Elementos: `pila_falsa`, `tapa_trasera`, `lastre`, `grapa` |
| 15 (antes 14) "Láser en la cuna" | Ya no se suelda en paralelo al pulsador: se traba el pulsador en encendido y se enhebra el cable por la canaleta |
| 16 (antes 15) "Electrónica" | Agrega el elemento `regulador` y la resistencia de 10 kΩ |
| 17 (antes 16) "Cableado" | Recorrido nuevo del cable del láser |

El `assert(len(pasos) == 18)` pasa a 19.
