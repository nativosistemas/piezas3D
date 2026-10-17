# Contrato: piezas y ensamblaje (012)

Lo que cambia en `src/` y lo que otras partes del pipeline pueden dar por cierto después.

## Piezas

| Archivo | Interfaz que se mantiene | Lo nuevo |
|---|---|---|
| `src/puntero_laser_adaptador_tripode.scad` | `pieza_adaptador_tripode()`, encajes y caja envolvente iguales | Módulo `marcas_cardinales()` restado al final del `difference()` |
| `src/puntero_laser_plataforma_azimut.scad` | `pieza_plataforma_azimut()`, encajes y caja envolvente iguales | Módulo `indice_azimut()` restado al final |
| `src/puntero_laser_brazo_horquilla.scad` | `pieza_brazo_horquilla(lado)`; la variante `"cable"` no cambia ni un vértice | En la variante `"motor"`: oreja en `cuerpo_brazo()` y módulo `aguja_indice_altura()` sumado |
| `src/puntero_laser_polea_altitud.scad` | `pieza_polea_altitud()`, dentado, cubo y hexágono iguales | 2 agujeros guía restados; `r_aligerado` sale de parámetros |
| `src/puntero_laser_disco_escala.scad` (**nuevo**) | — | `pieza_disco_escala()` con encabezado estándar; z = 0 es la cara que apoya en la polea y la escala queda en z = `espesor_disco_escala` |

Las caras de referencia de cada pieza siguen en el mismo lugar. El brazo del motor crece solo en +Y de
su sistema de impresión (hacia arriba en el conjunto).

## Ensamblaje (`src/puntero_laser_ensamblaje.scad`)

- **Elementos**:
  - `disco_escala`: `translate([x_ext_polea_alt, 0, z_eje_altura]) rotate([angulo_altura, 0, 0])`,
    orientado igual que la polea, con la cara z = 0 sobre la cara exterior de la polea.
  - `tornillos_disco`: 2 tornillos M3 × 8 con su arandela.
- **Nombres para el visor** (`nombres_elementos`):
  - `["disco_escala", "Disco de la escala de altura", "impresa"]`
  - `["tornillos_disco", "Tornillos M3 × 8 del disco de la escala", "comprada"]`
- **Colores**: `disco_escala` en «WhiteSmoke»; `tornillos_disco` en el gris de la tornillería.
- **Grupos**: los dos elementos se suman a `grupo_horquilla` y a `elementos_altura`.
- **Pasos**: se suman al paso donde entra `polea_alt`, con un desplazamiento explotado en +X mayor que
  el de la polea.
- **Simulación**: el 7.º campo de la articulación `azimut` (`reposo`) pasa de 0 a `azimut_reposo`
  (180). El visor no cambia: ya aplica `valor − reposo` (contrato 007).
- **Comprobaciones**: se agregan M-03, M-07 y M-08 ([data-model.md](../data-model.md)). Las
  comprobaciones de choque existentes deben seguir pasando sin tocarlas.

## Exportación

- `exports/puntero_laser_disco_escala.stl`, nueva.
- Se regeneran `adaptador_tripode`, `plataforma_azimut`, `brazo_horquilla_motor` y `polea_altitud`.
- Las otras 9 STL se comparan por vértices con las de `70ee3d6` y deben quedar iguales.
