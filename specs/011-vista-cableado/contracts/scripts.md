# Contrato: cambios en los scripts

Amplía los contratos de la [005](../../005-visor-armado-3d/contracts/scripts.md), la
[007](../../007-simulacion-funcionamiento/contracts/scripts.md) y la
[008](../../008-identificacion-componentes/contracts/scripts.md). La línea de comandos no cambia.

## `scripts/generar_visor.py`

- Lee las líneas `CABLE;…` y las listas del cableado ([ensamblaje.md](ensamblaje.md)) de la misma
  salida de datos (`paso_armado=-1`). No exporta mallas para los cables: copia sus puntos, redondeados
  a 0,1 mm.
- Si hay cables:
  - Lee la **Tabla de cables** de la guía ([guia.md](guia.md)) y compara sus pares (desde, hasta) con
    los del ensamblaje (C-05). Falla nombrando cada diferencia, primero las de la guía.
  - Agrega `datos.cableado` ([../data-model.md](../data-model.md#3-en-el-visor)) y exporta también
    las mallas de los elementos que referencian los cables y de los de `transparentes`. C-06 va en
    `validar()`.
  - Con mallas reutilizadas, toma el cableado de la página actual (los dos salen de las mismas
    fuentes).
- `VERSION = 4`. Un visor de versión 3 queda desactualizado: `--comprobar` falla y `generar_web.py` lo
  vuelve a exportar.
- La huella no cambia: la comparación con la guía se hace cada vez que se genera o se comprueba el
  visor, así que cambiar la Tabla de cables no reexporta mallas pero sí hace fallar `--comprobar` si
  ya no coincide con el ensamblaje.
- El resumen suma la cantidad de cables:
  `✓ Visor 3D: … (3.9 MB, 51 piezas con nombres, 2 articulaciones, 26 cables, mallas exportadas)`.

## `scripts/generar_web.py`

- Si los datos del visor tienen `cableado`, la lista de pasos suma, después de «Ver cómo funciona»:
  `<a class="boton-3d" href="armado_3d.html#cableado">Ver el cableado</a> Cada cable de pin a pin, con
  sus conectores.`
- Nada más cambia.

## `scripts/capturas_armado.sh`

Sin cambios. Las vistas de los pasos no muestran cables (`ver_cables` es `false` por defecto).
