# Contrato: comandos

## `scripts/generar_visor.py` (nuevo)

```text
scripts/generar_visor.py <diseño> <carpeta_spec>               genera specs/<NNN>/web/armado_3d.html
scripts/generar_visor.py --comprobar <diseño> <carpeta_spec>   no escribe; falla si no está al día
scripts/generar_visor.py --reexportar <diseño> <carpeta_spec>  ignora la huella y exporta todo
```

Lee: `src/<diseño>_ensamblaje.scad` (vía OpenSCAD), `docs/<diseño>_guia.md` (títulos y textos de
los pasos), `scripts/vendor/three-0.160.0/` y su plantilla.

| Situación | Salida | Código |
|---|---|---|
| Generado | `✓ Visor: specs/<NNN>/web/armado_3d.html (2,9 MB, 43 piezas, mallas reutilizadas)` | 0 |
| Al día (`--comprobar`) | `✓ El visor está al día` | 0 |
| Fuentes cambiadas (`--comprobar`) | `Desactualizado: …armado_3d.html (cambiaron las fuentes). Ejecutar: scripts/generar_web.py …` | 1 |
| Guía cambiada (`--comprobar`) | `Desactualizado: …armado_3d.html (cambió la guía). Ejecutar: …` | 1 |
| Falta el visor (`--comprobar`) | `Falta el visor 3D: …` | 1 |
| Ensamblaje sin datos de pasos | `src/<diseño>_ensamblaje.scad no entrega los datos de los pasos (ver la skill disenio-multipieza)` | 1 |
| Pasos de la tabla ≠ pasos de la guía | `La tabla tiene N pasos y la guía M` | 1 |
| Elemento que no exporta o queda vacío | `No se pudo exportar '<elemento>' (paso N): <error de OpenSCAD>` | 1 |
| Más de 10 MB | `El visor pesa X MB (máx. 10). Más pesados: …` | 1 |

Solo biblioteca estándar de Python y OpenSCAD. La exportación de las piezas funciona dentro del
sandbox. `--comprobar` no ejecuta OpenSCAD.

## `scripts/generar_web.py` (cambios)

- Si existe `src/<diseño>_ensamblaje.scad`, llama a `generar_visor.py` con los mismos argumentos
  (incluido `--comprobar`) y agrega los enlaces al visor en la web. Si no existe, no hay visor ni
  enlaces y no es un error.
- Los mensajes y códigos de salida del visor se propagan sin cambios.

## `scripts/capturas_armado.sh`

Sin cambios: sigue leyendo solo las líneas `PASO;n;k`.
