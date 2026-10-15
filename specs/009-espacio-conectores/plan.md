# Plan de implementación: Espacio para conectores y cableado del puntero láser

**Rama**: `009-espacio-conectores` | **Fecha**: 2026-10-15 | **Especificación**: [spec.md](spec.md)

**Entrada**: especificación de la funcionalidad en `specs/009-espacio-conectores/spec.md`

## Resumen

La electrónica del puntero láser se dimensionó sin el espacio de los conectores. Con Dupont rectos
(aclaración de la especificación), los del ESP32 tocarían la plataforma y la tapa quedaría justa. Se
agregan parámetros de conectores y cables, volúmenes que reservan su espacio y comprobaciones de
choque y de largo de cable. De ellos salen la elevación del ESP32 (15 → 23,9 mm) y la altura de la tapa
(27,6 → 33,5 mm, dentro del límite de 34,34 mm que impone el carro del motor de altura). Cambian la
plataforma y la tapa; la guía, las capturas, la web y el visor se regeneran.

Enfoque y números: [research.md](research.md).

## Contexto técnico

**Lenguaje/Versión**: OpenSCAD 2021.01 (diseño); Python 3 solo a través de los scripts existentes.

**Dependencias principales**: `src/perfil_impresora.scad`, scripts del pipeline
(`verificar_pieza.sh`, `capturas_armado.sh`, `generar_web.py`).

**Almacenamiento**: archivos del repositorio.

**Pruebas**: validación estricta de los `.scad` (asserts nuevos V-22 a V-26), valores fuera de rango a
propósito ([quickstart.md](quickstart.md)), caja envolvente de las STL que cambian, capturas PNG
revisadas y `generar_web.py --comprobar`.

**Plataforma**: impresión FDM en PETG (sin cambios).

**Tipo de proyecto**: diseño paramétrico de varias piezas.

**Objetivos**: todos los conectores con ≥ 1 mm de holgura; cables de motor con ≥ 20 mm de reserva
(SC-004); tapa ≤ 34,34 mm.

**Restricciones**: `--hardwarnings` sin avisos; solo cambian la plataforma y la tapa (las otras 11
STL iguales por vértices).

**Escala**: 1 diseño, 2 piezas que cambian, 5 asserts nuevos.

## Verificación de la constitución

*Puerta: se cumple antes de la investigación y se vuelve a revisar después del diseño.*

| Principio / puerta | Cómo se cumple | Estado |
|---|---|---|
| I. Diseño paramétrico | Medidas de conectores como parámetros con rango y aviso de medir; la elevación del ESP32 y la altura de la tapa pasan a ser derivadas; el `+ 5` sin nombre pasa a `holgura_techo_tapa`; validaciones con `assert` y mensaje en español | ✅ |
| II. Pipeline de cinco fases | Tareas agrupadas: 1) parámetros, ensamblaje, plataforma, tapa; 2) FEM: no aplica (R3); 3) STL de plataforma y tapa; 4) guía; 5) capturas, web y visor | ✅ |
| III. Simulación FEM | **No aplica**: los postes del soporte del ESP32 solo reciben la fuerza de enchufar (pocos N, hacia el labio) y la tapa no soporta carga; nada del camino de carga (base, brazos, pernos) cambia | ✅ (justificado) |
| IV. Manufactura aditiva | Postes y tapa con las mismas paredes; la abertura USB conserva la punta de gota (sin soporte); la tapa sigue entrando en la cama; perfil de impresora sin cambios | ✅ |
| V. Documentación y web | La guía actualiza alto de la tapa, masa, el paso 16 (conectar el ESP32 antes de encajarlo) y la tabla de adaptación; la BOM no cambia (los Dupont ya están) | ✅ |
| Gobernanza | Las medidas viven en `puntero_laser_parametros.scad`; las comprobaciones, en parámetros y ensamblaje, como las existentes; sin cambios en skills ni constitución | ✅ |
| Puerta 1 (diseño) | `verificar_pieza.sh` sobre parámetros, ensamblaje, plataforma y tapa; capturas de las dos piezas revisadas | ✅ planificado |
| Puerta 2 (simulación) | Justificación de arriba | ✅ |
| Puerta 3 (exportación) | STL de plataforma y tapa regeneradas; las otras 11 iguales | ✅ planificado |
| Puerta 4 (documentación) | Guía sin marcadores, BOM sin cambios | ✅ planificado |
| Puerta 5 (web) | `--comprobar`; capturas de pasos revisadas (cambian las que muestran la plataforma o la tapa); visor revisado | ✅ planificado |

**Revisión después del diseño**: sin violaciones. El margen de la tapa con el carro queda en 0,84 mm;
la comprobación existente lo vigila si alguien cambia los conectores.

## Estructura del proyecto

### Documentación (esta funcionalidad)

```text
specs/009-espacio-conectores/
├── spec.md
├── plan.md               # este archivo
├── research.md           # fase 0
├── data-model.md         # fase 1: parámetros, derivadas, volúmenes y validaciones
├── quickstart.md         # fase 1
├── contracts/
│   └── parametros.md     # parámetros nuevos y mensajes de validación (interfaz para quien adapta el diseño)
├── checklists/requirements.md
└── tasks.md              # fase 2
```

### Código y datos

```text
src/
├── puntero_laser_parametros.scad          # parámetros, derivadas, largo de cables, V-22…V-26
├── puntero_laser_ensamblaje.scad          # elemento "conectores", choques de conectores, paso 17
├── puntero_laser_plataforma_azimut.scad   # sin cambios de código (usa elevacion_esp32)
└── puntero_laser_tapa_electronica.scad    # abertura USB desde el enchufe

exports/puntero_laser_plataforma_azimut.stl, exports/puntero_laser_tapa_electronica.stl
docs/puntero_laser_guia.md, docs/img/puntero_laser_*.png
specs/002-puntero-laser-estelar/web/{index.html,armado_3d.html}
```

## Seguimiento de la complejidad

Sin violaciones que justificar.
