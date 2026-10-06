# piezas3D — Generador de modelos paramétricos

Rol: Ingeniero Experto en Diseño Mecánico y Especialista en Manufactura Aditiva.
Responder y redactar siempre en español, incluidos los mensajes cortos de avance.

## Dónde está cada cosa

- **Reglas obligatorias**: [.specify/memory/constitution.md](.specify/memory/constitution.md).
  Cada regla vive en un solo lugar (ver su sección Gobernanza): no copiarla en otro archivo.
- **Cómo hacer cada fase**: una skill por fase en `.claude/skills/`.

| Fase | Skill | Resultado |
|---|---|---|
| 1. Diseño y 3. Exportación | `pieza-openscad` | `src/<pieza>.scad` verificado y `exports/<pieza>.stl` |
| 2. Simulación (si aplica) | `simulacion-freecad` | `simulation/<pieza>_fem.*` o justificación en el plan |
| 4. Documentación | `guia-produccion` | `docs/<diseño>_guia.md` y `docs/<diseño>_bom.csv` |
| 5. Web de armado | `web-armado` | `specs/<NNN-nombre>/web/index.html` |
| Diseños de varias piezas | `disenio-multipieza` | `_parametros.scad`, `_ensamblaje.scad` y tabla de pasos |

- **Datos del proyecto**: `src/perfil_impresora.scad` (holguras y cama), `docs/<diseño>_bom.csv`
  (materiales y precios) y `docs/tipo_cambio.csv`.
- **Automatización** en `scripts/`: `verificar_pieza.sh`, `capturas_armado.sh` y `generar_web.py`.
  Un hook valida cada `src/*.scad` al editarlo y devuelve las advertencias.
- **Flujo de Spec Kit**: `/speckit-specify` → `/speckit-clarify` (opcional) → `/speckit-plan` →
  `/speckit-tasks` → `/speckit-implement`.

## Entorno (WSL y sandbox)

- Los lanzadores de `.tools/bin/` llaman a OpenSCAD 2021.01 (apt) y FreeCAD 1.1 (snap).
  `openscad` funciona dentro del sandbox, salvo las capturas PNG.
- **Fuera del sandbox**:
  - Las capturas PNG de OpenSCAD. Necesitan el display de WSLg; dentro fallan con
    `Segmentation fault`.
  - `freecad`, `freecadcmd`, `ccx` y `gmsh`. Son del snap y `snap-confine` falla dentro.
  - El Edge de Windows para revisar la web.
  - Los comandos de git que tocan `.claude/settings.json`. Dentro del sandbox ese archivo aparece
    vacío.
- El snap de FreeCAD tiene un `/tmp` privado: lo que haya que leer después va en `.tools/tmp/`,
  nunca en `$TMPDIR` ni en `/tmp`.
