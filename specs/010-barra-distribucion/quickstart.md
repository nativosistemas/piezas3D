# Validación: Barra de distribución de alimentación

Comandos desde la raíz del repositorio. Las capturas PNG van fuera del sandbox.

## 1. El diseño pasa con los valores por defecto (SC-001, SC-002)

```bash
scripts/verificar_pieza.sh --rapido src/puntero_laser_parametros.scad
scripts/verificar_pieza.sh --rapido src/puntero_laser_ensamblaje.scad
.tools/bin/openscad -o .tools/tmp/p.csg src/puntero_laser_parametros.scad 2>&1 | grep -E "COTAS|DISEÑO"
```

**Esperado**: sin avisos; `alto_tapa=33.5` y la plataforma con el mismo tamaño que antes; la masa
estimada sube ≈ 3 g.

## 2. Medidas que no entran fallan con su mensaje (SC-004)

```bash
for d in pines_barra=5 barra_largo=20 barra_ancho=10 uln2003_ancho=28; do
  .tools/bin/openscad --hardwarnings -o .tools/tmp/x.csg -D "$d" src/puntero_laser_ensamblaje.scad 2>&1 | grep -m1 -E "assert|ERROR"
done
```

**Esperado**: cada uno falla nombrando la medida (V-27, V-28, V-29 dos veces). `-D pines_barra=8 -D
barra_largo=30.5` alarga la barra más allá del relé: el sobrante y la tapa crecen en Y, y la
validación sigue pasando o nombra lo que choca.

## 3. Piezas

```bash
scripts/verificar_pieza.sh src/puntero_laser_plataforma_azimut.scad
scripts/verificar_pieza.sh src/puntero_laser_tapa_electronica.scad
```

**Esperado**: pasan. La captura de la plataforma muestra el soporte nuevo al lado del regulador. La
STL de la tapa y las otras 11 no cambian (se comparan por vértices).

## 4. Documentación, web y visor (SC-003)

```bash
scripts/capturas_armado.sh puntero_laser        # fuera del sandbox
scripts/generar_web.py puntero_laser specs/002-puntero-laser-estelar
scripts/generar_web.py --comprobar puntero_laser specs/002-puntero-laser-estelar
```

**Esperado**:
- La lista de materiales trae la placa perforada, la tira de pines y el termocontraíble, con precio
  verificado o vacío (y el total marcado como parcial), y el cable de silicona de 70 cm.
- En la guía, los primeros pasos nombran el soldador, el estaño y el termocontraíble. La sección 5.4
  tiene la tabla de pines y el esquema con la barra.
- En el paso 16 del visor la barra baja a su soporte; en el paso 17 sus Dupont están dentro del
  volumen transparente.

## 5. Prueba real (pendiente del armado)

Con la barra armada, sin placas conectadas:
- **Continuidad**: no hay continuidad entre las dos tiras, y sí la hay entre los pines de una misma
  tira.
- **Tensión**: con el interruptor cerrado, ≈ 5 V entre las dos tiras en cada pin; con el interruptor
  abierto, 0 V.
