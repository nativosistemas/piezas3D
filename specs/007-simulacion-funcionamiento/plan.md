# Plan de implementación: Simulación de funcionamiento en el visor 3D

**Rama**: `007-simulacion-funcionamiento` | **Fecha**: 2026-10-15 | **Especificación**: [spec.md](spec.md)

**Entrada**: especificación de la funcionalidad en `specs/007-simulacion-funcionamiento/spec.md`

## Resumen

El visor 3D de armado (`armado_3d.html`) suma una pestaña **Funcionamiento**: el aparato armado, con
un deslizador por eje móvil, los motores girando según su correa, el láser que se enciende con su
haz y un modo automático que recorre objetivos de demostración a la velocidad real.

Enfoque ([research.md](research.md)):

- **Declaración en el ensamblaje**: cinco listas opcionales (`articulaciones`, `motores`,
  `emisores`, `objetivos`, `deformables`) con números que salen de los parámetros. La biblioteca
  `armado_comun.scad` las valida con `assert` y las entrega con `paso_armado = -1` (R7).
- **Mismas mallas**: cada articulación declara su reposo (el ángulo del catálogo) y el visor gira
  las mallas desde ahí; no se exportan otras piezas (R1). Solo el cable se exporta además cada 5° de
  altura (R5).
- **Comprobación automática de pivotes**: el generador exporta los elementos de cada articulación en
  los extremos del rango y los compara con las mallas giradas (R6): un signo o un punto mal
  declarado falla al generar, no en el navegador.
- **Página**: grupos anidados de three.js (azimut → altura; motores dentro de su marco), haz con
  brillo aditivo, máquina de estados por tiempo real para el automático (R8–R10).

## Contexto técnico

**Lenguaje/Versión**: Python 3 (biblioteca estándar), OpenSCAD 2021.01, HTML + CSS + JavaScript
(módulos ES).

**Dependencias principales**: las de la 005, sin agregados: OpenSCAD (`.tools/bin/openscad`),
three.js 0.160.0 incrustado (`scripts/vendor/three-0.160.0/`), Edge de Windows para revisar.

**Almacenamiento**: archivos del repositorio; el visor generado se versiona.

**Pruebas**: escenarios de [quickstart.md](quickstart.md): validación estricta de los `.scad`,
comprobación de pivotes del generador, `--comprobar` (puerta 5), declaraciones inválidas a
propósito y capturas del visor con `?modo=funcionamiento&…`. El proyecto no tiene pruebas
unitarias y esta funcionalidad no lo justifica.

**Plataforma**: navegadores actuales de computadora y celular, abriendo el archivo local.

**Tipo de proyecto**: herramienta del pipeline (biblioteca OpenSCAD + script + plantilla HTML).

**Objetivos de rendimiento**: movimiento continuo en computadora y celular de gama media; el modo
automático respeta el tiempo real (±10 %); regenerar sin cambios en pocos segundos (caché por
huella de la 005).

**Restricciones**: sin internet ni servidor; ≤ 10 MB por diseño (estimado ≈ 4 MB); STL y capturas
de armado sin cambios; `--hardwarnings` sin avisos (por eso `is_undef` y no valores por defecto
redefinidos).

**Escala**: un diseño con partes móviles (puntero láser: 2 articulaciones, 2 motores, 1 emisor, 1
deformable); la caja de pilas no declara nada. El formato aguanta diseños con más articulaciones
encadenadas.

## Verificación de la constitución

*Puerta: se cumple antes de la investigación y se vuelve a revisar después del diseño.*

| Principio / puerta | Cómo se cumple | Estado |
|---|---|---|
| I. Diseño paramétrico | Las declaraciones usan parámetros (relación de la correa, rango, velocidad, cotas); los literales `-10`/`95` del barrido pasan a constantes con nombre; las validaciones son `assert` con mensaje en español; `armado_comun.scad` mantiene su encabezado y orden | ✅ |
| II. Pipeline de cinco fases | Tareas agrupadas: 1) `.scad` (biblioteca, parámetros, ensamblaje); 2) simulación FEM: no aplica; 3) exportación: comprobar que las STL no cambian; 4) documentación: skills y guía (enlace al modo); 5) generador, plantilla, web y revisión en el navegador | ✅ |
| III. Simulación FEM | **No aplica**: ninguna pieza ni carga cambia; la "simulación" de esta funcionalidad es una animación cinemática para la web, no un análisis | ✅ (justificado) |
| IV. Manufactura aditiva | Las piezas no cambian; las constantes nuevas no tocan geometría. Fase 3 compara las STL por vértices ordenados | ✅ |
| V. Documentación y web | El visor sigue saliendo del ensamblaje y la guía, sin trabajo a mano; las capturas PNG no cambian; la web enlaza al modo nuevo | ✅ |
| Gobernanza: un solo lugar por regla | Los datos viven en el ensamblaje (no se repiten en la página); la convención va en la skill `disenio-multipieza`, la revisión en `web-armado`; la constitución no cambia (R12) | ✅ |
| Puerta 1 (diseño) | `verificar_pieza.sh --rapido` sobre la biblioteca, los parámetros y el ensamblaje; capturas de armado regeneradas e iguales | ✅ planificado |
| Puerta 3 (exportación) | STL regeneradas iguales por vértices ordenados | ✅ planificado |
| Puerta 4 (documentación) | Guía sin cambios de contenido técnico; si se agrega una mención al modo Funcionamiento, sin marcadores | ✅ planificado |
| Puerta 5 (web) | `generar_web.py --comprobar` pasa para los dos diseños; visor revisado en el navegador (Armado y Funcionamiento) | ✅ planificado |

**Revisión después del diseño (fase 1)**: sin violaciones. La comprobación de pivotes refuerza la
regla "lo que se puede calcular se calcula" de la puerta 1.

## Estructura del proyecto

### Documentación (esta funcionalidad)

```text
specs/007-simulacion-funcionamiento/
├── spec.md
├── plan.md               # este archivo
├── research.md           # fase 0
├── data-model.md         # fase 1
├── quickstart.md         # fase 1
├── contracts/
│   ├── ensamblaje.md     # cómo declarar articulaciones, motores, emisores, objetivos, deformables
│   ├── scripts.md        # cambios en generar_visor.py y generar_web.py
│   └── visor.md          # pestaña, direcciones, controles y datos
├── checklists/requirements.md
└── tasks.md              # fase 2 (/speckit-tasks)
```

### Código y datos (raíz del repositorio)

```text
src/
├── armado_comun.scad                 # lectura con is_undef, validaciones y salida de la simulación
├── puntero_laser_parametros.scad     # angulo_altura_min/max, medios_pasos_por_segundo_max, velocidad_max_eje
└── puntero_laser_ensamblaje.scad     # declaraciones del puntero láser; usa las constantes de rango

scripts/
├── generar_visor.py                  # lee la simulación, fotogramas, comprobación de pivotes, version 2
├── plantilla_visor.html              # pestañas, grupos anidados, haz, automático, direcciones
└── generar_web.py                    # enlace "Ver cómo funciona"

specs/002-puntero-laser-estelar/web/armado_3d.html   # regenerado (con simulación)
specs/002-puntero-laser-estelar/web/index.html       # regenerado (enlace)
specs/004-caja-pilas-aa/web/armado_3d.html           # regenerado (version 2, sin simulación)

.claude/skills/disenio-multipieza/SKILL.md   # convención para declarar partes móviles
.claude/skills/web-armado/SKILL.md           # revisar el modo Funcionamiento
```

**Decisión de estructura**: todo entra en los archivos de la 005; no hay archivos nuevos de código.
La plantilla crece (~250 líneas de JavaScript); si pasa de ~600 líneas en total, la simulación se
separa en un segundo módulo incrustado igual que three.js, decisión que se toma al implementar.

## Seguimiento de complejidad

| Agregado | Por qué hace falta | Alternativa más simple descartada porque |
|---|---|---|
| Fotogramas del cable (22 mallas, ≈ 1,2 MB) | Que el cable no se despegue ni desaparezca (FR-014) | Girarlo entero lo despega del brazo; ocultarlo contradice FR-014 (R5) |
| Comprobación de pivotes (~20 exportaciones al cambiar la huella) | Detectar un signo o un punto mal declarado al generar (SC-002) | La revisión a ojo en el navegador deja pasar errores chicos (R6) |
| Signo en la relación de cada motor | El azimut y la altura giran en sentidos relativos distintos (R3) | Una relación sin signo muestra un motor girando al revés |

## Dependencias y orden

1. Parámetros (constantes de rango y velocidad) y validación de que las STL no cambian.
2. `armado_comun.scad`: lectura, validaciones y salida; ensamblaje del puntero láser con sus
   declaraciones; validación estricta y capturas de armado iguales.
3. `generar_visor.py`: lectura, fotogramas, comprobación de pivotes, `version: 2`; regenerar los
   dos visores (la caja de pilas solo cambia de versión).
4. Plantilla: pestañas y modo manual (historias 1 y 4) → láser (historia 2) → automático
   (historia 3); revisión en el Edge con las capturas del quickstart.
5. `generar_web.py` (enlace), skills y commit.
