# Plan de implementación: Visor 3D de armado paso a paso

**Rama**: `005-visor-armado-3d` | **Fecha**: 2026-10-08 | **Especificación**: [spec.md](spec.md)

**Entrada**: especificación de la funcionalidad en `specs/005-visor-armado-3d/spec.md`

## Resumen

Cada diseño de varias piezas tendrá, junto a su web de armado, una página `armado_3d.html` con el
armado en 3D: las piezas de cada paso se deslizan desde la vista explotada hasta su lugar, lo ya
armado se ve transparente y se puede girar, acercar, avanzar, repetir y recorrer el movimiento.

Enfoque, validado con un prototipo sobre el puntero láser ([research.md](research.md)):

- **Una sola fuente**: la tabla de pasos y el catálogo de elementos del ensamblaje, los mismos que
  generan las capturas PNG. La maquinaria común de las vistas explotadas pasa a una biblioteca,
  `src/armado_comun.scad`, que además entrega los datos del visor (incluido el contexto de cada
  paso según los subconjuntos). Así visor y capturas no pueden contradecirse (R5).
- **Generación**: `scripts/generar_visor.py` exporta cada elemento con OpenSCAD a resolución reducida,
  lee los textos de la guía y escribe un HTML autocontenido. `scripts/generar_web.py` lo llama y
  enlaza el visor desde la web (R1, R8).
- **Sin internet**: three.js r160 copiado en el repositorio e incrustado con un *import map* de URL
  `data:`. Probado sin red: el puntero láser completo pesa 2,9 MB (R4).
- **Caché por huella**: si las fuentes no cambiaron, se reutilizan las mallas de la página existente;
  `--comprobar` detecta un visor desactualizado sin ejecutar OpenSCAD (R2).
- **Giros** declarados de forma opcional en la tabla de pasos, primer uso en la polea de altura (R7).
- **Constitución 2.1.0**: el visor pasa a ser obligatorio para los diseños con ensamblaje (R10).

## Contexto técnico

**Lenguaje/Versión**: Python 3 (biblioteca estándar), OpenSCAD 2021.01, HTML + CSS + JavaScript
(módulos ES) para la página.

**Dependencias principales**:

| Dependencia | Uso | Dónde |
|---|---|---|
| OpenSCAD 2021.01 | Exportar cada elemento y los datos de los pasos | `.tools/bin/openscad` (funciona en el sandbox) |
| three.js 0.160.0 (MIT) | Motor 3D y control de órbita en la página | `scripts/vendor/three-0.160.0/` (copia fija) |
| Edge de Windows | Revisión sin ventana (fuera del sandbox) | `/mnt/c/Program Files (x86)/Microsoft/Edge/…` |

**Almacenamiento**: archivos del repositorio. El visor generado (`specs/<NNN>/web/armado_3d.html`) se
versiona, igual que `index.html` y las capturas.

**Pruebas**: los escenarios de [quickstart.md](quickstart.md):

- `--comprobar` (puerta 5) y las validaciones del generador (data-model, sección 2);
- los `assert` de `armado_comun.scad` y de cada ensamblaje (validación estricta con el hook);
- capturas del visor en momentos fijos con `?paso=N&t=…`, comparadas con las PNG de la guía.

El proyecto no tiene un marco de pruebas unitarias y esta funcionalidad no lo justifica.

**Plataforma**: navegadores actuales de computadora (Edge, Chrome, Firefox) y de celular (Chrome en
Android, Safari en iOS), abriendo el archivo local.

**Tipo de proyecto**: herramienta del pipeline (scripts + biblioteca OpenSCAD + plantilla HTML).

**Objetivos de rendimiento**: primer paso visible en < 5 s en computadora y < 10 s en celular
(SC-004); animación continua; regenerar sin cambios de fuentes en pocos segundos (R2).

**Restricciones**: sin internet ni servidor (FR-018); ≤ 10 MB por diseño (FR-005); `generar_web.py`
sigue usando solo la biblioteca estándar; las STL de impresión no cambian.

**Escala**: 2 diseños con ensamblaje hoy (puntero láser: 18 pasos y 43 elementos; caja de pilas: 3
pasos y 3 elementos); el formato debe aguantar diseños futuros parecidos.

## Verificación de la constitución

*Puerta: se cumple antes de la investigación y se vuelve a revisar después del diseño.*

| Principio / puerta | Cómo se cumple | Estado |
|---|---|---|
| I. Diseño paramétrico | `armado_comun.scad` lleva encabezado, sección de parámetros, `eps`, módulos nombrados en español y `assert` con mensaje; las proporciones de la flecha salen de `diametro_flecha`. Los ensamblajes siguen siendo de revisión: ninguna pieza imprimible cambia | ✅ |
| II. Pipeline de cinco fases | Las tareas se agrupan en las cinco fases: 1) cambios en `.scad` (biblioteca y ensamblajes); 2) simulación: no aplica; 3) exportación: verificar que las STL no cambian; 4) documentación: skills y capturas regeneradas; 5) visor, web y constitución | ✅ |
| III. Simulación | **No aplica**: la funcionalidad no cambia ninguna pieza ni carga | ✅ (justificado) |
| IV. Manufactura aditiva | La resolución reducida (`$fn = 32`) es solo para el visor; las STL siguen con `$fn = 64`. La fase 3 comprueba que las STL no cambian de geometría | ✅ |
| V. Documentación y web | El visor se genera desde la guía y el ensamblaje (no a mano). Las capturas PNG se mantienen. Se agrega el visor como requisito (enmienda 2.1.0) | ✅ con enmienda |
| Gobernanza: un solo lugar por regla | La maquinaria de vistas explotadas deja de estar copiada en cada ensamblaje (`armado_comun.scad`). La convención se documenta en la skill `disenio-multipieza` y la revisión del visor en `web-armado`; la constitución solo exige el resultado | ✅ |
| Puerta 1 (diseño) | `verificar_pieza.sh --rapido` sobre la biblioteca y los ensamblajes; capturas de armado regeneradas y revisadas | ✅ planificado |
| Puerta 3 (exportación) | Comparar las STL regeneradas por vértices ordenados (como el 2026-10-07): misma geometría | ✅ planificado |
| Puerta 5 (web) | `generar_web.py --comprobar` cubre el visor; el visor se revisa en el navegador | ✅ planificado |

**Revisión después del diseño (fase 1)**: sin violaciones nuevas. La enmienda de la constitución es
parte del alcance (FR-023) y se hace con `/speckit-constitution`, no editando el archivo a mano.

## Estructura del proyecto

### Documentación (esta funcionalidad)

```text
specs/005-visor-armado-3d/
├── spec.md
├── plan.md               # este archivo
├── research.md           # fase 0
├── data-model.md         # fase 1
├── quickstart.md         # fase 1
├── contracts/
│   ├── ensamblaje.md     # convención del ensamblaje y salida de datos
│   ├── scripts.md        # generar_visor.py y cambios en generar_web.py
│   └── visor.md          # página, direcciones, controles y datos incrustados
├── checklists/requirements.md
└── tasks.md              # fase 2 (/speckit-tasks)
```

### Código y datos (raíz del repositorio)

```text
src/
├── armado_comun.scad                 # NUEVO: vistas explotadas, contexto, datos del visor, armado()
├── puntero_laser_ensamblaje.scad     # usa armado_comun; giro de la polea en el paso 7
└── caja_pilas_ensamblaje.scad        # usa armado_comun; grupo único (de la funcionalidad 004)

scripts/
├── generar_visor.py                  # NUEVO: exporta elementos, huella, valida y escribe el visor
├── plantilla_visor.html              # NUEVO: página del visor (sin datos)
├── vendor/three-0.160.0/             # NUEVO: three.module.min.js, OrbitControls.js, LICENSE
├── generar_web.py                    # llama al visor, enlaces "Ver en 3D", --comprobar
└── capturas_armado.sh                # sin cambios

specs/002-puntero-laser-estelar/web/armado_3d.html    # generado
specs/004-caja-pilas-aa/web/armado_3d.html            # generado

.claude/skills/disenio-multipieza/SKILL.md   # convención: armado_comun, grupo, diametro_flecha, giro
.claude/skills/web-armado/SKILL.md           # generar y revisar el visor
.specify/memory/constitution.md              # 2.1.0 vía /speckit-constitution
CLAUDE.md                                    # mapa: armado_3d.html y generar_visor.py
```

**Decisión de estructura**: la plantilla del visor es un archivo propio en `scripts/` (no un texto
dentro del script, como la de la web) porque tiene ~300 líneas de JavaScript que conviene leer y
revisar como HTML. El prototipo de `.tools/tmp/visor_3d/` es el punto de partida y se descarta al
terminar.

## Seguimiento de complejidad

| Agregado | Por qué hace falta | Alternativa más simple descartada porque |
|---|---|---|
| Copia de three.js en el repositorio (~700 KB) | Funcionar sin internet (FR-018) | El CDN exige conexión; empaquetar con esbuild suma Node al pipeline (R4) |
| Biblioteca `armado_comun.scad` y cambio de los dos ensamblajes | Visor y capturas con el mismo contexto (SC-002) y sin código copiado por diseño | Reimplementar los grupos en JavaScript crea dos fuentes que se desincronizan (R5) |
| Huella y reutilización de mallas | Regenerar la web no debe costar un minuto ni ensuciar el diff con STL no deterministas | Una caché fuera del repositorio no sirve para `--comprobar` en un clon nuevo (R2) |

## Dependencias y orden

1. **Antes de implementar**: hacer commit de la funcionalidad 004 (caja de pilas) en su rama y
   traerla a esta, porque se modifica su ensamblaje ([R11](research.md#r11-dependencia-con-la-funcionalidad-004)).
2. `armado_comun.scad` y la migración de los dos ensamblajes, con las capturas PNG regeneradas y
   comparadas (deben quedar iguales salvo el orden de dibujo de la caja, que pasa a ser opaco primero).
3. `generar_visor.py` + plantilla + three.js; después la integración con `generar_web.py`.
4. Giros (historia 3).
5. Skills, `CLAUDE.md` y enmienda de la constitución.
