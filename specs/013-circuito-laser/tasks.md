---

description: "Lista de tareas del circuito del láser en el visor 3D"
---

# Tareas: Circuito del láser en el visor 3D

**Entrada**: documentos de diseño de `specs/013-circuito-laser/`

**Requisitos previos**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Pruebas**: no hay tareas de prueba aparte. Cada fase se cierra con las validaciones de OpenSCAD,
las comprobaciones de los generadores y los escenarios del quickstart.

**Organización**: por las cinco fases del pipeline (Principio II, como en la 011). Cada tarea lleva
su historia de usuario:
- **US1**: ver por dónde llega la energía al láser (P1).
- **US2**: saber qué hace cada pieza del circuito (P2).
- **US3**: abrirlo directo y que sirva en cualquier diseño (P3).

## Formato: `[ID] [P?] [Historia] Descripción`

---

## Fase 0: Preparación

- [X] T001 Tomar la línea de base:
  - Comprobar que `scripts/generar_web.py --comprobar puntero_laser specs/002-puntero-laser-estelar` y `scripts/generar_web.py --comprobar caja_pilas specs/004-caja-pilas-aa` pasan.
  - Guardar las 13 STL del puntero en `.tools/tmp/stl_antes/` para compararlas después.
  - Anotar el tamaño de `specs/002-puntero-laser-estelar/web/armado_3d.html`.

---

## Fase 1: Diseño (`src/*.scad`)

### Parámetros

- [X] T002 [US1] En `src/puntero_laser_parametros.scad`, junto a `espesor_ojal`, agregar `d_ext_ojal = 6;`, `d_int_ojal = 3.2;` y `ancho_lengueta_ojal = 3;` con comentario (research R3), y en la sección de comprobaciones el `assert` V-30 de [data-model.md §1](data-model.md): `descentrado_hilo_pila + ancho_lengueta_ojal/2 <= d_pila_falsa/2 - 0.5 && d_ext_ojal/2 <= d_pila_falsa/2 - 0.5`, mensaje `"diametro_hueco_bateria=…: el ojal del contacto positivo no entra en la cara de la pila falsa"`.

### Biblioteca común (contrato del ensamblaje)

- [X] T003 [US3] En `src/armado_comun.scad`: documentar `circuitos` en el encabezado (con enlace a `specs/013-circuito-laser/contracts/ensamblaje.md`), agregar `function circuitos_declarados() = is_undef(circuitos) ? [] : circuitos;` y el módulo `comprobar_circuitos()` llamado desde `armado()` después de `comprobar_cables()`, con un `assert` por regla de [contracts/ensamblaje.md](contracts/ensamblaje.md) (mensajes que empiezan con `circuitos:`). Un miembro es válido si está en `elementos` o es el id de un cable; no puede ser de `ocultos_cableado` ni el `elemento` de un cable (mensaje que pide nombrar el cable).
- [X] T004 [US1] En `src/armado_comun.scad`, dentro de `datos_armado()` después de `RADIO_CURVA_CABLEADO`, agregar `echo(str("CIRCUITOS;", circuitos_declarados()));`.

### Ensamblaje del puntero láser

- [X] T005 [US1] En `src/puntero_laser_ensamblaje.scad`, sección de parámetros: derivadas para ubicar las piezas (research R2): `angulo_prisionero_neg = angulo_cable + desfase_prisionero_tapa`, `y_prisioneros = -l_trasero + z_prisioneros_tapa`, `r_punta_prisionero = r_funda_int - holgura("deslizante")`, `r_cara_resalte = r_funda_ext + espesor_resalte_prisionero`, `y_cara_pila = y_borde_tubo + largo_pila_falsa`, la función `radial(a)` (vector unitario en el conjunto hacia el ángulo `a` del sistema de la tapa, con `en_conjunto`) y los módulos `en_pila()` (misma transformación que el elemento `pila_falsa`) y `en_tapa()` (la de `tapa_trasera`).
- [X] T006 [US1] En `src/puntero_laser_ensamblaje.scad`, agregar a `elementos` y a `module elemento(e)` los 9 elementos de [data-model.md §2](data-model.md): tornillo ISO 7380 (cabeza `iso7380_m3_cabeza_d` × `iso7380_m3_cabeza_alto` sobre el ojal, vástago hasta `prof_agujero_tornillo`), tuerca en su ranura, ojal positivo (aro `d_ext_ojal`/`d_int_ojal` de `espesor_ojal` más lengüeta de `ancho_lengueta_ojal` hasta `descentrado_hilo_pila` sobre `angulo_cable`), prisioneros radiales de `largo_prisionero_tapa` desde `r_punta_prisionero` (punta cónica), ojal y tuerca negativos sobre la cara del resalte, contratuerca del de fijación, e hilos con `cordon`-de-1-hilo: el rojo ventana → ranura del escalón (a `prof_ranura_cable/2` bajo el borde) → ranura de la pila → agujero axial → lengüeta; el negro desde el inicio de `cable_laser_movil`, rodeando la tapa por fuera de los resaltes, hasta la lengüeta del ojal negativo. Colores en `color_elemento()`, anclas en `anclas()` fuera de cualquier sólido, nombres en `nombres_elementos` (tipo `"comprada"`), los 9 en `elementos_altura`.
- [X] T007 [US1] En `src/puntero_laser_ensamblaje.scad`, tabla `pasos`: en el paso 14 los 9 elementos con los desplazamientos de [data-model.md §2](data-model.md); en el paso 15, los 9 con `150*v_laser` y `false`.
- [X] T008 [US1] En `src/puntero_laser_ensamblaje.scad`, junto a los cables, declarar `circuitos` con el circuito `laser` de [data-model.md §3](data-model.md) y actualizar la descripción del encabezado.
- [X] T009 Validar el diseño:
  - `scripts/verificar_pieza.sh src/puntero_laser_ensamblaje.scad` sin errores ni advertencias.
  - `ECHO: "CIRCUITOS;…"` presente (quickstart §1).
  - Los casos de [quickstart.md §2](quickstart.md), y deshacerlos.
  - Captura del conjunto y de la cola del láser con las piezas nuevas (fuera del sandbox), revisada: nada flota ni atraviesa la pila, la tapa o el tubo más que lo previsto.

---

## Fase 2: Simulación

- [X] T010 La simulación FEM no aplica (plan.md, Principio III, research R9): no hay tarea de simulación.

---

## Fase 3: Exportación

- [X] T011 Comparar por vértices las STL del puntero con `.tools/tmp/stl_antes/`; deben ser iguales (los cambios en `puntero_laser_parametros.scad` no tocan cotas impresas).

---

## Fase 4: Documentación

- [X] T012 [US1] En `docs/puntero_laser_guia.md`, paso 14, viñeta **Pila falsa**: decir que el caño del terminal no entra en la cara de la pila (tocaría el tubo, que es el negativo), que se corta y que el hilo rojo se suelda a la lengüeta del ojal (research R3).

---

## Fase 5: Web de armado y visor

- [X] T013 [US3] En `scripts/generar_visor.py` ([contracts/scripts.md](contracts/scripts.md)): `VERSION = 5`; en `cableado_declarado()` leer `lista("CIRCUITOS")` y agregar `circuitos` (solo si hay); en `exportar()` sumar a `de_cableado` los elementos miembros, translúcidos y de encuadre; C-08 en `validar()`; `N circuitos, ` en el resumen; actualizar el docstring con el contrato de la 013.
- [X] T014 [US1] En `scripts/plantilla_visor.html`, panel del modo Cableado: fila `#circuitos` de botones (`aria-pressed`), bloque `#panel-circuito` oculto con la descripción y la lista `#miembros-circuito`, estilos de ambos.
- [X] T015 [US1] En `scripts/plantilla_visor.html`, escena ([contracts/visor.md](contracts/visor.md)): `activarCircuito(id | null)` que guarda el color original de cada malla del modo, aplica los aspectos de la tabla (miembros, translúcidos 0,35, resto `#b8bcc2` a 0,08), deshabilita «Atenuar las piezas», oculta la lista de cables y encuadra `encuadre`; al soltar, restaura y llama a `atenuarPiezas()`. Guardar la opacidad de estado en `mat.userData.alfa` y usarla en `soltar()`. «Vista inicial» e Inicio encuadran el circuito activo.
- [X] T016 [US2] En `scripts/plantilla_visor.html`, lista del circuito: un subtítulo por grupo y un renglón por miembro con su muestra y nombre (`nombreDe` o el nombre del cable); señalar, enfocar o tocar un renglón resalta el miembro.
- [X] T017 [US3] En `scripts/plantilla_visor.html`, `?circuito=<id>` con `?modo=cableado` (o `#cableado`) activa el circuito al abrir, antes de `?senalar=`.
- [X] T018 Regenerar las vistas explotadas con `scripts/capturas_armado.sh puntero_laser` (fuera del sandbox) y revisar el paso 14 (y que el 15 en adelante no cambien más que por las piezas nuevas en contexto).
- [X] T019 Generar y comprobar: `scripts/generar_web.py puntero_laser specs/002-puntero-laser-estelar` y `--comprobar` en los dos diseños con visor.
- [X] T020 [US2] Revisar en el Edge sin ventana (fuera del sandbox) las direcciones de [quickstart.md §4](quickstart.md).
- [X] T021 [P] Fuera del sandbox de escritura, sumar un apartado a dos skills: `.claude/skills/disenio-multipieza/SKILL.md` (cómo declarar `circuitos`) y `.claude/skills/web-armado/SKILL.md` (cómo revisar un circuito con `?circuito=`).

---

## Fase final: Cierre

- [X] T022 Revisar los criterios de éxito (SC-001 a SC-005), actualizar el estado de `spec.md`, marcar las tareas y completar "Notas de la implementación". Pedir al usuario la prueba interactiva en el navegador.

## Dependencias y orden

- T001 → T002 → T003 y T004 → T005 → T006 → T007 y T008 → T009.
- T009 → T010 → T011 → T012.
- T013 → T014 → T015 → T016 y T017 (la plantilla necesita los datos del generador).
- T018 necesita T007. T019 necesita T012 y T013 a T017. T020 necesita T019.
- T021 puede hacerse en cualquier momento después de T009.

## Ejemplos de trabajo en paralelo

- Con la biblioteca terminada (T004), T013 (generador) puede avanzar junto con T005 a T008, porque el formato del eco lo fija el contrato.
- T021 (skills) en paralelo con la fase 5.

## Estrategia

El incremento mínimo útil es **US1**: las piezas nuevas, el circuito declarado y el botón que lo
resalta (T002, T004 a T008, T013 a T015). **US2** suma la lista y los nombres (T016, T020). **US3**
suma las validaciones y la dirección directa (T003, T013, T017). Las tres se cierran juntas antes del
commit.

## Notas de la implementación

- **Piezas nuevas** (9): tornillo y tuerca del contacto positivo, ojal y tramo de hilo rojo, prisionero del
  negativo con su tuerca, ojal y tramo de hilo negro, y el prisionero de fijación con su contratuerca.
  Comprobaciones nuevas: V-30 (ojal en la cara de la pila) en los parámetros y K-01…K-03 (tornillo que
  pasa la tuerca sin salir por atrás, cabeza contra el resorte comprimido, prisionero que alcanza para el
  ojal y la tuerca) en el ensamblaje.
- **Hallazgo (research R3)**: el terminal de ojal entero no entra en la cara de la pila sin tocar el tubo
  (el negativo). La guía, paso 14, ahora dice que se corte el caño y se suelde el hilo en la lengüeta.
- **Visor**: 4,0 MB (antes 3,9), 67 piezas, 1 circuito. Los translúcidos quedaron en 0,25 (con 0,35 la
  pila se veía verde a través del tubo del láser).
- **Capturas**: cambian los pasos 14 a 18 (las piezas nuevas entran en el 14 y quedan en contexto
  después). Los pasos 8 a 13 salieron con diferencias de pocos píxeles por el renderizado, sin cambios
  reales, y se dejaron como estaban.
- **STL**: iguales por vértices (pila falsa, tapa trasera, grapa y cuna).
- **Caja de pilas**: su visor se regeneró porque cambió la biblioteca común y la versión del formato;
  sin circuitos, se comporta igual.
- **Ampliación (2026-10-20, a pedido del usuario)**: el circuito pasó de empezar en el regulador a
  mostrar todo el camino, del power bank al láser, en 7 etapas, con el control del relé (ESP32, GPIO 23
  y resistencia de 10 kΩ). El power bank y el ESP32 se suman a los translúcidos (opacos tapaban la cola
  del láser y el cable del GPIO 23), y la casilla «Atenuar las piezas» quedó arriba de la lista del
  circuito.
- **Pendiente**: la prueba interactiva en el navegador (tocar el botón, soltarlo, señalar renglones y
  cambiar de modo y volver).
