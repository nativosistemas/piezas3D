# Contrato: interfaz del generador de la caja de pilas

## 1. Entradas

Los parámetros públicos de [data-model.md, Entidad 1](../data-model.md#entidad-1-parámetros-públicos-srccaja_pilas_parametrosscad),
declarados una sola vez en `src/caja_pilas_parametros.scad`. Se cambian en el Customizer de OpenSCAD
o en la línea de comandos con `-D`, y **se pasan iguales a las dos piezas**:

```bash
.tools/bin/openscad -D cantidad_pilas=6 -o exports/caja_pilas_caja.stl src/caja_pilas_caja.scad
```

```bash
.tools/bin/openscad -D cantidad_pilas=6 -o exports/caja_pilas_tapa.stl src/caja_pilas_tapa.scad
```

## 2. Salidas

### 2.1 Éxito

| Archivo | Contenido |
|---|---|
| `exports/caja_pilas_caja.stl` | Caja en su orientación de impresión, apoyada en Z = 0 |
| `exports/caja_pilas_tapa.stl` | Tapa con la cara exterior en Z = 0 |

Al renderizar `src/caja_pilas_parametros.scad` se imprimen con `echo` las medidas exteriores, el alto
cerrado, `deformacion_pestana` y `juego_vertical_pila`.

### 2.2 Error

Una combinación inválida detiene el render con `ERROR: Assertion ... failed` y un mensaje en español
que empieza con el nombre del parámetro, por ejemplo:

```text
saliente_reborde=0.8: la pestaña se deformaría 2,4 % al cerrar (máximo 1,5 %)
```

Las reglas son V-01…V-09 de [data-model.md, Entidad 3](../data-model.md#entidad-3-reglas-de-validación-assert).

## 3. Garantías

- Con los mismos parámetros, la pollera de la tapa entra en la boca de la caja con
  `holgura("justo")` y el reborde cae en la ranura (lo comprueba el ensamblaje).
- La tapa encastra en sus dos orientaciones (es simétrica respecto del centro en X e Y).
- Si cambia un parámetro, hay que regenerar **los dos** STL.
