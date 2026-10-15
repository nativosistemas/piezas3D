---

description: "Lista de tareas de la simulación de funcionamiento en el visor 3D"
---

# Tareas: Simulación de funcionamiento en el visor 3D

**Entrada**: documentos de diseño de `specs/007-simulacion-funcionamiento/`

**Requisitos previos**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/ensamblaje.md](contracts/ensamblaje.md),
[contracts/scripts.md](contracts/scripts.md), [contracts/visor.md](contracts/visor.md),
[quickstart.md](quickstart.md)

**Pruebas**: no se piden tareas de prueba aparte; cada fase se cierra con los escenarios del
quickstart, las validaciones de OpenSCAD y la comprobación de pivotes del generador.

**Organización**: por las cinco fases del pipeline (Principio II), con la historia de usuario en cada
tarea. La fase 5 está agrupada por historia, en orden de prioridad.

## Formato: `[ID] [P?] [Historia] Descripción`

- **[P]**: se puede hacer en paralelo (otro archivo y sin dependencias pendientes).
- **[Historia]**: US1 (mover a mano y ver qué gira), US2 (encender el láser), US3 (recorrido
  automático) o US4 (la simulación sale sola desde el ensamblaje).

**Entorno** (ver `CLAUDE.md`): OpenSCAD exporta dentro del sandbox; las capturas PNG y el Edge van
**fuera** del sandbox. Los archivos de `.claude/skills/` se editan con la herramienta de edición, no
con comandos de la terminal (el sandbox no deja escribirlos).

---

## Fase 0: Preparación

- [X] T001 Guardar la referencia para comparar después en `.tools/tmp/base_007/`: copiar
  `docs/img/puntero_laser_paso_*.png`, `docs/img/puntero_laser_ensamblaje.png`, `exports/puntero_laser_*.stl`
  y los dos `armado_3d.html` (`specs/002-puntero-laser-estelar/web/` y `specs/004-caja-pilas-aa/web/`).

---

## Fase 1: Diseño (`src/*.scad`) — fundacional, bloquea todo lo demás

- [X] T002 [US4] En `src/puntero_laser_parametros.scad`, sección `/* [Hidden] */`, agregar
  `angulo_altura_min = -10;`, `angulo_altura_max = 95;` (rango de la altura, research R2),
  `medios_pasos_por_segundo_max = 900;` (velocidad máxima fiable de la tabla del firmware de la guía)
  y, después de `pasos_por_grado`, `velocidad_max_eje = medios_pasos_por_segundo_max/pasos_por_grado;`
  (°/s, ≈ 19,9; research R4). Reemplazar los literales `-10` y `95` del barrido V-07
  (`holgura_barrido_zona`, el comentario de `secciones` y el mensaje del `assert` de la línea ~729)
  por las constantes; si `angulo_altura` del ensamblaje tiene el rango del personalizador
  `[-10:1:95]`, dejarlo (el personalizador no admite variables) con un comentario que nombre las
  constantes. Validar con `scripts/verificar_pieza.sh --rapido src/puntero_laser_parametros.scad`.
- [X] T003 [US4] En `src/armado_comun.scad`: documentar en el encabezado las listas opcionales
  (`articulaciones`, `motores`, `emisores`, `objetivos`, `deformables`, `transparentes_simulacion`)
  con referencia a `specs/007-simulacion-funcionamiento/contracts/ensamblaje.md`; agregar funciones
  de lectura `simulacion_articulaciones()` … `simulacion_transparentes()` que devuelven la lista del
  diseño o `[]` con `is_undef(…)` (NO redefinir variables: con `--hardwarnings` detiene la
  validación; research R7).
- [X] T004 [US4] En `src/armado_comun.scad`, agregar `comprobar_simulacion()` y llamarlo desde
  `armado()`, con `assert` y mensaje en español que nombre el dato (data-model, "Validaciones en
  OpenSCAD"): articulación con 11 campos y motor con 8, emisor con 7, objetivo con 2, deformable con 3;
  "Todo elemento nombrado existe en `elementos`"; "Ningún elemento en dos articulaciones, en una
  articulación y un motor, ni deformable y móvil"; nombres de articulaciones y motores únicos;
  `padre` y `montado_en` son `""` o una articulación existente y la cadena de padres no es circular
  (recorrer como máximo `len(articulaciones)` niveles); eje y dirección no nulos (`norm > 0`); rango
  `undef` o `mín < máx`; reposo dentro del rango; velocidad > 0; relación ≠ 0; largo > 0; cada objetivo
  tiene "tantos [valores] como articulaciones y dentro de cada rango"; la articulación de cada
  deformable tiene `variable` no vacía y sus ángulos están dentro del rango.
- [X] T005 [US4] En `src/armado_comun.scad`, ampliar `datos_armado()`: después de las líneas de la
  005, emitir siempre `ARTICULACIONES;<lista>`, `MOTORES;<lista>`, `EMISORES;<lista>`,
  `OBJETIVOS;<lista>`, `DEFORMABLES;<lista>` y `TRANSPARENTES;<lista>` (listas vacías si el diseño
  no declara nada). Validar con `scripts/verificar_pieza.sh --rapido src/armado_comun.scad` si el
  script la acepta, y siempre a través de los dos ensamblajes.
- [X] T006 [US1] En `src/puntero_laser_ensamblaje.scad`, después de `include <armado_comun.scad>` y
  antes de `armado()`, declarar la simulación según el ejemplo de
  [contracts/ensamblaje.md](contracts/ensamblaje.md#ejemplo-el-puntero-láser): `elementos_altura`
  (cuna, laser, pila_falsa, tapa_trasera, lastre, grapa, tuerca_munon, perno_alt_cable,
  perno_alt_motor, polea_alt), `elementos_azimut` calculados (todo menos `grupo_base`, altura,
  poleas 20T y `cable_laser`), las dos articulaciones (azimut: Z hacia abajo `[0, 0, -1]` por el
  origen, sin rango, reposo 0, sin variable; altura: `[1, 0, 0]` por `[0, 0, z_eje_altura]`, rango
  `[angulo_altura_min, angulo_altura_max]`, reposo `angulo_altura`, padre `"azimut"`, variable
  `"angulo_altura"`; las dos con `velocidad_max_eje` y `pasos_por_grado`), los dos motores
  (`polea20_az` con relación `-relacion_correa` y `polea20_alt` con `relacion_correa`, los dos
  montados en `"azimut"`; punto y eje sacados de las transformaciones de `elemento("polea20_az")` y
  de `matriz_polea20_alt`), el emisor `laser` (punto `en_conjunto([0, l_delantero, 0], angulo_altura)`,
  dirección `[0, cos(angulo_altura), sin(angulo_altura)]`, `"Lime"`, `largo_haz_simulacion = 600`),
  `deformables = [["cable_laser", "altura", [for (a = [angulo_altura_min:5:angulo_altura_max]) a]]]`
  y `transparentes_simulacion = ["tapa"]`. Usar las constantes de T002 en `%laser_en(-10)` y
  `%laser_en(95)` de `ensamblaje_principal()`. Confirmar en el código que la punta del láser está en
  `+l_delantero` del eje Y del sistema del láser (`laser()` gira `[-90, 0, 0]`); si no, corregir punto
  y dirección.
- [X] T007 [US3] En `src/puntero_laser_ensamblaje.scad`, declarar `objetivos` de demostración
  (research R10): 6 apuntes con nombre, por ejemplo `["Norte bajo", [0, 10]]`, `["Este", [90, 35]]`,
  `["Cenit", [180, 88]]`, `["Oeste alto", [270, 60]]`, `["Casi norte", [350, 25]]`,
  `["Noreste", [10, 45]]` (el paso de 350° a 10° prueba el camino corto), todos dentro del rango.
- [X] T008 [US4] Validar `src/puntero_laser_ensamblaje.scad` y `src/caja_pilas_ensamblaje.scad` con
  `scripts/verificar_pieza.sh --rapido` (sin avisos). Con `-D paso_armado=-1`, comprobar que las
  líneas nuevas se leen con `json.loads` (reemplazando `undef` por `null`) y que en la caja de pilas
  salen vacías. Exportar `cable_laser` con `-D angulo_altura=95` y comprobar que no está vacío.
- [X] T009 [US4] Probar las declaraciones inválidas de [quickstart.md](quickstart.md) escenario 3
  (rango invertido, `cuna` en las dos articulaciones, eje nulo) con OpenSCAD directo: cada una falla
  con un mensaje que nombra el dato. Deshacer cada cambio.

**Punto de control**: Puerta 1 para los `.scad` tocados; regenerar las capturas de armado con
`scripts/capturas_armado.sh puntero_laser` (fuera del sandbox) y compararlas con `.tools/tmp/base_007/`:
deben ser iguales.

---

## Fase 2: Simulación

- [X] T010 Confirmar que no aplica: ninguna pieza ni carga cambia; la "simulación" de esta
  funcionalidad es una animación cinemática (plan, "Verificación de la constitución", principio III).
  Sin archivos en `simulation/`.

---

## Fase 3: Exportación

- [X] T011 Regenerar las STL del puntero láser (`exports/puntero_laser_*.stl`) y compararlas con
  `.tools/tmp/base_007/` por vértices ordenados: misma geometría (las constantes de T002 no cambian
  valores). Si git las marca solo por orden de triángulos, restaurar las de la referencia.

---

## Fase 4: Documentación

- [X] T012 [P] [US1] En `docs/puntero_laser_guia.md`, si la guía menciona el visor 3D, agregar una
  frase: la pestaña Funcionamiento del visor muestra cómo se mueven los ejes y los motores. Sin
  marcadores de plantilla. Si la guía no menciona el visor, no tocarla.

---

## Fase 5: Web de armado y visor

### Generador (fundacional para las historias de la fase 5)

- [X] T013 [US4] En `scripts/generar_visor.py`, `datos_del_ensamblaje()`: leer las líneas
  `ARTICULACIONES;` … `TRANSPARENTES;` con el mismo `vector` y armar `simulacion` según
  [data-model.md](data-model.md#2-datos-incrustados-json) (objetos con nombres de campo; `variable`
  no viaja a la página; rango sin límite → `null`). Si `articulaciones` está vacía, `simulacion`
  es `None` y no se agrega al JSON. Subir `VERSION` a 2 y mencionar en el docstring las
  líneas nuevas y el contrato `specs/007-simulacion-funcionamiento/contracts/scripts.md`.
- [X] T014 [US4] En `scripts/generar_visor.py`, `exportar()`: sumar a `nombres` los elementos de
  articulaciones y motores (y los transparentes) que no estén en los pasos, y exportar los
  fotogramas de cada deformable con `-D <variable>=<a>` en el mismo `ThreadPoolExecutor`
  (`malla()` recibe definiciones extra). Mensaje de error: "No se pudo exportar 'cable_laser' con
  angulo_altura=95: …". Guardar los fotogramas en `simulacion.deformables[e].fotogramas`
  (`{"a", "malla"}`).
- [X] T015 [US4] En `scripts/generar_visor.py`, agregar `comprobar_pivotes()` (research R6): para cada
  articulación con variable, exportar cada elemento rígido de la articulación (y de las articulaciones
  hijas) en `mín` y `máx` con `-D <variable>=<a>`; girar los vértices de la malla del catálogo
  `a − reposo` alrededor de (`punto`, `eje`) con Rodrigues en Python; comparar cajas envolventes y
  fallar si alguna esquina difiere más de 0,5 mm con el mensaje de
  [contracts/scripts.md](contracts/scripts.md). Las exportaciones van en paralelo y solo cuando no se
  reutilizan mallas. Los motores de esa articulación se comprueban igual, sumando su propio giro.
- [X] T016 [US4] En `scripts/generar_visor.py`, `generar()` y `validar()`: con mallas reutilizadas,
  tomar `simulacion` de la página actual; validar que todo elemento móvil, de motor o transparente
  tenga malla y que cada fotograma tenga malla no vacía; el tamaño cuenta los fotogramas; el mensaje
  final agrega "N articulaciones" si hay simulación.
- [X] T017 [US4] Regenerar los dos visores con `scripts/generar_web.py puntero_laser
  specs/002-puntero-laser-estelar` y `scripts/generar_web.py caja_pilas specs/004-caja-pilas-aa`
  (quickstart escenarios 1 y 2): el puntero láser sale con `simulacion`, ≤ 10 MB y sin errores de
  pivote; la caja de pilas, sin `simulacion`. Probar quickstart escenario 3 (punto y reposo de altura
  mal declarados → falla la comprobación de pivotes) y deshacer.

**Punto de control**: el JSON del puntero láser tiene 2 articulaciones, 2 motores, 1 emisor, 6
objetivos y 22 fotogramas del cable; la comprobación de pivotes pasa.

### Historia 1 - Mover a mano y ver qué gira (P1) 🎯 MVP

**Objetivo**: pestaña Funcionamiento con un deslizador por articulación y los motores girando.

**Prueba independiente**: quickstart escenario 6.

- [X] T018 [US1] En `scripts/plantilla_visor.html`: pestañas "Armado" y "Funcionamiento" arriba del
  `<aside>`, visibles solo si `datos.simulacion` existe; el panel de Armado actual queda en su
  pestaña y uno nuevo para Funcionamiento. Cambiar de pestaña conserva el paso, `t` y la cámara
  (FR-020). CSS: desde 360 px sin desplazamiento horizontal, deslizadores a todo el ancho.
- [X] T019 [US1] En `scripts/plantilla_visor.html`, construir la escena de Funcionamiento con grupos
  anidados (data-model, "Transformación de un grupo"): una malla por elemento del catálogo (clonando
  las del armado), cada articulación como grupo hijo del de su padre con el giro
  `valor − reposo` alrededor de la recta (`punto`, `eje`) (trasladar al punto, girar con
  `Quaternion.setFromAxisAngle`, volver); los motores como grupos hijos de `montado_en`, girados
  `relacion × (valor − reposo)` de su articulación; lo demás fijo. Todo opaco salvo `transparentes`,
  con la transparencia del contexto. Mostrar u ocultar esta escena y la del armado según la pestaña.
- [X] T020 [US1] En `scripts/plantilla_visor.html`, controles por articulación: etiqueta, deslizador
  y campo numérico (°), con el rango como tope (sin rango: 0–360 que da la vuelta sin salto),
  posición en pasos si hay `pasos_por_grado`; lectura por motor (giro acumulado en grados y vueltas);
  botón "Reposo"; nota "Simulación cinemática: el cable y las correas se muestran aproximados; no se
  calculan choques ni fuerzas." (contracts/visor.md).
- [X] T021 [US1] En `scripts/plantilla_visor.html`, marca de giro en cada motor: una franja de color
  contrastante (p. ej. `OrangeRed`) sobre la cara de la polea, del radio de su caja envolvente
  medido perpendicular al eje, como hija del grupo del motor (research R3).
- [X] T022 [US1] En `scripts/plantilla_visor.html`, deformables: crear las mallas de los fotogramas
  (ocultas) en el grupo del padre de su articulación y mostrar la del ángulo más cercano al valor
  actual (research R5).
- [X] T023 [US1] En `scripts/plantilla_visor.html`, direcciones `#funcionamiento` y
  `?modo=funcionamiento&<articulación>=<valor>` (valor fuera de rango → tope; nombre desconocido →
  se ignora), y la tecla `Inicio` sigue siendo "Vista inicial" (encuadra el conjunto, sin el haz).
- [X] T024 [US1] Regenerar el visor del puntero láser y revisar en el Edge (fuera del sandbox)
  quickstart escenarios 5 y 6: posiciones iguales a OpenSCAD en altura −10°, 45° y 95° y azimut 0°,
  90° y 180°; motores a 4:1 con el sentido de research R3 (altura 90° → motor 180°); el cable no se
  despega; volver a Armado conserva el paso.

**Punto de control**: historia 1 completa y demostrable (MVP).

### Historia 2 - Encender y apagar el láser (P1)

**Objetivo**: haz del láser que acompaña al eje.

**Prueba independiente**: quickstart escenario 7.

- [X] T025 [US2] En `scripts/plantilla_visor.html`, por emisor: cilindro fino del `largo` declarado
  desde `punto` en `direccion`, material emisivo con mezcla aditiva y `depthWrite: false`; halo con un
  sprite cuya textura es un degradado radial dibujado en un `<canvas>` (sin imágenes externas); luz
  puntual tenue en la salida. Todo hijo del grupo de su articulación y excluido del encuadre
  (research R8).
- [X] T026 [US2] En `scripts/plantilla_visor.html`, botón por emisor con estado (encendido/apagado),
  tecla `L` para el primero y `&<emisor>=1` en la dirección. Los emisores empiezan apagados al entrar
  al modo y se apagan al salir o con "Reposo".
- [X] T027 [US2] Regenerar y capturar en el Edge `?modo=funcionamiento&laser=1` y
  `?modo=funcionamiento&altura=90&azimut=120&laser=1` (quickstart escenario 7): el haz sale de la
  punta y sigue el eje del láser.

### Historia 3 - Recorrido automático de apuntes (P2)

**Objetivo**: recorrido por los objetivos a la velocidad real.

**Prueba independiente**: quickstart escenario 8.

- [X] T028 [US3] En `scripts/plantilla_visor.html`, máquina de estados del automático (data-model,
  "Transiciones"; research R10): `moviendo` → `apuntando` (emisores encendidos 3 s) → siguiente
  objetivo en bucle; cada articulación avanza hacia su objetivo a `velocidad × multiplicador` con el
  tiempo de `reloj.getDelta()` recortado a 0,1 s; sin rango, camino más corto y valor normalizado a
  0–360°. Los deslizadores muestran la posición mientras se mueve.
- [X] T029 [US3] En `scripts/plantilla_visor.html`, controles del automático: botón "Automático"
  (tecla `A`; oculto si hay menos de 2 objetivos), selector ×1 / ×5 / ×20 con el aviso "velocidad no
  real" fuera de ×1, texto "Hacia: <objetivo>" / "Apuntando: <objetivo>", y `&auto=1&vel=N` en la
  dirección. Cualquier control manual, "Reposo" o salir del modo lo detiene y apaga los emisores.
- [ ] T030 [US3] **Pendiente del usuario** (el Edge sin ventana no avanza el reloj al ritmo real; el
  recorrido con ×5 y ×20 ya se capturó). Regenerar y revisar en el Edge el quickstart escenario 8: tiempos con reloj (±10 %),
  camino corto de 350° a 10°, detención al tocar un deslizador, pestaña en segundo plano.

### Historia 4 - La simulación sale sola (P1): integración

**Prueba independiente**: quickstart escenarios 1, 3 y 4.

- [X] T031 [US4] En `scripts/generar_web.py`, `vistas_de_pasos()`: si el visor trae `simulacion`
  (leerlo con `generar_visor.datos_de_pagina`), agregar junto a "Ver el armado en 3D" el enlace
  "Ver cómo funciona" → `armado_3d.html#funcionamiento` (contracts/scripts.md). Regenerar las dos
  webs: la del puntero láser tiene el enlace; la de la caja de pilas no cambia.
- [X] T032 [US4] Quickstart escenario 4: `scripts/generar_web.py --comprobar` pasa para los dos
  diseños; cambiar `dientes_polea_conducida` a 84 hace fallar la comprobación; regenerado, el motor
  gira 4,2:1; volver a 80 y regenerar.

---

## Fase final: Cierre

- [X] T033 [P] En `.claude/skills/disenio-multipieza/SKILL.md` (herramienta de edición), agregar una
  sección breve "Partes móviles (simulación)": qué listas declarar, que los números salen de los
  parámetros, que el reposo es el ángulo del catálogo, el signo de la relación y cuándo declarar un
  deformable, con enlace a `specs/007-simulacion-funcionamiento/contracts/ensamblaje.md`.
- [X] T034 [P] En `.claude/skills/web-armado/SKILL.md` (herramienta de edición), agregar a la revisión
  del visor: abrir la pestaña Funcionamiento, mover cada eje a sus topes, encender los emisores y
  correr el automático; capturas con `?modo=funcionamiento&…`.
- [ ] T035 **Escenario 9 hecho** (iframe de 360 px, sin desplazamiento horizontal); **pendiente del
  usuario**: escenario 10. Quickstart escenario 9 (celular, 360 px en la emulación del Edge) y escenario 10
  (comprensión). Marcar en `spec.md` el estado ("Implementada", con lo que quede pendiente) y en
  este archivo las tareas hechas.
- [X] T036 Commit de la funcionalidad en la rama `007-simulacion-funcionamiento` (los comandos de git
  que tocan `.claude/settings.json` van fuera del sandbox; esta funcionalidad no lo toca).

---

## Dependencias y orden

```text
T001 ─► Fase 1 (T002 ─► T003 ─► T004 ─► T005 ─► T006 ─► T007 ─► T008 ─► T009)
        ─► T010, T011 ─► T012
        ─► Generador (T013 ─► T014 ─► T015 ─► T016 ─► T017)
            ─► US1 (T018 ─► T019 ─► T020 ─► T021 ─► T022 ─► T023 ─► T024)   🎯 MVP
                ─► US2 (T025 ─► T026 ─► T027)
                    ─► US3 (T028 ─► T029 ─► T030)
            ─► US4 integración (T031 ─► T032)   (puede ir después de T017, en paralelo con US1–US3)
        ─► Cierre (T033 ∥ T034) ─► T035 ─► T036
```

- US2 necesita la escena de US1 (el haz es hijo del grupo de altura).
- US3 necesita US1 (valores de las articulaciones) y US2 (encender los emisores al llegar).
- US4 es la base de todo (Fase 1 y generador) y cierra con la integración web y `--comprobar`.

## Paralelismo

- T012 (guía) en paralelo con el generador (T013–T017): otro archivo.
- T031 (`generar_web.py`) en paralelo con US1–US3 (`plantilla_visor.html`), una vez hecho T017.
- T033 y T034: skills distintas.
- Dentro de la plantilla, las tareas son secuenciales (mismo archivo).

## Estrategia

1. **MVP**: Fase 1 + generador + US1 → el aparato se mueve a mano en el visor con los motores
   girando. Revisar en el Edge antes de seguir.
2. **Incremento 2**: US2 (láser).
3. **Incremento 3**: US3 (automático).
4. **Cierre**: enlace en la web, `--comprobar`, skills y commit.
