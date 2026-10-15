# Validación: Espacio para conectores y cableado

Comandos desde la raíz del repositorio. Las capturas PNG van fuera del sandbox.

## 1. El diseño pasa con los valores por defecto (SC-001, SC-004)

```bash
scripts/verificar_pieza.sh --rapido src/puntero_laser_parametros.scad
scripts/verificar_pieza.sh --rapido src/puntero_laser_ensamblaje.scad
.tools/bin/openscad -o .tools/tmp/p.csg src/puntero_laser_parametros.scad 2>&1 | grep -E "COTAS|CABLES"
```

**Esperado**: sin avisos; `alto_tapa=33.5`, `elevacion_esp32=23.9`; los largos de los cables de
motor con su reserva (≥ 20 mm).

## 2. Medidas que no entran fallan con su mensaje (SC-005)

```bash
for d in largo_dupont=20 pines_por_lado_esp32=21 ancho_enchufe_usb=16 largo_cable_motor=150; do
  .tools/bin/openscad --hardwarnings -o .tools/tmp/x.csg -D "$d" src/puntero_laser_ensamblaje.scad 2>&1 | grep -m1 -E "assert|ERROR"
done
```

**Esperado**: cada uno falla nombrando la medida (`largo_dupont=20` hace crecer la tapa hasta chocar
con el carro).

## 3. Piezas

```bash
scripts/verificar_pieza.sh src/puntero_laser_plataforma_azimut.scad
scripts/verificar_pieza.sh src/puntero_laser_tapa_electronica.scad
```

**Esperado**: pasan; la tapa mide 33,5 mm de alto; las capturas muestran los postes del ESP32 más
altos y la abertura USB más alta. Las otras 11 STL no cambian.

## 4. Web y visor

```bash
scripts/capturas_armado.sh puntero_laser        # fuera del sandbox
scripts/generar_web.py puntero_laser specs/002-puntero-laser-estelar
scripts/generar_web.py --comprobar puntero_laser specs/002-puntero-laser-estelar
```

**Esperado**: el paso 17 del visor muestra el espacio de los conectores en transparente; la etiqueta
lo nombra "Cables Dupont y enchufes (espacio reservado)".
