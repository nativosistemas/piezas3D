# Contrato: la página del visor (modo Funcionamiento)

Amplía el [contrato de la 005](../../005-visor-armado-3d/contracts/visor.md). Si los datos no traen
`simulacion`, la página es idéntica a la de la 005.

## Direcciones

| Dirección | Efecto |
|---|---|
| `armado_3d.html#funcionamiento` | Abre en el modo Funcionamiento, en reposo y con los emisores apagados |
| `armado_3d.html?modo=funcionamiento&altura=95&azimut=30&laser=1` | Funcionamiento con esos valores (un parámetro por articulación o emisor, con su `nombre`), quieto; para revisión y capturas |
| `…&auto=1&vel=20` | Arranca el modo automático a esa velocidad |

Un valor fuera de rango se lleva al tope; un nombre desconocido se ignora.

## Pestañas

"Armado" y "Funcionamiento", arriba del panel lateral. Solo aparecen si hay `simulacion`. Cambiar de
pestaña no mueve la cámara ni cambia el paso de armado.

## Controles del modo Funcionamiento

| Control | Mouse / teclado | Tacto |
|---|---|---|
| Valor de una articulación | Deslizador o campo numérico (°); flechas del teclado sobre el deslizador | Deslizador |
| Emisor encendido / apagado | Botón; `L` el primero | Botón |
| Automático | Botón; `A` | Botón |
| Velocidad del automático | Selector ×1 / ×5 / ×20 | Selector |
| Reposo (todo al reposo y emisores apagados) | Botón; `Inicio` sigue siendo "Vista inicial" | Botón |
| Girar, acercar, desplazar, vista inicial | Como en Armado | Como en Armado |

## Lo que se muestra

- El conjunto completo: opaco, salvo `transparentes`, que van con la transparencia del contexto.
- Por articulación: etiqueta, valor en grados (azimut sin límite: 0–360°), rango y, si hay
  `pasos_por_grado`, la posición en pasos.
- Por motor: etiqueta y giro acumulado (grados y vueltas). La polea lleva una marca de giro.
- Por emisor encendido: el haz desde `punto` en `direccion`, con su largo, un halo en la salida y
  el botón en estado "encendido".
- En automático: "Hacia: <objetivo>" o "Apuntando: <objetivo>"; con ×5 o ×20, "velocidad no real".
- Una nota: "Simulación cinemática: el cable y las correas se muestran aproximados; no se calculan
  choques ni fuerzas."

## Datos incrustados

El objeto de la 005 con `version: 2` y `simulacion` según
[../data-model.md](../data-model.md#2-datos-incrustados-json).
