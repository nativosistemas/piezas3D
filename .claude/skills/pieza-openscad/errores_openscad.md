# Errores frecuentes de OpenSCAD

| Mensaje o síntoma | Causa habitual | Solución |
|---|---|---|
| `Parser error ... line N` | Falta `;`, llave o paréntesis | Revisar la línea N y la anterior |
| `Object may not be a valid 2-manifold` | Caras coplanarias o volúmenes que solo se tocan | Usar `eps` para que los volúmenes se solapen |
| `Current top level object is empty` | Un módulo no se llama o un `difference()` lo restó todo | Revisar el ensamblaje; usar `echo()` para ver valores |
| `Assertion ... failed` | Un parámetro viola una regla del diseño | Leer el mensaje del `assert()` y corregir el parámetro |
| `... was assigned on line N but was overwritten` | Se volvió a declarar un nombre del perfil de impresora u otro `include` | Usar otro nombre; no redeclarar lo que da el perfil |
| `DEPRECATED: Using ranges of the form [begin:end] with begin value greater than the end value` | Un `for` con rango vacío, como `[0:-1]` | Usar paso explícito: `[0:1:n-1]` da una lista vacía sin aviso |
| Render muy lento | `$fn` alto o `minkowski()` complejo | `$fn` bajo mientras se diseña, alto para exportar; `render()` en subconjuntos |
| `include`/`use` no encuentra el archivo | Ruta con `~` (OpenSCAD no la expande) o ruta mal relativa | Usar rutas relativas a la carpeta del `.scad` |
| PNG vacío y `Segmentation fault` | Sin contexto gráfico: dentro del sandbox no hay display de WSLg | Ejecutar el comando de captura fuera del sandbox |
| `ERROR: no se generó el archivo de salida` con `-o x.echo` | La pieza no tiene `echo()`: el lanzador trata el archivo vacío como fallo | Para validar sin render usar `-o x.csg` (es lo que hace `verificar_pieza.sh --rapido`) |
| En una vista con `color(..., alfa)`, una pieza dentro de otra transparente no se ve | La transparencia de la vista previa no muestra bien lo que queda adentro | Desplazar la pieza fuera del contenedor para mostrarla |
