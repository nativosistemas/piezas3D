---

description: "Lista de tareas del visor 3D de armado paso a paso"
---

# Tareas: Visor 3D de armado paso a paso

**Entrada**: documentos de diseño de `specs/005-visor-armado-3d/`

**Requisitos previos**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/ensamblaje.md](contracts/ensamblaje.md),
[contracts/scripts.md](contracts/scripts.md), [contracts/visor.md](contracts/visor.md),
[quickstart.md](quickstart.md)

**Pruebas**: no se piden tareas de prueba aparte; cada fase se cierra con los escenarios del
quickstart y las validaciones del generador.

**Organización**: por las cinco fases del pipeline (Principio II), con la historia de usuario en cada
tarea. Las tareas de la fase 5 están agrupadas por historia.

## Formato: `[ID] [P?] [Historia] Descripción`

- **[P]**: se puede hacer en paralelo (otro archivo y sin dependencias pendientes).
- **[Historia]**: US1 (seguir el armado en 3D), US2 (el visor sale solo para cualquier diseño) o US3
  (giros).

**Entorno** (ver `CLAUDE.md`): OpenSCAD exporta dentro del sandbox; las capturas PNG y el Edge van
**fuera** del sandbox. Los archivos de `.claude/skills/` se editan con la herramienta de edición, no
con comandos de la terminal (el sandbox no deja escribirlos).

---

## Fase 0: Preparación

- [X] T001 Copiar three.js 0.160.0 a `scripts/vendor/three-0.160.0/`: `three.module.min.js`,
  `OrbitControls.js` y `LICENSE`, desde `.tools/tmp/visor_3d/vendor/` o desde
  `https://cdn.jsdelivr.net/npm/three@0.160.0/` (`build/three.module.min.js`,
  `examples/jsm/controls/OrbitControls.js`, `LICENSE`). Agregar `scripts/vendor/three-0.160.0/README.md`
  con origen, versión, licencia MIT, fecha y para qué se usa (R4).
- [X] T002 [P] Guardar la referencia para comparar después: copiar `docs/img/*_paso_*.png`,
  `docs/img/puntero_laser_ensamblaje.png` y `docs/img/caja_pilas.png` a `.tools/tmp/base_005/`.

---

## Fase 1: Diseño (`src/*.scad`) — fundacional, bloquea todo lo demás

- [X] T003 [US2] Crear `src/armado_comun.scad` según [contracts/ensamblaje.md](contracts/ensamblaje.md):
  encabezado estándar, `eps`, `contiene`, `unicos`, `flecha(desde, hasta)` con cilindro de
  `diametro_flecha`, punta de `2.5*diametro_flecha` de diámetro y `min(10/3*diametro_flecha, largo/2)`
  de largo; `contexto_paso(n)` ("elementos de pasos anteriores que no están en el paso n y cuyo grupo
  coincide con el de algún elemento del paso n", usando `grupo(e, n)` del diseño); `vista_paso(n)`
  como la actual del puntero láser (lo opaco y sus flechas primero, después lo no resaltado y el
  contexto en `alfa_contexto`; origen opcional en el cuarto campo; el quinto campo, giro, se ignora);
  `datos_armado()` con las líneas `PASO;n;k`, `PASOS;…`, `COLOR;e;color` y `CONTEXTO;n;[…]` en ese
  orden; `armado()` que despacha `solo_elemento` → `paso_armado == -1` → `0` (llama a
  `ensamblaje_principal()` del diseño) → `n`. `assert` con mensaje en español: todo elemento de
  `pasos` está en `elementos`; cada entrada tiene de 3 a 5 campos; el desplazamiento es un vector de
  3; el origen es `undef` o un vector de 3; el giro, si está, es `[punto, eje, grados]`.
- [X] T004 [US2] Migrar `src/puntero_laser_ensamblaje.scad` a la biblioteca: `include
  <armado_comun.scad>`, definir `diametro_flecha = 2.4`, borrar `vista_paso`, `flecha`, `contiene`,
  `unicos`, `contexto` y el despacho del final (y los `echo` de datos agregados en el prototipo), y
  llamar a `armado()`. Conservan su lugar: `pasos`, grupos, `grupo(e, n)`, `elementos`,
  `color_elemento`, `elemento`, `anclas`, `ensamblaje_principal` y las comprobaciones del conjunto.
  Validar con `scripts/verificar_pieza.sh --rapido`.
- [X] T005 [P] [US2] Migrar `src/caja_pilas_ensamblaje.scad` igual que T004: agregar el parámetro
  `solo_elemento = "";`, `diametro_flecha = 1.6`, `function grupo(e, n) = "conjunto";`, borrar la
  maquinaria repetida y llamar a `armado()`. Validar con `scripts/verificar_pieza.sh --rapido`.
- [X] T006 [US2] Comprobar la salida de datos de los dos ensamblajes con `-D paso_armado=-1`: las
  líneas `PASOS;` se leen con `json.loads` después de reemplazar `undef` por `null`; hay un `COLOR;`
  por elemento y un `CONTEXTO;` por paso; en el puntero láser, `CONTEXTO;11` y `CONTEXTO;12` NO
  incluyen `carro_alt`, `motor_alt` ni `tornillos_orejas_alt`. Exportar un elemento con
  `-D 'solo_elemento="brazo_motor"'` y comprobar que el STL tiene solo esa pieza.

**Punto de control**: Puerta 1 para los archivos `.scad` tocados.

---

## Fase 2: Simulación

- [X] T007 Confirmar que no aplica: ninguna pieza ni carga cambia (plan, "Verificación de la
  constitución", Principio III). Sin archivos en `simulation/`.

---

## Fase 3: Exportación

- [X] T008 [US2] Regenerar las STL de los dos diseños (`.tools/bin/openscad --hardwarnings -o
  exports/<pieza>.stl src/<pieza>.scad`; los brazos del puntero láser con `-D 'lado="motor"'` y
  `-D 'lado="cable"'` sobre `src/puntero_laser_brazo_horquilla.scad`) y
  compararlas con las del último commit por vértices ordenados (`grep vertex | sort | md5sum`). Deben
  tener la misma geometría; restaurar con `git checkout` las que solo cambian el orden de las caras.

**Punto de control**: Puerta 3; las STL no cambiaron.

---

## Fase 4: Documentación (capturas de la guía)

- [X] T009 [US2] Regenerar las capturas de armado de los dos diseños fuera del sandbox
  (`scripts/capturas_armado.sh puntero_laser` y `scripts/capturas_armado.sh caja_pilas`) y
  compararlas con `.tools/tmp/base_005/`: las del puntero láser deben quedar iguales; en la caja de
  pilas solo pueden cambiar el orden de dibujo (opaco primero) y la punta de la flecha. Mirar cada
  imagen que cambió (skill `web-armado`, sección 2).

**Punto de control**: Puerta 4; las guías no cambian de texto.

---

## Fase 5: Web de armado y visor

### Historias 1 y 2 (P1): el visor, generado solo para cualquier diseño 🎯 MVP

**Objetivo**: `scripts/generar_web.py` genera `armado_3d.html` para los dos diseños y lo enlaza.

**Prueba independiente**: quickstart, escenarios 1 a 7 y 9.

- [X] T010 [P] [US1] Crear `scripts/plantilla_visor.html` a partir de
  `.tools/tmp/visor_3d/plantilla.html`, según [contracts/visor.md](contracts/visor.md):
  - marcadores `/*IMPORTMAP*/` (dentro de `<script type="importmap">`) y `/*DATOS*/` (dentro de
    `<script type="application/json" id="datos-visor">`), que reemplaza el generador;
  - malla desde `Float32` en base64 (sin cargador STL) y normales calculadas (sombreado plano);
  - contexto de cada paso tomado de `pasos[i].contexto` (no calculado en JavaScript);
  - movimiento en dos tramos cuando hay origen ([data-model.md, sección 3](data-model.md#3-estado-del-visor-en-el-navegador));
    lo opaco se dibuja antes que lo transparente;
  - controles: anterior/siguiente, selector de paso, repetir, deslizador, vista inicial y "Volver a
    la guía" (`index.html#instrucciones-paso-a-paso`); teclado `←`, `→`, `Espacio`, `Inicio`;
  - `#paso-N` al abrir, `?paso=N&t=…` para revisión; la cámara no cambia al cambiar de paso;
  - paso sin piezas: texto y conjunto armado, sin movimiento;
  - negritas `**…**` del texto como `<strong>`, con el resto escapado;
  - mensaje "Este navegador no puede mostrar el visor 3D." con enlace a la web si no hay contexto 3D;
  - diseño de dos columnas en computadora y una sola desde 760 px, sin desplazamiento horizontal a
    360 px; leyenda "Las piezas nuevas van en color…".
- [X] T011 [P] [US2] Crear `scripts/generar_visor.py` según [contracts/scripts.md](contracts/scripts.md)
  (solo biblioteca estándar):
  - argumentos `<diseño> <carpeta_spec>`, `--comprobar` y `--reexportar`;
  - leer los datos con `-D paso_armado=-1` (R6) y los títulos y textos de los pasos de
    `docs/<diseño>_guia.md` (lista numerada de "### Instrucciones Paso a Paso"; título = negrita
    inicial sin el punto final);
  - validar: "Cantidad de pasos de la tabla = cantidad de pasos de la guía", "Todo elemento de una
    entrada o de un contexto tiene color y malla", "Ninguna malla vacía", "Tamaño total de la página
    ≤ 10 MB" (listando los cinco elementos más pesados) y "La página no contiene URL http(s):// de
    recursos";
  - huella `sha256:` de `src/<diseño>_*.scad`, `src/armado_comun.scad`, `src/perfil_impresora.scad`
    (contenido, en orden alfabético) y la resolución `fn = 32`; si coincide con la de la página
    existente y no se pidió `--reexportar`, reutilizar sus mallas;
  - si no, exportar cada elemento con `-D 'solo_elemento="<e>"' -D '$fn=32'` a una carpeta temporal
    y convertir el STL ASCII a `Float32` x, y, z en base64;
  - JSON con `version: 1` y claves ordenadas (salida determinista); *import map* con
    `data:text/javascript;base64,` para `three` y `three/addons/controls/OrbitControls.js`;
  - `--comprobar`: sin OpenSCAD, comparar la huella y la página reconstruida con las mallas que ya
    tiene; mensajes y códigos de la tabla del contrato.
- [X] T012 [US2] Integrar en `scripts/generar_web.py`: si existe `src/<diseño>_ensamblaje.scad`,
  llamar a `scripts/generar_visor.py` con los mismos argumentos (también con `--comprobar`) y
  propagar su código de salida; agregar "Ver el armado en 3D" (→ `armado_3d.html`) antes de la lista
  de pasos y "Ver en 3D" (→ `armado_3d.html#paso-N`) en cada paso que tiene captura (en
  `vistas_de_pasos`); sin ensamblaje, ni visor ni enlaces. Actualizar el docstring (lee/escribe).
- [X] T013 [US2] Generar los dos visores (`scripts/generar_web.py puntero_laser
  specs/002-puntero-laser-estelar` y `scripts/generar_web.py caja_pilas specs/004-caja-pilas-aa`):
  anotar tamaño y tiempo; repetir y comprobar que la segunda vez reutiliza las mallas y que el
  `armado_3d.html` no cambia (quickstart, escenario 1).
- [X] T014 [US1] Revisar los visores en el Edge sin ventana, fuera del sandbox y sin red
  (quickstart, escenarios 3 a 5): para cada paso con piezas de los dos diseños, `?paso=N&t=0`
  comparado con su captura PNG (SC-002); puntero láser paso 8 en `t=0.25` y `t=0.75`; paso 16 sin
  piezas; ancho 360 px. Corregir la plantilla o el generador hasta que coincidan.
- [X] T015 [US2] Ejecutar los escenarios 2 (`--comprobar` detecta fuentes y guía cambiadas y visor
  faltante) y 9 (diseño sin ensamblaje) del quickstart.
- [X] T016 [US1] Pedir al usuario que pruebe la interacción en su navegador y en un celular
  (quickstart, escenarios 6 y 7) y corregir lo que encuentre.

**Punto de control**: Puerta 5 con el visor; el MVP está completo.

### Historia 3 (P3): giros además de desplazamientos

**Objetivo**: la polea de altura del puntero láser gira mientras entra (paso 7).

**Prueba independiente**: quickstart, escenario 8.

- [X] T017 [US3] En `scripts/plantilla_visor.html`, aplicar el giro de una entrada (`g = [punto, eje,
  grados]`): rotación alrededor del eje que pasa por `punto` (en la posición final, desplazado junto
  con la pieza), de `grados` a 0 con el mismo avance que el desplazamiento (incluidos los dos tramos).
- [X] T018 [US3] En `src/puntero_laser_ensamblaje.scad`, paso 7: agregar a `polea_alt` y
  `perno_alt_motor` el giro `[[0, 0, z_eje_altura], [1, 0, 0], 720]` con el origen en `undef`.
  Comprobar que `scripts/capturas_armado.sh puntero_laser` deja `docs/img/puntero_laser_paso_07.png`
  igual que en T009.
- [X] T019 [US3] Regenerar el visor del puntero láser y capturar el paso 7 en `t = 0.5` (quickstart,
  escenario 8): la polea avanza girando sobre su eje.

---

## Fase final: Instrucciones del proyecto y constitución

- [X] T020 [P] Actualizar `.claude/skills/disenio-multipieza/SKILL.md` (sección de la tabla de
  pasos): el ensamblaje incluye `armado_comun.scad`, define `diametro_flecha` y `grupo(e, n)` (sin
  subconjuntos, `"conjunto"`) y llama a `armado()`; el quinto campo, giro, y su formato; el visor sale
  de esa misma tabla. Enlazar a la biblioteca en lugar de repetir su código.
- [X] T021 [P] Actualizar `.claude/skills/web-armado/SKILL.md`: el visor se genera con
  `generar_web.py`; cómo revisarlo (comando del Edge con SwiftShader, `?paso=N&t=…`, sin red) y
  agregarlo a la lista de control de la puerta 5.
- [X] T022 [P] Actualizar `CLAUDE.md`: en la tabla de fases, la fase 5 también entrega
  `specs/<NNN-nombre>/web/armado_3d.html`; en "Automatización", `generar_visor.py`.
- [X] T023 Enmendar la constitución con `/speckit-constitution` (versión 2.1.0, R10): en el Principio
  V, "todo diseño de varias piezas con ensamblaje DEBE tener un visor 3D de armado generado desde su
  ensamblaje y su guía, que funcione sin internet"; en la puerta 5, que `--comprobar` cubre el visor
  y que el visor se revisó en un navegador.
- [X] T024 Correr todos los escenarios del quickstart de punta a punta y `scripts/generar_web.py
  --comprobar` para los dos diseños.
- [X] T025 Cambiar el estado de `specs/005-visor-armado-3d/spec.md` a "Implementada" y marcar las
  tareas hechas.

---

## Dependencias y orden

```text
Fase 0 (T001, T002) ──► Fase 1 (T003 ──► T004, T005 ──► T006) ──► Fase 2 (T007) ──► Fase 3 (T008)
  ──► Fase 4 (T009) ──► Fase 5: T010 + T011 ──► T012 ──► T013 ──► T014, T015 ──► T016
                                                   └──► US3: T017 ──► T018 ──► T019 (después de T013)
  ──► Fase final: T020, T021, T022 ──► T023 ──► T024 ──► T025
```

- **US1 y US2** se implementan juntas: el visor (US1) no existe sin el generador (US2) y viceversa.
- **US3** depende del visor andando (T013); no bloquea al MVP.
- La enmienda de la constitución (T023) va al final, cuando el visor existe para todos los diseños con
  ensamblaje y la puerta 5 ya lo puede comprobar.

## Paralelismo

- T001 y T002 (archivos distintos).
- T004 y T005 después de T003 (un ensamblaje cada una).
- T010 (plantilla) y T011 (generador): solo comparten los marcadores `/*IMPORTMAP*/` y `/*DATOS*/`
  y el formato de datos de [contracts/visor.md](contracts/visor.md).
- T020, T021 y T022 (tres archivos de instrucciones).

## Estrategia

1. **MVP** (fases 0 a 5 hasta T016): visor de los dos diseños, generado y comprobado con la web.
   Detenerse y validar con el usuario (T016).
2. **Incremento**: giros (US3, T017 a T019).
3. **Cierre**: instrucciones, constitución 2.1.0 y validación completa (T020 a T025).
