# Inventario de instrucciones del agente

**Fecha**: 2026-10-06 | **Rama**: `003-instrucciones-y-web`

Objetivo: que cada regla viva en **un solo lugar**, elegido según **cuándo** la necesita el agente.

| Cuándo se necesita | Destino |
|---|---|
| Siempre, en cada mensaje | `CLAUDE.md` (corto: mapa y avisos de entorno) |
| Al planificar una feature | `.specify/memory/constitution.md` (reglas DEBE verificables, sin comandos) |
| En una fase concreta | Una skill por fase en `.claude/skills/`, con sus plantillas como archivos |
| Se puede comprobar con código | `scripts/` o un hook de `.claude/settings.json` |
| Es un dato del proyecto | Un archivo real (`src/perfil_impresora.scad`, `docs/<diseño>_bom.csv`) |

## Archivos de partida

| Archivo | Tamaño | Se carga |
|---|---|---|
| `CLAUDE.md` | 1,6 KB | Siempre |
| `.specify/memory/constitution.md` | 12,2 KB | En `/speckit-plan`, `/speckit-analyze`, `/speckit-converge` |
| `.github/spec_kit_profile.md` | 15,9 KB | Cuando el agente sigue el enlace de `CLAUDE.md` |
| `.claude/skills/disenio-multipieza/SKILL.md` | 7,9 KB | Al invocar la skill (la descripción, siempre) |

## Regla por regla

Abreviaturas: **C** = constitución, **P** = perfil (`spec_kit_profile.md`), **S** = skill
`disenio-multipieza`, **CL** = `CLAUDE.md`. ⚠️ = repetida en más de un lugar.

### Contexto y entorno

| Regla | Hoy está en | Destino |
|---|---|---|
| Responder y redactar en español | CL, C (Estructura) ⚠️ | CL + C (DEBE) |
| Rol: ingeniero mecánico y de manufactura aditiva | CL, P §1 ⚠️ | CL |
| Lanzadores de `.tools/bin/`; snap solo fuera del sandbox; `/tmp` privado del snap | CL, S §1, C (Estructura) ⚠️ | CL |
| Capturas PNG necesitan WSLg (fuera del sandbox) | CL, P §5.3, P §7 ⚠️ | CL (una línea) + skill `pieza-openscad` |
| Flujo de Spec Kit (`specify → … → implement`) | CL, S §1, S §5 ⚠️ | CL |

### Diseño (fase 1)

| Regla | Hoy está en | Destino |
|---|---|---|
| Todo en OpenSCAD paramétrico, en `src/` | C I, P §3, S §1 ⚠️ | C |
| Encabezado estándar y sección de parámetros | C I, P §4.A ⚠️ | C (regla) + `plantilla_pieza.scad` (forma) |
| Orden del archivo, `eps`, `assert()`, cotas relativas, perfiles 2D | C I (con detalle), P §4.A ⚠️ | C (regla corta) + plantilla |
| Supuestos explícitos y valores por defecto | P §3, S §5.1 ⚠️ | skill `pieza-openscad` |
| Ciclo de verificación: validación estricta → caja envolvente → capturas | P §5, C (puerta 1) ⚠️ | `scripts/verificar_pieza.sh` + skill `pieza-openscad`; C solo exige el resultado |
| Modificar un STL de terceros | C (Estructura), P §6 ⚠️ | C (dónde va el original) + `pieza-openscad/modificar_stl.md` |
| Errores frecuentes de OpenSCAD | P §7 | `pieza-openscad/errores_openscad.md` |

### Varias piezas

| Regla | Hoy está en | Destino |
|---|---|---|
| Cuándo dividir en piezas | S §2 | skill `disenio-multipieza` |
| Tipos de unión y holguras de referencia | S §3 | skill `disenio-multipieza` (las holguras salen del perfil) |
| `<diseño>_parametros.scad`, una pieza por archivo, `_ensamblaje.scad`, un `.stl` por pieza | S §4 (citado en `specs/002/plan.md`) | C (Estructura: convención obligatoria) + skill |

### Manufactura

| Regla | Hoy está en | Destino |
|---|---|---|
| Minimizar voladizos y soportes; límites FDM | C IV, P §4.C ⚠️ | C (regla) + valores en `src/perfil_impresora.scad` |
| Perfil de impresora único como fuente de holguras | C IV, P §4.C (plantilla), S §3 ⚠️ | **Archivo real** `src/perfil_impresora.scad` (pendiente desde la v1.1.0) |
| Procedimiento de calibración (peine) | P §4.C | skill `pieza-openscad` (hasta que el peine sea un diseño propio) |
| `.stl` en `exports/`, coincide con los parámetros | C IV, C (puerta 3), S §4 ⚠️ | C |

### Simulación (fase 2)

| Regla | Hoy está en | Destino |
|---|---|---|
| Cuándo simular y cuándo justificar que no | C III, P §3.2, S §5.5 ⚠️ | C |
| Cómo exportar a FreeCAD, banco FEM, cargas y criterios | C III (con detalle), P §3.2 ⚠️ | skill `simulacion-freecad` (a partir de `simulation/soporte_pared_taladro_fem.py`) |

### Documentación (fase 4)

| Regla | Hoy está en | Destino |
|---|---|---|
| Guía con impresión (A) y armado (B) | C V, P §4.B, S §5.7 ⚠️ | C (regla) + `guia-produccion/plantilla_guia.md` |
| Lista de materiales con cantidades y medidas | C V, S §5.7 ⚠️ | **Datos** en `docs/<diseño>_bom.csv`; la guía la recibe generada |
| Captura isométrica por pieza | C V, P §5.3 ⚠️ | C + skill |

### Web de armado (fase 5, nueva)

| Regla | Hoy está en | Destino |
|---|---|---|
| Web con componentes, primeros pasos, armado, precio y consejos | — | C (fase 5 + puerta 5) + skill `web-armado` + `scripts/generar_web.py` |
| Precios en ARS y USD, cada uno con fuente y fecha; sin precios inventados | — | `docs/<diseño>_bom.csv` + `docs/tipo_cambio.csv` |
| Ubicación: `specs/<NNN-nombre>/web/` | — | C (excepción en Estructura: `specs/` puede contener la web generada) |
| Vista explotada de cada paso de armado (`paso_armado` en `_ensamblaje.scad`) | — | skill `disenio-multipieza` (cómo armar la tabla de pasos) + `scripts/capturas_armado.sh` |

### Calidad y gobernanza

| Regla | Hoy está en | Destino |
|---|---|---|
| Cuatro puertas de calidad | C, S §6 ⚠️ | C (cinco puertas) |
| Árbol del repositorio | C, P §2, S §4 ⚠️ | C |
| Versionado y enmiendas | C | C |

## Inconsistencias encontradas

1. **Holgura de tornillo**: S §3 dice "+0,3 mm al agujero"; P §4.C usa `holgura_justo = 0.25`.
   Al pasar a usar el perfil real, la tabla de la skill debe referirse a `holgura("…")` y no dar
   números propios.
2. **Perfil de impresora**: la C v1.1.0 lo exige y lo marca como pendiente; ninguna pieza lo
   incluye. `puntero_laser_parametros.scad` declara sus propias holguras y `espesor_min_pared`,
   `cama_max`. Migrarlo es trabajo aparte (cambia el diseño entregado).
3. **Secciones de las guías**: la sección 3 es "Adaptación" en el taladro y "Puesta a punto" en el
   láser. Ninguna tiene "Consejos y buenas prácticas". La plantilla nueva fija los títulos.
4. **Pipeline**: C II dice "cuatro fases (NO NEGOCIABLE)". Sumar la web lo redefine → versión
   **MAYOR (2.0.0)**.

## Etapas

1. ✅ Inventario (este archivo).
2. ✅ Automatización: `src/perfil_impresora.scad`, `scripts/verificar_pieza.sh`, hook de validación,
   `docs/<diseño>_bom.csv`, `scripts/generar_web.py`; piloto con el puntero láser
   (`specs/002-puntero-laser-estelar/web/index.html`). Vistas explotadas por paso: parámetro
   `paso_armado` y tabla `pasos` en `_ensamblaje.scad`, capturas con `scripts/capturas_armado.sh`
   (fuera del sandbox) en `docs/img/<diseño>_paso_NN.png`. Pendiente: 17 componentes sin precio
   verificado (bulonería M8/M3, relé de 3,3 V, cables).
3. ✅ Partir el perfil en skills (`pieza-openscad`, `simulacion-freecad`, `guia-produccion`,
   `web-armado`) y recortar `disenio-multipieza`. El perfil queda como mapa de redirección hasta la
   etapa 4. Inconsistencia 1 resuelta: la tabla de uniones usa `holgura("…")`.
4. ✅ Constitución 2.0.0 con `/speckit-constitution`: cinco fases, puerta 5, convención de varias
   piezas, organización de las instrucciones en Gobernanza y sin comandos ni plantillas.
5. ✅ `CLAUDE.md` reducido a un mapa (fases → skills, datos, scripts y avisos de entorno);
   `.github/spec_kit_profile.md` eliminado. Las specs 001 y 002 lo siguen citando como historial.
6. Probar en una sesión nueva con un diseño chico (pendiente: lo hace el usuario).
