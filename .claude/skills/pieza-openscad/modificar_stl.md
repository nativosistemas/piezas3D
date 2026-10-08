# Modificar un STL existente

Cuando una pieza de terceros está *casi* bien (mover un agujero, agregar 2 mm, aplanar una cara),
**no reconstruirla**: importarla y cortar o sumar sobre ella.

1. Guardar el original en `src/externos/<nombre>.stl` junto a `src/externos/<nombre>.md` con la URL
   de origen y la licencia, y respetarla al publicar el resultado.
2. Comprobar que el original sea un sólido cerrado. Si OpenSCAD avisa
   `Object may not be a valid 2-manifold`, repararlo primero (por ejemplo, con el reparador del
   laminador): sobre una malla rota las operaciones booleanas dan resultados incorrectos.
3. Crear `src/<nombre>_modificado.scad` con el encabezado estándar:

   ```openscad
   archivo_original = "externos/<nombre>.stl";
   difference() {
       import(archivo_original, convexity = 10);
       // Agujero nuevo, ubicado con cotas medidas, nunca a ojo
       translate([x_agujero, y_agujero, -eps])
           cylinder(h = alto_pieza + 2 * eps, d = diametro_agujero);
   }
   ```

   | Necesidad | Operación |
   |---|---|
   | Agujero nuevo o agrandar uno existente | `difference()` con un cilindro (en el mismo eje que el original) |
   | Agregar material (saliente, refuerzo, suplemento) | `union()` con el elemento nuevo |
   | Aplanar una cara o recortar una parte | `intersection()` o `difference()` con un cubo grande |

4. Las coordenadas salen de **medir**, no de la captura: caja envolvente
   (`scripts/verificar_pieza.sh`) o un cubo de referencia ubicado en una posición conocida.
5. Verificar que el cambio sea **exactamente** el pedido y nada más, y seguir con el pipeline normal.

El resultado sigue siendo una malla: el cambio se puede repetir editando el `.scad`, pero la forma
original no se vuelve paramétrica.
