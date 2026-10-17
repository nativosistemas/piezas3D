# Contrato: la Tabla de cables de la guía

Va en `docs/<diseño>_guia.md`, dentro de la sección de conexiones (en el puntero láser, la 5.4),
después de la tabla de pines de la barra de distribución.

## Formato

```markdown
**Tabla de cables**:

| N.º | Desde | Hasta | Conectores | Largo |
|-----|-------|-------|------------|-------|
| 1 | Power bank USB +5 V | Interruptor | USB-A / soldado | ≈ 160 mm |
| 2 | Power bank USB GND | Barra GND (entrada) | USB-A / soldado | ≈ 170 mm |
…
| 9 | ESP32 GPIO 16 | ULN2003 azimut IN1 | Dupont hembra / Dupont hembra | ≈ 75 mm |
…
```

## Reglas que comprueba `generar_visor.py`

- El encabezado es exactamente `**Tabla de cables**:` seguido de una tabla Markdown cuyas dos primeras
  columnas después de `N.º` se llaman `Desde` y `Hasta`.
- Cada renglón es un cable. Los textos de Desde y Hasta se comparan con los del ensamblaje después de
  quitar los espacios de los bordes y los `**` de negrita. Las mayúsculas y los acentos cuentan.
- Los N.º son 1, 2, 3… sin saltos.
- No se comparan ni los conectores ni el largo: son texto para la persona. El largo lo informa el
  ensamblaje con `echo` (`CABLES largo_<id>=…`) y se copia al actualizar la guía.

## Errores

| Situación | Mensaje |
|---|---|
| Falta la tabla | `<guía> no tiene la **Tabla de cables** (el ensamblaje declara cables)` |
| Renglón solo en la guía | `La Tabla de cables de la guía tiene «<desde> → <hasta>» y el ensamblaje no` |
| Cable solo en el ensamblaje | `El ensamblaje tiene el cable '<id>' («<desde> → <hasta>») y la Tabla de cables de la guía no` |
| Numeración | `<guía>: la Tabla de cables no está numerada 1, 2, 3…` |
