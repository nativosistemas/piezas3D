---
name: disenio-multipieza
description: Cómo encarar en piezas3D un diseño de varias piezas impresas que después se arman. Cuándo dividir, cómo unir las piezas, cómo organizar los archivos y cómo armar la tabla de pasos con las vistas explotadas. Usar al plantear un diseño nuevo, sobre todo si es grande, tiene partes móviles, mezcla materiales o no entra en la cama de la impresora.
---

# Diseño de varias piezas

El pipeline, las reglas y las puertas de calidad son los de siempre (`.specify/memory/constitution.md`)
y cada pieza se modela y verifica con la skill `pieza-openscad`. Esta guía agrega solo lo propio de
un diseño de varias piezas. Ejemplo completo: el puntero láser estelar
(`src/puntero_laser_*.scad`, `specs/002-puntero-laser-estelar/`).

## 1. ¿Hace falta dividir?

Dividir **solo si hay un motivo**: cada unión agrega tornillos, holguras y pasos de armado.

- **No entra en la cama** de la impresora (con el margen de `src/perfil_impresora.scad`).
- **Se imprimiría con muchos soportes** y separada se imprime plana.
- **Resistencia**: conviene orientar cada parte para que las capas no queden en la dirección del
  esfuerzo.
- **Partes móviles**: bisagras, ejes, tapas, cajones, ruedas.
- **Materiales distintos**: por ejemplo, cuerpo en PETG y patas o juntas en TPU.
- **Repuestos**: una parte que se gasta o se rompe y conviene cambiar sola.
- **Acceso**: tiene que abrirse para meter electrónica, pilas, etc.

Si ninguno aplica, hacer **una sola pieza**. En la especificación, anotar el motivo de cada corte.

## 2. Cómo unir las piezas

Elegir la unión más simple que cumpla. Las holguras salen **siempre** de
`holgura("…")` del perfil de impresora, nunca de números sueltos. Si el perfil no está medido, la
guía lo avisa (skill `guia-produccion`).

| Unión | Cuándo usarla | Holgura |
|---|---|---|
| Tornillo + tuerca embebida (M3, M4) | Uniones fuertes que se desarman | Paso del tornillo: `"deslizante"`; hexágono: `"justo"` |
| Inserto roscado en caliente | Se desarma muchas veces | Agujero según el fabricante del inserto |
| Tornillo autorroscante en plástico | Uniones simples y baratas | Agujero = 85 % del diámetro del tornillo |
| Encastre a presión (*snap-fit*) | Tapas y carcasas sin herramientas | `"justo"` |
| Cola de milano o ranura deslizante | Unir tramos largos en línea | `"justo"` o `"deslizante"` por lado |
| Pasador o clavija | Alinear dos piezas antes de pegar o atornillar | `"presion"` o `"justo"` |
| Rodamiento a presión | Ejes que giran con poco juego | Calibrar con una probeta impresa (como la del 608 del puntero láser) |
| Eje o bisagra impresa | Partes que giran | `"deslizante"` o `"suelto"` |
| Pegamento (cianoacrilato o epoxi) | Unión permanente sin carga alta | Sin holgura extra |

- Agregar **guías de alineación** (pasadores, marcos, rebajes) para que las piezas solo encajen en
  la posición correcta.
- Usar **una misma medida de tornillo** en todo el diseño siempre que se pueda.

## 3. Cómo organizar los archivos

```text
src/
├── perfil_impresora.scad       # Holguras y límites de la impresora (común a todo el proyecto)
├── <diseño>_parametros.scad    # Medidas compartidas, derivadas y validaciones del diseño
├── <diseño>_<pieza_a>.scad     # Una pieza por archivo, en su orientación de impresión
├── <diseño>_<pieza_b>.scad
└── <diseño>_ensamblaje.scad    # Todas las piezas y componentes en su lugar (no se exporta)
simulation/<diseño>_<pieza>_fem.*   # Solo las piezas con carga (skill simulacion-freecad)
exports/<diseño>_<pieza>.stl        # Un STL por pieza (el ensamblaje no se exporta)
docs/<diseño>_guia.md               # Una sola guía para el conjunto (skill guia-produccion)
docs/<diseño>_bom.csv               # Lista de materiales con precios (skills guia-produccion y web-armado)
docs/img/<diseño>_*.png             # Capturas de cada pieza, del conjunto y de cada paso
```

- Cada pieza hace `include <<diseño>_parametros.scad>`: si cambia una medida compartida, cambia en
  todas las piezas y siguen encajando. Si cambia, **regenerar todos los STL**.
- Cada pieza se modela **en su orientación de impresión**; el ensamblaje la rota y la ubica.
- El ensamblaje comprueba con `assert` que las piezas no se choquen y que las holguras sean
  positivas, y dibuja los componentes comprados (rodamientos, tornillos, motores, placas) como
  volúmenes simples.

## 4. Tabla de pasos, vistas explotadas y visor 3D

El ensamblaje es la fuente de las imágenes de armado de la web y del visor 3D (skill `web-armado`).
La maquinaria común está en `src/armado_comun.scad`; el contrato completo, en
`specs/005-visor-armado-3d/contracts/ensamblaje.md`. Modelos: `src/puntero_laser_ensamblaje.scad`
(con subconjuntos, origen y giro) y `src/caja_pilas_ensamblaje.scad` (el caso mínimo).

1. **Biblioteca común**: `include <armado_comun.scad>` y, al final de la sección de ensamblaje,
   `armado();`. No copiar `vista_paso`, `flecha` ni las utilidades: están en la biblioteca.
2. **Lo que define el diseño**: los parámetros `paso_armado` (`0` conjunto, `n` vista del paso `n`,
   `-1` datos de los pasos) y `solo_elemento` (`""`); `alfa_contexto`, `color_flecha` y
   `diametro_flecha`; `elementos`, `color_elemento(e)`, `elemento(e)`, `anclas(e)`, `grupo(e, n)` y
   `ensamblaje_principal()`.
3. **Catálogo de elementos**: `elemento(nombre)` dibuja cada pieza o componente en su posición
   final. El conjunto, las vistas por paso y el visor lo usan, así que hay una sola fuente de
   posiciones. Cada tornillo o tuerca que nombre la guía tiene su elemento.
4. **Tabla `pasos`**: una entrada por cada paso de "Instrucciones Paso a Paso" de la guía y en el
   mismo orden. Cada entrada es `[elemento, desplazamiento, resaltar, origen?, giro?]`:
   - `desplazamiento`: de dónde viene la pieza, es decir, el sentido contrario a como entra. Tiene
     que coincidir con el texto (desde arriba, por la ventana lateral, desde abajo de la plataforma).
   - `resaltar = false`: el elemento se dibuja transparente. Sirve para el contenedor donde entra
     algo (para que se vea lo de adentro) y para un subconjunto ya armado que se mueve junto.
   - `origen` (opcional): el desplazamiento de la pieza que recibe al elemento. La flecha sale de ahí
     y el visor mueve el elemento en dos tramos (primero entra en la pieza, después bajan juntos).
     Sirve para una tuerca que entra de costado en un brazo que baja.
   - `giro` (opcional, solo para el visor): `[punto, eje, grados]`, un punto del eje en la posición
     final, su dirección y el ángulo total. La pieza llega girando (una polea que se enrosca). Para
     usarlo sin origen, el cuarto campo es `undef`.
   - Un paso sin piezas nuevas (cableado, puesta a punto) es una lista vacía y no tiene imagen; el
     visor muestra el conjunto armado.
5. **Subconjuntos**: si partes del aparato se arman por separado y después se unen, `grupo(e, n)`
   devuelve el subconjunto del elemento en el paso `n` y `"conjunto"` después de la unión. Así ni las
   vistas ni el visor muestran piezas que todavía no se montaron en ese subconjunto. Sin
   subconjuntos: `function grupo(e, n) = "conjunto";`.
6. **Anclas**: un punto por elemento (o uno por tornillo de un grupo) donde se dibuja la flecha.
   Tiene que quedar **fuera** de cualquier pieza sólida, si no la flecha no se ve.
7. `assert(len(pasos) == <pasos de la guía>)`. La biblioteca comprueba que cada elemento de la tabla
   exista y que los campos tengan el formato correcto.

## 5. Lista de control

- [ ] Cada corte entre piezas tiene un motivo de la sección 1, anotado en la especificación.
- [ ] Las medidas compartidas están en un solo `_parametros.scad`.
- [ ] Las holguras salen de `holgura("…")`.
- [ ] El ensamblaje no tiene choques y sus `assert` pasan.
- [ ] Hay un STL por pieza y todos coinciden con los parámetros actuales.
- [ ] El ensamblaje usa `armado_comun.scad` y la tabla `pasos` tiene un paso por cada instrucción de
  la guía; las vistas explotadas y el visor 3D se revisaron.
