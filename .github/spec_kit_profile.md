# Perfil de GitHub Spec Kit (dividido)

Este perfil se dividió el 2026-10-06 para que cada regla esté en un solo lugar
(`specs/003-instrucciones-y-web/inventario.md`). Su contenido está ahora en:

| Sección anterior | Dónde está ahora |
|---|---|
| 1. Metadatos y rol | `CLAUDE.md` |
| 2. Estructura de directorios | `.specify/memory/constitution.md` (Estructura del Repositorio) |
| 3. Pipeline y supuestos explícitos | Constitución (Principio II) y skill `pieza-openscad` (sección 1) |
| 4.A Plantilla del `.scad` | `.claude/skills/pieza-openscad/plantilla_pieza.scad` |
| 4.B Plantilla de la guía de producción | `.claude/skills/guia-produccion/plantilla_guia.md` |
| 4.C Perfil de impresora y calibración | `src/perfil_impresora.scad` y `.claude/skills/pieza-openscad/calibracion.md` |
| 5. Verificación del diseño | `scripts/verificar_pieza.sh` y skill `pieza-openscad` (sección 3) |
| 6. Modificar un STL existente | `.claude/skills/pieza-openscad/modificar_stl.md` |
| 7. Errores frecuentes de OpenSCAD | `.claude/skills/pieza-openscad/errores_openscad.md` |
| Simulación en FreeCAD (fase 2) | Skill `simulacion-freecad` |
| Web de armado (fase 5, nueva) | Skill `web-armado` y `scripts/generar_web.py` |

Este archivo se elimina en la etapa 4, cuando la constitución deje de citarlo.
