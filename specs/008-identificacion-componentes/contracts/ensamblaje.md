# Contrato: nombrar los elementos en el ensamblaje

Amplía el [contrato de la 005](../../005-visor-armado-3d/contracts/ensamblaje.md). Es **opcional**:
un ensamblaje que no lo define genera el visor como antes (identificadores con `_` como espacios y
sin tipo).

## Lo que define el diseño (junto a `elementos`, antes de `armado()`)

```openscad
// Nombre y tipo de cada elemento para el visor 3D: [elemento, nombre, tipo ("impresa" o "comprada")]
nombres_elementos = [
    ["base",         "Base",                                   "impresa"],
    ["608_base_sup", "Rodamiento 608ZZ (base, superior)",      "comprada"],
    ["tornillos_pie", "Tornillos M3 × 12 del pie (4)",         "comprada"],
    …
];
```

Campos y reglas: [../data-model.md](../data-model.md#1-en-el-ensamblaje-openscad).

## Reglas

- Si la lista existe, DEBE tener exactamente una entrada por elemento de `elementos`.
- Los nombres de lo comprado DEBEN coincidir con la descripción de `docs/<diseño>_bom.csv` (pueden
  agregar dónde va la pieza); los de lo impreso, con el nombre de la pieza en la guía.
- Los nombres pueden tener cualquier carácter (acentos, `×`, comillas, `;`).
- Un elemento solo agrupa piezas iguales (los cuatro tornillos de un pie); componentes distintos van
  en elementos separados, porque el visor identifica elementos (las placas del puntero láser: ESP32,
  relé y dos ULN2003, un elemento cada una).

## Errores (assert en `armado_comun.scad`)

| Situación | Mensaje |
|---|---|
| Entrada mal formada | `nombres_elementos: <entrada> debe ser [elemento, nombre, tipo]` |
| Elemento desconocido | `nombres_elementos: elemento desconocido '<e>'` |
| Elemento repetido | `nombres_elementos: '<e>' está repetido` |
| Falta un elemento | `nombres_elementos: falta el nombre de '<e>'` |
| Nombre vacío | `nombres_elementos: el nombre de '<e>' está vacío` |
| Tipo inválido | `nombres_elementos: el tipo de '<e>' debe ser "impresa" o "comprada"` |
