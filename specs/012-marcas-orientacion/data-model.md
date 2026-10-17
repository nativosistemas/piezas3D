# Modelo de datos (fase 1): Marcas de orientación y de altura

Las "entidades" de esta funcionalidad son parámetros y geometría del diseño. Todo vive en
`src/puntero_laser_parametros.scad`, salvo que se indique otro archivo. Los valores son los de partida;
el plan de tareas puede ajustarlos si las comprobaciones lo piden.

## Parámetros nuevos

| Parámetro | Valor | Sección | Uso |
|---|---|---|---|
| `profundidad_grabado` | 0,6 mm | `/* [Marcas] */` | profundidad de todas las marcas |
| `ancho_raya` | 1,0 mm | `/* [Marcas] */` | rayas de la escala |
| `ancho_linea_referencia` | 1,2 mm | `/* [Marcas] */` | líneas bajo las letras y raya del índice de azimut |
| `alto_letra` | 10 mm | `/* [Marcas] */` | «S» y «O» |
| `fuente_marcas` | "Liberation Sans:style=Bold" | `/* [Marcas] */` | tipografía |
| `espesor_disco_escala` | 2 mm | `/* [Marcas] */` | disco de la escala |
| `d_interior_disco_escala` | 20 mm | `/* [Marcas] */` | paso de la llave tubo de 13 mm |
| `giro_ranura_disco` | 32° | `/* [Marcas] */` | ±giro de las ranuras, ≥ 30° |
| `paso_escala` | 15° | `/* [Marcas] */` | entre rayas |
| `angulo_escala_max` | 90° | `/* [Marcas] */` | última raya |
| `holgura_aguja` | 2,5 mm | `/* [Marcas] */` | de la pestaña de la polea a la cara interior de la aguja |
| `seccion_aguja` | [5, 4] mm | `/* [Marcas] */` | radial × tangencial |
| `azimut_reposo` | 180° | derivado (comentado) | azimut de brújula del láser en la posición modelada |

## Derivados nuevos

- `r_borde_polea_alt = d_exterior_conducida/2 + espesor_brida`: radio de la pestaña, ≈ 26,2 mm.
- `r_exterior_disco_escala = r_borde_polea_alt`.
- `r_agujeros_disco = r_aligerado`, a 0° y 180°. Hoy `r_aligerado` es local de la polea; pasa a
  parámetros como derivado compartido.
- `r_aguja_int = r_borde_polea_alt + holgura_aguja` y `r_aguja_ext = r_aguja_int + seccion_aguja[0]`.
- `x_punta_aguja = x_ext_polea_alt + espesor_disco_escala`: plano de la escala en el conjunto.
- `alto_aguja = x_punta_aguja - x_cara_ext_brazo`: ≈ 42 mm sobre la cara exterior del brazo.
- `alto_brazo` pasa a ser `max(alto actual, altura_eje + r_aguja_ext + pared)`.
- `r_correa_ext_alt`: radio de la cara exterior de la correa sobre la polea de altura, para M-03.

## Geometría por pieza

| Pieza (archivo) | Cambio | Orientación de impresión |
|---|---|---|
| Base (`adaptador_tripode`) | Resta: «S» en +Y y «O» en +X, con línea vertical debajo, en el cilindro de apoyo | Igual (parada) |
| Plataforma (`plataforma_azimut`) | Resta: raya vertical en la cara del borde +Y (x = 0) y triángulo en la cara superior junto al borde | Igual |
| Brazo, variante motor (`brazo_horquilla`) | Suma: oreja en el perfil 2D y aguja con punta en V | Igual (aguja vertical) |
| Polea de altura (`polea_altitud`) | Resta: 2 agujeros guía Ø `diametro_autorroscante_m3` a `r_agujeros_disco`, 0° y 180° | Igual |
| Disco de la escala (`disco_escala`, **nuevo**) | Anillo con 2 ranuras en arco y 7 rayas grabadas | Plano, escala hacia arriba |

## Elementos y datos del ensamblaje

- **Elementos nuevos**:
  - `disco_escala`: «Disco de la escala de altura», impresa.
  - `tornillos_disco`: «Tornillos M3 × 8 del disco de la escala», comprada.
- **Grupos**: los dos van en `grupo_horquilla` y en `elementos_altura`.
- **Pasos**: se suman al paso en que entra `polea_alt`, con un desplazamiento explotado en +X.
- **Simulación**: `articulaciones[azimut]` pasa a `reposo = azimut_reposo` (180). Los `objetivos`
  quedan en grados de brújula.

## Validaciones (asserts con mensaje en español)

| Id | Dónde | Regla |
|---|---|---|
| M-01 | base | Las letras y sus líneas caben entre el chaflán y `z_cuerpo_base_sup`, y su ángulo está a más de `ancho_ventana/2` (más el ancho de la letra) de la ventana en −Y |
| M-02 | base | `profundidad_grabado` deja al menos `espesor_min_pared` hasta la cámara interior (`d_camara`) a la altura de las letras |
| M-03 | ensamblaje | Holgura de la aguja a la correa (`r_aguja_int − r_correa_ext_alt`) ≥ 2 mm y de la aguja al disco > 0 |
| M-04 | brazo | `alto_brazo` ≤ cama útil |
| M-05 | polea | Pared de cada agujero guía a los aligerados y a la raíz del dentado ≥ `espesor_min_pared` |
| M-06 | disco | `giro_ranura_disco` ≥ 30° (cubre el escalón de 60° del hexágono) y las ranuras no tocan las rayas largas ni el agujero central |
| M-07 | ensamblaje | Con el azimut en reposo, la dirección del láser (+Y) coincide con el ángulo de la línea de la «S», y la «O» queda 90° en sentido horario |
| M-08 | ensamblaje | Para cada raya de ángulo `a`, su posición girada `a` grados con la cuna cae frente a la punta de la aguja, a menos de 0,1° |
| M-09 | plataforma | La raya del índice no toca otros vaciados del borde +Y |
