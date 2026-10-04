# Modelo de datos (Fase 1): Soporte de pared paramétrico para taladro

**Funcionalidad**: [spec.md](spec.md) | **Investigación**: [research.md](research.md)

En este proyecto el «modelo de datos» es el **conjunto de parámetros** del generador, sus valores
derivados, las reglas de validación y la geometría que producen. Todas las cotas están en mm y los
ejes siguen la convención de [research.md](research.md): X = ancho, Y = profundidad (pared en Y = 0) y
Z = altura (cara inferior de la bandeja en Z = 0).

## Entidad 1: Conjunto de parámetros del soporte (editables)

| Grupo (Customizer) | Nombre | Por defecto | Rango [mín:paso:máx] | Requisito |
|--------------------|--------|-------------|----------------------|-----------|
| Dimensiones principales | `ancho` | 80 | [50:1:150] | FR-005 |
| Dimensiones principales | `profundidad` | 100 | [60:1:160] | FR-005 |
| Dimensiones principales | `diametro_tornillo` | 5 | [3:0.5:8] | FR-005, FR-007 |
| Taladro | `ancho_ranura` | 46 | [30:1:60] | FR-002, FR-005 |
| Taladro | `diametro_cuerpo_taladro` | 60 | [40:1:90] | FR-008 (solo validación) |
| Estructura | `espesor` | 6 | [4:0.5:10] | FR-005 |
| Estructura | `altura_placa` | 70 | [50:1:120] | FR-005 |
| Estructura | `espesor_cartela` | 5 | [3:0.5:10] | FR-001 |
| Detalles | `holgura_tornillo` | 0.4 | [0.2:0.05:1.0] | FR-005, FR-007 |
| Detalles | `altura_labio` | 3 | [0:0.5:4.5] (0 = sin labio) | R3, FR-012 |
| Detalles | `chaflan_ranura` | 1.5 | [0:0.5:3] | FR-003 |
| Detalles | `radio_esquinas` | 4 | [0:0.5:10] | FR-003 |
| Detalles | `radio_filete` | 3 | [0:0.5:6] | R1 |
| Calidad | `$fn` | 64 | [24:8:128] | Principio I |

## Entidad 2: Valores derivados y constantes internas (`/* [Hidden] */`)

| Nombre | Definición | Valor por defecto |
|--------|------------|-------------------|
| `longitud_labio` | constante | 6 |
| `holgura_cuerpo_min` | constante: `longitud_labio + 2` | 8 |
| `margen_cuerpo_carril` | constante: apoyo mínimo del cuerpo sobre cada carril × 2 | 8 |
| `holgura_cuerpo_cartela` | constante: holgura mínima entre el cuerpo y las cartelas | 2 |
| `altura_cartela_min_util` | constante: altura útil mínima de cartela bajo los tornillos | 10 |
| `espesor_min_pared` | constante: espesor mínimo de cualquier sección (3 líneas de 0,4 mm, FR-012) | 1.2 |
| `espesor_min_bajo_avellanado` | constante: ≥ `espesor_min_pared` | 1.5 |
| `diametro_orificio` | `diametro_tornillo + holgura_tornillo` | 5.4 |
| `diametro_cabeza` | `2 * diametro_tornillo` | 10 |
| `profundidad_avellanado` | `(diametro_cabeza - diametro_orificio) / 2 + 0.3` | 2.6 |
| `ancho_carril` | `(ancho - ancho_ranura) / 2` | 17 |
| `centro_ranura_y` | `espesor + (profundidad - espesor) / 2` | 53 |
| `radio_ranura` | `ancho_ranura / 2` | 23 |
| `fondo_ranura_y` | `centro_ranura_y - radio_ranura` | 30 |
| `tornillo_z` | `altura_placa - diametro_cabeza` | 60 |
| `tornillo_x` | `[diametro_cabeza, ancho - diametro_cabeza]` | [10, 70] |
| `altura_cartela` | `tornillo_z - diametro_cabeza` (medida desde Z = 0) | 50 |
| `fin_cartela_y` | `profundidad - longitud_labio - 2` | 92 |
| `radio_esquinas_util` | `min(radio_esquinas, ancho_carril / 2 - eps)`: los dos redondeos de la punta de cada carril no se solapan | 4 |

## Reglas de validación

Cada regla se implementa con `assert(condición, mensaje)`. El mensaje nombra el parámetro, el valor
recibido y el límite (FR-010, SC-005). La columna «Caso límite» enlaza con la especificación.

| ID | Condición que DEBE cumplirse | Caso límite |
|----|------------------------------|-------------|
| V-01 | Cada parámetro editable es numérico y está dentro de su rango (tabla de la Entidad 1) | Valores no numéricos, negativos o cero; tornillo < 3 mm |
| V-02 | `ancho_carril >= 2 * espesor` | Ranura demasiado ancha |
| V-03 | `diametro_tornillo` permite margen al borde: `ancho >= 4 * diametro_cabeza` | Tornillo demasiado grande |
| V-04 | `espesor - profundidad_avellanado >= espesor_min_bajo_avellanado` | Avellanado más profundo que la placa |
| V-05 | `altura_cartela - espesor >= 2 * radio_filete + altura_cartela_min_util` (deja cartela útil bajo los tornillos) | Placa demasiado baja para el tornillo |
| V-06 | `profundidad >= espesor + diametro_cuerpo_taladro + 2 * holgura_cuerpo_min` | Profundidad insuficiente |
| V-07 | `diametro_cuerpo_taladro >= ancho_ranura + margen_cuerpo_carril` | El cuerpo cabría por la ranura |
| V-08 | `diametro_cuerpo_taladro <= ancho - 2 * espesor_cartela - holgura_cuerpo_cartela` | El cuerpo choca con las cartelas |
| V-09 | `fondo_ranura_y - espesor >= espesor` (material entre la ranura y la placa) | Ranura demasiado cerca de la placa |
| V-10 | `espesor_cartela <= ancho_carril - chaflan_ranura` | Cartela sobre el chaflán |

**Reglas defensivas**: V-09 y V-10 no pueden fallar cuando se cumplen V-06, V-07 y V-08, porque
algebraicamente `fondo_ranura_y − espesor ≥ 12 ≥ espesor` y
`ancho_carril − chaflan_ranura ≥ espesor_cartela + 2`. Se mantienen como protección ante cambios
futuros, pero no tienen caso de prueba en el quickstart.

**Espesor mínimo (FR-012)**: con los rangos admitidos, los elementos delgados cumplen siempre
`≥ espesor_min_pared` (1,2 mm):

- Cara superior del labio: `longitud_labio − altura_labio` ≥ 6 − 4,5 = 1,5 mm.
- Pared bajo el avellanado: `espesor − profundidad_avellanado` ≥ 1,5 mm (V-04).
- Cartelas: `espesor_cartela` ≥ 3 mm.

**Rango validado estructuralmente** (sin repetir la simulación): `profundidad ≤ 100`,
`espesor ≥ 6`, `ancho ≥ 80`, `espesor_cartela ≥ 5` y material PETG o PLA. Fuera de ese rango la guía
exige repetir la simulación (FR-017). No es un error de generación.

## Entidad 3: Geometría producida (módulos)

Solo se usan primitivas que el importador CSG de FreeCAD 1.1.4 reconstruye bien: `cube`,
`cylinder` (incluido `r1/r2`) y `polyhedron` (prismas mediante el módulo auxiliar
`prisma_yz(perfil, x0, longitud)`), con `rotate`, `translate`, `union`, `difference` e
`intersection`. **No** se usan `linear_extrude` ni primitivas 2D (`circle`, `square`, `polygon`),
porque fallan dentro de booleanas anidadas («Null input shape», verificado en la implementación),
ni tampoco `hull` ni `minkowski` (R10).

| Módulo | Qué genera | Requisito |
|--------|------------|-----------|
| `ensamblaje_principal()` | `difference()` de los cuerpos menos los vaciados | Principio I |
| `placa_trasera()` | prisma `ancho × espesor × altura_placa` | FR-001 |
| `bandeja()` | prisma `ancho × profundidad × espesor` con esquinas frontales redondeadas (`radio_esquinas`) | FR-001, FR-003 |
| `cartelas()` | 2 prismas triangulares (`prisma_yz`) en X = 0 y X = ancho − espesor_cartela, recortados por el contorno de la bandeja | FR-001 |
| `filete_interior()` | relleno cóncavo de `radio_filete` en la arista placa–bandeja | R1 |
| `labios_retencion()` | 2 trapecios a 45° de `altura_labio × longitud_labio` sobre los carriles, en el borde frontal | R3 |
| `vaciado_ranura()` | U (cilindro + prisma) pasante en Z; chaflán superior (cono + prisma trapezoidal) que por encima de la bandeja sigue en vertical con el ancho ampliado para que los labios no queden en voladizo; redondeo de la boca con `radio_esquinas_util` | FR-002, FR-003, FR-011 |
| `vaciado_tornillos()` | 2 × (cilindro pasante `diametro_orificio` + cono avellanado 90° en la cara frontal de la placa) | FR-004, FR-007, FR-009 |

**Caja envolvente esperada**: `[ancho, profundidad, altura_placa]`. Valor por defecto:
80 × 100 × 70 mm (SC-004).

## Entidad 4: Taladro soportado (referencia, no se modela)

| Atributo | Valor de referencia | Uso |
|----------|---------------------|-----|
| Ø exterior del portabrocas | ≤ 44 mm | Debe ser < `ancho_ranura` (holgura ≥ 2 mm) |
| Ø del cuerpo / caja de engranajes | 60 mm | `diametro_cuerpo_taladro` |
| Peso con batería | ≤ 2,5 kg | Carga de diseño de 25 N |

## Entidad 5: Tornillería de fijación (BOM)

| Elemento | Cantidad | Especificación por defecto | Regla para otros diámetros |
|----------|----------|----------------------------|----------------------------|
| Tornillo de cabeza avellanada para taco | 2 | Ø5 × 50 mm | Ø = `diametro_tornillo`; longitud ≥ `espesor` + longitud del taco |
| Taco de nailon | 2 | Ø8 × 40 mm | Según el tornillo y el tipo de pared (lo indica la guía) |

## Estados del artefacto (ciclo de vida)

```text
Parámetros editados ──render OK──> .scad válido ──simulación OK / fuera de rango validado──> validado
        │                                                                                      │
        └──assert falla──> error con mensaje (sin STL)          exportación .stl <─────────────┘
                                                                         │
                                                         guía de producción actualizada
```

Si se cambia cualquier parámetro, el `.stl` y los valores citados en la guía DEBEN regenerarse
(Principio IV).
