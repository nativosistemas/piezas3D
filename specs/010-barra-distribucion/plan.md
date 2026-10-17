# Plan de implementación: Barra de distribución de alimentación del puntero láser

**Rama**: `010-barra-distribucion` | **Fecha**: 2026-10-17 | **Especificación**: [spec.md](spec.md)

**Entrada**: especificación de la funcionalidad en `specs/010-barra-distribucion/spec.md`

## Resumen

El esquema reparte +5 V y GND a 5 destinos cada uno, pero un Dupont no se bifurca. Se agrega una
barra de distribución: un trozo de placa perforada de 3 × 10 agujeros (7,6 × 25,4 mm) con dos tiras
de 6 pines macho. Va en un soporte de la plataforma, en la franja de 13 mm que queda libre al lado del
regulador, en la columna de los ULN2003. Con eso la tapa, el hueco del sobrante y el tamaño de la
plataforma no cambian: se regenera solo la STL de la plataforma. La barra y sus Dupont entran en las
comprobaciones de zonas y de conectores. La lista de materiales suma la placa perforada, la tira de
pines y el termocontraíble, y el cable de silicona pasa de 60 a 70 cm. La guía suma las herramientas
de soldadura, el armado y la prueba de la barra (en el paso 16) y la tabla de pines (en la sección
5.4).

Enfoque y números: [research.md](research.md).

## Contexto técnico

**Lenguaje/Versión**: OpenSCAD 2021.01 (diseño); Python 3 solo a través de los scripts existentes.

**Dependencias principales**: `src/perfil_impresora.scad`, scripts del pipeline
(`verificar_pieza.sh`, `capturas_armado.sh`, `generar_web.py`), skills `pieza-openscad`,
`guia-produccion` y `web-armado`.

**Almacenamiento**: archivos del repositorio.

**Pruebas**:
- Validación estricta de los `.scad`, con los asserts nuevos V-27 a V-29.
- Valores fuera de rango a propósito ([quickstart.md](quickstart.md)).
- Caja envolvente de la STL de la plataforma, y las otras 12 STL comparadas por vértices.
- Capturas PNG revisadas y `generar_web.py --comprobar`.

**Plataforma**: impresión FDM en PETG (sin cambios).

**Tipo de proyecto**: diseño paramétrico de varias piezas.

**Objetivos**:
- 6 pines por tira (5 destinos y 1 de reserva).
- Barra y Dupont con la holgura de zonas (2 mm) y la de conectores (1 mm).
- Tapa en 33,5 mm, sin cambios.

**Restricciones**:
- `--hardwarnings` sin avisos.
- Solo cambia la STL de la plataforma.
- Los 19 pasos de armado se mantienen.
- Los precios nuevos se verifican en la tienda o quedan vacíos.

**Escala**: 1 diseño, 1 pieza que cambia, 3 parámetros, 3 asserts nuevos, 3 renglones nuevos en la
lista de materiales y 1 modificado.

## Verificación de la constitución

*Puerta: se cumple antes de la investigación y se vuelve a revisar después del diseño.*

| Principio / puerta | Cómo se cumple | Estado |
|---|---|---|
| I. Diseño paramétrico | La placa, los pines y la posición del soporte son parámetros o derivadas, con rango y aviso de medir; los destinos van como constantes con nombre; las validaciones son `assert` con mensaje en español | ✅ |
| II. Pipeline de cinco fases | Tareas agrupadas por fase: 1) parámetros, plataforma y ensamblaje; 2) FEM, que no aplica (R7); 3) STL de la plataforma; 4) guía y lista de materiales; 5) capturas, precios, web y visor | ✅ |
| III. Simulación FEM | **No aplica**: el soporte es igual a los de las otras placas, solo recibe ≈ 5 N al enchufar, y el camino de carga no cambia (R7) | ✅ (justificado) |
| IV. Manufactura aditiva | Usa el mismo `soporte_placa`, con las paredes y el labio con chaflán de los otros soportes (sin soportes de impresión); la plataforma conserva su tamaño y entra en la cama; el perfil de impresora no cambia | ✅ |
| V. Documentación y web | La lista de materiales se edita en el CSV y la guía la toma de ahí; cada precio queda con tienda, enlace y fecha, o vacío; la vista explotada del paso 16 y el visor salen del ensamblaje | ✅ |
| Gobernanza | Las medidas viven en `puntero_laser_parametros.scad`; el soporte, en la plataforma; la asignación de pines, en la guía (5.4); no cambian skills ni la constitución | ✅ |
| Puerta 1 (diseño) | `verificar_pieza.sh` sobre parámetros, ensamblaje y plataforma, con la captura de la plataforma revisada | ✅ planificado |
| Puerta 2 (simulación) | Justificación de arriba | ✅ |
| Puerta 3 (exportación) | STL de la plataforma regenerada; las otras 12, iguales | ✅ planificado |
| Puerta 4 (documentación) | Guía sin marcadores; lista de materiales con los renglones nuevos | ✅ planificado |
| Puerta 5 (web) | `--comprobar`; captura del paso 16 revisada; visor revisado en los pasos 16 y 17 | ✅ planificado |

**Revisión después del diseño**: sin violaciones. Quedan 1,7 mm de margen en X junto al regulador
y 0,25 mm en Y con el fin de la columna del relé, que es la más larga. Si la barra crece, empuja el
hueco del sobrante en lugar de chocar, y en ese caso la vigilan las comprobaciones existentes de la
tapa y de la cama.

## Estructura del proyecto

### Documentación (esta funcionalidad)

```text
specs/010-barra-distribucion/
├── spec.md
├── plan.md               # este archivo
├── research.md           # fase 0: ubicación, tamaño, pines, entrada, materiales
├── data-model.md         # fase 1: parámetros, derivadas, elemento del ensamblaje y validaciones
├── quickstart.md         # fase 1
├── contracts/
│   └── parametros.md     # parámetros nuevos, asignación de pines y mensajes
├── checklists/requirements.md
└── tasks.md              # fase 2 (/speckit-tasks)
```

### Código y datos

```text
src/
├── puntero_laser_parametros.scad          # parámetros, zona_barra, zona_regulador ajustada, y_sob0, masa, V-27…V-29
├── puntero_laser_plataforma_azimut.scad   # soporte_placa de la barra en soportes_placas()
└── puntero_laser_ensamblaje.scad          # elemento "barra", su volumen en "conectores", paso 16, ancla, identificación

exports/puntero_laser_plataforma_azimut.stl
docs/puntero_laser_bom.csv                 # placa perforada, tira de pines, termocontraíble; cable de silicona a 70 cm
docs/puntero_laser_guia.md                 # primeros pasos (herramientas), paso 16, sección 5.4, tabla de adaptación, mensajes V-27…V-29
docs/img/puntero_laser_*.png               # plataforma y vistas de los pasos que la muestran
specs/002-puntero-laser-estelar/web/{index.html,armado_3d.html}
```

## Seguimiento de la complejidad

Sin violaciones que justificar.
