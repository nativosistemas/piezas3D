# Plan de implementación: Puntero láser estelar motorizado (alt-az)

**Rama**: `002-puntero-laser-estelar` | **Fecha**: 2026-10-04 | **Especificación**: [spec.md](spec.md)

**Entrada**: especificación de la funcionalidad en `specs/002-puntero-laser-estelar/spec.md`

## Resumen

Se diseñará una montura altitud-azimut de horquilla, impresa en PETG, para apuntar un puntero láser
verde "303" a las estrellas desde el trípode de un telescopio, con rosca 3/8"-16. El conjunto tiene
estas partes:

- Una **base fija** con la tuerca del trípode embebida, 2 rodamientos 608ZZ y la polea GT2 80T de
  azimut integrada.
- Una **plataforma giratoria** que lleva toda la electrónica (ESP32, 2 drivers ULN2003, relé y power
  bank) y los dos motores 28BYJ-48. Así ningún cable cruza el eje de azimut y el giro es ilimitado.
- Una **horquilla** de 2 brazos con un 608ZZ cada uno.
- Una **cuna tubular** donde el láser se desliza para equilibrarlo, con 6 tornillos de colimación.

Cada eje se mueve con una correa GT2 de 200 mm y relación exacta de 1:4 (polea 20T comprada y 80T
impresa). Da 45,286 pasos/° y divide por 4 el juego de la caja del motor.

El presupuesto de error estimado es ≈ 0,5° (suma cuadrática) y ≈ 1,3° (peor caso). Se cumple el
límite de 2° **siempre que el firmware llegue a cada objetivo desde el mismo sentido**, use la
relación real del motor (4075,77 medios pasos por vuelta) y alinee con 2 estrellas. Esas reglas
quedan fijadas en el [contrato de firmware](contracts/interfaz_firmware.md). El firmware en sí queda
fuera de alcance.

El diseño se divide en 10 archivos imprimibles que comparten un único
`src/puntero_laser_parametros.scad`, más un ensamblaje de revisión con comprobaciones de choque. Las
cargas son de decenas de newtons y las tensiones de ~1 MPa, así que la simulación FEM **no aplica**.
La justificación analítica está en [research.md R10](research.md).

## Contexto técnico

**Lenguaje/Versión**: OpenSCAD 2021.01

**Dependencias principales**: las mismas herramientas de `.tools/` que en la funcionalidad 001. Solo
se usan las siguientes:

| Herramienta | Lanzador | Uso |
|-------------|----------|-----|
| OpenSCAD 2021.01 | `.tools/bin/openscad` | Diseño, Customizer, exportación de STL, imagen del ensamblaje y `echo` de los derivados |
| Python 3 del sistema | `python3` | Medir las cajas envolventes de los STL |
| Laminador FDM (PrusaSlicer, Orca o Cura) | — (fuera del entorno) | Comprobar la imprimibilidad |

FreeCAD, Gmsh y CalculiX **no** se usan (R10).

**Componentes comprados** (restricciones del usuario):

- ESP32 DevKit, 2 × 28BYJ-48 con ULN2003, relé de 1 canal compatible con 3,3 V, láser 303 y power
  bank de 5 V y ≥ 2 A.
- 2 poleas GT2 20T de 5 mm y 2 correas GT2 cerradas de 200 × 6 mm.
- 4 rodamientos 608ZZ, pernos M8, tuerca 3/8"-16 y tornillería M3 ([data-model.md, Entidad 6](data-model.md#entidad-6-componentes-comprados-bom)).

**Almacenamiento**: archivos del repositorio (`.scad`, `.stl` y `.md`)

**Pruebas**: escenarios por línea de comandos en [quickstart.md](quickstart.md):

- `echo` de los derivados.
- Render de las 10 piezas con `--hardwarnings`.
- Cajas envolventes ≤ 200 × 200.
- Ensamblaje con `assert` de choque.
- Variantes con `-D`.
- Casos inválidos.
- Pruebas físicas F1–F10.

**Plataforma objetivo**:

- Desarrollo: Linux (WSL2), dentro del sandbox, con `.tools/bin/`.
- Fabricación: impresora FDM con boquilla de 0,4 mm y cama de 220 × 220 mm (piezas ≤ 200 × 200).
- Uso: exterior, de noche, con humedad.

**Tipo de proyecto**: generador paramétrico multipieza para manufactura aditiva (skill
`disenio-multipieza`)

**Objetivos de rendimiento**:

- Error de apuntado < 2° (objetivo ≤ 1°) y repetibilidad ≤ 0,3° (SC-003, SC-004).
- Resolución ≤ 0,05° por eje (FR-017): se diseña para 0,022°.
- Render CGAL de cada pieza en < 2 min con `$fn = 64`. Las poleas son las más pesadas por los
  dientes.

**Restricciones**:

- Cada pieza ≤ 200 × 200 mm en su orientación de impresión.
- Sin soportes, salvo como máximo una pieza indicada en la guía. Voladizos ≤ 45°.
- Paredes ≥ 1,2 mm.
- M3 unificado, salvo los ejes M8 y la tuerca 3/8"-16.
- Ningún cable cruza el eje de azimut.
- La altura cubre de −10° a 95° sin choques.

**Escala/Alcance**:

- 12 archivos `.scad`: parámetros, 9 piezas (el brazo con 2 variantes) y el ensamblaje.
- ~35 parámetros públicos y 14 reglas de validación.
- 10 STL (11 piezas físicas: el carro se imprime 2 veces).
- 1 guía de producción.

## Comprobación de la constitución

*PUERTA: debe superarse antes de la Fase 0 y volver a comprobarse tras el diseño de la Fase 1.*

### Principios

| Principio | Cómo lo cumple el plan | Estado |
|-----------|------------------------|--------|
| I. Diseño paramétrico en OpenSCAD | 12 archivos en `src/` con encabezado estándar y la sección `// --- PARÁMETROS Y CONSTANTES ---`. Los parámetros compartidos se declaran una sola vez en `puntero_laser_parametros.scad`, con grupos del Customizer. Los derivados y las constantes de componentes estándar van en `[Hidden]`, con nombre y sin números mágicos. Los módulos tienen nombres en español y `snake_case`. Cada pieza hace `include <puntero_laser_parametros.scad>` **dentro** de su sección `// --- PARÁMETROS Y CONSTANTES ---`, así que todas sus dimensiones y `$fn` quedan declarados en esa sección. Cada archivo tiene `ensamblaje_principal()` ([data-model.md](data-model.md)) | ✅ |
| II. Pipeline lineal de cuatro fases | Las tareas se agruparán en: 1) diseño (parámetros → piezas → ensamblaje), 2) simulación (**no aplica**, con justificación), 3) exportación de los 10 STL juntos y 4) guía `docs/puntero_laser_guia.md`. Ninguna fase empieza sin cerrar la anterior | ✅ |
| III. Simulación en FreeCAD | **No aplica**, con justificación explícita (ver abajo y [research.md R10](research.md)). Los esfuerzos son ≤ 1 MPa frente a ≥ 20 MPa del PETG entre capas (factor de seguridad > 20), y la flexión de los brazos produce < 0,06° de error. El requisito determinante es la rigidez para la precisión, y un cálculo cerrado alcanza para verificarla. Si `masa_laser_g` > 400 o `alto_brazo` > 160, la guía exige repetir el cálculo | ✅ (justificado) |
| IV. Diseño para manufactura aditiva | Cada pieza se modela en su orientación de impresión: brazos planos, cuna de pie, poleas con los dientes verticales, tapa con el techo sobre la cama. Las pestañas de las poleas llevan chaflán de 45° y los agujeros horizontales tienen forma de gota. Las holguras son parámetros. La `probeta_ajuste_608` calibra el ajuste a presión. Los 10 STL en `exports/` se regeneran juntos si cambia cualquier parámetro compartido | ✅ |
| V. Documentación de producción | Una sola guía, `docs/puntero_laser_guia.md`, con la plantilla B del perfil. **A)** Tabla de piezas con orientación, relleno, perímetros, soportes, adherencia y material. **B)** BOM con medidas exactas (Entidad 6) y orden de armado paso a paso, más el equilibrado, la colimación, el montaje en el trípode, los requisitos de firmware y la seguridad del láser | ✅ |

**Justificación de la falta de simulación (Principio III, Puerta 2)**:

Valores recalculados en T026 con la geometría final: brazo de 36 × **12** mm y 126,3 mm de largo,
E = 2000 MPa y σ admisible entre capas de 20 MPa.

| Caso | Carga | Resultado | Criterio |
|------|-------|-----------|----------|
| Brazo con golpe lateral | 5 N en la punta | σ = 0,73 MPa → factor de seguridad 27 | ≥ 10 ✅ |
| Brazo con carga axial (cuna, láser y tensión de la correa) | 15 N | δ = 0,002 mm | — ✅ |
| Brazo con carga lateral en un solo brazo | 1,5 N | δ = 0,097 mm → el eje de altura se inclina 0,089° | < 0,1° ✅ |
| Par de la correa de altura (plano de la correa a 41 mm del brazo) | 15 N × 41 mm | El eje se inclina 0,032°, constante (lo absorbe la alineación) | < 0,1° ✅ |
| Par del eje de altura (FR-024) | Desbalance de 10 mm / 20 mm | 23,5 / 47,1 mN·m frente a 122,4 disponibles → factor de seguridad 5,2 / 2,6 | ≥ 3 / ≥ 2 ✅ |
| Base y plataforma | 10 N estáticos | Despreciable | — ✅ |

El primer cálculo (brazo de 10 mm) dio 0,159° en el caso lateral. Supera el criterio de 0,1°, y por
eso, como indica T026, se volvió a la Fase 1 y se subió `espesor_brazo` a 12 mm.

**Condición de validez**: `masa_laser_g ≤ 400` y `alto_brazo ≤ 160`. Fuera de ese rango hay que
repetir este cálculo. Ninguna decisión de diseño cambiaría con una simulación FEM. El detalle está en
[research.md R10](research.md).

### Puertas de calidad

| Puerta | Verificación prevista | Estado |
|--------|-----------------------|--------|
| 1. Diseño | Escenarios 1, 2 y 4 del quickstart: los 12 `.scad` renderizan con `--hardwarnings` sin errores y el ensamblaje pasa los `assert` de choque | ✅ Cumplida (T020, T036): las 10 piezas y el ensamblaje con código 0 y 0 `WARNING`/`ERROR`, `Simple: yes`; render ≤ 16 s por pieza y 108 s el ensamblaje; intersecciones pieza a pieza vacías a −10°, 0°, 45°, 90° y 95°. Por la constitución v1.1.0, además: validación estricta (`--check-parameters=true --check-parameter-ranges=true`) sin avisos, caja envolvente medida y capturas PNG (isométrica, frente, lateral y superior) revisadas, generadas fuera del sandbox según `CLAUDE.md` |
| 2. Simulación | Justificación explícita de que no aplica en este plan y en research.md R10 | ✅ Cumplida (justificación registrada) |
| 3. Exportación | Escenarios 2 y 3: 10 STL en `exports/` regenerados con los valores por defecto, todos ≤ 200 × 200 | ✅ Cumplida (T027–T028): 10 STL; el mayor es la plataforma, de 194,3 × 165,9 mm; ninguno necesita soportes |
| 4. Documentación | Escenario 8: guía sin marcadores, con las secciones A y B completas | ✅ Cumplida (T035): `docs/puntero_laser_guia.md` sin marcadores, con las secciones 1 a 6 |

### Estructura del repositorio

Solo se escribe en `src/`, `exports/` y `docs/`, más los artefactos de Spec Kit en
`specs/002-puntero-laser-estelar/`. No se escribe en `simulation/` porque la simulación no aplica. No
se crea `tests/`. Todo está en español. ✅

**Resultado antes de la Fase 0**: SUPERADA. No hay violaciones.
**Resultado tras la Fase 1**: SUPERADA. El diseño (10 piezas, uniones U-01…U-12, reglas V-01…V-14)
no introduce desviaciones. Las puertas 1, 3 y 4 quedan como criterios de cierre de la
implementación.

## Estructura del proyecto

### Documentación (esta funcionalidad)

```text
specs/002-puntero-laser-estelar/
├── spec.md                        # Especificación (/speckit-specify)
├── plan.md                        # Este archivo (/speckit-plan)
├── research.md                    # Fase 0: decisiones R1–R14 y presupuesto de error
├── data-model.md                  # Fase 1: parámetros, derivados, validaciones, piezas, uniones y BOM
├── quickstart.md                  # Fase 1: escenarios de verificación ejecutables y pruebas físicas
├── contracts/
│   ├── interfaz_generador.md      # Fase 1: parámetros públicos, invocación, STL y errores
│   └── interfaz_firmware.md       # Fase 1: lo que la mecánica garantiza y lo que el firmware debe cumplir
├── checklists/
│   └── requirements.md            # Calidad de la especificación
└── tasks.md                       # Fase 2 (/speckit-tasks, NO lo crea /speckit-plan)
```

### Código fuente y entregables (raíz del repositorio)

```text
src/
├── puntero_laser_parametros.scad          # Compartido: parámetros, derivados, asserts, dentado_gt2()
├── puntero_laser_adaptador_tripode.scad   # Base fija + polea 80T de azimut + tuerca 3/8"
├── puntero_laser_plataforma_azimut.scad   # Plataforma giratoria (electrónica, carro de azimut)
├── puntero_laser_brazo_horquilla.scad     # lado = "motor" | "cable"
├── puntero_laser_cuna_laser.scad          # Tubo del láser con colimación y muñones
├── puntero_laser_polea_altitud.scad       # Polea 80T con cubo largo
├── puntero_laser_carro_motor.scad         # Carro tensor (×2)
├── puntero_laser_separador_azimut.scad    # Separador entre los aros interiores de los 608
├── puntero_laser_tapa_electronica.scad    # Tapa del lado −X
├── puntero_laser_probeta_ajuste_608.scad  # Calibración del ajuste a presión
└── puntero_laser_ensamblaje.scad          # Solo revisión (no se exporta)
exports/
└── puntero_laser_*.stl                    # 10 STL (los brazos en 2 variantes)
docs/
└── puntero_laser_guia.md                  # Guía única: impresión, BOM, armado, firmware y seguridad
```

**Decisión de estructura**: se sigue la sección 4 de la skill `disenio-multipieza`, con el prefijo
`puntero_laser` para no chocar con la funcionalidad 001. El brazo se genera con un solo archivo y el
parámetro `lado`, porque las dos variantes comparten el 90 % de la geometría. Igual se exportan 2 STL,
para cumplir con "un STL por pieza".

### Orden de modelado (para `/speckit-tasks`)

1. `puntero_laser_parametros.scad`: parámetros, derivados (incluida la bisección de
   `distancia_centros`), V-01…V-14 y `dentado_gt2()`.
2. `probeta_ajuste_608`: es la primera pieza física que se imprime.
3. `carro_motor` y `separador_azimut`: piezas simples que fijan las cotas del motor.
4. `adaptador_tripode` y `polea_altitud`: comparten el dentado GT2.
5. `cuna_laser`, que define `semiancho_interior_horquilla`.
6. `brazo_horquilla` (las 2 variantes).
7. `plataforma_azimut`: integra las zonas de R5 y las referencias de todo lo anterior.
8. `tapa_electronica`.
9. `ensamblaje`: posicionado, componentes comprados, láser en 3 ángulos y `assert` de choque.

## Riesgos y mitigaciones

| Riesgo | Mitigación |
|--------|------------|
| El ajuste del 608 en el plástico varía con la impresora y produce inclinación del eje (error que cambia con el azimut) | `probeta_ajuste_608` + parámetro `ajuste_608`. Rodamientos de azimut separados ≥ 30 mm y con precarga (R6) |
| Los dientes GT2 impresos salen mal y aparece juego o saltos de la correa | Parámetro `ajuste_diente_gt2`, 4 perímetros, revisión en el laminador (escenario 7). Repuesto barato: solo se reimprime la polea o la base |
| Las medidas reales del láser, el power bank o las placas difieren de las de referencia | Todo es parámetro con rango (FR-018). El quickstart incluye una variante. La guía pide medir antes de imprimir |
| El firmware no aplica la llegada unidireccional o la constante de pasos real, y se superan los 2° | Contrato de firmware con valores, regla de sobrepaso y pruebas de verificación (F5 y F6). La guía lo destaca |
| El eje del 28BYJ-48 es corto y la polea 20T queda con poca superficie de agarre | Assert V-10 (≥ 5 mm dentro del cubo). La plataforma tiene una abertura donde entra el cubo |
| El relé de 5 V no se apaga con la lógica de 3,3 V del ESP32 | La BOM exige un módulo compatible con 3,3 V. La guía explica cómo identificarlo |
| El power bank se apaga por bajo consumo | Se documentan alternativas (R11) |
| Seguridad del láser (aeronaves, vista) | Apagado automático, bloqueo por altura y advertencias (R12, FR-027) |
| Choque del láser al apuntar al cenit si se cambia el largo | `altura_eje` derivada del largo y del centro de masa, más V-07 en el ensamblaje |

## Seguimiento de la complejidad

Sin violaciones de la constitución: no aplica. La cantidad de piezas (10 archivos) está justificada
pieza por pieza en [research.md R2](research.md) con los motivos de la sección 2 de la skill
`disenio-multipieza`.
