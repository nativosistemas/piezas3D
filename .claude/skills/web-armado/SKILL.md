---
name: web-armado
description: Fase 5 del pipeline de piezas3D. Generar la web de armado de un diseño en specs/<NNN>/web/ (componentes con precio en ARS y USD, primeros pasos, armado paso a paso con vistas explotadas, consejos), buscar y verificar precios de componentes. Usar cuando la guía está terminada, al actualizar precios o cuando el usuario pide la web, el costo o el precio del producto.
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

La segunda falla si la guía o la web no están al día con sus fuentes. Es la comprobación de la
puerta 5.

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
- [ ] La página se revisó en un navegador.
