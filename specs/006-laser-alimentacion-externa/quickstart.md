# Guía de verificación: Láser alimentado desde el power bank

**Plan**: [plan.md](plan.md) | **Modelo de datos**: [data-model.md](data-model.md) | **Base**:
[002 quickstart.md](../002-puntero-laser-estelar/quickstart.md)

Los escenarios 1–8 son por línea de comandos, desde la raíz del repositorio, dentro del sandbox,
salvo las capturas PNG y el navegador (ver `CLAUDE.md`). Los escenarios F1–F8 son pruebas físicas.

## Escenarios por línea de comandos

### 1. Derivados del láser convertido

```bash
.tools/bin/openscad -o "$TMPDIR/p.echo" src/puntero_laser_parametros.scad && grep -E "DISEÑO|AVISO" "$TMPDIR/p.echo"
```

Con los valores por defecto se espera:

| Derivado | Valor esperado |
|---|---|
| `masa_laser_mod_g` | 166,9 g |
| `l_trasero` | 92,7 mm |
| `largo_tapa_fuera` | 17,75 mm |
| `hueco_equilibrado` | 13,0 mm (mín. 12) |
| `caida_cable_v` | 0,080 V |
| `alto_brazo` | 126,3 mm (igual que en la 002) |

No debe aparecer ninguna línea `AVISO`.

### 2. Piezas nuevas y modificadas

```bash
for p in pila_falsa tapa_trasera grapa_cable cuna_laser plataforma_azimut; do scripts/verificar_pieza.sh src/puntero_laser_$p.scad || break; done
```

Las 5 piezas pasan la validación estricta, apoyan en Z = 0 y entran en la cama. La plataforma sigue
midiendo 194,3 × 165,9 mm, porque el regulador entra en la columna A ([research R8](research.md)).

### 3. Capturas (fuera del sandbox)

Igual que el escenario 2, con `--capturas "$TMPDIR/cap"`. Hay que revisar en las capturas:

- la canaleta a 150° de la cuna y que no quede la ranura vieja;
- el escalón, la ranura y la ventana de la tapa;
- la ranura lateral de la tuerca de la pila falsa.

### 4. Ensamblaje y barrido

```bash
.tools/bin/openscad --hardwarnings -o "$TMPDIR/ens.png" --imgsize=1600,1200 --viewall --autocenter src/puntero_laser_ensamblaje.scad
```

Termina sin error: V-07 con la tapa y su tuerca de −10° a 95°, V-19 y los choques de la columna A.
La tabla tiene 19 pasos.

### 5. Variantes válidas

| Variante | `-D` en todas las piezas | Resultado esperado |
|---|---|---|
| Batería 16340 | `diametro_hueco_bateria=16.5 profundidad_hueco_bateria=36` | Pila falsa más corta. `l_trasero` cambia y el ensamblaje pasa |
| Sin lastre | `tuercas_lastre_tapa=0` | `alto_brazo` = 129,4 mm, sin `AVISO`; las piezas se generan igual |
| Láser ya medido | `distancia_trasera_centro_masa_nueva=100` | `l_trasero` = 100 y `AVISO` de `alto_brazo` = 131,5 mm |
| Mini-360 | `regulador_largo=17 regulador_ancho=11` | La columna A se acorta |

### 6. Casos inválidos

Cada caso termina con `ERROR: Assertion` y un mensaje que nombra el parámetro:

| Caso | `-D` | Regla |
|---|---|---|
| Hueco más grande que el tubo | `diametro_hueco_bateria=22 diametro_zona_tapa=23` | V-16 |
| Cable demasiado largo | `largo_cable_laser=1000` (constante oculta; `-D` la reemplaza igual) | V-20 |
| Tapa pegada a la cuna | `distancia_trasera_centro_masa_nueva=75` | V-19 |
| Valor fuera de rango | `tuercas_lastre_tapa=4` | V-15 |

### 7. Exportación

Hay 13 STL en `exports/`, todos regenerados con los valores por defecto.

### 8. Guía, web y visor

```bash
python3 scripts/generar_web.py --comprobar puntero_laser specs/002-puntero-laser-estelar
```

Termina sin errores. La web y el visor 3D muestran el paso "Preparar el láser" con la pila falsa, la
tapa, el lastre y la grapa. La revisión en el navegador se hace fuera del sandbox.

## Pruebas físicas

| # | Prueba | Criterio | Requisito |
|---|---|---|---|
| F1 | Continuidad del tubo: multímetro entre la zona roscada (con la punta del prisionero apretada) y el cuerpo del cabezal | < 1 Ω | FR-008 |
| F2 | Ajustar el regulador sin el láser: puentear IN del relé a 3,3 V y girar el preset | 3,6–3,8 V en la salida | FR-002 |
| F3 | ESP32 borrado, interruptor cerrado; después, cable del GPIO23 suelto | 0 V en los hilos del láser en los dos casos | FR-003, FR-003a, SC-002 |
| F4 | 10 arranques seguidos del ESP32 con el láser conectado, mirando el haz | Ningún destello | SC-002 |
| F5 | 10 maniobras del relé | 10 encendidos y 10 apagados | SC-001 |
| F6 | Láser encendido y los 2 motores moviéndose | 3,5–3,8 V en la pila falsa; el haz no parpadea | SC-003 |
| F7 | Equilibrado con la pila falsa y la tapa; motores sin energía de 0° a 90° | Movimiento < 0,2° | SC-005 |
| F8 | 20 recorridos de −10° a 95° mirando el cable | No se tensa, no roza correas ni poleas y no se sale de la canaleta ni de la grapa | SC-004 |
| F9 | Pasar de la pila falsa a la batería original y volver, cronometrando | < 10 min | SC-007 |
