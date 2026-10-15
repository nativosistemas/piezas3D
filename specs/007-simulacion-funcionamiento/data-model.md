# Modelo de datos: Simulación de funcionamiento

**Funcionalidad**: [spec.md](spec.md) · **Investigación**: [research.md](research.md)

Amplía el [modelo de la 005](../005-visor-armado-3d/data-model.md); lo que no se nombra acá no
cambia.

## 1. En el ensamblaje (OpenSCAD)

Todas las listas son **opcionales**. Si `articulaciones` no está definida o está vacía, el diseño no
tiene simulación y las demás se ignoran. Sintaxis exacta en
[contracts/ensamblaje.md](contracts/ensamblaje.md).

### Articulación

`[nombre, etiqueta, elementos, punto, eje, rango, reposo, padre, velocidad, variable, pasos_por_grado]`

| Campo | Tipo | Regla |
|---|---|---|
| nombre | texto | Único, `snake_case`; también es el parámetro de la dirección (`?altura=95`) |
| etiqueta | texto | Lo que lee la persona ("Altura") |
| elementos | lista de textos | Del catálogo; un elemento está a lo sumo en una articulación o un motor |
| punto | [x, y, z] mm | Un punto del eje de giro, en coordenadas del conjunto con todo en reposo |
| eje | [x, y, z] | Dirección del eje; no nula; el sentido positivo sigue la regla de la mano derecha |
| rango | [mín, máx] ° o `undef` | `mín < máx`; `undef` = sin límite (vuelta completa) |
| reposo | ° | Ángulo en que el catálogo dibuja sus elementos; dentro del rango |
| padre | texto | Nombre de la articulación sobre la que va montada, o `""` |
| velocidad | °/s | > 0; la máxima del aparato real |
| variable | texto o `""` | Variable del ensamblaje que fija el ángulo del catálogo (para deformables y R6) |
| pasos_por_grado | número o `undef` | Opcional; si está, el visor muestra la posición en pasos |

Los elementos que no están en ninguna articulación ni motor quedan **fijos**.

### Motor

`[nombre, etiqueta, elementos, punto, eje, articulacion, relacion, montado_en]`

| Campo | Tipo | Regla |
|---|---|---|
| nombre, etiqueta | texto | Como en la articulación |
| elementos | lista de textos | Lo que gira con el motor (la polea 20T) |
| punto, eje | vectores | Eje del motor, en reposo |
| articulacion | texto | La que impulsa |
| relacion | número ≠ 0 | Vueltas del motor por vuelta de la articulación, **con signo**, medidas respecto de `montado_en` |
| montado_en | texto | Articulación cuyo marco lleva al motor (`""` = fijo) |

Giro del motor respecto de su marco = `relacion × (valor − reposo)` de su articulación.

### Emisor

`[nombre, etiqueta, punto, direccion, color, articulacion, largo]`

| Campo | Regla |
|---|---|
| punto | Salida del haz en reposo (mm) |
| direccion | No nula; se normaliza |
| color | Nombre de color CSS (`"Lime"`) |
| articulacion | La que lo lleva (`""` = fijo) |
| largo | mm, > 0 |

### Objetivo

`[nombre, valores]`: `valores` tiene un número por articulación, en el orden de `articulaciones`,
cada uno dentro de su rango. Hacen falta al menos 2 para el modo automático; con menos, el botón
"Automático" no aparece.

### Deformable

`[elemento, articulacion, angulos]`: el elemento se exporta además con `-D <variable>=<a>` para cada
ángulo de `angulos` (la articulación DEBE tener `variable`). Se ubica en el marco del padre de esa
articulación. El elemento no puede estar en una articulación ni en un motor.

### Transparentes en la simulación

`transparentes_simulacion`: lista de elementos que el modo Funcionamiento dibuja transparentes (la
tapa de la electrónica). Por defecto, vacía.

### Validaciones en OpenSCAD (`armado_comun.scad`, con mensaje que nombra el dato)

- Todo elemento nombrado existe en `elementos`.
- Ningún elemento en dos articulaciones, en una articulación y un motor, ni deformable y móvil.
- Nombres de articulaciones y motores únicos; padres y `montado_en` existentes; sin ciclos.
- Eje y dirección no nulos; `mín < máx`; reposo dentro del rango; velocidad > 0; relación ≠ 0;
  largo > 0.
- Valores de cada objetivo: tantos como articulaciones y dentro de cada rango.
- Deformable: su articulación tiene variable; sus ángulos están dentro del rango.

## 2. Datos incrustados (JSON)

`version` pasa a **2**. Se agrega, solo si hay articulaciones:

```json
"simulacion": {
  "articulaciones": [{ "nombre": "altura", "etiqueta": "Altura", "elementos": ["cuna", "…"],
                       "punto": [0, 0, 112.4], "eje": [1, 0, 0], "rango": [-10, 95], "reposo": 45,
                       "padre": "azimut", "velocidad": 19.9, "pasos_por_grado": 45.29 }],
  "motores": [{ "nombre": "motor_altura", "etiqueta": "Motor de altura", "elementos": ["polea20_alt"],
                "punto": […], "eje": […], "articulacion": "altura", "relacion": 4, "montado_en": "azimut" }],
  "emisores": [{ "nombre": "laser", "etiqueta": "Láser", "punto": […], "direccion": […],
                 "color": "Lime", "articulacion": "altura", "largo": 600 }],
  "objetivos": [{ "nombre": "Cenit", "valores": [0, 88] }],
  "deformables": { "cable_laser": { "articulacion": "altura", "color": "Red",
                                    "fotogramas": [{ "a": -10, "malla": "<base64>" }, …] } },
  "transparentes": ["tapa"]
}
```

`variable` no viaja a la página (solo la usa el generador). `rango` sin límite va como `null`.

### Validaciones del generador

- Las de la 005, más: todo elemento móvil, de motor o deformable tiene malla; cada fotograma de un
  deformable tiene malla no vacía.
- **Pivotes (R6)**: para cada articulación con variable, cada elemento rígido exportado en `mín` y
  `máx` coincide con su malla del catálogo girada `valor − reposo` (cajas envolventes, ≤ 0,5 mm).
- Tamaño ≤ 10 MB contando los fotogramas.

## 3. Estado en el navegador

| Campo | Valor |
|---|---|
| modo | `armado` o `funcionamiento` |
| valores | Un ángulo por articulación (empieza en el reposo) |
| emisores | Encendido o apagado por emisor (empiezan apagados) |
| automático | `apagado`, `moviendo` (objetivo i) o `apuntando` (objetivo i, tiempo restante) |
| velocidad | 1, 5 o 20 |
| armado | Paso, `t` y reproducción de la 005, conservados mientras se está en Funcionamiento |

**Transiciones**:

```text
armado ──(pestaña Funcionamiento)──► funcionamiento (valores y emisores como se dejaron; al abrir, reposo y apagados)
funcionamiento ──(pestaña Armado)──► armado (paso y t como estaban; emisores apagados, automático apagado)
manual ──(Automático)──► moviendo(objetivo siguiente)
moviendo ──(todas las articulaciones llegaron)──► apuntando (emisores encendidos, 3 s)
apuntando ──(terminó el tiempo)──► moviendo(objetivo siguiente; emisores apagados)
moviendo/apuntando ──(deslizador, botón de emisor, Reposo, Automático, salir)──► manual (emisores apagados)
cualquiera ──(Reposo)──► valores = reposo, emisores apagados
```

**Transformación de un grupo** (de la raíz hacia las hojas): cada articulación es un grupo hijo del
grupo de su padre, girado `valor − reposo` alrededor de la recta (`punto`, `eje`). Un motor es un
grupo hijo del de `montado_en`, girado `relacion × (valor − reposo)` de su articulación alrededor
de su propio eje. Un deformable muestra el fotograma de ángulo más cercano al valor de su
articulación, dentro del grupo del padre. Un emisor es hijo del grupo de su articulación.
