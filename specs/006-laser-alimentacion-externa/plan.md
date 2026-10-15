# Plan de implementación: Láser alimentado desde el power bank

**Rama**: `006-laser-alimentacion-externa` | **Fecha**: 2026-10-14 | **Especificación**: [spec.md](spec.md)

**Entrada**: especificación de la funcionalidad en `specs/006-laser-alimentacion-externa/spec.md`,
que modifica el diseño [002-puntero-laser-estelar](../002-puntero-laser-estelar/plan.md).

## Resumen

Se quita la batería del láser 303 y se lo alimenta desde el power bank. La cadena es: interruptor
general → **relé (COM → NA)** → **regulador MP1584EN a 3,7 V** → 2 hilos de 26 AWG. Una
**resistencia de 10 kΩ** fija la entrada del relé en "apagado", así que el láser queda sin energía en
todo estado en que el ESP32 no lo encienda. Lo único que no cubre el hardware es un firmware colgado
con el pin en alto: para eso se exige un *watchdog* ([research R1–R2](research.md)).

Hay 3 piezas impresas nuevas:

- **Pila falsa**: lleva el contacto **+**, un tornillo M3 de cabeza alomada.
- **Tapa trasera** sin rosca, impresa de pie:
  - se fija con 2 prisioneros M3 de punta cónica, y uno de ellos es el contacto **−**, porque muerde el
    tubo y atraviesa el anodizado;
  - el cable sale por el costado, y el alivio de tensión lo da la grapa;
  - lleva **2 tuercas M10 de lastre**.
- **Grapa** que sujeta el cable al láser.

El lastre es la decisión clave: deja la geometría idéntica a la 002 (brazos de 126,3 mm), así que la
horquilla, la base y la polea ya impresas siguen sirviendo, y la justificación sin FEM sigue valiendo.
Sin lastre el diseño también cumple, pero los brazos crecen 3 mm y la flexión queda al límite
([R5](research.md), corregido en la implementación).

El cable va del lado −X, 30° por debajo de la horizontal (150° en el sistema de impresión de la
cuna). Corre por una **canaleta exterior de la cuna** que no cambia el barrido, y desde el muñón −X
sigue el recorrido de la 002 ([R6](research.md)). El regulador entra en la columna de los ULN2003,
así que la plataforma y la tapa de la electrónica no cambian de tamaño ([R8](research.md)).

## Contexto técnico

**Lenguaje/Versión**: OpenSCAD 2021.01, el mismo de la 002.

**Dependencias principales**:

- `.tools/bin/openscad`.
- `scripts/verificar_pieza.sh`, `scripts/capturas_armado.sh`, `scripts/generar_web.py` y
  `scripts/generar_visor.py`.
- Python 3 del sistema.
- FreeCAD **no** se usa ([R10](research.md)).

**Componentes comprados nuevos**:

- MP1584EN (o mini-360) y una resistencia de 10 kΩ.
- 2 prisioneros M3 × 10 DIN 914, 1 tornillo M3 × 8 ISO 7380, 2 tuercas M3 y 2 terminales de ojal M3.
- 2 tuercas M10 ([Entidad 6](data-model.md#entidad-6-lista-de-materiales-docspuntero_laser_bomcsv)).

**Almacenamiento**: archivos del repositorio (`.scad`, `.stl`, `.md`, `.csv` y `.html`).

**Pruebas**: escenarios 1–8 y pruebas físicas F1–F9 de [quickstart.md](quickstart.md).

**Plataforma objetivo**: la de la 002. Desarrollo en WSL2 con sandbox; FDM con boquilla de 0,4 mm y
piezas ≤ 200 × 200 mm; uso nocturno a la intemperie.

**Tipo de proyecto**: modificación de un generador paramétrico multipieza (skill
`disenio-multipieza`).

**Objetivos de rendimiento**:

- Caída de tensión en el cable < 0,1 V: se diseña para 0,08 V.
- Tensión en el láser de 3,5–3,8 V con los motores en marcha.
- Flexión del brazo < 0,1°: se diseña para 0,093°.

**Restricciones**:

- No se cambia ningún parámetro público de la 002 ni el nombre de ningún STL.
- La plataforma sigue ≤ 196 mm.
- Ningún cable pasa por dentro de la cuna.
- La canaleta no va del lado −X de la cuna (del lado del brazo).

**Escala/Alcance**:

- 3 piezas nuevas y 2 modificadas, más el ensamblaje.
- 11 parámetros públicos nuevos y 7 reglas nuevas (V-15…V-21).
- De 10 a 13 STL.
- 1 paso de armado nuevo (de 18 a 19).

## Comprobación de la constitución

*PUERTA: debe superarse antes de la Fase 0 y volver a comprobarse tras el diseño de la Fase 1.*

### Principios

| Principio | Cómo lo cumple el plan | Estado |
|-----------|------------------------|--------|
| I. Diseño paramétrico en OpenSCAD | Los 3 archivos nuevos parten de la plantilla de `pieza-openscad`, con encabezado, `// --- PARÁMETROS Y CONSTANTES ---` con `include <puntero_laser_parametros.scad>`, orden fijo (suma → resta al final → ensamblaje) y `ensamblaje_principal()`. Los parámetros y constantes nuevos van solo en `_parametros.scad` (Entidades 1–3), con validaciones `assert()` V-15…V-21 en español. Las posiciones se definen desde el borde del tubo y el ángulo `angulo_cable`. Las piezas nuevas se construyen con perfiles 2D extruidos | ✅ |
| II. Pipeline lineal de cinco fases | Tareas agrupadas en: 1) diseño (parámetros → pila → tapa → grapa → cuna → plataforma → ensamblaje), 2) simulación (no aplica, justificada), 3) exportación de los 13 STL, 4) guía y BOM, 5) web y visor | ✅ |
| III. Simulación en FreeCAD | **No aplica**: las piezas nuevas soportan ≤ 10 N con factores > 60 y el láser nuevo es más liviano (161 g < 180 g). La flexión del brazo, recalculada por escalado, da 0,093° < 0,1° ([R10](research.md)). Se agrega un `AVISO` si `alto_brazo` > 131 mm | ✅ (justificado) |
| IV. Diseño para manufactura aditiva | Todas las piezas se imprimen sin soportes: la pila y la tapa de pie (la tapa con el piso trasero sobre la cama, para que no haya un puente de 30 mm), y la grapa plana. Los resaltes de los prisioneros llevan chaflán de 45° y la canaleta es un nervio vertical con puentes de 2,5 mm. Las holguras salen de `holgura()` del perfil de impresora, que tiene `perfil_medido = false`: la guía DEBE decir que el ajuste de la funda y de la pila falsa usa **valores por defecto, no medidos** | ✅ |
| V. Documentación y web de armado | Se actualizan `docs/puntero_laser_guia.md` (secciones A y B, conexiones, ajuste del regulador, F1, equilibrado, consumo, vuelta a la batería) y `docs/puntero_laser_bom.csv` (Entidad 6). Los precios nuevos se verifican o quedan vacíos. La web y el visor 3D se regeneran con `generar_web.py` en la carpeta del diseño, `specs/002-puntero-laser-estelar/web/`, con la vista explotada del paso nuevo | ✅ |

### Puertas de calidad

| Puerta | Verificación prevista | Estado |
|--------|-----------------------|--------|
| 1. Diseño | Escenarios 2–4: `verificar_pieza.sh` sin avisos en las 5 piezas tocadas, capturas revisadas fuera del sandbox y ensamblaje con V-07 y V-19 aprobados | ✅ Cumplida (T009–T020): 5 piezas con validación estricta y caja medida; ensamblaje sin errores a −10°, 0°, 45°, 90° y 95°; 4 variantes válidas y 4 casos inválidos según lo previsto; capturas revisadas |
| 2. Simulación | Justificación de este plan y de [R10](research.md) | ✅ Cumplida |
| 3. Exportación | Escenario 7: 13 STL regenerados juntos | ✅ Cumplida (T022): todos ≤ 200 × 200 mm; cambian la cuna, la plataforma y las 3 piezas nuevas (los brazos, 0,003 mm) |
| 4. Documentación | Guía sin marcadores y lista de materiales generada desde el CSV | ✅ Cumplida (T023–T029) |
| 5. Web de armado | Escenario 8: `--comprobar` sin errores, precios con fuente y fecha, vista explotada del paso 14 revisada y web y visor revisados en el navegador | ✅ Cumplida (T030–T033): `--comprobar` sin errores; los 7 renglones nuevos quedan sin precio (no se pudieron verificar) y la web avisa que el total es parcial; vistas 14–18 y visor revisados en el Edge |

### Estructura del repositorio

- Se escribe en `src/`, `exports/`, `docs/` y `docs/img/`, en la web de la 002 y en los artefactos de
  esta carpeta.
- No se escribe en `simulation/`, porque la simulación no aplica.
- No se tocan `scripts/` ni la constitución.
- Todo va en español. ✅

**Resultado antes de la Fase 0**: SUPERADA. No hay violaciones.

**Resultado tras la Fase 1**: SUPERADA. El diseño (U-13…U-16 y V-15…V-21) no agrega desviaciones.
La única decisión con impacto fuera de las piezas nuevas, el lastre, existe justamente para no
modificar la horquilla.

## Estructura del proyecto

### Documentación (esta funcionalidad)

```text
specs/006-laser-alimentacion-externa/
├── spec.md                    # Especificación (/speckit-specify + aclaración)
├── plan.md                    # Este archivo
├── research.md                # Fase 0: R1–R11
├── data-model.md              # Fase 1: parámetros, derivados, reglas, piezas, BOM y pasos
├── quickstart.md              # Fase 1: escenarios 1–8 y pruebas F1–F9
├── contracts/
│   ├── interfaz_generador.md  # Cambios compatibles del generador
│   └── interfaz_firmware.md   # Garantías del hardware frente al firmware y esquema nuevo
├── checklists/requirements.md
└── tasks.md                   # Fase 2 (/speckit-tasks)
```

### Código fuente y entregables

```text
src/
├── puntero_laser_parametros.scad          # CAMBIA: grupo "Láser sin batería", derivados, V-15…V-21
├── puntero_laser_pila_falsa.scad          # NUEVA
├── puntero_laser_tapa_trasera.scad        # NUEVA
├── puntero_laser_grapa_cable.scad         # NUEVA
├── puntero_laser_cuna_laser.scad          # CAMBIA: canaleta_cable() a 150°, sin ranura_cable()
├── puntero_laser_plataforma_azimut.scad   # CAMBIA: soporte del regulador en la columna A
└── puntero_laser_ensamblaje.scad          # CAMBIA: elementos nuevos, láser convertido, 19 pasos
exports/puntero_laser_*.stl                # 13 STL (se regeneran todos)
docs/puntero_laser_guia.md                 # CAMBIA
docs/puntero_laser_bom.csv                 # CAMBIA
docs/img/puntero_laser_*.png               # Capturas de las piezas nuevas y vistas explotadas
specs/002-puntero-laser-estelar/web/       # index.html y armado_3d.html regenerados
```

**Decisión de estructura**: las piezas nuevas siguen el prefijo `puntero_laser_` y la sección 4 de la
skill `disenio-multipieza`. La web se regenera en la carpeta de la 002, porque es la web del diseño y
la 006 es una modificación. Así queda un solo `index.html` del puntero láser.

### Orden de modelado (para `/speckit-tasks`)

1. `_parametros.scad`: grupo nuevo, derivados (centro de masa, `l_trasero`, columna A, secciones de
   la tapa), V-15…V-21 y el aviso. Comprobar el escenario 1.
2. `pila_falsa`: define `largo_pila_falsa` y la ranura del cable.
3. `tapa_trasera`: escalón, ranura, ventana, resaltes, ranuras de la brida y hexágono del lastre.
4. `grapa_cable`.
5. `cuna_laser`: canaleta y quitar la ranura.
6. `plataforma_azimut`: soporte del regulador.
7. `ensamblaje`: elementos nuevos, `laser()` como tubo sin tapa + tapa impresa, tabla de 19 pasos.
8. Regenerar los 13 STL. Después vienen la guía y la BOM, y por último la web y el visor.

## Riesgos y mitigaciones

| Riesgo | Mitigación |
|--------|------------|
| Las medidas reales del láser difieren de las supuestas | Todas son parámetros con rango (Entidad 1). La guía explica cómo medir cada una ([R11](research.md)). La pila y la tapa son piezas chicas: reimprimirlas es barato |
| El prisionero no atraviesa el anodizado | Prueba F1 antes de cerrar. Alternativa en la guía: limar un punto de la rosca, donde apoya la punta |
| La batería original iba con el + hacia la cola | La guía pide comprobar la orientación antes de sacarla. La pila falsa se pone igual, y si la polaridad está invertida se cruzan los hilos en el regulador |
| Regulador sin ajustar al conectar el láser | Paso de ajuste obligatorio (F2) con el láser desconectado, con advertencia destacada en la guía |
| El centro de masa real difiere del calculado | Parámetro `distancia_trasera_centro_masa_nueva` para cargar la medida; V-19 asegura el lugar para equilibrar |
| Firmware colgado con el láser encendido | *Watchdog* obligatorio en el [contrato de firmware](contracts/interfaz_firmware.md) |
| El pulsador del láser es momentáneo | La guía explica cómo puentearlo, por la ventana del pulsador que ya tiene la cuna |

## Seguimiento de la complejidad

No hay violaciones de la constitución. Hay 2 complejidades agregadas, justificadas:

- **El lastre**: evita rediseñar la horquilla (R5).
- **El prisionero como contacto**: resuelve el anodizado y además fija la tapa (R3).
