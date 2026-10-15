# Validación: Simulación de funcionamiento en el visor 3D

Escenarios de punta a punta. Los comandos se corren desde la raíz del repositorio. Contratos:
[ensamblaje](contracts/ensamblaje.md), [scripts](contracts/scripts.md) y [visor](contracts/visor.md).

## Requisitos previos

- La funcionalidad 006 con commit (`cc0f0a2`); esta rama sale de ahí.
- OpenSCAD 2021.01 en `.tools/bin/openscad` (funciona dentro del sandbox).
- Para el navegador: el Edge de Windows, **fuera del sandbox**:

  ```bash
  edge="/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
  ```

- Capturas sin ventana (abreviatura usada abajo; `URL` es lo que va después de `armado_3d.html`):

  ```bash
  captura() { "$edge" --headless=new --host-resolver-rules="MAP * ~NOTFOUND" --use-angle=swiftshader \
    --enable-unsafe-swiftshader --hide-scrollbars --window-size=1280,800 --virtual-time-budget=10000 \
    --screenshot="$(wslpath -w "$PWD/.tools/tmp/$1.png")" \
    "file:///$(wslpath -w "$PWD/specs/002-puntero-laser-estelar/web/armado_3d.html" | tr '\\' '/')$2"; }
  ```

## 1. Nada cambia fuera de la simulación (FR-004, FR-007)

```bash
scripts/verificar_pieza.sh --rapido src/puntero_laser_ensamblaje.scad
scripts/capturas_armado.sh puntero_laser            # fuera del sandbox
git status --short docs/img exports
```

**Esperado**: la validación pasa sin avisos; las capturas de los pasos y las STL no cambian (si git
las marca, compararlas por píxeles y por vértices ordenados: deben ser iguales). La caja de pilas
genera su visor sin la pestaña Funcionamiento:

```bash
scripts/generar_web.py caja_pilas specs/004-caja-pilas-aa
grep -c '"simulacion"' specs/004-caja-pilas-aa/web/armado_3d.html     # 0
```

## 2. El visor sale con la simulación (historia 4, SC-001, SC-008)

```bash
scripts/generar_web.py puntero_laser specs/002-puntero-laser-estelar
```

**Esperado**: `✓ Visor 3D: … (≈ 4 MB, … 2 articulaciones, mallas exportadas)`, sin errores de
pivote (la comprobación R6 pasó). Tamaño ≤ 10 MB. La web tiene el enlace "Ver cómo funciona".

## 3. Las declaraciones inválidas se detectan (historia 4, escenario 3)

Uno por vez, en `src/puntero_laser_ensamblaje.scad`, y deshacer después de cada uno:

| Cambio | Mensaje esperado |
|---|---|
| Rango de altura `[95, -10]` | nombra `altura` y el rango invertido |
| Agregar `"cuna"` a los elementos del azimut | nombra `cuna` en dos articulaciones |
| Eje de altura `[0, 0, 0]` | nombra `altura` y el eje nulo |
| Punto de altura `[0, 0, 0]` | la comprobación de pivotes nombra `altura`, un elemento y el ángulo |
| Reposo de altura `0` | ídem (el reposo no es el ángulo del catálogo) |

## 4. Comprobación de la puerta 5 (SC-007)

```bash
scripts/generar_web.py --comprobar puntero_laser specs/002-puntero-laser-estelar
```

**Esperado**: `✓`. Cambiar `dientes_polea_conducida` de 80 a 84 y repetir: falla con "cambiaron las
fuentes". Regenerar: el motor gira 4,2 veces el eje. Volver a 80 y regenerar. (Con 90 el diseño no es
válido: el tope tensor no entra; OpenSCAD lo rechaza y el visor no se genera.)

## 5. Posiciones coinciden con OpenSCAD (SC-002)

```bash
captura alt95 "?modo=funcionamiento&altura=95&azimut=0"
.tools/bin/openscad -D 'angulo_altura=95' -D 'ver_tapa=false' --camera=… -o "$PWD/.tools/tmp/alt95_scad.png" src/puntero_laser_ensamblaje.scad   # fuera del sandbox
```

**Esperado**: la cuna, el láser y el cable en la misma posición en las dos imágenes. Repetir con
`altura=-10` y con `azimut=90` y `180` (girando a mano el conjunto en OpenSCAD). La comprobación de
pivotes ya cubrió las cajas envolventes; esta revisión cubre el azimut y el cable.

## 6. Mover a mano y ver los motores (historia 1, SC-003)

Abrir `armado_3d.html#funcionamiento` en el Edge:

- Mover Azimut: gira todo menos la base; la polea del motor de azimut, con su marca, gira 4 vueltas
  por vuelta de la plataforma y en sentido contrario respecto de la plataforma.
- Mover Altura: la cuna y el láser se inclinan sin despegarse de la horquilla; la polea grande gira
  con ellos y la 20T gira 4 veces más, en el mismo sentido. Llevar Altura a 90°: el motor marca 180°
  (45° × 4). No pasa de −10° ni de 95°.
- El cable acompaña al láser sin despegarse de forma evidente (cambia de forma cada 5°).
- "Reposo" vuelve a azimut 0° y altura 45°.
- Volver a la pestaña Armado: el paso y la vista son los que estaban.

## 7. Láser (historia 2, SC-005)

```bash
captura laser45 "?modo=funcionamiento&laser=1"
captura laser90 "?modo=funcionamiento&altura=90&azimut=120&laser=1"
```

**Esperado**: el haz verde sale de la punta del láser, en la dirección de su eje, con un brillo en
la salida, en las dos capturas. En el navegador: `L` lo prende y apaga; al entrar al modo empieza
apagado.

## 8. Modo automático (historia 3, SC-006)

En el navegador, "Automático" a ×1:

- Recorre los objetivos en bucle; el láser está apagado mientras se mueve y encendido 3 s al llegar.
- El tiempo entre dos objetivos, medido con reloj, es `max(Δazimut, Δaltura) / 19,9 °/s` (±10 %).
- El paso de 350° a 10° de azimut va por el camino corto (20°).
- Con ×20 aparece "velocidad no real"; tocar un deslizador lo detiene y apaga el láser.
- Con la pestaña en segundo plano unos segundos, al volver sigue en el objetivo correcto.

## 9. Celular (FR-021)

Emulación de dispositivos del Edge a 360 px: los controles de Funcionamiento entran debajo de la
vista, sin desplazamiento horizontal, y los deslizadores se manejan con el dedo.

## 10. Comprensión (SC-004)

Una persona que no conoce el diseño, solo con el modo Funcionamiento, dice en menos de 1 minuto qué
motor mueve cada eje y qué partes quedan fijas.
