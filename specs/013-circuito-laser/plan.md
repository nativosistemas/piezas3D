# Plan de implementación: Circuito del láser en el visor 3D

**Rama**: `013-circuito-laser` | **Fecha**: 2026-10-19 | **Especificación**: [spec.md](spec.md)

**Entrada**: especificación de la funcionalidad en `specs/013-circuito-laser/spec.md`

## Resumen

El modo Cableado del visor suma un botón por circuito declarado en el ensamblaje. El puntero láser
declara uno, «Circuito del láser», con todo el camino de la energía: power bank, interruptor, barra,
relé (con su control desde el ESP32 y la resistencia de 10 kΩ), regulador, cable del láser, la pila
falsa y las piezas metálicas de los contactos. Al activarlo, eso queda en color; el láser, la pila,
el power bank y el ESP32 se ven translúcidos para mostrar lo de adentro o lo de abajo, y todo lo demás
queda casi invisible. El panel lista el recorrido en 7 etapas.

Para eso entran al ensamblaje 9 elementos nuevos, que hoy no existen: el tornillo y la tuerca del
contacto positivo, los dos prisioneros de la tapa trasera (uno con su tuerca), los dos ojales y los
tramos finales de los hilos rojo y negro (R1, R2). Al modelarlos apareció un problema real: el
terminal de ojal completo no entra en la cara de la pila sin tocar el tubo, que es el negativo. Se
modela recortado, con una comprobación, y la guía dice que se corte el caño y se suelde el hilo (R3).

El mecanismo es genérico: lista opcional `circuitos` en el ensamblaje (R4), validada en
`armado_comun.scad` y leída por `generar_visor.py` (formato versión 5). La plantilla del visor la
dibuja (R5). Se abre directo con `?modo=cableado&circuito=laser`.

Enfoque y alternativas: [research.md](research.md).

## Contexto técnico

**Lenguaje/Versión**: OpenSCAD 2021.01 (ensamblaje, parámetros y biblioteca común); Python 3, solo
biblioteca estándar (`generar_visor.py`); JavaScript con three.js 0.160.0 ya incluido, en la
plantilla del visor.

**Dependencias principales**: `src/armado_comun.scad` (contratos de la 005, 007, 008 y 011),
`src/puntero_laser_parametros.scad` (cotas de la pila falsa y la tapa trasera de la 006),
`docs/puntero_laser_guia.md` (paso 14) y las skills `disenio-multipieza` y `web-armado`.

**Almacenamiento**: archivos del repositorio; los datos del visor van incrustados en
`armado_3d.html`.

**Pruebas**:
- Validación estricta del ensamblaje (`verificar_pieza.sh`) con V-30 y C-07.
- Casos que fallan a propósito ([quickstart.md](quickstart.md) §2).
- C-08 en `generar_visor.py` y `generar_web.py --comprobar` para los dos diseños con visor.
- Captura del paso 14 regenerada y revisada.
- Las STL del puntero láser que usan los parámetros tocados (pila falsa, tapa trasera, grapa y cuna) comparadas por vértices con las de `5949982` (no deben cambiar).
- Capturas del visor en el Edge sin ventana y prueba interactiva pedida al usuario.

**Plataforma**: navegador moderno con WebGL, sin internet ni servidor.

**Tipo de proyecto**: diseño paramétrico de varias piezas, con generadores de la web y del visor.

**Objetivos**: 9 elementos nuevos; el visor crece menos de 0,15 MB (hoy 3,9 MB; límite 10 MB).

**Restricciones**:
- `--hardwarnings` sin avisos.
- Los modos Armado, Funcionamiento y Cableado, los enlaces existentes y el visor de la caja de pilas
  no cambian de comportamiento sin un circuito activo.
- Las STL no cambian (no hay piezas impresas nuevas ni cambios de cotas impresas).

**Escala**: 1 circuito, 9 elementos, 3 constantes, 1 lista nueva en el contrato del ensamblaje,
3 validaciones (V-30, C-07, C-08), 1 frase de la guía, 1 captura.

## Verificación de la constitución

*Puerta: se cumple antes de la investigación y se vuelve a revisar después del diseño.*

| Principio / puerta | Cómo se cumple | Estado |
|---|---|---|
| I. Diseño paramétrico | Las medidas del ojal son constantes con nombre en los parámetros; cada pieza se ubica con las transformaciones de la pila y la tapa y sus cotas (R2), sin coordenadas sueltas. V-30 y C-07 son `assert` con mensaje en español. Nombres en español y `snake_case` | ✅ |
| II. Pipeline de cinco fases | 1) parámetros, elementos, circuito y biblioteca; 2) FEM no aplica (R9); 3) STL comparadas; 4) frase del paso 14; 5) generador, plantilla, captura del paso 14, web y revisión | ✅ |
| III. Simulación FEM | **No aplica**: tornillería comprada sin cargas nuevas, ya contada en la masa del láser (R9) | ✅ (justificado) |
| IV. Manufactura aditiva | Sin piezas impresas nuevas ni cambios en las existentes | ✅ |
| V. Documentación y web | El visor sigue saliendo del ensamblaje y la guía; la lista de materiales ya tenía estas piezas (sin renglones nuevos); la vista explotada del paso 14 se regenera | ✅ |
| Gobernanza | El contrato vive en `contracts/ensamblaje.md` y en el encabezado de `armado_comun.scad`; la constitución no cambia. Dos skills suman un apartado: `disenio-multipieza` (declarar `circuitos`) y `web-armado` (revisar el circuito) | ✅ |
| Puerta 1 (diseño) | `verificar_pieza.sh` sobre el ensamblaje; captura del paso 14 revisada | ✅ planificado |
| Puerta 2 (simulación) | Justificación de arriba | ✅ |
| Puerta 3 (exportación) | Las 13 STL comparadas por vértices | ✅ planificado |
| Puerta 4 (documentación) | Paso 14 de la guía con el ojal recortado y soldado; sin marcadores | ✅ planificado |
| Puerta 5 (web) | `--comprobar` en los dos diseños y el visor revisado en el navegador ([quickstart.md](quickstart.md) §4) | ✅ planificado |

**Revisión después del diseño**: sin violaciones. El hallazgo de R3 cambia una frase de la guía, no
piezas ni compras.

## Estructura del proyecto

### Documentación (esta funcionalidad)

```text
specs/013-circuito-laser/
├── spec.md
├── plan.md               # este archivo
├── research.md           # fase 0: piezas, posiciones, ojal, declaración, visor, validaciones
├── data-model.md         # fase 1: constantes, elementos, circuito, datos del visor, validaciones
├── quickstart.md         # fase 1: escenarios de validación
├── contracts/
│   ├── ensamblaje.md     # lista circuitos
│   ├── visor.md          # botón, escena y panel del circuito
│   └── scripts.md        # generar_visor.py (versión 5, C-08)
├── checklists/requirements.md
└── tasks.md              # fase 2 (/speckit-tasks)
```

### Código y datos

```text
src/
├── puntero_laser_parametros.scad    # d_ext_ojal, d_int_ojal, ancho_lengueta_ojal; V-30
├── armado_comun.scad                # circuitos: comprobar_circuitos(), echo CIRCUITOS; encabezado
└── puntero_laser_ensamblaje.scad    # 9 elementos (geometría, color, anclas, nombres, pasos 14 y 15,
                                     # elementos_altura) y la lista circuitos
scripts/
├── generar_visor.py                 # VERSION 5, lectura de CIRCUITOS, exportación, C-08, resumen
└── plantilla_visor.html             # botones, escena y lista del circuito, ?circuito=
docs/
├── puntero_laser_guia.md            # paso 14: el caño del ojal se corta y el hilo se suelda
└── img/puntero_laser_paso_14.png    # regenerada
specs/002-puntero-laser-estelar/web/ # armado_3d.html e index.html regenerados
.claude/skills/disenio-multipieza/SKILL.md, .claude/skills/web-armado/SKILL.md   # un apartado cada una
```

**Decisión de estructura**: se sigue el patrón de las 007, 008 y 011: datos opcionales en el
ensamblaje, validación en la biblioteca común, transporte en el generador y dibujo en la plantilla.

## Seguimiento de la complejidad

Sin violaciones que justificar.
