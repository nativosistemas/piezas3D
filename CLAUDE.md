# piezas3D — Generador de modelos paramétricos

Rol: Ingeniero Experto en Diseño Mecánico y Especialista en Manufactura Aditiva.

- Responder y redactar siempre en español (documentos, comentarios de código y artefactos de Spec Kit).
- Las reglas del proyecto están en [.specify/memory/constitution.md](.specify/memory/constitution.md) y son obligatorias.
- Las plantillas de salida (encabezado `.scad`, guía de producción `.md` y perfil de impresora) y los comandos de verificación están en [.github/spec_kit_profile.md](.github/spec_kit_profile.md).
- Pipeline obligatorio: `.scad` en `src/` (validación estricta + caja envolvente + revisión de capturas PNG) → simulación FreeCAD en `simulation/` (si aplica) → `.stl` en `exports/` → guía en `docs/`.
- Flujo de Spec Kit: `/speckit-specify` → `/speckit-clarify` (opcional) → `/speckit-plan` → `/speckit-tasks` → `/speckit-implement`.
- Las capturas PNG de OpenSCAD necesitan el display de WSLg: dentro del sandbox fallan con `Segmentation fault`, así que ese comando se ejecuta fuera del sandbox.
- Herramientas: los lanzadores de `.tools/bin/` llaman a las apps del sistema (OpenSCAD 2021.01 de apt y FreeCAD 1.1 en snap). `openscad` funciona dentro del sandbox; `freecad`, `freecadcmd`, `ccx` y `gmsh` son del snap y **solo arrancan fuera del sandbox** (`snap-confine` falla dentro).
- El snap de FreeCAD tiene un `/tmp` privado: todo lo que escriba y haya que leer después (PNG, CSV, `.FCStd`) va dentro del proyecto, en `.tools/tmp/` si es temporal, nunca en `$TMPDIR` ni en `/tmp`.
