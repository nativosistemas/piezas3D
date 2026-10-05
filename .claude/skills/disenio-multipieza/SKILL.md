---
name: disenio-multipieza
description: Resume qué sabe hacer el proyecto piezas3D y cómo encarar un diseño que necesita varias piezas impresas que después se arman. Usar cuando el usuario plantea un diseño nuevo, sobre todo si es grande, tiene partes móviles, mezcla materiales o no entra en la cama de la impresora.
---

# Diseño multipieza en piezas3D

Guía corta para el agente. Primero dice **qué sabe hacer el proyecto** y después **cómo dividir
un diseño en piezas que se arman**.

> Las reglas obligatorias están en `.specify/memory/constitution.md`. Esta guía no las reemplaza:
> las aplica a diseños de varias piezas.

---

## 1. Qué sabe hacer este proyecto

| Habilidad | Herramienta | Resultado |
|---|---|---|
| Modelar piezas paramétricas | OpenSCAD | `.scad` en `src/` |
| Revisar la forma con capturas PNG | OpenSCAD (línea de comandos) | Capturas temporales; la isométrica final en `docs/img/` |
| Validar que una pieza aguanta la carga (FEA) | FreeCAD + Gmsh + CalculiX | Script y notas en `simulation/` |
| Generar el archivo para imprimir | OpenSCAD (línea de comandos) | `.stl` en `exports/` |
| Escribir la guía de impresión y armado | Markdown | `docs/<diseño>_guia.md` |
| Planificar el trabajo paso a paso | Spec Kit (`/speckit-*`) | `specs/<NNN-nombre>/` |

Las herramientas son las del sistema (OpenSCAD de apt y FreeCAD en snap) y se llaman con los
lanzadores de `.tools/bin/`: `openscad`, `freecad`, `freecadcmd`, `gmsh`, `ccx`. Los cuatro
últimos son del snap: solo arrancan fuera del sandbox y escriben sus temporales en
`.tools/tmp/`, porque no ven el `/tmp` del sistema.

Ejemplo terminado (una sola pieza): soporte de pared para taladro
(`src/soporte_pared_taladro.scad`, `specs/001-soporte-pared-taladro/`).

---

## 2. ¿Hace falta dividir en varias piezas?

Dividir **solo si hay un motivo**. Cada unión agrega tornillos, tolerancias y pasos de armado.

Motivos válidos:

- **No entra en la cama** de la impresora (dejar ~10 mm de margen por lado).
- **Se imprimiría con muchos soportes** en una sola pieza y separada se imprime plana.
- **Resistencia**: conviene orientar cada parte para que las capas no queden en la dirección del
  esfuerzo.
- **Partes móviles**: bisagras, ejes, tapas, cajones, ruedas.
- **Materiales distintos**: por ejemplo, cuerpo en PETG y patas o juntas en TPU.
- **Repuestos**: una parte que se gasta o se rompe y conviene cambiar sola.
- **Acceso**: tiene que abrirse para meter electrónica, pilas, etc.

Si ninguno aplica, hacer **una sola pieza**.

---

## 3. Cómo unir las piezas

Elegir la unión más simple que cumpla. Holguras de referencia para FDM con boquilla de 0,4 mm.
Son **valores por defecto**: si existe `src/perfil_impresora.scad` con `perfil_medido = true`,
mandan sus valores (`holgura("presion" | "justo" | "deslizante" | "suelto")`); si no, avisar en la
guía que las holguras no están medidas (plantilla 4.C de `.github/spec_kit_profile.md`).

| Unión | Cuándo usarla | Holgura típica |
|---|---|---|
| Tornillo + tuerca embebida (M3, M4) | Uniones fuertes que se desarman | +0,3 mm al agujero, +0,2 mm al hexágono |
| Inserto roscado en caliente | Se desarma muchas veces | Agujero según el fabricante del inserto |
| Tornillo autorroscante en plástico | Uniones simples y baratas | Agujero = 85 % del diámetro del tornillo |
| Encastre a presión (*snap-fit*) | Tapas y carcasas sin herramientas | 0,2–0,3 mm |
| Cola de milano / ranura deslizante | Unir tramos largos en línea | 0,2–0,3 mm por lado |
| Pasador o clavija | Alinear dos piezas antes de pegar o atornillar | 0,1–0,2 mm |
| Eje o bisagra impresa | Partes que giran | 0,3–0,5 mm |
| Pegamento (cianoacrilato / epoxi) | Unión permanente sin carga alta | Sin holgura extra |

Reglas:

- Las holguras van como **parámetros** (p. ej., `holgura_encastre = holgura("justo");`), nunca
  como números sueltos.
- Agregar **guías de alineación** (pasadores, rebajes) para que las piezas solo encajen en la
  posición correcta.
- Usar **una misma medida de tornillo** en todo el diseño siempre que se pueda.

---

## 4. Cómo organizar los archivos

Todo sigue en las carpetas de siempre. Las piezas se distinguen por el nombre:

```text
src/
├── perfil_impresora.scad       # Holguras y límites medidos de la impresora (común a todo el proyecto)
├── <diseño>_parametros.scad    # Medidas compartidas del diseño; hace include <perfil_impresora.scad>
├── <diseño>_<pieza_a>.scad     # Una pieza por archivo, con su encabezado estándar
├── <diseño>_<pieza_b>.scad
└── <diseño>_ensamblaje.scad    # Todas las piezas juntas en su posición (solo para revisar)

simulation/
└── <diseño>_<pieza>_fem.*      # Solo las piezas que soportan carga

exports/
├── <diseño>_<pieza_a>.stl      # Un .stl por pieza, ya en orientación de impresión
└── <diseño>_<pieza_b>.stl      # (el ensamblaje NO se exporta)

docs/
├── <diseño>_guia.md            # Una sola guía para todo el conjunto
└── img/<diseño>_*.png          # Captura del ensamblaje y de cada pieza
```

Puntos clave:

- Cada pieza hace `include <<diseño>_parametros.scad>`. Así, si cambia una medida compartida,
  cambia en todas las piezas a la vez y siguen encajando.
- Cada pieza se modela **en su orientación de impresión**. El archivo de ensamblaje se encarga de
  rotarlas y moverlas a su lugar.
- En el ensamblaje, usar `assert` para comprobar que las piezas no se superponen y que las
  holguras son mayores que cero.
- Si cambia un parámetro compartido, **regenerar todos los `.stl`**, no solo el de la pieza tocada.

---

## 5. Paso a paso

1. **Entender el diseño.** Preguntar lo que falte: medidas, carga, tamaño de la cama de la
   impresora, material, si se tiene que poder desarmar. Preguntar solo lo que no se puede
   suponer; lo demás, suponerlo y anotarlo como supuesto en la especificación (sección 3 del
   perfil).
2. **Dividir.** Listar las piezas con el motivo de cada corte (sección 2) y el tipo de unión
   (sección 3). Hacer un dibujo simple o una tabla de quién se une con quién.
3. **Especificar y planificar** con Spec Kit: `/speckit-specify` → `/speckit-plan` →
   `/speckit-tasks`. En el plan, dejar la lista de piezas, uniones y holguras.
4. **Modelar** (fase 1): primero `_parametros.scad`, después cada pieza, al final `_ensamblaje.scad`.
   Cada archivo pasa por el ciclo de verificación (sección 5 del perfil): validación estricta,
   caja envolvente y capturas PNG. En el ensamblaje, mirar sobre todo frente, lateral y superior:
   ahí se ven los choques y las holguras que faltan.
5. **Simular** (fase 2): solo las piezas con carga. Para las demás, escribir en el plan por qué
   no hace falta.
6. **Exportar** (fase 3): un `.stl` por pieza en `exports/`.
7. **Documentar** (fase 4): una guía en `docs/` con:
   - Tabla de **piezas impresas**: nombre, cantidad, material, orientación, relleno, soportes.
   - **Tornillería y extras** (BOM): cantidad y medida exacta (p. ej., `4 × Tornillo M3x12mm`).
   - **Orden de armado** paso a paso, diciendo qué pieza va con cuál y con qué.

---

## 6. Lista de control antes de terminar

- [ ] Cada corte entre piezas tiene un motivo de la sección 2.
- [ ] Las medidas compartidas están en un solo archivo `_parametros.scad`.
- [ ] Cada pieza tiene encabezado estándar y pasa la validación estricta sin advertencias.
- [ ] Las holguras salen del perfil de impresora; si no está medido, la guía lo avisa.
- [ ] Revisé las capturas del ensamblaje: todas las piezas encajan, sin choques.
- [ ] Hay un `.stl` por pieza y todos coinciden con los parámetros actuales.
- [ ] Las piezas con carga están simuladas (o hay justificación de por qué no).
- [ ] La guía tiene la tabla de piezas, la BOM y el orden de armado.
