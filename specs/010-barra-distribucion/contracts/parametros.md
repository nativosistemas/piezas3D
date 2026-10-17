# Contrato: barra de distribución (parámetros y conexiones)

Interfaz para quien arma o adapta el diseño (secciones 4 y 5.4 de la guía). Fórmulas:
[../data-model.md](../data-model.md).

## Qué medir y dónde ponerlo

En `src/puntero_laser_parametros.scad`, sección `/* [Conectores y cables] */`:

| Medir | Parámetro |
|---|---|
| Largo del trozo de placa perforada cortado | `barra_largo` |
| Ancho del trozo de placa perforada cortado | `barra_ancho` |
| Pines de cada tira (si se agregan accesorios) | `pines_barra` |

## Qué cambia solo

El soporte de la barra en la plataforma. Si la barra pasa el largo de la columna del relé, también
crecen el hueco del sobrante y la tapa en Y. Después de cambiar un valor, correr
`scripts/verificar_pieza.sh` sobre la plataforma y la tapa y volver a imprimir las que cambien.

## Asignación de pines (la guía la reproduce en la sección 5.4)

La tabla de [../research.md](../research.md#r5-destinos-sin-pines-macho) es la fuente. Las
entradas E+ (desde el interruptor, con cable rojo de 26 AWG) y E− (negro del cable USB) se sueldan en
el agujero 8 de cada tira.

## Errores

Los mensajes V-27 a V-29 de [../data-model.md](../data-model.md#4-validaciones-nuevas) y el de zonas
solapadas (V-08), que nombra la barra y la zona con la que choca.
