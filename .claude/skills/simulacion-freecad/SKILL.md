---
name: simulacion-freecad
description: Fase 2 del pipeline de piezas3D. Validar con FEM en FreeCAD (Gmsh + CalculiX) una pieza que soporta carga, o justificar por escrito que no hace falta. Usar cuando una pieza aguanta peso, esfuerzo, golpes o vibración, o al llegar a la fase 2 de un plan.
---

# Simulación FEM en FreeCAD

Cuándo es obligatorio simular lo dice el **Principio III** de `.specify/memory/constitution.md`.
Ejemplo completo y probado: `simulation/soporte_pared_taladro_fem.md` (documento) y
`simulation/soporte_pared_taladro_fem.py` (script).

## 1. ¿Hace falta simular?

- **Sí**: la pieza sostiene una carga relevante y su falla tiene consecuencias (se cae algo, se
  rompe un equipo, alguien se lastima).
- **No, con justificación**: las tensiones estimadas a mano quedan muy lejos del límite. Escribir
  en el plan el precálculo analítico (viga, tensión, factor de seguridad) y por qué alcanza. Ejemplo:
  `specs/002-puntero-laser-estelar/research.md` descarta el FEM con tensiones de ~1 MPa.

## 2. Criterios antes de simular

Fijarlos en la especificación **antes** de ver resultados:

| Concepto | Valor de referencia |
|---|---|
| Carga de diseño | La real, en N, con su dirección y dónde se apoya |
| Material PETG impreso | E = 2000 MPa, ν = 0,38, ρ = 1270 kg/m³ |
| Resistencia efectiva en FDM | σ_lim = 30 MPa (conservador frente a ~50 MPa nominal) |
| Factor de seguridad | 3 → σ von Mises máx. ≤ 10 MPa |
| Flecha | La que admita el uso (por ejemplo, ≤ 1 mm en el borde) |

## 3. Exportar el modelo

OpenSCAD no exporta STEP: el modelo pasa a FreeCAD como árbol CSG, que se reconstruye como sólido
B-rep exacto.

```bash
.tools/bin/openscad -o simulation/<pieza>.csg src/<pieza>.scad
```

- El importador CSG de FreeCAD 1.1 reconstruye bien `cube`, `cylinder` y `polyhedron` con
  transformaciones y booleanas. Con `linear_extrude` o primitivas 2D dentro de booleanas falla
  («Null input shape»): modelar las piezas que se van a simular sin ellos.
- Comprobar que la importación da **un único sólido** y que su volumen coincide con el del STL.
- **Vía alternativa** si el CSG no se importa: importar el STL de `exports/` → banco *Part* →
  *Create shape from mesh* → *Convert to solid* → *Refine shape* (sólido facetado).

## 4. Script de análisis

Copiar `simulation/soporte_pared_taladro_fem.py` a `simulation/<pieza>_fem.py` y adaptar:

- **Caras por geometría**, nunca por nombre `FaceN` (cambia con los parámetros): planas con una
  normal y una posición dadas, cónicas dentro de una zona, etc.
- **Variantes** con `FEM_VARIANTE`: `base` (uso normal), `conservadora` (apoyo reducido) y `pesima`
  (carga concentrada en el peor lugar).
- **Singularidades**: no contar los nodos a menos de 2 mm de las fijaciones rígidas al calcular la
  tensión máxima, pero informar también el máximo bruto.
- **Convergencia** con `FEM_MALLA_MM`: repetir con una malla más fina; la variación de σ máx. y de
  la flecha debe quedar por debajo del 5 %.
- Imprimir una línea `RESULTADO …` fácil de leer y de comparar.
- Guardar el `.FCStd` **liviano** (sin malla ni resultados, ~20 KB); con
  `FEM_GUARDAR_RESULTADOS=1`, completo (~40 MB, no se versiona).

## 5. Ejecutar

```bash
.tools/bin/freecadcmd simulation/<pieza>_fem.py
```

- `freecadcmd`, `freecad`, `gmsh` y `ccx` son del snap: **solo arrancan fuera del sandbox**.
- El snap tiene un `/tmp` privado: todo lo que haya que leer después va en el proyecto, en
  `.tools/tmp/` si es temporal, nunca en `$TMPDIR` ni en `/tmp`.

## 6. Documentar `simulation/<pieza>_fem.md`

Con las mismas secciones que el ejemplo:

1. Objetivo y criterios de aceptación.
2. Exportación del modelo (comando y comprobación del sólido).
3. Ejecución automatizada y variables de entorno.
4. Pasos equivalentes en la interfaz gráfica (*FEM Workbench*: análisis, material, fijaciones,
   cargas, malla, solver, resultados), para revisarlo a mano.
5. Resultados: tabla por variante y malla, huellas SHA-256 del `.scad` y del `.csg`, versiones de
   FreeCAD, Gmsh y CalculiX, ubicación de los máximos y conclusión (cumple o no).
6. **Cuándo repetir la simulación**: el rango de parámetros validado. Fuera de ese rango, volver a
   exportar y simular.

La puerta 2 de la constitución se cumple con este documento o con la justificación del punto 1.
