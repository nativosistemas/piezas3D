# Investigación: Visor 3D de armado paso a paso

**Funcionalidad**: [spec.md](spec.md) · **Fecha**: 2026-10-08

Mediciones hechas con el prototipo de `.tools/tmp/visor_3d/` sobre el puntero láser (rama
`005-visor-armado-3d`, OpenSCAD 2021.01, Edge de Windows sin ventana).

## R1. Quién genera el visor y cuándo

**Decisión**: un script nuevo, `scripts/generar_visor.py <diseño> <carpeta_spec> [--comprobar]`,
escribe `specs/<NNN>/web/armado_3d.html`. `scripts/generar_web.py` lo llama solo cuando existe
`src/<diseño>_ensamblaje.scad`, y su `--comprobar` también llama al del visor. Así, la web y el
visor salen con un solo comando (FR-001, SC-001).

**Motivo**: el visor necesita OpenSCAD para exportar las piezas; la web no, y hoy `generar_web.py`
solo usa la biblioteca estándar de Python. Separarlo mantiene cada script con una responsabilidad y
permite regenerar solo el visor. Exportar el STL funciona dentro del sandbox (no necesita el display
de WSLg, a diferencia de las capturas PNG).

**Alternativas descartadas**:
- Todo dentro de `generar_web.py`: mezcla la conversión de Markdown con la exportación 3D y lo hace
  depender de OpenSCAD aunque el diseño sea de una sola pieza.
- Un paso aparte que se corre a mano (como `capturas_armado.sh`): contradice FR-001 y se olvida.

## R2. Tiempo de exportación y caché por huella

**Medición**: el puntero láser completo (18 pasos, 43 elementos) tarda **59 s** en exportarse con
`$fn = 32`.

**Decisión**: el visor guarda una **huella** (SHA-256) de sus fuentes: `src/<diseño>_*.scad`,
`src/armado_comun.scad`, `src/perfil_impresora.scad` y la resolución del visor. Al regenerar, si la
huella coincide con la de la página existente, reutiliza las mallas incrustadas en esa página en vez
de volver a exportar; los textos de la guía se leen siempre. Sin carpeta de caché aparte.

`--comprobar` no necesita OpenSCAD: recalcula la huella, la compara con la de la página y reconstruye
la página con las mallas que ya tiene y la guía actual; si algo difiere, falla (FR-007, SC-006).

**Motivo**: regenerar la web cuando cambia solo un precio no debe costar un minuto. Además, OpenSCAD
2021 no exporta los STL de forma determinista (el orden de las caras cambia entre corridas con la
misma geometría, visto el 2026-10-07), así que reexportar sin necesidad ensuciaría el diff.

**Alternativas descartadas**:
- Caché en `.tools/` (ignorada por git): en un clon nuevo `--comprobar` no tendría con qué comparar.
- Guardar las mallas en un JSON versionado además de la página: duplica megas en el repositorio.

## R3. Formato de las mallas

**Decisión**: por elemento, las coordenadas de los triángulos en `Float32` little-endian, sin índices
ni normales, codificadas en base64 dentro de un JSON en la página. El visor calcula las normales
(sombreado plano, aspecto de pieza CAD). Exportación con `-D '$fn=32'` (FR-006); los STL de impresión
siguen con `$fn = 64`. Los elementos con `$fn` propio (dentados GT2) no cambian.

**Medición**: 43 elementos, 2,0 MB de mallas en el prototipo (STL binario con normales: 50 bytes por
triángulo). Sin las normales del STL, ~1,5 MB.

**Alternativas descartadas**: STL binario con el cargador de three.js (agrega bytes y un módulo más);
cuantizar a `Int16` (ahorra ~50 %, innecesario con este margen); GLB (OpenSCAD 2021 no lo exporta y
haría falta una herramienta externa).

## R4. Motor 3D sin internet

**Decisión**: three.js **r160** (0.160.0, licencia MIT) copiado en `scripts/vendor/three-0.160.0/`
(`three.module.min.js`, `OrbitControls.js` y `LICENSE`). El generador lo incrusta en la página con
un *import map* cuyas entradas son URL `data:` en base64; el código del visor importa `three` y
`OrbitControls` como siempre.

**Verificación (2026-10-08)**: el visor completo del puntero láser (18 pasos) abierto como archivo
local en Edge con la resolución de nombres bloqueada (`--host-resolver-rules="MAP * ~NOTFOUND"`)
funciona y pesa **2,9 MB** en total.

**Motivo**: FR-018 pide funcionar sin conexión. Una página `file://` no puede leer otros archivos con
`fetch` ni importar módulos de la misma carpeta en Edge y Chrome, así que todo va dentro del HTML.

**Alternativas descartadas**:
- CDN (como el prototipo): no funciona sin internet.
- Empaquetar con esbuild: agrega Node al pipeline; el *import map* con `data:` resuelve lo mismo sin
  herramientas.
- Escribir un control de órbita propio: más código propio y peor manejo táctil.

## R5. Lo que el visor necesita de cada ensamblaje (y una biblioteca común)

**Hallazgo**: el prototipo dibujaba en el paso 11 el carro del motor de altura, que se monta en el
13: los subconjuntos solo los conoce la función `grupo(e, n)` del ensamblaje. Además,
`puntero_laser_ensamblaje.scad` y `caja_pilas_ensamblaje.scad` repiten la misma maquinaria
(`vista_paso`, `flecha`, `contiene`, `unicos`) con pequeñas diferencias: la caja no tiene grupos ni
origen y dibuja lo transparente antes que lo opaco.

**Decisión**: nueva biblioteca `src/armado_comun.scad`, que cada ensamblaje incluye con `include`.
Contiene la vista explotada genérica (con origen, grupos y lo opaco primero), la flecha, las
utilidades de listas, `contexto_paso(n)` (lo armado que se ve en el paso n, la misma función que usa
la vista explotada) y la salida de datos para el visor. El ensamblaje de cada diseño define solo lo
propio: `pasos`, `elementos`, `color_elemento(e)`, `elemento(e)`, `anclas(e)`, `grupo(e, n)` y
`diametro_flecha`. El contrato está en [contracts/ensamblaje.md](contracts/ensamblaje.md).

**Motivo**: SC-002 exige que visor y capturas coincidan en el 100 % de los pasos; eso se garantiza si
los dos salen de la misma función. Y la regla de "cada cosa en un solo lugar" de la constitución
aplica también al código repetido.

**Alternativas descartadas**: que el visor reimplemente los grupos en JavaScript (dos fuentes que se
desincronizan); exportar un `GRUPO;n;e` por elemento y paso (más datos y la lógica de contexto
duplicada igual).

## R6. Datos de los pasos: de OpenSCAD a JSON

**Decisión**: con `paso_armado = -1`, el ensamblaje emite además de las líneas `PASO;n;k` (que usa
`capturas_armado.sh`) las líneas `PASOS;…`, `COLOR;e;nombre` y `CONTEXTO;n;[…]`. Los vectores de
OpenSCAD se leen como JSON reemplazando `undef` por `null`.

**Verificación**: `json.loads` lee la tabla de pasos del puntero láser tal como la imprime `echo`
(incluidos los vectores calculados como `-130*v_laser`).

## R7. Giros (historia 3)

**Decisión**: quinto campo opcional de cada entrada de la tabla: `[punto, eje, grados]`, un punto del
eje en la posición final, la dirección del eje y el ángulo total. La pieza arranca girada `grados` y
llega a 0 junto con el desplazamiento. Para usarlo sin origen, el cuarto campo es `undef`. La vista
explotada lo ignora (FR-022). Primer uso: la polea de altura del puntero láser (paso 7, dos vueltas).

**Alternativas descartadas**: un campo con nombre (OpenSCAD no tiene diccionarios); giros como
elementos aparte (rompe la correspondencia elemento-pieza).

## R8. Página aparte, enlaces y revisión

**Decisión**:
- El visor es `specs/<NNN>/web/armado_3d.html`. La web enlaza a él al principio de las instrucciones
  ("Ver el armado en 3D") y desde cada paso ("Ver en 3D"), con `armado_3d.html#paso-N`.
- El visor abre en el paso del fragmento `#paso-N`. Para revisar sin interacción, `?paso=N&t=0.5`
  congela ese momento, como en el prototipo.
- Si el navegador no puede crear el contexto 3D, muestra un mensaje y un enlace a la web (FR-021).
- La revisión visual usa el Edge sin ventana con SwiftShader (`--use-angle=swiftshader
  --enable-unsafe-swiftshader`), fuera del sandbox, igual que la revisión de la web.

## R9. Tamaño máximo

**Decisión**: el generador informa el tamaño y falla por encima de **10 MB**, listando los cinco
elementos más pesados (FR-005). Referencia: puntero láser completo, 2,9 MB.

## R10. Enmienda de la constitución

**Decisión**: versión **2.1.0** (MENOR: se agrega un requisito). En el Principio V, todo diseño de
varias piezas con ensamblaje DEBE tener visor 3D generado desde el ensamblaje; en la puerta 5,
`--comprobar` cubre el visor y el visor se revisa en un navegador. Se hace con `/speckit-constitution`,
como manda la Gobernanza.

## R11. Dependencia con la funcionalidad 004

La caja de pilas (004) todavía no tiene commit: sus archivos están sin seguimiento en la carpeta de
trabajo. Esta funcionalidad modifica `src/caja_pilas_ensamblaje.scad` (biblioteca común y datos del
visor) y la usa para SC-001. Antes de implementar hay que hacer commit de la 004 en su rama y traerla
a esta (merge), para que los cambios de la 005 queden separados.
