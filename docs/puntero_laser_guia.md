# Guía de Producción: Puntero láser estelar motorizado

Montura motorizada de dos ejes (altitud-azimut) que apunta un puntero láser verde "303" a cualquier
estrella del cielo. Se enrosca al tornillo 3/8"-16 de un trípode de telescopio. Un ESP32 mueve dos
motores 28BYJ-48 a través de correas GT2 con reducción 1:4 y enciende el láser con un relé. El láser
va **sin su batería**: una pila falsa impresa y una tapa trasera impresa lo conectan al power bank a
través del relé y de un regulador a 3,7 V, así que con el ESP32 apagado el láser queda sin energía. La
mecánica está pensada para un error de apuntado menor a 2°: el presupuesto estimado es de 0,5° (suma
cuadrática) y 1,35° en el peor caso.

![Conjunto armado (el láser se muestra a 45°; en transparente, a −10° y a 95°)](img/puntero_laser_ensamblaje.png)

```text
                    polea de altura 80T (por fuera del brazo)
                         │      cuna con el láser (gira en altura, −10° … 95°)
                         ▼     ┌──────────────────────────┐
      brazo "cable" ║════════[cuna]════════║ brazo "motor" ◄── motor de altura + carro (pilares)
                    ║                      ║          │ correa GT2 200 mm
   ─X  power bank ┌─╨──────────────────────╨─┐ tapa: ESP32, relé, regulador,    +X
       (de pie)   │      plataforma de azimut │ 2 × ULN2003, interruptor y cables
                  └────────────┬─────────────┘
          motor de azimut (+Y) │ perno M8, 2 × 608ZZ
                  ┌────────────┴─────────────┐
                  │  base + polea fija 80T    │  ◄── correa GT2 200 mm (bajo la plataforma)
                  └────────────┬─────────────┘
                       tuerca 3/8"-16 ── trípode
```

| Archivo | Uso |
|---------|-----|
| `exports/puntero_laser_*.stl` (13 archivos) | Piezas listas para el laminador (valores por defecto) |
| `src/puntero_laser_parametros.scad` | Medidas compartidas: el único archivo que hay que editar para adaptar el diseño (sección 4) |
| `src/puntero_laser_<pieza>.scad` | Una pieza por archivo |
| `src/puntero_laser_ensamblaje.scad` | Vista del conjunto con comprobaciones de choque (no se imprime) |

### Valores del diseño entregado

| Parámetro | Valor | Parámetro | Valor |
|-----------|-------|-----------|-------|
| `diametro_laser` | 30 mm | `largo_laser` | 190 mm |
| `distancia_trasera_centro_masa` | 95 mm | `masa_laser_g` | 180 g |
| `powerbank_largo × _ancho × _alto` | 100 × 65 × 25 mm | `esp32_largo × _ancho` | 55 × 28 mm |
| `rele_largo × _ancho` | 50 × 26 mm | `uln2003_largo × _ancho` | 35 × 32 mm |
| `dientes_polea_conducida` | 80 | `largo_correa` | 200 mm |
| `espesor_brazo` | 12 mm | `ajuste_608` | +0,10 mm |
| `holgura_encastre` | 0,25 mm | `holgura_colimacion` | 2 mm por lado |
| `diametro_hueco_bateria` | 18,5 mm (18650) | `profundidad_hueco_bateria` | 65 mm |
| `diametro_zona_tapa` | 30 mm | `largo_zona_tapa` | 12 mm |
| `largo_tapa_original` | 20 mm | `tuercas_lastre_tapa` | 2 (M10) |
| `masa_bateria_g` / `masa_tapa_original_g` | 45 g / 20 g | `regulador_largo × _ancho` | 22 × 17 mm (MP1584EN) |

> **Las medidas del láser sin batería son supuestas.** Hay que reemplazarlas por las de tu ejemplar
> antes de imprimir la pila falsa y la tapa trasera (sección 4.1).

Cotas que resultan (las imprime `src/puntero_laser_parametros.scad` con `echo`):

| Cota | Valor |
|------|-------|
| Distancia entre los centros de las poleas | 45,97 mm |
| Altura del eje de altura sobre la plataforma | 109,3 mm (179,8 mm sobre el trípode) |
| Plataforma | 194,3 × 165,9 mm |
| Láser convertido (sin batería, con pila falsa, tapa, lastre y grapa) | ≈ 167 g, equilibrado a 92,7 mm de la cola |
| Hueco entre la tapa trasera y la cuna (grapa y equilibrado) | 13,0 mm |
| Caída de tensión en el cable del láser | 0,08 V |
| Centro de masa de la parte giratoria | a ≈ 4 mm del eje |
| Masa total estimada del aparato | ≈ 965 g |

## Primeros pasos

1. **Medir tus componentes** antes de imprimir nada: diámetro, largo y punto de equilibrio del láser,
   el hueco de su batería y la rosca de su tapa trasera, y las medidas del power bank y de las placas
   (sección 4.1). Si difieren de los valores del diseño
   entregado, cargarlos en `src/puntero_laser_parametros.scad` y regenerar los STL (sección 4.3).
2. **Imprimir la probeta del 608** y calibrar `ajuste_608` (sección 3.1). Si el valor cambia,
   regenerar los 13 STL.
3. **Imprimir el resto de las piezas** en PETG (sección 1).
4. **Comprar los componentes** de la lista de materiales (sección 2). Con el relé, fijarse que sea
   compatible con 3,3 V (sección 5.4). Hace falta un **multímetro** para ajustar el regulador y probar
   el contacto del tubo.
5. **Armar** siguiendo los pasos de la sección 2 y hacer la **puesta a punto** (sección 3).

## 1. Especificaciones de Impresión 3D

> **Holguras por defecto, no medidas.** Este proyecto todavía no tiene un perfil de impresora medido
> (`src/perfil_impresora.scad`). Los encajes de este diseño usan valores genéricos para FDM con
> boquilla de 0,4 mm:
>
> - encastres de 0,25 mm;
> - paso de M3 de 0,3 mm;
> - alojamientos de tuerca de 0,2 mm;
> - paso de M8 de 0,4 mm;
> - 608 a presión con +0,10 mm.
>
> Las piezas del láser sin batería toman sus holguras de `src/perfil_impresora.scad`, que tiene
> `perfil_medido = false`, así que también son **valores por defecto, no medidos**: la funda de la
> tapa trasera es deslizante (+0,30 mm), la pila falsa entra suelta (−0,40 mm), y la grapa y las
> tuercas M10 del lastre van a presión (0,15 mm).
>
> Los más críticos son los alojamientos de los 608: calibrarlos con la probeta (3.1) antes de
> imprimir el resto.

**Orden de impresión**: imprimir **primero la probeta de ajuste del 608** (sección 3.1). Si el valor
de `ajuste_608` cambia, hay que **regenerar los 13 STL** antes de imprimir el resto.

| Pieza | STL | Cant. | Orientación (cara sobre la cama) | Relleno | Perímetros | Soportes | Adherencia | Masa maciza* |
|-------|-----|-------|----------------------------------|---------|------------|----------|------------|--------------|
| Probeta de ajuste del 608 | `puntero_laser_probeta_ajuste_608.stl` | 1 | Plana, tal como viene | 15 % | 3 | No | — | 13 g |
| Adaptador del trípode (base) | `puntero_laser_adaptador_tripode.stl` | 1 | Cara de apoyo del trípode | 40 % giroide | 4 | No | — | 254 g |
| Plataforma de azimut | `puntero_laser_plataforma_azimut.stl` | 1 | Cara inferior | 20 % giroide | 3 | No | Borde (brim) de 5 mm si la cama despega esquinas | 212 g |
| Brazo de la horquilla, motor | `puntero_laser_brazo_horquilla_motor.stl` | 1 | Cara interior (pilares hacia arriba) | 30 % | 4 | No | — | 101 g |
| Brazo de la horquilla, cable | `puntero_laser_brazo_horquilla_cable.stl` | 1 | Cara interior (canal hacia arriba) | 30 % | 4 | No | — | 57 g |
| Cuna del láser | `puntero_laser_cuna_laser.stl` | 1 | De pie, sobre un anillo de colimación | 30 % | 4 | No | Borde (brim) de 5 mm | 55 g |
| Polea de altura | `puntero_laser_polea_altitud.stl` | 1 | Cara exterior (cubo hacia arriba) | 40 % | 4; capa de 0,16 mm | No | — | 23 g |
| Carro del motor | `puntero_laser_carro_motor.stl` | **2** | Plano | 40 % | 4 | No | — | 8 g c/u |
| Separador y 3 arandelas | `puntero_laser_separador_azimut.stl` | 1 | De pie, tal como viene | 100 % | — | No | — | 1 g |
| Tapa de la electrónica | `puntero_laser_tapa_electronica.stl` | 1 | Techo | 15 % | 3 | No | — | 54 g |
| Pila falsa | `puntero_laser_pila_falsa.stl` | 1 | De pie, cara trasera (la de la ranura) | 30 % | 3 | No | Borde (brim) de 3 mm | 20 g |
| Tapa trasera del láser | `puntero_laser_tapa_trasera.stl` | 1 | De pie, piso trasero | 40 % | 4 | No | — | 21 g |
| Grapa del cable | `puntero_laser_grapa_cable.stl` | 1 | Plana | 100 % | — | No | — | 1 g |

\* Masa si la pieza fuera maciza de PETG. Con los ajustes de la tabla, el conjunto impreso pesa
≈ 440 g; el laminador da el valor exacto.

| | | |
|---|---|---|
| ![Base](img/puntero_laser_adaptador_tripode.png) Base | ![Plataforma](img/puntero_laser_plataforma_azimut.png) Plataforma | ![Cuna](img/puntero_laser_cuna_laser.png) Cuna |
| ![Brazo motor](img/puntero_laser_brazo_horquilla_motor.png) Brazo motor | ![Brazo cable](img/puntero_laser_brazo_horquilla_cable.png) Brazo cable | ![Polea de altura](img/puntero_laser_polea_altitud.png) Polea de altura |
| ![Carro](img/puntero_laser_carro_motor.png) Carro (×2) | ![Separador](img/puntero_laser_separador_azimut.png) Separador y arandelas | ![Tapa](img/puntero_laser_tapa_electronica.png) Tapa |
| ![Probeta](img/puntero_laser_probeta_ajuste_608.png) Probeta del 608 | ![Pila falsa](img/puntero_laser_pila_falsa.png) Pila falsa | ![Tapa trasera](img/puntero_laser_tapa_trasera.png) Tapa trasera |
| ![Grapa](img/puntero_laser_grapa_cable.png) Grapa del cable | | |

**Ninguna pieza necesita soportes.** Los únicos voladizos son puentes cortos: los techos de las
tuercas embebidas, los puentes de la canaleta del cable de la cuna, la ranura de la tuerca de la pila
falsa, las ventanas con techo a dos aguas (ningún puente supera 10 mm), y la repisa anular de 3 mm
sobre el alojamiento del 608 inferior de la base. Los resaltes de los prisioneros de la tapa trasera
tienen chaflán de 45° por debajo. Los muñones de la cuna, la ventana de la base y las pestañas
de las poleas tienen perfiles a 45°.

**Configuración común del laminador**:

- Capa de 0,2 mm (0,16 mm en las poleas, para que los dientes GT2 salgan definidos).
- 5 capas superiores e inferiores.
- Sin "alisado" (ironing) en las caras de apoyo de los rodamientos.

**Material recomendado: PETG**, con boquilla a 230–245 °C y cama a 70–85 °C. Resiste la humedad
nocturna y la temperatura dentro de un auto al sol. El PLA sirve para pruebas, pero se ablanda a
~55 °C.

## 2. Ensamblaje y Lista de Materiales (BOM)

### Herrajes / Tornillería Requerida

<!-- BOM:inicio (generado desde docs/puntero_laser_bom.csv con scripts/generar_web.py: no editar a mano) -->
**Rodamientos, poleas y correas**

* 4 × Rodamiento 608ZZ (22 × 8 × 7 mm)
* 2 × Polea GT2 20 dientes, agujero de 5 mm, para correa de 6 mm (con 2 prisioneros)
* 2 × Correa GT2 cerrada de 200 mm × 6 mm (100 dientes)

**Pernos y tuercas M8 y del trípode**

* 1 × Perno M8 × 50 mm cabeza hexagonal (eje de azimut)
* 1 × Perno M8 × 55 mm cabeza hexagonal (eje de altura, lado del motor: entra desde afuera por la polea)
* 1 × Perno M8 × 30 mm cabeza hexagonal (eje de altura, lado del cable)
* 2 × Tuerca autoblocante M8
* 1 × Tuerca M8 común de 6,5 mm de alto (DIN 934), para el muñón +X de la cuna
* 1 × Tuerca 3/8"-16 UNC (tornillo del trípode)
* 2 × Tuerca M10 (DIN 934): lastre de la tapa trasera del láser
* 2–4 × Arandela M8 fina (solo si hace falta ajustar la horquilla a la plataforma, paso 8)
* 4 × Tuerca M8 extra como contrapeso (opcional, sección 3.4)

**Tornillería M3**

* 4 × Tornillo M3 × 12 mm + 4 × tuerca M3: pies de los brazos
* 2 × Tornillo M3 × 10 mm + 2 × tuerca M3: carro de azimut
* 2 × Tornillo M3 × 12 mm: carro de altura, autorroscante en los pilares
* 4 × Tornillo M3 × 8 mm + 4 × arandela M3: orejas de los motores, autorroscante en el carro
* 2 × Tornillo M3 × 16 mm: tensores, autorroscante en los topes
* 6 × Prisionero M3 × 8 mm (DIN 916, punta plana): colimación del láser
* 1 × Tornillo M3 × 12 mm para roscar previamente los agujeros de los prisioneros (se retira)
* 2 × Tornillo M3 × 10 mm + 2 × tuerca M3: tapa
* 2 × Prisionero M3 × 12 mm punta cónica (DIN 914) + 2 × tuerca M3: tapa trasera del láser (uno es el contacto negativo)
* 1 × Tornillo M3 × 8 mm cabeza alomada (ISO 7380) + 1 × tuerca M3: contacto positivo de la pila falsa

**Electrónica**

* 1 × ESP32 DevKit (30 o 38 pines)
* 2 × Motor paso a paso 28BYJ-48 de 5 V con su placa driver ULN2003
* 1 × Módulo relé de 1 canal **compatible con lógica de 3,3 V**: disparo por nivel alto, o con puente "H/L" en H
* 1 × Resistencia de 10 kΩ 1/4 W, entre IN y GND del relé (láser apagado con el ESP32 apagado)
* 1 × Módulo reductor de tensión ajustable MP1584EN (o mini-360), ajustado a 3,7 V
* 2 × Terminal de ojal M3 para cable de 26 AWG (contactos + y − del láser)
* 1 × Puntero láser verde "303" (se usa sin su batería: la batería y la tapa original se guardan)
* 1 × Power bank USB de 5 V y ≥ 2 A
* 1 × Interruptor de palanca miniatura con rosca M6 (tipo MTS-102)
* 1 × Cable USB-A con salida a bornes (o cable USB cortado)
* 60 cm de cable de silicona de 2 × 26 AWG, rojo y negro (regulador → láser)
* Cables Dupont hembra-hembra
* Bridas de 3 mm
* Una banda elástica o una tira de velcro para el power bank
<!-- BOM:fin -->

### Instrucciones Paso a Paso

Antes de empezar, retirar los restos de impresión de todos los alojamientos y probar el ajuste de los
608 (sección 3.1).

1. **Base: tuerca del trípode.** Dejar caer la tuerca 3/8"-16 por arriba de la base hasta su
   alojamiento hexagonal del fondo. El tornillo del trípode la tira contra el piso.
2. **Base: rodamientos de azimut.** Prensar un 608ZZ desde arriba en el alojamiento superior. Meter
   el segundo 608 por la ventana lateral y prensarlo hacia arriba en el alojamiento inferior: se puede
   tirar de él con el perno M8 × 50, arandelas y una tuerca. Los dos quedan apoyados contra el resalte
   central.
3. **Cuna: perno del lado del cable.** Antes de colocar el láser, meter el perno M8 × 30 desde
   **dentro del tubo**, con la punta primero, por el muñón −X (el que está junto a la canaleta del cable),
   hasta que la cabeza entre en su hexágono. El perno queda apuntando hacia afuera.
4. **Brazos: rodamientos.** Prensar un 608ZZ en cada brazo desde la cara exterior, hasta que quede
   enrasado y apoyado en el labio interior.
5. **Cuna entre los brazos.** La horquilla se arma con los brazos **sueltos**: atornillados a la
   plataforma quedan a 50 mm, y la cuna con sus anillos de contacto mide 60 mm. Calzar el **brazo
   cable** sobre el perno M8 × 30 hasta que el anillo de contacto del muñón −X apoye en el aro interior
   del 608. Del otro lado, calzar el **brazo motor** sobre el anillo del muñón +X. Las caras interiores
   de los brazos miran hacia la cuna.
6. **Lado del cable.** Poner una arandela de contacto impresa y una tuerca autoblocante M8 en el perno
   M8 × 30. Apretar sin frenar el giro.
7. **Polea de altura.** Meter la tuerca M8 común por un extremo del tubo y encajarla en el hexágono del
   muñón +X; sostenerla con un dedo. Pasar el perno M8 × 55 por la polea 80T desde la cara exterior,
   con la cabeza en el hexágono, y llevarlo con el cubo de la polea hacia el brazo motor: atraviesa el
   608 y el muñón y llega a la tuerca. Enroscarlo **girando la polea** mientras se sostiene la cuna,
   hasta que apriete; no hace falta llave. La cabeza hace de chaveta: la polea, el perno y la cuna
   giran juntos. La punta queda 0,5 mm antes del interior del tubo y no toca el láser.
8. **Horquilla a la plataforma.** Colocar una tuerca M3 en cada ranura del pie de los brazos,
   entrándola por la cara exterior del brazo. Bajar la horquilla armada (brazos, cuna y polea) a los
   marcos de la plataforma: el **brazo motor** en +X (lado de la tapa) y el **brazo cable** en −X (lado
   del power bank). Fijar cada brazo con 2 × M3 × 12 desde abajo de la plataforma. Si para que los pies
   entren en los marcos hay que separar los brazos, la cuna queda corta: retirar el brazo cable, poner
   arandelas M8 finas en el perno entre el muñón y el 608, y volver a armar ese lado.
9. **Motores a los carros.** Atornillar cada 28BYJ-48 a un carro con 2 × M3 × 8 y arandela,
   autorroscantes en los agujeros de las orejas. El cuerpo del motor queda hacia +X del carro, del
   lado contrario al agujero del eje.
10. **Motor de azimut.** Colocar las 2 tuercas M3 en los hexágonos de la cara inferior de la
    plataforma, bajo el asiento del carro (+Y). Apoyar el carro con el motor encima y el eje hacia
    abajo, a través de la abertura alargada, con la cara del tensor hacia el tope. Fijarlo con
    2 × M3 × 10 sin apretar. Desde abajo, calzar la polea 20T en el eje, con el cubo hacia arriba metido
    en la abertura, y apretar sus prisioneros sobre la cara plana del eje.
11. **Plataforma sobre la base.** Colocar una arandela de contacto impresa sobre el aro interior del 608
    superior. Con la cuna horizontal, meter el perno M8 × 50 entre los brazos, por debajo de la cuna, y
    pasarlo por el cubo central: la cabeza queda en el hexágono, enrasada. Sosteniéndolo, bajar la
    plataforma sobre la base. Antes de que el perno salga por el 608 inferior, poner el **separador**
    entre los dos rodamientos. Por la ventana lateral, poner la segunda arandela de contacto y la
    tuerca autoblocante M8, y apretar con una llave de 13 mm hasta que **desaparezca el juego** y la
    plataforma gire suave, sin frenarse.
12. **Correa de azimut.** Pasar la correa de 200 mm alrededor de la polea fija de la base y de la polea
    20T. Tensar con el tornillo M3 × 16 del tope (sección 3.2) y apretar los 2 M3 del carro.
13. **Motor de altura.** Atornillar el carro con su motor sobre los 2 pilares del brazo motor con
    2 × M3 × 12 autorroscantes, sin apretar. El motor queda entre el carro y el brazo, con el eje hacia
    afuera. Calzar la polea 20T (cubo hacia el carro), pasar la correa, tensar con el tornillo del tope
    y apretar.
14. **Preparar el láser.** Antes de sacar la batería, fijarse hacia dónde apunta su **+** (en el 303
    suele ir hacia el cabezal). Desenroscar la tapa original y sacar la batería; guardar las dos para
    volver a usar el láser a mano (ver "Volver a la batería original").
    - **Prueba del tubo**: con el multímetro en continuidad, medir entre la rosca trasera y el cuerpo
      del cabezal. Debe dar < 1 Ω; si no, limar un punto de la rosca donde va a morder el prisionero.
    - **Pila falsa**: crimpar o soldar un terminal de ojal M3 al hilo **rojo**. Meter la tuerca M3 por
      la ranura lateral de la pila, poner el ojal sobre la cara delantera (la del "+") y apretar el
      tornillo M3 × 8 de cabeza alomada. Pasar el hilo por el agujero axial y sacarlo por la ranura de
      la cara trasera. Meter la pila en el tubo con la cabeza del tornillo hacia donde iba el + de la
      batería.
    - **Lastre**: meter a presión las 2 tuercas M10 en el hexágono de la tapa trasera (si quedan
      flojas, una gota de cianoacrilato).
    - **Tapa trasera**: pasar el hilo rojo por la ranura del escalón y la ventana. Girar la pila falsa
      hasta que su ranura quede alineada con la ventana, y calzar la tapa sobre la rosca hasta que el
      borde del tubo apoye en el escalón (empuja la pila y comprime el resorte del cabezal).
    - **Prisioneros**: roscar los 2 prisioneros M3 × 12 de punta cónica hasta que muerdan la rosca del
      tubo. En el que está a 45° de la ventana, poner el ojal del hilo **negro** y apretarlo con una
      tuerca M3; en el otro, una tuerca M3 como contratuerca.
    - **Grapa**: calzarla a presión sobre el tubo, delante de la tapa, con su ojal alineado con la
      ventana, y meter los 2 hilos a presión en el ojal. La grapa es el alivio de tensión: un tirón del
      cable no llega a los contactos.
15. **Láser en la cuna.** Trabar el pulsador del láser en encendido. Si el pulsador es momentáneo (se
    apaga al soltarlo), puentearlo con un hilo soldado, a través de la ventana del pulsador de la cuna.
    Pasar el láser por la cuna con el cabezal hacia +Y (adelante), entrándolo **por el extremo
    trasero de la cuna, cabezal primero**: la tapa trasera no pasa por la cuna y queda atrás. Si el
    cabezal no pasa por la cuna, sacar la grapa y la tapa (aflojando los prisioneros, sin sacar la
    pila falsa), entrar el láser cola primero por el extremo delantero y volver a ponerlas. Enhebrar los 2 hilos por los
    3 puentes de la **canaleta** de la cuna (lado −X, abajo), desde el borde trasero hasta el muñón −X.
    Pasarlos por el agujero del brazo cable dejando un **bucle de 40 mm** y bajarlos por el canal de la
    cara exterior del brazo.
16. **Electrónica.** Encajar las placas en sus soportes (lado +X): los 2 ULN2003, el **regulador** (en el
    tercer soporte de la misma columna) y el relé apoyados, y el ESP32 elevado, con los pines hacia
    abajo. Soldar la **resistencia de 10 kΩ** entre los pines IN y GND del relé (o meterla en el cable
    Dupont). Atornillar el interruptor en su soporte, con la palanca hacia +X. Colocar el power bank de
    pie en su bolsillo (−X), con el conector USB hacia el extremo bajo de la pared (−Y), y sujetarlo
    con la banda elástica alrededor del bolsillo.
17. **Cableado.** Conectar según la sección 5.4. **Antes de conectar los hilos del láser, ajustar el
    regulador a 3,7 V** (sección 5.4): 5 V directos queman el láser.
    - El cable de alimentación y los hilos del láser cruzan por el **conducto elevado** (Y = −30 mm).
    - Los hilos del láser van al regulador: el rojo a OUT+ y el negro a OUT−.
    - El cable del motor de altura baja por el canal de la cara exterior del brazo motor.
    - El cable del motor de azimut se fija con una brida al puente de la plataforma y entra a la tapa
      por la pared −X.
    - El sobrante se enrolla en el hueco del extremo +Y, bajo la tapa.
    - Ningún cable debe tocar correas ni poleas.
18. **Tapa.** Bajar la tapa sobre el reborde de la plataforma (la palanca del interruptor entra por la
    ranura) y fijarla con 2 × M3 × 10 y tuerca en sus orejas.
19. **Puesta a punto.** Equilibrar y colimar el láser (secciones 3.3 y 3.5) y hacer las pruebas del
    láser de la sección 5.5.

### Montaje en el trípode

Enroscar la base a mano sobre el tornillo 3/8"-16 de la cabeza del trípode hasta que apoye firme;
no hacen falta herramientas y se hace en menos de 1 minuto. Nivelar el trípode a ojo (±2°): la
alineación con 2 estrellas corrige el resto (sección 5.3).

### Volver a la batería original

Para usar el láser a mano, sin el aparato:

1. Apagar el interruptor general y soltar los hilos del láser del regulador.
2. Sacar el láser de la cuna con la grapa y la tapa trasera puestas.
3. Aflojar los 2 prisioneros de la tapa trasera, retirar la tapa (con el lastre) y sacar la pila
   falsa tirando del hilo rojo.
4. Poner la batería con su + hacia donde estaba y enroscar la tapa original con la llave.

Para volver al aparato, repetir el paso 14 desde "Pila falsa". Todo el cambio lleva menos de 10
minutos.

## 3. Puesta a punto mecánica para la precisión

### 3.1 Calibración del ajuste del 608

La probeta tiene 5 anillos de 22 mm + ajuste. El anillo con **1 punto** es −0,1 mm y el de **5 puntos**
es +0,3 mm, en pasos de 0,1 mm.

1. Probar un 608ZZ en cada anillo.
2. Elegir el que entra con **presión firme a mano** (o con una prensa suave) y no tiene juego.
3. Poner ese valor en `ajuste_608` dentro de `src/puntero_laser_parametros.scad` y regenerar los 10
   STL (sección 4.3).

| Anillo (puntos) | 1 | 2 | 3 | 4 | 5 |
|-----------------|---|---|---|---|---|
| `ajuste_608` | −0,1 | 0 | +0,1 (por defecto) | +0,2 | +0,3 |

Un 608 flojo en la base inclina la plataforma con un error que **cambia con el azimut** y que la
alineación no corrige. Es el ajuste más importante del aparato.

### 3.2 Tensado de las correas

Aflojar los 2 M3 del carro, girar el tornillo del tope hasta que la correa ceda **≈ 2 mm** al
presionarla con un dedo en el centro del tramo, y volver a apretar los M3. Una correa floja agrega
juego; una muy tensa frena el motor. El carro tiene ±3 mm de recorrido.

### 3.3 Equilibrado del láser

Se hace con el láser **ya convertido**: pila falsa, tapa trasera con su lastre y grapa puestas. Con
los motores **sin energía**, deslizar el láser dentro de la cuna (con los prisioneros flojos) hasta que
quede **quieto a 0°, 45° y 90°**. El diseño deja ±3,5 mm de recorrido entre la tapa trasera y la
cuna. Si el punto de equilibrio real queda fuera de ese recorrido, medirlo desde el extremo trasero de
la tapa impresa, cargarlo en `distancia_trasera_centro_masa_nueva` y regenerar los STL. Entonces fijarlo con los 6 prisioneros. Con el láser
equilibrado, el motor trabaja descansado y su caja sostiene la posición sin energía: la deriva debe
ser ≤ 0,2° en 5 minutos.

**Par del eje de altura (FR-024)**:

| Situación | Par necesario | Par disponible (34 mN·m × 4 × 0,9) | Factor de seguridad |
|-----------|---------------|------------------------------------|---------------------|
| Láser equilibrado (desbalance ≤ 10 mm) | 22,3 mN·m | 122,4 mN·m | 5,5 |
| Láser sin equilibrar (desbalance de 20 mm) | 44,5 mN·m | 122,4 mN·m | 2,7, sin margen con frío |

### 3.4 Contrapeso (opcional)

El centro de masa de la parte giratoria queda a ≈ 4 mm del eje. Si un power bank más pesado lo
desplaza, se pueden apilar hasta 4 tuercas M8 en el alojamiento del contrapeso (esquina −X, +Y).

### 3.5 Colimación del haz

1. Roscar los 6 agujeros de los anillos pasando primero un tornillo M3 × 12, y después colocar los
   prisioneros M3 × 8.
2. Apuntar el aparato a una pared a **10 m**.
3. Girar el láser sobre su propio eje dentro de la cuna, con los prisioneros flojos: el punto describe
   un círculo.
4. Ajustar los prisioneros de los dos anillos hasta que el círculo mida **≤ 44 mm** de diámetro
   (≤ 0,25°).

El rango de corrección es de ±1,2° (±2 mm en 94 mm).

### 3.6 Presupuesto de error

| Fuente | Valor estimado | Cómo se controla |
|--------|----------------|------------------|
| Resolución (cada eje) | 0,022° | Correa 1:4: 45,29 pasos/° |
| Repetibilidad de la caja del motor (cada eje) | 0,1° | Llegada siempre desde el mismo sentido (sección 5.2) |
| Correa y dientes impresos (cada eje) | 0,1° | Tensado (3.2) |
| Inclinación de la plataforma | ≤ 0,1° | 608 a presión (3.1), separados 30 mm y precargados |
| Perpendicularidad entre ejes | ≤ 0,25° | Brazos en marcos; la alineación lo absorbe en parte |
| Colimación residual | ≤ 0,2° | Sección 3.5 |
| Centrado de las estrellas de alineación | 0,3° | Sección 5.3 |
| Flexión de los brazos y hora | 0,06° | Brazos de 12 mm; hora por NTP |
| **Total** | **0,50° (suma cuadrática); 1,35° (peor caso)** | Límite de 2° (objetivo 1°) |

**Cuándo repetir el cálculo estructural**: si el láser pesa más de 400 g (`masa_laser_g > 400`) o el
brazo supera los 131 mm (`alto_brazo > 131`): por encima de ese largo, la flexión lateral del brazo
pasa de 0,1°. La generación lo avisa con una línea `AVISO`. Ver la justificación en
`specs/002-puntero-laser-estelar/plan.md` y `specs/006-laser-alimentacion-externa/research.md` (R5).

## 4. Adaptación a tus componentes

### 4.1 Qué medir

| Componente | Qué medir | Parámetro |
|------------|-----------|-----------|
| Láser | Diámetro del **cuerpo** (no del cabezal) | `diametro_laser` |
| Láser | Largo total con la tapa original | `largo_laser` |
| Láser | **Punto de equilibrio**: apoyarlo con su batería y su tapa original sobre un borde hasta que no caiga, y medir desde el extremo trasero | `distancia_trasera_centro_masa` |
| Láser | Masa con su batería y su tapa original | `masa_laser_g` |
| Láser | Diámetro interior del tubo, sin la batería | `diametro_hueco_bateria` |
| Láser | Con la varilla del calibre: del borde trasero del tubo al contacto del cabezal, sin comprimir el resorte | `profundidad_hueco_bateria` |
| Láser | Diámetro exterior y largo de la rosca donde enrosca la tapa original | `diametro_zona_tapa`, `largo_zona_tapa` |
| Láser | Cuánto sobresale la tapa original del borde del tubo | `largo_tapa_original` |
| Láser | Masa de la batería y de la tapa original (balanza de cocina) | `masa_bateria_g`, `masa_tapa_original_g` |
| Láser convertido | Punto de equilibrio con la pila falsa y la tapa impresa, desde el extremo trasero de la tapa (solo si difiere del calculado) | `distancia_trasera_centro_masa_nueva` |
| Regulador | Largo y ancho del módulo | `regulador_largo`, `regulador_ancho` |
| Power bank | Largo, ancho (queda vertical) y espesor | `powerbank_largo`, `_ancho`, `_alto` |
| ESP32, relé, ULN2003 | Largo y ancho de cada placa | `esp32_*`, `rele_*`, `uln2003_*` |

### 4.2 Cómo cambiar los parámetros

- **Con interfaz gráfica**: abrir `src/puntero_laser_parametros.scad` en OpenSCAD, cambiar los valores
  y guardar. Todas las piezas toman los valores de ese archivo.
- **Por línea de comandos**: pasar **los mismos** `-D` a todas las piezas:

  ```bash
  .tools/bin/openscad --hardwarnings -D diametro_laser=26 -D largo_laser=240 -o exports/puntero_laser_cuna_laser.stl src/puntero_laser_cuna_laser.scad
  ```

- Para revisar el conjunto, renderizar `src/puntero_laser_ensamblaje.scad`. Si algo choca, la
  generación se detiene con un mensaje.

### 4.3 Regenerar todo

Después de **cualquier** cambio, regenerar los **13 STL**, no solo el de la pieza tocada. Los comandos
están en `specs/002-puntero-laser-estelar/quickstart.md`, escenario 2, y en
`specs/006-laser-alimentacion-externa/quickstart.md`, escenario 2 (las 3 piezas del láser sin batería).

### 4.4 Mensajes de error de la validación

| Regla | Mensaje (empieza por) | Qué significa | Cómo corregirlo |
|-------|-----------------------|---------------|-----------------|
| V-01 | `<parámetro>=<valor>: fuera de rango` | Valor fuera de su rango admitido | Usar un valor dentro del rango indicado |
| V-02 | `distancia_trasera_centro_masa=` | El punto de equilibrio no está entre el 40 % y el 60 % del largo | Repetir la medición del punto de equilibrio |
| V-03 | `powerbank_alto=` | La plataforma supera 196 mm | Componentes más chicos o `largo_correa` más corto |
| V-04 | `largo_laser=` | El brazo supera 196 mm | Láser más corto, o equilibrarlo más cerca del medio |
| V-05, V-06 | `largo_correa=` | Correa corta: el tope tensor o las poleas no entran | Correa más larga (de 200 a 240 mm) |
| V-07 | `holgura_barrido=` | El láser toca algo en algún ángulo entre −10° y 95° | Subir `holgura_barrido` |
| V-08 | `<componente>_ancho` o `altura_placas=` | Componentes solapados o la tapa choca | Reducir medidas o cambiar el componente |
| V-10 | `espesor_plataforma=` | El eje del motor entra < 5 mm en la polea 20T | Reducir `espesor_plataforma` |
| V-11 | `<parámetro>=…: <pared> = … mm` | Una pared queda < 1,2 mm, o el brazo no aloja el 608 | Ajustar el parámetro nombrado |
| V-12 | `holgura_colimacion=` | La corrección del haz es < 1° | Aumentar `holgura_colimacion` o `largo_tubo_cuna` |
| V-13 | `powerbank_largo=` | Centro de masa a más de 20 mm del eje | Usar el contrapeso (3.4) o cambiar el power bank |
| V-14 | `separacion_608_azimut=` | Rodamientos de azimut muy juntos | Usar `separacion_608_azimut` ≥ 6 |
| Base | `diametro_apoyo_tripode=` | La base toca la polea 20T o su cono baja hasta la cámara | Reducir `diametro_apoyo_tripode` |
| V-15 | `<parámetro>=<valor>: fuera de rango` | Un parámetro del láser sin batería está fuera de su rango | Usar un valor dentro del rango indicado |
| V-16 | `diametro_hueco_bateria=` | El hueco de la batería no entra en el tubo, o la pila falsa queda muy fina para el hilo | Repetir las mediciones del tubo |
| V-17 | `tuercas_lastre_tapa=` | Las tuercas M10 no dejan escalón para el borde del tubo | Menos tuercas de lastre |
| V-18 | `espesor_resalte_prisionero=` | El prisionero M3 × 12 no alcanza para el ojal y la contratuerca | — (constante del diseño) |
| V-19 | `distancia_trasera_centro_masa_nueva=` | La tapa trasera queda muy cerca de la cuna: no entran la grapa y el equilibrado | Más lastre, o revisar el punto de equilibrio medido |
| V-20 | `largo_cable_laser=` | El cable del láser hace caer más de 0,1 V | Cable más corto o más grueso |
| V-21 | `regulador_ancho=` | El regulador no entra en la columna de los ULN2003 | Usar un módulo más chico (mini-360) |
| Aviso | `AVISO: alto_brazo=` | El brazo supera 131 mm | Repetir el cálculo de flexión (sección 3.6) |

## 5. Electrónica y requisitos del firmware

El firmware del ESP32 no forma parte de este diseño. Para que la mecánica dé la precisión prometida,
**debe** cumplir lo siguiente (copia de `specs/002-puntero-laser-estelar/contracts/interfaz_firmware.md`,
con los cambios de `specs/006-laser-alimentacion-externa/contracts/interfaz_firmware.md`).

### 5.1 Conversión de pasos a grados

| Magnitud | Azimut | Altura |
|----------|--------|--------|
| Relación interna real del 28BYJ-48 | 63,68395:1 | 63,68395:1 |
| Medios pasos por vuelta del motor | **4075,7728** | **4075,7728** |
| Relación de la correa | 80/20 = 4 | 80/20 = 4 |
| Medios pasos por vuelta del eje | **16 303,09** | **16 303,09** |
| Medios pasos por grado | **45,2864** | **45,2864** |
| Resolución | 0,0221° | 0,0221° |
| Rango | Ilimitado | **−10° … 95°** (fuera de ese rango, choque) |
| Velocidad máxima fiable | ≈ 900 medios pasos/s ≈ 20°/s | Ídem |

**No usar 4096 pasos por vuelta**: ese valor agrega 1,79° de error por cada vuelta del eje y por sí solo
consume el presupuesto. Acumular la posición en pasos enteros y convertir a grados solo para mostrarla.

**Sentidos**: definir `invertir_azimut` e `invertir_altura` y calibrarlos. Un paso positivo debe girar
el azimut en sentido horario visto desde arriba (hacia el este) y subir el láser.

### 5.2 Llegada unidireccional (compensación del juego)

Toda llegada a un objetivo termina moviéndose **en sentido positivo**. Si el movimiento necesario es
negativo, el firmware se pasa **2,0°** (≈ 91 medios pasos) y vuelve. Sin esta regla, el juego de la caja
del motor (0,25–0,75° después de la correa) lleva el peor caso a ≈ 2°.

Además:

- Usar rampas de aceleración (≥ 200 medios pasos/s²).
- Desenergizar las bobinas en reposo. Si aparece deriva, mantener energizado solo el eje de altura.

### 5.3 Alineación con 2 estrellas

Al encender, la posición es desconocida (no hay finales de carrera).

1. Centrar manualmente el haz en una estrella conocida y confirmar.
2. Repetir con una segunda estrella.
3. El firmware calcula la transformación entre las coordenadas del cielo y las de los motores (por
   ejemplo, con el método de Taki).

Así se corrigen la nivelación del trípode y la orientación al norte, sin brújula. Conviene usar
estrellas separadas entre 60° y 120° en azimut y con alturas de 20° a 70°.

La hora se toma por NTP (WiFi) o RTC/GPS: un minuto de error equivale a 0,25°.

### 5.4 Conexiones

```text
Power bank USB 5V ──(conducto)──> interruptor general (bajo la tapa) ──┬──> ESP32 5V/VIN (GND común)
                                                                     ├──> ULN2003 azimut +5V
                                                                     ├──> ULN2003 altura +5V
                                                                     ├──> Relé VCC
                                                                     └──> Relé COM
ESP32 GPIO16, 17, 18, 19 ──> ULN2003 azimut IN1…IN4 ──> 28BYJ-48 azimut
ESP32 GPIO25, 26, 27, 33 ──> ULN2003 altura IN1…IN4 ──> 28BYJ-48 altura
ESP32 GPIO23             ──> Relé IN (activo en nivel alto) ──[10 kΩ]──> GND
Relé NA                  ──> Regulador MP1584 IN+  (IN− a GND)
Regulador OUT+ (3,7 V)   ──> hilo rojo 26 AWG  ──> pila falsa (+, tornillo de la punta)
Regulador OUT−           ──> hilo negro 26 AWG ──> prisionero de la tapa trasera (−, cuerpo del láser)
```

- No usar los pines de arranque (0, 2, 12 y 15) ni los de solo entrada (34–39).
- Los motores **no** se alimentan desde el pin 3V3 ni a través del USB del ESP32.
- **Relé**: los módulos de 5 V con disparo por nivel bajo y optoacoplador no se apagan del todo con
  los 3,3 V del ESP32. Usar uno marcado "3.3V", uno con disparo por nivel alto, o uno con puente H/L en
  H. Se comprueba así: con IN a 3,3 V el relé debe cerrar, y con IN a GND debe quedar en reposo.
- **Láser apagado con el ESP32 apagado**: el láser va en el contacto **NA** del relé, y la resistencia
  de 10 kΩ deja la entrada IN en 0 V cuando el ESP32 no la maneja (sin energía, arrancando,
  reiniciándose, sin programa, en sueño profundo o con el cable suelto). Lo único que el circuito no
  puede cubrir es un firmware colgado con el GPIO23 en alto: para eso, el *watchdog* de la sección 6.

> **Ajustar el regulador ANTES de conectar el láser.** Un MP1584 nuevo puede venir ajustado a
> cualquier tensión, y 5 V directos queman el láser.
>
> 1. Con los hilos del láser **sueltos**, cerrar el interruptor general y puentear la entrada IN del
>    relé a 3,3 V del ESP32 (el relé hace clic).
> 2. Medir la salida del regulador con el multímetro y girar su preset hasta que marque **3,7 V**
>    (entre 3,6 y 3,8 V).
> 3. Quitar el puente, abrir el interruptor y recién entonces conectar el rojo a OUT+ y el negro a OUT−.

- **Consumo máximo** ≈ 1,16 A: 0,75 A de los 2 motores, el ESP32 con WiFi y el relé, más ≈ 0,41 A
  del láser a través del regulador. El power bank debe dar ≥ 2 A. Si se apaga solo por bajo consumo
  (con el láser apagado el consumo baja), usar su modo "baja corriente", o una resistencia de carga
  de 100 Ω y 0,5 W que un GPIO libre conecte en ráfagas.

**Recorrido de los cables**:

| Cable | Recorrido |
|-------|-----------|
| Alimentación y láser | Conducto elevado que cruza la franja del láser (Y = −30 mm) |
| Láser | Ventana de la tapa trasera → grapa → canaleta de la cuna (lado −X, abajo) → bucle de 40 mm → agujero y canal del brazo cable |
| Motor de altura | Canal de la cara exterior del brazo motor |
| Motor de azimut | Brida en el puente de la plataforma → pared −X de la tapa |

Ningún cable cruza el eje de azimut, así que el aparato gira sin límite.

### 5.5 Pruebas de aceptación

| Prueba | Criterio |
|--------|----------|
| Puntero a una pared a 3 m (1° ≈ 52 mm): 10 idas y vueltas de 90° con llegada unidireccional | Dispersión ≤ 16 mm (0,3°) y error ≤ 26 mm (0,5°) |
| Ordenar 360° de azimut | Vuelve a la marca con ≤ 16 mm a 3 m. Si no, la constante de pasos está mal |
| Láser encendido 31 s; ordenar una altura de 5° | Se apaga a los 30 s; no enciende por debajo de 10° |
| Multímetro en los hilos del láser con el ESP32 borrado, y después con el cable del GPIO23 suelto | 0 V en los dos casos |
| 10 arranques seguidos del ESP32 mirando el láser | Ningún destello |
| Láser encendido y los 2 motores moviéndose | 3,5–3,8 V en los hilos del láser; el haz no parpadea |
| Firmware de prueba con un bucle infinito y el láser encendido | El *watchdog* reinicia el ESP32 en ≤ 5 s y el láser se apaga |

## 6. Seguridad del láser

Los punteros "303" suelen superar los 5 mW (clase 3B en la práctica): pueden dañar la vista y
encandilar a pilotos.

- **Nunca** apuntar a aeronaves, personas, animales ni vehículos. No usarlo cerca de aeropuertos.
- Respetar la normativa local sobre punteros láser (potencia permitida y lugares de uso).
- El firmware debe:
  - Apagar el láser tras **30 s** de encendido continuo e imponer un enfriamiento de igual duración.
  - No encenderlo por debajo de **10°** de altura.
  - Dejarlo **apagado al arrancar** o reiniciar, y apagarlo si se pierde la conexión con el mando
    durante más de 2 s. La primera línea de `setup()` pone el GPIO23 como salida en bajo, sin pull-up
    interno.
  - Activar el *watchdog* de tareas del ESP32 (`esp_task_wdt`) con ≤ 5 s: si el programa se cuelga
    con el láser encendido, el ESP32 se reinicia y el circuito apaga el láser.
  - Esperar ≈ 50 ms después de cerrar el relé antes de dar el haz por encendido (arranque del
    regulador y del láser).
- Con frío (< 0 °C) el láser verde puede no encender o perder potencia. Es normal.
- El **interruptor general** es el corte manual de emergencia: abrirlo deja sin energía al relé y al
  regulador, y el láser se apaga. La llave del láser ya no se usa, porque viene en la tapa original.
- Si el láser no se apaga con el ESP32 apagado, los contactos del relé están pegados: abrir el
  interruptor general y cambiar el relé.
- No mirar nunca el haz ni sus reflejos en superficies brillantes.

## 7. Consejos y buenas prácticas

Resumen de las recomendaciones de esta guía, en el orden en que aparecen al construir:

- **Medir antes de imprimir.** El diseño se adapta a tu láser y a tu power bank cambiando parámetros;
  imprimir con medidas que no son las tuyas desperdicia filamento (sección 4).
- **Calibrar el 608 primero.** Es el ajuste más importante del aparato: un 608 flojo en la base
  inclina la plataforma con un error que la alineación no corrige (sección 3.1).
- **Regenerar todos los STL** después de cualquier cambio de parámetros, no solo el de la pieza tocada
  (sección 4.3).
- **PETG, no PLA**, para las piezas definitivas: el PLA se ablanda a ~55 °C, por ejemplo dentro de un
  auto al sol (sección 1).
- **Sin alisado (ironing)** en las caras de apoyo de los rodamientos, y capa de 0,16 mm en las poleas
  para que los dientes GT2 salgan definidos (sección 1).
- **Limpiar los alojamientos** de restos de impresión antes de armar (sección 2).
- **Tensar las correas con medida**: deben ceder ≈ 2 mm con un dedo. Floja agrega juego; muy tensa
  frena el motor (sección 3.2).
- **Equilibrar el láser con los motores sin energía** antes de fijarlo con los prisioneros (sección 3.3).
- **Medir el láser antes de imprimir la pila falsa y la tapa trasera**: sus medidas por defecto son
  supuestas (sección 4.1).
- **Probar la continuidad del tubo** antes de cerrar la tapa trasera, y poner la pila falsa con su
  tornillo donde iba el + de la batería (paso 14).
- **Ningún cable debe tocar correas ni poleas**, y el del láser necesita su bucle de 40 mm para
  acompañar el giro (pasos 15 y 17).
- **Ajustar el regulador a 3,7 V antes de conectar el láser**: 5 V directos lo queman (sección 5.4).
- **Equilibrar con el láser ya convertido**, con la pila falsa, la tapa y el lastre puestos
  (sección 3.3).
- **Relé compatible con 3,3 V**: con un módulo de 5 V por nivel bajo, el láser puede no apagarse
  (sección 5.4).
- **Usar la constante de pasos correcta** (45,2864 medios pasos por grado), no 4096 pasos por vuelta
  (sección 5.1).
- **El interruptor general es el corte de emergencia**: abrirlo apaga el láser (sección 6).
- **Watchdog en el firmware**: es lo único que apaga el láser si el programa se cuelga con el relé
  cerrado (sección 6).
