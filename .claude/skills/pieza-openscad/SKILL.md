---
name: pieza-openscad
description: Fases 1 y 3 del pipeline de piezas3D. Modelar una pieza paramétrica en OpenSCAD, verificarla (validación estricta, caja envolvente, capturas PNG) y exportar el STL. Usar al crear o modificar cualquier .scad de src/, al adaptar un STL de terceros, al calibrar holguras o cuando OpenSCAD da un error.
---

# Pieza paramétrica en OpenSCAD

Las reglas obligatorias del código (encabezado, orden del archivo, `eps`, `assert()`, cotas
relativas, nombres en español) están en el **Principio I** de `.specify/memory/constitution.md`.
Esta skill explica **cómo** cumplirlas. Si el diseño tiene varias piezas, usar también la skill
`disenio-multipieza`.

## 1. Antes de modelar: supuestos explícitos

Preguntar solo lo que dejaría la pieza **sin sentido** si se inventa (por ejemplo, el diámetro del
tubo que tiene que sujetar). Para el resto, elegir un valor razonable y anotarlo en la sección
*Assumptions* de la especificación, un supuesto por línea, para que el usuario vea de un vistazo
cuáles corregir.

Valores por defecto: pared 2 mm, piso 2 mm, radio de esquinas 2 mm, holgura `holgura("justo")` para
tornillos y ejes, `$fn = 64`, base plana sobre la cama y sin soportes.

## 2. Escribir el archivo

1. Copiar [plantilla_pieza.scad](plantilla_pieza.scad) a `src/<pieza>.scad`. Ya sigue el orden del
   Principio I: parámetros → derivadas → validaciones → ensamblaje → módulos (cuerpo, sumas, restas).
2. Cada parámetro lleva su comentario `// [mín:paso:máx]`: habilita el personalizador de OpenSCAD y
   el chequeo de rangos de la validación estricta.
3. Si la pieza tiene encajes, `include <perfil_impresora.scad>` y usar `holgura("presion" | "justo" |
   "deslizante" | "suelto")`. **No volver a declarar** nombres del perfil (`espesor_min_pared`,
   `cama`, …): con `--hardwarnings`, una reasignación detiene la validación.
4. Si la pieza se va a **simular** (fase 2), construirla con `cube`, `cylinder` y `polyhedron`: el
   importador CSG de FreeCAD 1.1 falla con `linear_extrude` y primitivas 2D dentro de booleanas.
   En las demás piezas, preferir perfiles 2D extruidos como pide el Principio I.

## 3. Verificar (fase 1)

Lo que se puede **calcular** no se juzga a ojo: la vista es para la forma, no para las medidas.

1. **Al guardar**: el hook del proyecto corre `scripts/verificar_pieza.sh --rapido` sobre cada
   `src/*.scad` editado (validación estricta sin render, < 1 s) y devuelve cualquier `WARNING`.
2. **Validación completa** (render, caja envolvente, apoyo en Z = 0 y cama del perfil):

   ```bash
   scripts/verificar_pieza.sh src/<pieza>.scad
   ```

   Comprobar que la caja envolvente coincide con las medidas de la especificación.
3. **Capturas PNG** (isométrica, frente, lateral, superior e inferior). Necesitan el display de
   WSLg, así que este comando se ejecuta **fuera del sandbox**:

   ```bash
   scripts/verificar_pieza.sh --capturas .tools/tmp/capturas src/<pieza>.scad
   ```

   Mirar cada captura con la herramienta de lectura de imágenes:
   - ¿La forma es la pedida? ¿Las proporciones son razonables?
   - ¿Falta o sobra geometría? ¿Hay piezas flotando o caras rotas?
   - ¿Hay voladizos, puentes largos o paredes finas que no se previeron?
   - ¿La cara que va sobre la cama es plana?

   En una pieza simple alcanza con la isométrica. Si el entorno no puede generar capturas, dejar
   constancia y pedir al usuario que revise el modelo en OpenSCAD.
4. **Iterar**: cambiar **una sola cosa**, volver a verificar y repetir. Así se sabe qué arregló o
   qué rompió cada corrección.

Captura final para la guía (fuera del sandbox):

```bash
.tools/bin/openscad -o docs/img/<pieza>.png --imgsize=1600,1200 --autocenter --viewall --colorscheme=Tomorrow src/<pieza>.scad
```

## 4. Exportar (fase 3)

```bash
.tools/bin/openscad --hardwarnings -o exports/<pieza>.stl src/<pieza>.scad
```

- Exportar con `$fn ≥ 64` y en la orientación de impresión.
- Si cambia un parámetro, **regenerar el STL**; si es un parámetro compartido, regenerar **todos**.
- Pasar `scripts/verificar_pieza.sh` sobre la pieza antes de dar el STL por bueno.

## Archivos de apoyo

| Archivo | Cuándo leerlo |
|---|---|
| [plantilla_pieza.scad](plantilla_pieza.scad) | Al crear una pieza nueva |
| [modificar_stl.md](modificar_stl.md) | Cuando el usuario trae un STL de terceros para modificar |
| [errores_openscad.md](errores_openscad.md) | Cuando OpenSCAD da un error o un resultado raro |
| [calibracion.md](calibracion.md) | Al medir la impresora o cuando un encaje sale flojo o duro |
