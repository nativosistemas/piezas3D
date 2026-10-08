---
name: web-armado
description: Fase 5 del pipeline de piezas3D. Generar la web de armado de un diseño en specs/<NNN>/web/ (componentes con precio en ARS y USD, primeros pasos, armado paso a paso con vistas explotadas, consejos) y su visor 3D de armado, buscar y verificar precios de componentes. Usar cuando la guía está terminada, al actualizar precios o cuando el usuario pide la web, el visor 3D, el costo o el precio del producto.
---

# Web de armado

La web **no se escribe a mano**: `scripts/generar_web.py` la arma con la guía
(`docs/<diseño>_guia.md`, skill `guia-produccion`), la lista de materiales
(`docs/<diseño>_bom.csv`), el tipo de cambio (`docs/tipo_cambio.csv`) y las capturas de
`docs/img/`. Para cambiar la web se cambian esas fuentes y se vuelve a generar.
Ejemplo: `specs/002-puntero-laser-estelar/web/index.html`.

## 1. Precios

Se muestran en **ARS y USD**. Cada precio lleva tienda, enlace y fecha; el generador rechaza un
precio sin fuente.

- **Solo precios verificados abriendo la página de la tienda** el día que se cargan. Los resúmenes
  del buscador traen precios viejos o de otro país: en el puntero láser, 4 de 11 diferían de la
  página real ($20.600 contra $21.100, $3.399 contra $1.119) y otro resultado era de una tienda
  colombiana en pesos colombianos.
- **Tiendas argentinas** con página de producto legible (Tiendanube, WooCommerce, etc.).
  MercadoLibre bloquea las consultas automáticas (403).
- Cargar el precio **actual** de la página. Si es de oferta o la tienda no tiene stock, decirlo en
  `nota`.
- Anotar en `nota` todo lo que el comprador tenga que saber: si el producto **no coincide con las
  medidas del diseño** (y qué parámetro cambiar), si la página no confirma un dato (rosca,
  prisioneros incluidos) o si trae más unidades de las necesarias.
- **Si no se puede verificar, el precio queda vacío.** La web lo muestra como "sin precio
  verificado" y avisa que el total es parcial. Nunca inventar ni estimar un precio.
- `paquete` es lo que trae lo que se compra: la web calcula lo que se gasta comprando paquetes
  completos y lo que se usa.

**Tipo de cambio**: agregar una fila a `docs/tipo_cambio.csv` con el dólar oficial (venta) de
[DolarApi](https://dolarapi.com/v1/dolares/oficial) y su fecha. El generador usa la fila más
reciente; las anteriores quedan como historial.

## 2. Vistas explotadas de cada paso

Solo en diseños de varias piezas con la tabla `pasos` en el `_ensamblaje.scad` (cómo armarla: skill
`disenio-multipieza`). Generar las capturas **fuera del sandbox** (necesitan WSLg):

```bash
scripts/capturas_armado.sh <diseño>
```

Escribe `docs/img/<diseño>_paso_NN.png`; los pasos sin piezas nuevas no tienen captura. **Mirar
cada imagen**:

- ¿Se ven las piezas del paso, en color, y la flecha naranja?
- ¿La flecha va en el sentido en que la pieza entra, según el texto de la guía?
- ¿Aparecen piezas que todavía no se montaron en ese subconjunto? (revisar los grupos)
- ¿Alguna pieza queda **adentro** de otra? La transparencia no la muestra: desplazarla por donde
  entra de verdad (por ejemplo, por la boca de un tubo o por una ventana), o dibujar el contenedor
  transparente con `resaltar = false`.

## 3. Generar y comprobar

```bash
scripts/generar_web.py <diseño> specs/<NNN-nombre>
scripts/generar_web.py --comprobar <diseño> specs/<NNN-nombre>
```

La segunda falla si la guía, la web o el visor 3D no están al día con sus fuentes. Es la
comprobación de la puerta 5.

### Visor 3D

Si el diseño tiene `src/<diseño>_ensamblaje.scad`, `generar_web.py` también genera
`specs/<NNN-nombre>/web/armado_3d.html` con `scripts/generar_visor.py` y lo enlaza desde la web ("Ver
el armado en 3D" y "Ver en 3D" en cada paso). Sale de la misma tabla de pasos que las capturas
(convención en la skill `disenio-multipieza`, sección 4); no se edita a mano.

- La primera vez, o cuando cambia algún `.scad` del diseño, exporta cada pieza con OpenSCAD (unos
  20 s para 43 piezas; funciona dentro del sandbox). Si las fuentes no cambiaron, reutiliza las mallas
  de la página. `scripts/generar_visor.py --reexportar <diseño> specs/<NNN-nombre>` fuerza la
  exportación.
- Es un solo archivo con todo adentro (three.js de `scripts/vendor/`): funciona sin internet y con
  doble clic. Máximo 10 MB.

**Revisarlo** en el Edge sin ventana, fuera del sandbox y sin red. `?paso=N&t=0.5` congela el paso N
en la mitad del movimiento (`t=0`: piezas separadas, como la captura):

```bash
"/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" --headless=new --host-resolver-rules="MAP * ~NOTFOUND" --use-angle=swiftshader --enable-unsafe-swiftshader --hide-scrollbars --window-size=1280,800 --virtual-time-budget=10000 --screenshot="$(wslpath -w "$PWD/.tools/tmp/visor.png")" "file:///$(wslpath -w "$PWD/specs/<NNN-nombre>/web/armado_3d.html" | tr '\\' '/')?paso=8&t=0"
```

- En cada paso con piezas, `t=0` debe mostrar las mismas piezas, colores y desplazamientos que su
  captura de `docs/img/`.
- En los pasos con origen, `t=0.25` y `t=0.75` muestran los dos tramos del movimiento.
- Las capturas solo muestran un paso abierto directamente; para probar la navegación (el
  reencuadre al cambiar de paso), pedirle al usuario que lo recorra en su navegador.

Revisar la página en un navegador. Captura sin abrir ventanas (fuera del sandbox, con el Edge de
Windows):

```bash
"/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" --headless=new --disable-gpu --hide-scrollbars --window-size=1280,5000 --screenshot="$(wslpath -w "$PWD/.tools/tmp/web.png")" "$(wslpath -w "$PWD/specs/<NNN-nombre>/web/index.html")"
```

- El Edge sin ventana no baja de 492 px de ancho: no sirve para ver el diseño de un celular.
- No respeta los anclajes (`#seccion`): para ver una sección, hacer una copia temporal que oculte
  las demás con CSS y borrarla después.

## 4. Lista de control (puerta 5)

- [ ] `scripts/generar_web.py --comprobar` termina sin errores.
- [ ] Todos los precios cargados tienen tienda, enlace y fecha, y fueron verificados en la página.
- [ ] Los componentes sin precio están vacíos en el CSV, no estimados.
- [ ] El tipo de cambio es del mismo período que los precios.
- [ ] Las vistas explotadas se revisaron una por una.
- [ ] Si el diseño tiene ensamblaje, el visor 3D se generó y se revisó sin red (`t=0` contra cada
  captura y los pasos con origen).
- [ ] La página se revisó en un navegador.
