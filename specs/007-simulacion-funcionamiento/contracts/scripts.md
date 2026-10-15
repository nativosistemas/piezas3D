# Contrato: comandos

Amplía el [contrato de la 005](../../005-visor-armado-3d/contracts/scripts.md): los comandos, las
opciones y los mensajes existentes no cambian.

## `scripts/generar_visor.py`

Sin opciones nuevas. Cuando el ensamblaje declara articulaciones, además de lo de la 005:

1. Lee las líneas `ARTICULACIONES;` … `TRANSPARENTES;` de la misma ejecución con `paso_armado=-1`.
2. Exporta las mallas de los elementos móviles y de motor que no estén ya en los pasos (normalmente
   ya están todas: el catálogo es el mismo).
3. Exporta los fotogramas de cada deformable (`-D <variable>=<a>`), en paralelo con el resto.
4. Comprueba los pivotes (R6) exportando los elementos de cada articulación con variable en `mín` y
   `máx`.
5. Incrusta `simulacion` en el JSON (`version: 2`).

Con mallas reutilizadas (huella igual) no ejecuta OpenSCAD: toma `simulacion` de la página actual.

| Situación | Salida | Código |
|---|---|---|
| Generado con simulación | `✓ Visor 3D: …armado_3d.html (4,0 MB, 49 piezas, 2 articulaciones, mallas exportadas)` | 0 |
| Generado sin simulación | Igual que en la 005 | 0 |
| Declaración inválida | El mensaje del `assert` de OpenSCAD, p. ej. `articulaciones: 'altura' tiene el rango invertido` | 1 |
| Pivote incorrecto | `La articulación 'altura' no coincide con OpenSCAD: 'cuna' a 95° difiere 12,3 mm (revisar punto, eje y reposo)` | 1 |
| Fotograma vacío | `No se pudo exportar 'cable_laser' con angulo_altura=95: …` | 1 |
| Más de 10 MB | Igual que en la 005, contando los fotogramas | 1 |
| `--comprobar` | Igual que en la 005; un cambio en una declaración cambia la huella | 0 / 1 |

## `scripts/generar_web.py`

Si el visor generado trae `simulacion` (lo lee con `generar_visor.datos_de_pagina`), la leyenda
de las vistas explotadas (`vistas_de_pasos`) agrega, junto a "Ver el armado en 3D", el enlace
"Ver cómo funciona" → `armado_3d.html#funcionamiento`. Sin simulación, la web no cambia.
`--comprobar` lo cubre igual que el resto de la web.

## `scripts/capturas_armado.sh`

Sin cambios.
