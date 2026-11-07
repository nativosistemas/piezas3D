# Contrato: `generar_visor.py` (circuitos)

Amplía el contrato de la [011](../../011-vista-cableado/contracts/scripts.md).

- `VERSION = 5`: los datos de `cableado` pueden traer `circuitos` (ver
  [data-model.md](../data-model.md) §4). Un visor de versión 4 se regenera.
- Lee la línea `CIRCUITOS;` y la convierte a objetos (`id`, `nombre`, `descripcion`, `grupos` con
  `titulo` y `miembros`, `translucidos`, `encuadre`). Sin circuitos declarados, no agrega la clave.
- Los elementos miembros o de encuadre que no estén en los pasos, la simulación ni el cableado se
  exportan igual (como los transparentes del cableado).
- **C-08** (en `validar()`): cada miembro, translúcido y elemento de encuadre existe en los datos del
  visor (elemento con malla o id de cable). Si no: `El circuito '<id>' nombra '<miembro>', que no está
  en el visor`, código 1.
- La línea de resumen suma `N circuitos, ` después de los cables.
- `--comprobar` no cambia: falla si la página no coincide con lo que se generaría.
