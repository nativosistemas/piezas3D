# Contrato: cambios en la interfaz del generador `puntero_laser`

**Funcionalidad**: [../spec.md](../spec.md) | **Modelo de datos**: [../data-model.md](../data-model.md) |
**Contrato base**: [002 interfaz_generador.md](../../002-puntero-laser-estelar/contracts/interfaz_generador.md)

El contrato de la 002 sigue vigente. Este documento enumera solo lo que cambia. **Todos los cambios
son compatibles**: no se renombra ni se elimina ningún parámetro público, no cambia ninguna unidad ni
la convención de ejes, y los 10 STL de la 002 conservan su nombre.

## 1. Entrada

### 1.1 Archivos nuevos

| Archivo | Rol |
|---------|-----|
| `src/puntero_laser_pila_falsa.scad` | Pila falsa con el contacto positivo |
| `src/puntero_laser_tapa_trasera.scad` | Tapa trasera con el contacto negativo, el lastre y la salida del cable |
| `src/puntero_laser_grapa_cable.scad` | Grapa que sujeta el cable al tubo del láser |

Las reglas pasan a ser V-01…V-21, más un aviso por `echo`.

### 1.2 Parámetros públicos

- Grupo nuevo del Customizer: **`Láser sin batería`**, con los 11 parámetros de la
  [Entidad 1](../data-model.md#entidad-1-parámetros-públicos-nuevos-customizer).
- `largo_laser`, `distancia_trasera_centro_masa` y `masa_laser_g` conservan nombre, unidad y valor.
  Se aclara que se miden con la batería y la tapa original, como en la 002.
- `distancia_trasera_centro_masa_nueva = 0` significa "calcular". Un valor mayor que 0 reemplaza el
  cálculo por la medida del láser ya convertido.

### 1.3 Formas de invocación nuevas

| Modo | Invocación | Resultado |
|------|------------|-----------|
| Pieza nueva | `.tools/bin/openscad --hardwarnings -o exports/puntero_laser_<pila_falsa\|tapa_trasera\|grapa_cable>.stl src/puntero_laser_<…>.scad` | STL oficial |
| Variante 16340 | `-D diametro_hueco_bateria=16.5 -D profundidad_hueco_bateria=36` en **todas** las piezas | STL personalizados |
| Valores del láser convertido | `.tools/bin/openscad -o "$TMPDIR/p.echo" src/puntero_laser_parametros.scad` | El `echo` agrega `masa_laser_mod_g`, `l_trasero`, `largo_tapa_fuera`, `hueco_equilibrado` y `caida_cable_v` |

## 2. Salida

### 2.1 STL oficiales: de 10 a 13

| Pieza | STL | Cant. a imprimir |
|-------|-----|------------------|
| Pila falsa | `exports/puntero_laser_pila_falsa.stl` | 1 |
| Tapa trasera del láser | `exports/puntero_laser_tapa_trasera.stl` | 1 |
| Grapa del cable | `exports/puntero_laser_grapa_cable.stl` | 1 |

Cambian de forma y se regeneran:

- `cuna_laser`: canaleta a 150° y sin la ranura del cable.
- `plataforma_azimut`: soporte del regulador.
- Los brazos, la polea de altura y la base, por el cambio de `altura_eje`.

### 2.2 Errores nuevos

Se usa el mismo formato que en la 002 (`ERROR: Assertion … failed: "<parámetro>=<valor>: …"`), para
V-15…V-21 ([Entidad 4](../data-model.md#entidad-4-validaciones-nuevas-v-15--v-21)).

Si `alto_brazo` > 131 mm, el generador **no** falla y escribe:

`ECHO: "AVISO: alto_brazo=<valor> supera 131 mm: repetir el cálculo de flexión (research 006, R5)"`

## 3. Artefactos asociados

| Artefacto | Ruta |
|-----------|------|
| Fuentes de las piezas | `src/puntero_laser_<pieza>.scad` (de 9 a 12 archivos) |
| Mallas de manufactura | `exports/puntero_laser_*.stl` (de 10 a 13 archivos) |
| Justificación de la falta de simulación | [plan.md](../plan.md) y [research.md R10](../research.md) |
