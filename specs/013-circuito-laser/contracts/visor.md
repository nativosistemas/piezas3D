# Contrato: circuitos en el modo Cableado del visor

Amplía el contrato del modo Cableado de la [011](../../011-vista-cableado/contracts/visor.md).

## Panel

- Si `cableado.circuitos` existe, debajo de la línea de texto del panel hay una fila de botones, uno
  por circuito, con su `nombre` y `aria-pressed`. Sin circuitos, el panel es el de la 011.
- Con un circuito activo:
  - El botón queda presionado y los demás sueltos (uno solo a la vez).
  - Debajo aparece su `descripcion` y la lista del circuito: un subtítulo por grupo y un renglón por
    miembro (muestra de color y nombre: el del elemento, o el del cable). Señalar, enfocar o tocar un
    renglón resalta el miembro en la escena.
  - La lista de cables se oculta y la casilla «Atenuar las piezas» queda deshabilitada.
- Al tocar de nuevo el botón activo, el panel vuelve al de la 011.

## Escena con un circuito activo

| Mallas | Aspecto |
|---|---|
| Miembros (elementos y todas las mallas de cada cable miembro) | Su color, opacos |
| Miembros en `translucidos` | Su color, opacidad 0,25, sin escribir profundidad |
| Todo lo demás del modo | Gris claro (`#b8bcc2`), opacidad 0,08, sin escribir profundidad |

- Señalar una malla funciona como en la 008/011; al soltarla, la opacidad vuelve a la de su estado
  (no a la del armado).
- «Vista inicial» (botón e Inicio) encuadra la caja de `encuadre` desde la dirección del modo.
- Al activar el circuito, la cámara hace esa vista inicial.
- Al desactivarlo, cada malla vuelve a su color y opacidad del modo Cableado (con la casilla de
  atenuar como esté), y la vista no cambia.
- Cambiar de modo y volver conserva el circuito activo.

## Direcciones

- `armado_3d.html?modo=cableado&circuito=<id>` abre el modo Cableado con ese circuito activo y su
  vista inicial. Un `id` inexistente se ignora.
- Se combina con `&senalar=<elemento o cable>` (la etiqueta sale después de encuadrar).
