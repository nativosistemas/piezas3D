# Plan de implementación: Vista de cableado en el visor 3D del puntero láser

**Rama**: `011-vista-cableado` | **Fecha**: 2026-10-17 | **Especificación**: [spec.md](spec.md)

**Entrada**: especificación de la funcionalidad en `specs/011-vista-cableado/spec.md`

## Resumen

El visor 3D suma un tercer modo, **Cableado**, y la web un tercer botón, «Ver el cableado». El modo
muestra el puntero láser armado, con la tapa transparente y las piezas impresas atenuadas, y dibuja
cada uno de los 26 cables de pin a pin, con su conector en cada punta. Cada cable se puede identificar
señalándolo en la escena o en la lista del panel, que está agrupada por placa.

Los cables se declaran como **datos** en el ensamblaje (lista opcional `cables`: desde, hasta,
colores, recorrido y conectores) y el visor construye los tubos en el navegador, así que no se
exportan mallas nuevas. Los recorridos los calcula una función a partir de la posición de cada pin,
siguiendo niveles ortogonales bajo la tapa.

La biblioteca común comprueba con `assert` que ningún cable atraviese una placa, la plataforma o la
tapa, y que el cable comprado alcance. La comprobación de largo reemplaza a la V-26 de los motores.

La guía suma una **Tabla de cables** en la sección 5.4, y `generar_visor.py` falla si la tabla y el
ensamblaje no tienen los mismos pares desde → hasta. Entran al modelo el interruptor y la resistencia
de 10 kΩ del relé, que ya están en la lista de materiales. Las piezas impresas no cambian, salvo que
la comprobación de choques obligue a subir la tapa (R5).

Enfoque y alternativas: [research.md](research.md).

## Contexto técnico

**Lenguaje/Versión**: OpenSCAD 2021.01 (ensamblaje y biblioteca común); Python 3, solo biblioteca
estándar (`generar_visor.py`, `generar_web.py`); JavaScript con three.js 0.160.0 ya incluido
(`scripts/vendor/`), en la plantilla del visor.

**Dependencias principales**: `src/armado_comun.scad` (contratos de la 005, 007 y 008),
`src/puntero_laser_parametros.scad` (posiciones de las placas, conectores de la 009, barra de la 010),
la guía `docs/puntero_laser_guia.md` y las skills `disenio-multipieza`, `guia-produccion` y
`web-armado`.

**Almacenamiento**: archivos del repositorio. Los datos del visor van incrustados en
`armado_3d.html`.

**Pruebas**:
- Validación estricta del ensamblaje (`verificar_pieza.sh`), con las comprobaciones nuevas C-01 a C-04.
- Casos que fallan a propósito ([quickstart.md](quickstart.md) §2).
- C-05 y C-06 en `generar_visor.py`, y `generar_web.py --comprobar` para los dos diseños con visor.
- Captura de los recorridos con `ver_cables=true`, revisada.
- Las 13 STL del puntero láser comparadas por vértices con las de `ed17342`.
- Revisión del visor en el Edge, en ancho de escritorio y de celular.

**Plataforma**: navegador moderno con WebGL, sin internet ni servidor (como el visor actual).

**Tipo de proyecto**: diseño paramétrico de varias piezas, con generadores de la web y del visor.

**Objetivos**:
- 26 cables en 7 grupos.
- El visor crece menos de 0,3 MB (hoy pesa 3,8 MB; el límite es 10 MB).
- La regeneración agrega solo la evaluación de los asserts y 2 mallas (el interruptor y la
  resistencia).

**Restricciones**:
- `--hardwarnings` sin avisos.
- Los modos Armado y Funcionamiento, los 19 pasos, los enlaces `#paso-N` y `#funcionamiento`, y la
  web y el visor de la caja de pilas no cambian de comportamiento.
- Las STL, iguales salvo lo que R5 obligue (anotado aquí si pasa).

**Escala**: 1 diseño, 26 cables, 2 elementos nuevos, 5 listas nuevas en el contrato del ensamblaje,
6 validaciones (C-01 a C-06), 1 tabla nueva en la guía, 1 modo nuevo en el visor y 1 botón en la web.

## Verificación de la constitución

*Puerta: se cumple antes de la investigación y se vuelve a revisar después del diseño.*

| Principio / puerta | Cómo se cumple | Estado |
|---|---|---|
| I. Diseño paramétrico | Los pines son constantes con nombre, relativas a los bordes de cada placa (R4). Los recorridos salen de una función de las posiciones de los pines y de los parámetros de la 009 (R5), no de coordenadas sueltas. Las medidas de los conectores salen de `largo_dupont`, `paso_pines`, etc. Las validaciones son `assert` con mensaje en español. Hay nombres en español y `snake_case` | ✅ |
| II. Pipeline de cinco fases | Tareas por fase: 1) biblioteca común, pines, recorridos, elementos nuevos y comprobaciones; 2) FEM, que no aplica (R9); 3) STL comparadas (y regeneradas si R5 cambia la tapa); 4) Tabla de cables, paso 16 y mensajes en la guía; 5) generadores, plantilla del visor, web, capturas y revisión | ✅ |
| III. Simulación FEM | **No aplica**: cables y componentes comprados, sin cargas nuevas; menos de 15 g ya contados en `masa_placas_g` (R9) | ✅ (justificado) |
| IV. Manufactura aditiva | No hay piezas impresas nuevas. Si R5 obliga a subir la tapa, se usan el mismo perfil y la misma orientación, y las comprobaciones de cama y del carro de altura de la 009 siguen vigentes | ✅ |
| V. Documentación y web | La Tabla de cables va en la guía. El visor sigue saliendo del ensamblaje y de la guía (C-05 los ata). El botón lo pone `generar_web.py`. No hay renglones nuevos en la lista de materiales. Se regeneran las vistas explotadas del paso 16 en adelante | ✅ |
| Gobernanza | El contrato de cables vive en `contracts/ensamblaje.md` y en el encabezado de `armado_comun.scad` (que lo enlaza); los pines, en el ensamblaje; qué se conecta con qué, en la guía. La constitución no cambia. Dos skills suman un apartado, igual que cuando llegaron la 007 y la 008: `disenio-multipieza` (cómo declarar `cables`) y `web-armado` (cómo revisar la pestaña Cableado) | ✅ |
| Puerta 1 (diseño) | `verificar_pieza.sh` sobre el ensamblaje (y la tapa si cambia), con la captura de los cables revisada | ✅ planificado |
| Puerta 2 (simulación) | Justificación de arriba | ✅ |
| Puerta 3 (exportación) | Las 13 STL comparadas por vértices | ✅ planificado |
| Puerta 4 (documentación) | Guía sin marcadores, con la Tabla de cables, el sentido de las placas en el paso 16 y el mensaje C-04 en la 4.4 | ✅ planificado |
| Puerta 5 (web) | `--comprobar` en los dos diseños con visor, la vista del paso 16 revisada y el visor revisado en el navegador ([quickstart.md](quickstart.md) §5) | ✅ planificado |

**Revisión después del diseño**: sin violaciones. El riesgo de R5 (2 mm de holgura de techo) no se
materializó: los tres niveles de recorrido (señales, GND y +5 V) entran entre los conectores y el techo,
los cables cruzan entre columnas por el pasillo y bajo las placas, y C-03 no encuentra choques. La tapa
no cambió y las 13 STL son iguales por vértices.

## Estructura del proyecto

### Documentación (esta funcionalidad)

```text
specs/011-vista-cableado/
├── spec.md
├── plan.md               # este archivo
├── research.md           # fase 0: representación, fuente, cables, pines, recorridos, choques, visor
├── data-model.md         # fase 1: listas del ensamblaje, Tabla de cables, datos del visor, validaciones
├── quickstart.md         # fase 1: escenarios de validación
├── contracts/
│   ├── ensamblaje.md     # lista cables y compañía, funciones y mensajes de la biblioteca
│   ├── visor.md          # pestaña, escena, panel y selección del modo Cableado
│   ├── scripts.md        # generar_visor.py (C-05, C-06, versión 4) y el botón de generar_web.py
│   └── guia.md           # formato de la Tabla de cables
├── checklists/requirements.md
└── tasks.md              # fase 2 (/speckit-tasks)
```

### Código y datos

```text
src/
├── armado_comun.scad                 # comprobar_cables(), choques_cable(), falta_largo(), echo CABLE;…,
│                                     # cables_modelados(); encabezado con el contrato
└── puntero_laser_ensamblaje.scad     # pines, pin(), recorridos, cables, obstáculos, grupos, conectores,
                                      # elementos interruptor y resistencia_rele (paso 16, nombres, anclas),
                                      # ver_cables; la V-26 pasa a C-04

scripts/
├── generar_visor.py                  # VERSION 4, lectura de cables, C-05, C-06, datos.cableado
├── plantilla_visor.html              # pestaña y panel Cableado, tubos y conectores, selección de cables
└── generar_web.py                    # botón «Ver el cableado»

docs/puntero_laser_guia.md            # Tabla de cables (5.4), sentido de las placas (paso 16), C-04 (4.4)
docs/img/puntero_laser_paso_16…18.png # vistas con el interruptor y la resistencia
specs/002-puntero-laser-estelar/web/{index.html,armado_3d.html}
specs/004-caja-pilas-aa/web/armado_3d.html   # regenerado por la versión 4, sin cambios visibles
.claude/skills/disenio-multipieza/SKILL.md   # apartado: declarar los cables (se edita fuera del sandbox)
.claude/skills/web-armado/SKILL.md           # apartado: revisar la pestaña Cableado (ídem)
```

**Decisión de estructura**: no hay archivos nuevos de código. Todo amplía la maquinaria existente
(biblioteca común, generador, plantilla), y el contrato se aplica a cualquier diseño que declare
`cables`.

## Seguimiento de la complejidad

Sin violaciones que justificar.
