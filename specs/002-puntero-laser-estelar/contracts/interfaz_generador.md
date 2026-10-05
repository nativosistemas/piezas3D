# Contrato: interfaz del generador `puntero_laser`

**Funcionalidad**: [../spec.md](../spec.md) | **Modelo de datos**: [../data-model.md](../data-model.md)

Este contrato define lo que el conjunto de archivos `.scad` le ofrece a quien lo usa, sea una persona
en la interfaz gráfica o un script de línea de comandos. Cualquier cambio incompatible DEBE reflejarse
aquí y en la guía de producción. Se consideran incompatibles estos cambios: renombrar o eliminar un
parámetro público, cambiar su unidad, cambiar la convención de ejes o cambiar el nombre de un STL.

## 1. Entrada

### 1.1 Archivos

| Archivo | Rol |
|---------|-----|
| `src/puntero_laser_parametros.scad` | **Único lugar** de los parámetros compartidos, los derivados, las reglas V-01…V-14 y los módulos utilitarios (`dentado_gt2`, `pestanas_polea`). No dibuja nada si se abre solo; imprime los derivados con `echo` |
| `src/puntero_laser_<pieza>.scad` | Una pieza por archivo, en su orientación de impresión. Hace `include <puntero_laser_parametros.scad>` |
| `src/puntero_laser_ensamblaje.scad` | Vista de conjunto con los componentes comprados y las comprobaciones de choque. No se exporta |

### 1.2 Parámetros públicos

Son los de la [Entidad 1](../data-model.md#entidad-1-parámetros-compartidos-editables). Se garantiza
lo siguiente:

- Los nombres son estables, en español y en `snake_case`. Las unidades están en mm, salvo `$fn`,
  `masa_laser_g` y los booleanos.
- Cada parámetro tiene una anotación de rango del Customizer y pertenece a uno de estos grupos:
  `Componentes comprados`, `Transmisión`, `Holguras`, `Estructura` y `Calidad`.
- Un parámetro se cambia **una vez** y afecta a todas las piezas: con `-D` sobre el archivo de la
  pieza (se propaga a través del `include`) o editando `_parametros.scad`.
- Lo que está bajo `/* [Hidden] */` no forma parte de la interfaz pública.
- Solo el brazo tiene un parámetro propio: `lado = "motor" | "cable"`.

### 1.3 Formas de invocación

| Modo | Invocación | Resultado |
|------|------------|-----------|
| Una pieza con los valores por defecto | `.tools/bin/openscad --hardwarnings -o exports/puntero_laser_<pieza>.stl src/puntero_laser_<pieza>.scad` | STL oficial |
| Brazo, variante de motor | `.tools/bin/openscad --hardwarnings -D 'lado="motor"' -o exports/puntero_laser_brazo_horquilla_motor.stl src/puntero_laser_brazo_horquilla.scad` | STL oficial |
| Brazo, variante de cable | `.tools/bin/openscad --hardwarnings -D 'lado="cable"' -o exports/puntero_laser_brazo_horquilla_cable.stl src/puntero_laser_brazo_horquilla.scad` | STL oficial |
| Variante personalizada | Igual que las anteriores, con `-D diametro_laser=26 -D largo_laser=240 …` y **los mismos `-D` en todas las piezas** | STL personalizados |
| Comprobación del conjunto | `.tools/bin/openscad --hardwarnings -o "$TMPDIR/ensamblaje.png" --imgsize=1600,1200 --viewall --autocenter src/puntero_laser_ensamblaje.scad` | Imagen de revisión. Si un `assert` de choque falla, termina con error |
| Valores para el firmware | `.tools/bin/openscad -o "$TMPDIR/p.echo" src/puntero_laser_parametros.scad` | Archivo `echo` con `pasos_por_grado`, `distancia_centros`, `altura_eje` y el presupuesto de error |

## 2. Salida

### 2.1 Éxito

- Malla cerrada, sin advertencias con `--hardwarnings`.
- Cada pieza viene **en su orientación de impresión**: apoyada en Z = 0 y centrada en X = Y = 0.
  Su caja envolvente es ≤ 200 × 200 mm en XY.
- Convención de ejes del ensamblaje (la de [research.md](../research.md)):
  - El origen está en la cara de apoyo de la base sobre el trípode.
  - Z es vertical, y el eje de azimut coincide con Z.
  - El eje de altura es paralelo a X.
  - A 0° de altura el láser apunta hacia +Y.
  - Los motores están en +X y la electrónica en −X.
- STL oficiales, siempre generados con los valores por defecto documentados en la guía:

  | Pieza | STL | Cant. a imprimir |
  |-------|-----|------------------|
  | Adaptador del trípode | `exports/puntero_laser_adaptador_tripode.stl` | 1 |
  | Plataforma de azimut | `exports/puntero_laser_plataforma_azimut.stl` | 1 |
  | Brazo de la horquilla (motor) | `exports/puntero_laser_brazo_horquilla_motor.stl` | 1 |
  | Brazo de la horquilla (cable) | `exports/puntero_laser_brazo_horquilla_cable.stl` | 1 |
  | Cuna del láser | `exports/puntero_laser_cuna_laser.stl` | 1 |
  | Polea de altura | `exports/puntero_laser_polea_altitud.stl` | 1 |
  | Carro del motor | `exports/puntero_laser_carro_motor.stl` | 2 |
  | Separador de azimut | `exports/puntero_laser_separador_azimut.stl` | 1 |
  | Tapa de la electrónica | `exports/puntero_laser_tapa_electronica.stl` | 1 |
  | Probeta de ajuste del 608 | `exports/puntero_laser_probeta_ajuste_608.stl` | 1 (opcional, se imprime primero) |

### 2.2 Error (parámetros inválidos o choque)

- La generación se detiene y no se escribe la malla.
- El error tiene este formato:
  `ERROR: Assertion '<condición>' failed: "<parámetro>=<valor>: <explicación y límite>"`.
- Cada regla V-01…V-14 tiene su mensaje, que empieza por el parámetro principal implicado. Ejemplo:
  `"powerbank_ancho=80: no entra en la zona −X (máx. 75); reduzca el ancho o use un power bank más
  delgado"`.
- Las reglas de choque (V-07 y V-08) se evalúan en el ensamblaje y también en la pieza que define la
  zona, para que también fallen al exportar esa pieza.

## 3. Artefactos asociados (rutas fijas)

| Artefacto | Ruta |
|-----------|------|
| Parámetros compartidos | `src/puntero_laser_parametros.scad` |
| Fuentes de las piezas | `src/puntero_laser_<pieza>.scad` (9 archivos) |
| Ensamblaje | `src/puntero_laser_ensamblaje.scad` |
| Justificación de la falta de simulación | [plan.md](../plan.md) (Constitución, Principio III) y [research.md R10](../research.md) |
| Mallas de manufactura | `exports/puntero_laser_*.stl` (10 archivos) |
| Guía de producción | `docs/puntero_laser_guia.md` |
| Requisitos de firmware | [interfaz_firmware.md](interfaz_firmware.md), copiados en la guía |
