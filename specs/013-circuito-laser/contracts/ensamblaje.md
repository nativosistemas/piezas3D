# Contrato: lista `circuitos` del ensamblaje

Amplía el contrato de cables de la [011](../../011-vista-cableado/contracts/ensamblaje.md). Lista
**opcional**; `armado_comun.scad` la lee con `is_undef`. Sin ella, nada cambia.

## Forma

```text
circuitos = [[id, nombre, descripción, grupos, translúcidos, encuadre], …]
grupos    = [[título, [miembro, …]], …]
```

| Campo | Tipo | Regla |
|---|---|---|
| id | texto | Único entre los circuitos; sin `;`. Es el valor de `?circuito=` en el visor |
| nombre | texto | No vacío, sin `;` ni `"`. Es el texto del botón |
| descripción | texto | No vacío, sin `;` ni `"`. Una línea bajo el botón |
| grupos | lista | Al menos un grupo; cada uno `[título, miembros]` con título no vacío y al menos un miembro, en el orden del recorrido |
| miembro | texto | Un elemento del catálogo o el id de un cable. No puede ser un elemento de `ocultos_cableado` ni el `elemento` de un cable (se nombra el cable). No se repite en el circuito |
| translúcidos | lista | Miembros (elementos) que se ven translúcidos porque contienen a otros |
| encuadre | lista | Elementos o cables cuya caja encuadra la «Vista inicial» del circuito; al menos uno |

Requiere que el ensamblaje declare `cables` (el botón vive en el modo Cableado).

## Validación (`comprobar_circuitos()`, C-07)

Un `assert` por regla de la tabla, con mensaje en español que empieza con `circuitos:` y nombra el
circuito y el miembro (p. ej. `circuitos: 'laser' nombra 'tornillo_contato', que no es un elemento ni
un cable`). Se valida siempre, también al exportar cada elemento.

## Salida (`datos_armado()`)

Una línea:

```text
ECHO: "CIRCUITOS;[[id, nombre, descripción, [[título, [miembros]], …], [translúcidos], [encuadre]], …]"
```

`generar_visor.py` la lee con el mismo lector de vectores que `GRUPOS_CABLEADO`.
