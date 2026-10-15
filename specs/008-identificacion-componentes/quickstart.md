# Validación: Identificación de componentes en el visor 3D

Escenarios de punta a punta. Los comandos se corren desde la raíz del repositorio. Contratos:
[ensamblaje](contracts/ensamblaje.md), [scripts](contracts/scripts.md) y [visor](contracts/visor.md).
Las abreviaturas `edge` y `captura` son las de la
[validación de la 007](../007-simulacion-funcionamiento/quickstart.md#requisitos-previos) (fuera del
sandbox).

## 1. Nada cambia en las piezas (FR-003, puerta 3)

```bash
scripts/verificar_pieza.sh --rapido src/armado_comun.scad
scripts/verificar_pieza.sh --rapido src/puntero_laser_ensamblaje.scad
scripts/verificar_pieza.sh --rapido src/caja_pilas_ensamblaje.scad
git status --short exports docs/img
```

**Esperado**: sin errores ni avisos; `exports` y `docs/img` sin cambios.

## 2. Declaraciones inválidas fallan (FR-002)

Con una copia del ensamblaje de la caja de pilas en `.tools/tmp/` (en el mismo `src/` para que
resuelva los `include`, o con `-D` sobre el original), probar por separado:

```bash
.tools/bin/openscad --hardwarnings -o .tools/tmp/x.csg -D 'paso_armado=-1' \
  -D 'nombres_elementos=[["caja","Caja","impresa"],["tapa","Tapa","impresa"]]' src/caja_pilas_ensamblaje.scad
```

**Esperado**: falla con `falta el nombre de 'pilas'`. Igual con un elemento inventado
(`elemento desconocido`), uno repetido, un nombre vacío y `"tipo"` = `"otro"`.

## 3. Los visores salen con nombres (FR-012, FR-013, SC-001)

```bash
scripts/generar_web.py caja_pilas specs/004-caja-pilas-aa
scripts/generar_web.py puntero_laser specs/002-puntero-laser-estelar
scripts/generar_web.py --comprobar caja_pilas specs/004-caja-pilas-aa
scripts/generar_web.py --comprobar puntero_laser specs/002-puntero-laser-estelar
```

**Esperado**: `✓ Visor 3D: … piezas con nombres …` y las comprobaciones sin errores. Cada nombre
de lo comprado se encuentra en `docs/<diseño>_bom.csv` (revisión a ojo, SC-002).

## 4. Sin nombres, igual que antes (FR-003, SC-005)

Generar el visor de la caja de pilas con la lista comentada (en una copia de trabajo, sin commit):
la página no muestra marcas de tipo y la lista dice "caja", "pilas", "tapa".

## 5. Lista del paso y selección en el navegador (historias 1–3, SC-003, SC-004)

```bash
captura paso5 '?paso=5&t=1&senalar=perno_az'
captura sim '?modo=funcionamiento&altura=45&azimut=30&senalar=polea20_alt'
```

**Esperado**: en las capturas, la lista del paso con marcas de tipo y nombres legibles; la pieza
resaltada y su etiqueta. Después, en Edge con ventana:

- Pasar el puntero por diez piezas al azar (incluida tornillería) en Funcionamiento con el modo
  automático andando: la etiqueta nombra bien cada una y aparece sin demora (SC-003, SC-004).
- En un paso con contexto atenuado, señalar una pieza nueva a través del contexto: se identifica la
  nueva.
- Arrastrar para girar: no queda nada resaltado.
- Pasar el puntero por los renglones de la lista: se resalta cada pieza.
- Con la emulación táctil (F12 → dispositivo), tocar una pieza y luego el fondo.
