# Contrato: declarar los cables en el ensamblaje

Amplía los contratos de la [005](../../005-visor-armado-3d/contracts/ensamblaje.md), la
[007](../../007-simulacion-funcionamiento/contracts/ensamblaje.md) y la
[008](../../008-identificacion-componentes/contracts/ensamblaje.md). Es **opcional**: un ensamblaje
sin `cables` genera el visor y la web como antes.

## Lo que define el diseño (junto a `elementos`, antes de `armado()`)

```openscad
// Cables para el modo Cableado del visor 3D (contrato: specs/011-vista-cableado/contracts/ensamblaje.md)
grupos_cableado = [["alimentacion", "Alimentación: power bank e interruptor"], …];
conectores_cableado = [["dupont", [paso_pines, paso_pines, largo_dupont], "Black"], …];
cables = [
    // [id, desde, hasta, función, grupo, hilos, diámetro, recorrido, extremos, largo_comprado, elemento]
    ["sen_az_in1", "ESP32 GPIO 16", "ULN2003 azimut IN1", "señal", "esp32_az", ["DodgerBlue"],
     diametro_cable_dupont, recorrido_dupont(pin("ESP32", "GPIO 16"), pin("ULN2003 azimut", "IN1"), 0),
     ["dupont", "dupont"], largo_cable_dupont, undef],
    ["hilos_laser", "Regulador OUT±", "Láser (pila falsa y tapa trasera)", "señal", "motores_laser",
     ["Red", "Black"], d_hilo, recorrido_hilos_laser, ["soldadura", "pila_falsa"], undef, "cable_laser"],
    …
];
obstaculos_cableado = [["el ESP32", [x0, y0, z0], [x1, y1, z1], "ESP32"],
                       ["la pared −X de la tapa", …, ""], …];
pasos_tapa_cableado = [["el conducto", [x0, y0, z0], [x1, y1, z1]], ["la entrada de un motor", …]];
transparentes_cableado = ["tapa"];
ocultos_cableado = ["conectores"];
reserva_cable = 10;                    // largo que se deja sin tensar en cada cable comprado
radio_curva_cableado = radio_curva_cable;
largo_elementos_cableado = [["cable_laser", …]];   // largo del tramo que dibuja cada elemento
```

Campos y reglas: [../data-model.md](../data-model.md#1-en-el-ensamblaje-openscad).

## Lo que hace la biblioteca común (`src/armado_comun.scad`)

- `comprobar_cables()`, llamado desde `armado()`: la forma de cada cable y de cada lista (C-01 y
  C-02). Lee las listas con `is_undef`, como las de la 007.
- `choques_cable(c)` y `falta_largo(c)`: las funciones de C-03 y C-04. Las llama `comprobar_cables()`
  para cada cable con recorrido, si el diseño declaró `obstaculos_cableado`, y solo al validar el
  conjunto o los datos (con `solo_elemento` vacío): exportar cada malla no las repite.
- Las paredes y el techo de la tapa son obstáculos como cualquier otro. Una muestra dentro de un paso
  (`pasos_tapa_cableado`) no choca con nada; así un cable cruza la pared solo por sus aberturas.
- Un cable puede tener recorrido, elemento o los dos. El elemento dibuja el tramo que se mueve con un
  eje (en el puntero láser, el cable que acompaña al láser), y el recorrido, el tramo fijo. Su largo
  (`largo_cable(c)`) suma el del recorrido y el que `largo_elementos_cableado` declara para el elemento.
- `datos_armado()` suma una línea por cable y una por cada lista, todas después de las de la 008:
  - `ECHO: "CABLE;<id>;<vector sin desde ni hasta>;<desde>;<hasta>"`: los textos van al final y
    separados por `;` (como el nombre en la 008: el lector toma todo hasta la última comilla). Ni
    `desde` ni `hasta` pueden contener `;` (C-01).
  - `ECHO: "GRUPOS_CABLEADO;<vector>"`, `ECHO: "CONECTORES_CABLEADO;<vector>"`,
    `ECHO: "TRANSPARENTES_CABLEADO;<vector>"`, `ECHO: "OCULTOS_CABLEADO;<vector>"` y
    `ECHO: "RADIO_CURVA_CABLEADO;<mm>"`.
- `cables_modelados()`: dibuja todos los cables (tubos con `hull()` de esferas, como `cordon()`, y un
  cubo por conector) para revisarlos en OpenSCAD. El ensamblaje lo llama desde
  `ensamblaje_principal()` si `ver_cables = true` (por defecto `false`, así el conjunto y las
  capturas no cambian).

## Errores

| Situación | Mensaje |
|---|---|
| Cable mal formado | `cables: <entrada> debe tener 11 campos` |
| Identificador repetido o igual a un elemento | `cables: '<id>' está repetido o es el nombre de un elemento` |
| Desde o hasta vacío o con `;` | `cables: el desde/hasta de '<id>' está vacío o tiene ';'` |
| Función inválida | `cables: la función de '<id>' debe ser "+5V", "GND" o "señal"` |
| Grupo, conector o elemento desconocido | `cables: '<id>' usa el grupo / conector / elemento desconocido '<x>'` |
| Sin recorrido ni elemento | `cables: '<id>' necesita un recorrido de 2 o más puntos, un elemento o los dos` |
| Diámetro ≤ 0 | `cables: el diámetro de '<id>' debe ser mayor que 0` |
| Choque (C-03) | `cables: '<id>' atraviesa <obstáculo> cerca de [x, y, z]` |
| Largo (C-04) | `cables: '<id>' mide <L> mm y el cable comprado <C> mm (faltan <F> mm)` |

El mensaje de C-04 para los cables de los motores reemplaza al de la V-26. La guía (4.4) actualiza
ese renglón.
