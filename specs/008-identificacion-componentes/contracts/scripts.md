# Contrato: cambios en los scripts

Amplía los contratos de la [005](../../005-visor-armado-3d/contracts/scripts.md) y la
[007](../../007-simulacion-funcionamiento/contracts/scripts.md). La línea de comandos no cambia.

## `scripts/generar_visor.py`

- Lee las líneas `ECHO: "NOMBRE;<elemento>;<tipo>;<nombre>"` de la salida de datos del ensamblaje.
- Si hay alguna, agrega `nombre` y `tipo` a cada elemento exportado; si no, no agrega nada.
- Al validar: si los datos traen nombres, cada elemento DEBE tener `nombre` no vacío y `tipo`
  `impresa` o `comprada` (segunda barrera; la primera son los `assert`).
- `VERSION = 3`. Un visor de versión 2 queda desactualizado: `--comprobar` falla y `generar_web.py`
  lo vuelve a exportar.
- El resumen de la salida suma `con nombres` cuando los hay:
  `✓ Visor 3D: … (4.1 MB, 49 piezas con nombres, 2 articulaciones, mallas exportadas)`.

## `scripts/generar_web.py`

Sin cambios.
