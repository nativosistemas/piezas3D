# Guía rápida de verificación: Caja con tapa a presión para 4 pilas AA

**Funcionalidad**: [spec.md](spec.md) | **Contrato**: [interfaz_generador.md](contracts/interfaz_generador.md)

Los parámetros y las reglas V-01…V-09 están en [data-model.md](data-model.md). Todos los comandos se
ejecutan desde la raíz del repositorio. Las herramientas son las de `.tools/bin/` descritas en
`CLAUDE.md`; no se usa FreeCAD (research.md R4).

## Escenario 1: derivados (FR-008, R4, R5)

```bash
.tools/bin/openscad -o "$TMPDIR/caja_pilas.echo" src/caja_pilas_parametros.scad && grep ECHO "$TMPDIR/caja_pilas.echo"
```

**Resultado esperado**: exterior 67,2 × 54,9 mm, caja de 24,9 mm, tapa de 10,0 mm, cerrada 26,9 mm,
`deformacion_pestana` ≈ 0,0138 y `juego_vertical_pila` = 8,4.

## Escenario 2: verificación de cada pieza (Puerta 1)

```bash
scripts/verificar_pieza.sh src/caja_pilas_caja.scad
```

```bash
scripts/verificar_pieza.sh src/caja_pilas_tapa.scad
```

**Resultado esperado**: validación estricta sin avisos, apoyo en Z = 0, dentro de la cama y cajas
envolventes de 67,2 × 54,9 × 24,9 y 67,2 × 54,9 × 10,0 mm.

## Escenario 3: ensamblaje y choques (Puerta 1, U-01)

```bash
scripts/verificar_pieza.sh src/caja_pilas_ensamblaje.scad
```

**Resultado esperado**: los `assert` del conjunto pasan (pollera dentro de la boca, reborde alineado
con la ranura, pollera por encima de los tabiques y de las pilas) y la línea `CONJUNTO` indica
`cerrada=26.9` con el reborde y la ranura a la misma altura (17,9 mm).

## Escenario 4: capturas (Puerta 1, fuera del sandbox)

```bash
scripts/verificar_pieza.sh --capturas .tools/tmp/capturas src/caja_pilas_caja.scad
```

```bash
scripts/verificar_pieza.sh --capturas .tools/tmp/capturas src/caja_pilas_tapa.scad
```

**Resultado esperado**: alojamientos separados, ranuras en las paredes largas, muesca en una pared
corta; pollera con dos pestañas y su reborde; nada flotando.

## Escenario 5: variantes (US2)

```bash
.tools/bin/openscad --hardwarnings -D cantidad_pilas=6 -o "$TMPDIR/c6.stl" src/caja_pilas_caja.scad
```

```bash
.tools/bin/openscad --hardwarnings -D diametro_pila=10.5 -D largo_pila=44.5 -o "$TMPDIR/aaa.stl" src/caja_pilas_caja.scad
```

**Resultado esperado**: con 6 pilas la caja mide 99,4 mm en X; con medidas de AAA, 51,2 × 48,9 mm.

## Escenario 6: casos inválidos (FR-010, SC-006)

```bash
for d in "saliente_reborde=0.8" "espesor_pared=1.6" "alto_tabique=6" "cantidad_pilas=10 -D diametro_pila=20"; do echo "== $d"; .tools/bin/openscad -D $d -o "$TMPDIR/x.csg" src/caja_pilas_caja.scad 2>&1 | grep -o "Assertion.*" | head -1; done
```

**Resultado esperado**: cada caso se rechaza con el mensaje de V-05, V-01, V-06 y V-03.

## Pruebas físicas (después de imprimir)

| Prueba | Criterio |
|---|---|
| F1. Cargar las pilas | Entran por su peso; las 4 en < 15 s (SC-002) |
| F2. Cerrar | La tapa encastra con el pulgar y queda al ras |
| F3. Sacudir | No se abre; ninguna pila cambia de alojamiento (FR-006) |
| F4. Caída de 75 cm | No se abre (SC-004) |
| F5. 50 ciclos | Sin grietas ni pérdida de retención (SC-003) |
| F6. Vaciar | Dando vuelta la caja, las pilas caen en < 3 s (SC-002) |
