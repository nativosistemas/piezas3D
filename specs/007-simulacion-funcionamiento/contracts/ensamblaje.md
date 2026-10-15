# Contrato: declarar las partes móviles en el ensamblaje

Amplía el [contrato de la 005](../../005-visor-armado-3d/contracts/ensamblaje.md). Todo lo de acá
es **opcional**: un ensamblaje que no lo define genera el visor igual que antes.

## Lo que define el diseño (después de `include <armado_comun.scad>`, antes de `armado()`)

```openscad
/* [Hidden] */
// [nombre, etiqueta, elementos, punto, eje, rango, reposo, padre, velocidad °/s, variable, pasos_por_grado]
articulaciones = [ … ];
// [nombre, etiqueta, elementos, punto, eje, articulación que impulsa, relación con signo, montado_en]
motores = [ … ];
// [nombre, etiqueta, punto de salida, dirección, color, articulación, largo]
emisores = [ … ];
// [nombre, [un valor por articulación, en su orden]]
objetivos = [ … ];
// [elemento, articulación, ángulos en que se exporta]
deformables = [ … ];
transparentes_simulacion = [ … ];
```

Campos y reglas: [../data-model.md](../data-model.md#1-en-el-ensamblaje-openscad). Los números
DEBEN salir de los parámetros del diseño (Principio I): relación de la correa, rango, velocidad,
cotas de los pivotes.

## Ejemplo: el puntero láser

```openscad
elementos_altura = ["cuna", "laser", "pila_falsa", "tapa_trasera", "lastre", "grapa", "tuerca_munon",
                    "perno_alt_cable", "perno_alt_motor", "polea_alt"];
elementos_motor_az = ["polea20_az"];
elementos_motor_alt = ["polea20_alt"];
deformables = [["cable_laser", "altura", [for (a = [angulo_altura_min:5:angulo_altura_max]) a]]];
elementos_azimut = [for (e = elementos)
    if (!contiene(grupo_base, e) && !contiene(elementos_altura, e) && !contiene(elementos_motor_az, e)
        && !contiene(elementos_motor_alt, e) && e != "cable_laser") e];

articulaciones = [
    ["azimut", "Azimut", elementos_azimut, [0, 0, 0], [0, 0, -1], undef, 0, "",
     velocidad_max_eje, "", pasos_por_grado],
    ["altura", "Altura", elementos_altura, [0, 0, z_eje_altura], [1, 0, 0],
     [angulo_altura_min, angulo_altura_max], angulo_altura, "azimut",
     velocidad_max_eje, "angulo_altura", pasos_por_grado]];
motores = [
    ["motor_azimut", "Motor de azimut", elementos_motor_az, [0, distancia_centros, 0], [0, 0, 1],
     "azimut", -relacion_correa, "azimut"],
    ["motor_altura", "Motor de altura", elementos_motor_alt, [0, 0, z_eje_motor_alt], [1, 0, 0],
     "altura", relacion_correa, "azimut"]];
emisores = [["laser", "Láser", en_conjunto([0, l_delantero, 0], angulo_altura),
             [0, cos(angulo_altura), sin(angulo_altura)], "Lime", "altura", largo_haz_simulacion]];
objetivos = [["Norte bajo", [0, 10]], ["Este", [90, 35]], …];
transparentes_simulacion = ["tapa"];
```

Signos: el azimut positivo gira en sentido horario visto desde arriba (eje `[0, 0, −1]`), como pide
la tabla del firmware de la guía; la altura positiva sube el láser. El signo de cada motor sale de
[research R3](../research.md#r3-motores-y-relación-de-transmisión). Los valores exactos (punto de
salida, eje de las poleas) se confirman en la implementación con la comprobación de pivotes y una
captura.

Nuevas constantes en `src/puntero_laser_parametros.scad` (`/* [Hidden] */`):
`angulo_altura_min = -10`, `angulo_altura_max = 95`, `medios_pasos_por_segundo_max = 900`,
`velocidad_max_eje = medios_pasos_por_segundo_max/pasos_por_grado`. En el ensamblaje:
`largo_haz_simulacion = 600`. Los literales `-10` y `95` del barrido V-07 y del conjunto pasan a
usar las constantes.

## Lo que agrega `armado_comun.scad`

| Nombre | Qué hace |
|---|---|
| `simulacion_articulaciones()`, `simulacion_motores()`, … | Devuelven la lista del diseño o `[]` si no está definida (`is_undef`, sin avisos) |
| `comprobar_simulacion()` | Los `assert` de [data-model](../data-model.md#validaciones-en-openscad-armado_comunscad-con-mensaje-que-nombra-el-dato); lo llama `armado()` |
| `datos_armado()` | Agrega las líneas de abajo después de las de la 005 |

## Salida con `paso_armado = -1` (agregada)

```text
ARTICULACIONES;<lista>      vector de OpenSCAD (undef → null)
MOTORES;<lista>
EMISORES;<lista>
OBJETIVOS;<lista>
DEFORMABLES;<lista>
TRANSPARENTES;<lista>
```

Se emiten siempre (listas vacías si el diseño no declara nada). `PASO;`, `PASOS;`, `COLOR;` y
`CONTEXTO;` no cambian.

## Exportar un fotograma o comprobar un pivote

```bash
.tools/bin/openscad -D 'solo_elemento="cable_laser"' -D 'angulo_altura=95' -D '$fn=32' -o cable_95.stl src/puntero_laser_ensamblaje.scad
```

DEBE dibujar el elemento como queda con la articulación en ese ángulo.
