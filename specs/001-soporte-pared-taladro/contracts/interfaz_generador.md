# Contrato: interfaz del generador `soporte_pared_taladro`

**Funcionalidad**: [../spec.md](../spec.md) | **Modelo de datos**: [../data-model.md](../data-model.md)

Este contrato define lo que el generador expone a quien lo usa, ya sea una persona en la interfaz
gráfica o un script de línea de comandos. Cualquier cambio incompatible (renombrar o eliminar un
parámetro, cambiar su unidad o la convención de ejes) DEBE reflejarse aquí y en la guía de producción.

## 1. Entrada

**Archivo**: `src/soporte_pared_taladro.scad`

### 1.1 Parámetros públicos

Son los nombres, valores por defecto y rangos de la
[Entidad 1 del modelo de datos](../data-model.md#entidad-1-conjunto-de-parámetros-del-soporte-editables).
Se garantiza lo siguiente:

- Los nombres son estables, en español y en `snake_case`.
- Las unidades están en milímetros (salvo `$fn`).
- Cada parámetro tiene una anotación de rango del Customizer (`// [mín:paso:máx]`) y pertenece a uno
  de estos grupos: `Dimensiones principales`, `Taladro`, `Estructura`, `Detalles` y `Calidad`.
- Lo que está bajo `/* [Hidden] */` **no** forma parte de la interfaz pública y puede cambiar.

### 1.2 Formas de invocación

| Modo | Invocación | Resultado |
|------|------------|-----------|
| Interfaz gráfica | Abrir el `.scad` en OpenSCAD → panel *Customizer* → ajustar → F6 → *Export STL* | Malla en la ruta elegida |
| Línea de comandos (valores por defecto) | `.tools/bin/openscad --hardwarnings -o exports/soporte_pared_taladro.stl src/soporte_pared_taladro.scad` | STL por defecto |
| Línea de comandos (personalizada) | `.tools/bin/openscad --hardwarnings -D ancho=100 -D profundidad=130 -o <salida>.stl src/soporte_pared_taladro.scad` | STL personalizado |
| Exportación para simulación | `.tools/bin/openscad -o simulation/soporte_pared_taladro.csg src/soporte_pared_taladro.scad` | Árbol CSG importable en FreeCAD |

## 2. Salida

### 2.1 Éxito

- Malla cerrada (*manifold*) sin advertencias de geometría (con `--hardwarnings` no hay ninguna).
- Sistema de coordenadas: origen en la esquina inferior trasera izquierda. La pared está en el
  plano Y = 0 y la cara inferior de la bandeja en Z = 0. Esta orientación es también la orientación de
  impresión.
- La caja envolvente es `[0, ancho] × [0, profundidad] × [0, altura_placa]` con una tolerancia de
  ±0,1 mm.
- La ranura está centrada en X = `ancho / 2`.
- Entregable oficial: `exports/soporte_pared_taladro.stl`, generado **siempre con los valores por
  defecto** documentados en la guía de producción.

### 2.2 Error (parámetros inválidos)

- La generación se detiene y no se escribe la malla de salida.
- El error tiene este formato:
  `ERROR: Assertion '<condición>' failed: "<parámetro>=<valor>: <explicación y límite>"`.
- Cada regla V-01…V-10 del [modelo de datos](../data-model.md#reglas-de-validación) tiene su propio
  mensaje, que empieza por el nombre del parámetro principal implicado. Ejemplo:
  `"ancho_ranura=60: deja carriles de 10 mm; con espesor=6 se necesitan al menos 12 mm (reduzca
  ancho_ranura o aumente ancho)"`.

## 3. Artefactos asociados (rutas fijas)

| Artefacto | Ruta |
|-----------|------|
| Fuente paramétrica | `src/soporte_pared_taladro.scad` |
| Exportación para FreeCAD | `simulation/soporte_pared_taladro.csg` |
| Guía de simulación y resultados | `simulation/soporte_pared_taladro_fem.md` |
| Script de simulación (para `.tools/bin/freecadcmd`) | `simulation/soporte_pared_taladro_fem.py` |
| Proyecto de simulación (lo genera el script) | `simulation/soporte_pared_taladro.FCStd` |
| Malla de manufactura | `exports/soporte_pared_taladro.stl` |
| Guía de producción | `docs/soporte_pared_taladro_guia.md` |
