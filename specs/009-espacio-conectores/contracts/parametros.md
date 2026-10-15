# Contrato: parámetros de conectores y cables del puntero láser

Interfaz para quien adapta el diseño a sus componentes (sección 4 de la guía). Detalle y fórmulas:
[../data-model.md](../data-model.md).

## Qué medir y dónde ponerlo

En `src/puntero_laser_parametros.scad`, sección `/* [Conectores y cables] */`:

| Medir | Parámetro |
|---|---|
| Largo del cuerpo plástico de un Dupont hembra | `largo_dupont` |
| Alto del plástico de una tira de pines | `alto_tira_pines` |
| Cuánto hay que dejar para doblar el cable sin forzarlo | `radio_curva_cable` |
| Alto del enchufe del motor ya conectado, sobre la placa | `alto_enchufe_motor` |
| Pines por fila del ESP32 | `pines_por_lado_esp32` |
| Ancho y alto de la funda del enchufe USB | `ancho_enchufe_usb`, `alto_enchufe_usb` |
| Largo del cable del motor, del motor al enchufe | `largo_cable_motor` |

## Qué cambia solo

La elevación del ESP32, la altura de la tapa y su abertura USB. Después de cambiar un valor:
`scripts/verificar_pieza.sh` sobre la plataforma y la tapa, y reimprimir las que cambien.

## Errores

Los mensajes V-22 a V-26 de [../data-model.md](../data-model.md#4-validaciones-nuevas). Si la tapa
crece de más, falla la comprobación existente "la tapa (… mm) toca el carro o el motor de altura":
usar conectores más cortos o a 90°.
