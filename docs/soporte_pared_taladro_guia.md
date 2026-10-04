# Guía de Producción: Soporte de pared para taladro

Soporte de pared impreso en 3D para colgar un taladro atornillador inalámbrico con el portabrocas
hacia abajo. El portabrocas pasa por la ranura en U de la bandeja, el cuerpo del taladro apoya sobre
ella y la empuñadura queda hacia el frente. Un pequeño labio en el borde frontal impide que el
taladro se deslice hacia fuera.

| Archivo | Uso |
|---------|-----|
| `exports/soporte_pared_taladro.stl` | Pieza lista para el laminador (valores por defecto) |
| `src/soporte_pared_taladro.scad` | Modelo paramétrico para adaptar la pieza (sección 3) |
| `simulation/soporte_pared_taladro_fem.md` | Validación estructural (sección 4) |

### Valores de la pieza entregada

| Parámetro | Valor | Parámetro | Valor |
|-----------|-------|-----------|-------|
| `ancho` | 80 mm | `espesor_cartela` | 5 mm |
| `profundidad` | 100 mm | `holgura_tornillo` | 0,4 mm |
| `diametro_tornillo` | 5 mm | `altura_labio` | 3 mm |
| `ancho_ranura` | 46 mm | `chaflan_ranura` | 1,5 mm |
| `diametro_cuerpo_taladro` | 60 mm | `radio_esquinas` | 4 mm |
| `espesor` | 6 mm | `radio_filete` | 3 mm |
| `altura_placa` | 70 mm | `$fn` | 64 |

Datos del STL: 80 × 100 × 70 mm (ancho × fondo × alto), 1756 facetas y 79,5 cm³ de volumen sólido.
Si fuera maciza de PETG pesaría 101 g; con los ajustes de la sección 1 la pieza impresa pesa
bastante menos (el laminador da el valor exacto).

## 1. Especificaciones de Impresión 3D

* **Orientación Óptima:** la **cara inferior de la bandeja apoyada en la cama**, es decir, la pieza
  en su posición de uso, que es la orientación en la que se exporta el STL. No hay que girarla en el
  laminador. Así:
  * La bandeja, que es la zona que trabaja a flexión, tiene las capas paralelas a la dirección de
    la tensión, que es la dirección más resistente en FDM.
  * Ninguna superficie supera los 45° de voladizo. Las cartelas son rampas, la ranura es vertical,
    los chaflanes se abren hacia arriba y los orificios horizontales de los tornillos (Ø 5,4 mm) se
    imprimen como pequeños puentes.
  * La pieza necesita una cama de al menos 80 × 100 mm (cabe en cualquier cama de 180 × 180 mm).
* **Configuración del Laminador (Slicer):**
  * **Altura de capa:** 0,2 mm (boquilla de 0,4 mm).
  * **Relleno (Infill):** 40 % giroide.
  * **Perímetros (Paredes):** 4 perímetros, con 5 capas superiores y 5 inferiores.
  * **Soportes:** **No**. Ninguna zona de la pieza los necesita.
  * **Adherencia:** sin brim ni raft. Si la cama tiende a despegar las esquinas, se puede añadir un
    brim de 3 mm.
* **Material Recomendado:** **PETG**, con boquilla a 230–245 °C, cama a 70–85 °C y ventilador al
  30–50 %. Resiste mejor que el PLA la deformación lenta bajo carga permanente (fluencia) y el calor
  de un taller. En cama de PEI conviene usar laca o pegamento en barra como desmoldeante.
  * **Alternativa:** PLA, solo en interiores a temperatura ambiente y lejos del sol directo.
  * **No recomendados:** TPU (flexible) y ABS (no aporta ventajas y exige cámara cerrada).

## 2. Ensamblaje y Lista de Materiales (BOM)

### Herrajes / Tornillería Requerida

* 2 × Tornillo de cabeza avellanada (plana, 90°) para taco, Ø5 × 50 mm.
* 2 × Taco de nailon Ø8 × 40 mm, para ladrillo macizo o hueco y hormigón.
  * **Pared de pladur:** en lugar de los tacos de nailon, usar 2 tacos basculantes metálicos para
    tornillo de 5 mm, o atornillar directamente a un montante metálico o de madera.

Herramientas: taladro con broca de Ø8 mm adecuada al tipo de pared, nivel, lápiz, metro y
destornillador PZ2 o PH2.

### Instrucciones Paso a Paso

1. **Paso 1 – Elegir la ubicación:** busca un tramo de pared libre de cables y tuberías. Debajo del
   soporte deben quedar **al menos 25 cm libres**, para que el portabrocas y la broca colgados no
   toquen nada.
2. **Paso 2 – Marcar:** apoya la placa trasera contra la pared con la bandeja abajo, nivélala y
   marca el centro de los dos orificios. Con los valores por defecto están a 60 mm de distancia
   entre sí y a 60 mm por encima de la base de la bandeja.
3. **Paso 3 – Taladrar:** perfora en cada marca con broca de Ø8 mm a 45 mm de profundidad y limpia
   el polvo del agujero.
4. **Paso 4 – Colocar los tacos:** introduce los tacos hasta que queden enrasados con la pared.
5. **Paso 5 – Atornillar:** presenta el soporte y atornilla los dos tornillos hasta que la cabeza
   quede enrasada en el avellanado. No sigas apretando una vez enrasada, o aplastarás el plástico.
6. **Paso 6 – Comprobar:** empuja la bandeja hacia abajo con la mano. El soporte no debe moverse ni
   separarse de la pared.
7. **Paso 7 – Colgar el taladro:** con el portabrocas hacia abajo y la empuñadura hacia el frente,
   baja el taladro de forma que el portabrocas entre en la ranura por arriba o por el frente,
   pasando por encima del labio. El cuerpo queda apoyado en la bandeja, detrás del labio.
8. **Paso 8 – Retirar el taladro:** con una mano, levanta el taladro unos milímetros para que el
   cuerpo supere el labio y sácalo hacia delante.

## 3. Adaptación a otro taladro o tornillería

### Cómo medir el taladro

Usa un calibre o una regla:

| Medida | Dónde se mide | Parámetro y regla |
|--------|---------------|-------------------|
| Ø exterior del portabrocas | Parte más ancha del portabrocas (normalmente 35–44 mm) | `ancho_ranura` ≥ Ø portabrocas + 2 mm |
| Ø del cuerpo | Zona que apoyará sobre la bandeja: caja de engranajes o anillo del embrague, justo por encima del portabrocas | `diametro_cuerpo_taladro` = esa medida. Debe ser ≥ `ancho_ranura` + 8 mm para que el cuerpo no pase por la ranura |
| Peso con batería | Báscula de cocina | ≤ 2,5 kg (carga validada) |

Además, la profundidad debe cumplir `profundidad` ≥ `espesor` + `diametro_cuerpo_taladro` + 16 mm
para dejar holgura con la pared y con el labio. Si el cuerpo es más ancho que
`ancho` − 2 × `espesor_cartela` − 2 mm, también hay que aumentar `ancho`.

### Cómo cambiar los parámetros

Solo se editan valores, nunca la geometría.

* **Con interfaz gráfica:** abre el modelo con `.tools/bin/openscad src/soporte_pared_taladro.scad`
  (fuera del sandbox, en un escritorio con pantalla).
  1. Muestra el panel *Customizer* (menú *Window*).
  2. Ajusta los valores; cada parámetro tiene su rango admitido.
  3. Pulsa F6 para generar la geometría y *File → Export → STL*.
* **Por línea de comandos**, desde la raíz del repositorio:

  ```bash
  .tools/bin/openscad --hardwarnings -D ancho=100 -D profundidad=130 -o exports/soporte_pared_taladro_100x130.stl src/soporte_pared_taladro.scad
  ```

  Usa un nombre propio para cada variante. `exports/soporte_pared_taladro.stl` es la pieza oficial
  y corresponde siempre a los valores por defecto de esta guía.

Si un valor o una combinación no es válida, la generación se detiene **sin crear el STL** y muestra
`ERROR: Assertion … failed: "<parámetro>=<valor>: <explicación>"`:

| Regla | Qué significa | Cómo corregirlo |
|-------|---------------|-----------------|
| V-01 | Un parámetro no es un número o está fuera de su rango | Usa un valor dentro del rango que indica el mensaje |
| V-02 | La ranura deja carriles más finos que 2 × `espesor` | Reduce `ancho_ranura` o aumenta `ancho` |
| V-03 | No cabe la cabeza del tornillo con margen al borde (`ancho` ≥ 4 × Ø cabeza) | Reduce `diametro_tornillo` o aumenta `ancho` |
| V-04 | El avellanado deja menos de 1,5 mm de placa | Aumenta `espesor` o reduce `diametro_tornillo` |
| V-05 | La placa es demasiado baja para los tornillos y las cartelas | Aumenta `altura_placa` o reduce `diametro_tornillo` |
| V-06 | No hay holgura entre el cuerpo del taladro y la pared o el labio | Aumenta `profundidad` |
| V-07 | El cuerpo del taladro cabría por la ranura | Revisa la medida del cuerpo o reduce `ancho_ranura` |
| V-08 | El cuerpo del taladro chocaría con las cartelas | Aumenta `ancho` o reduce `espesor_cartela` |
| V-09, V-10 | Reglas de protección: no pueden fallar si se cumplen las anteriores | — |

**Importante:** después de cambiar cualquier parámetro hay que **regenerar el STL** y, si sales del
rango validado (sección 4), **repetir la simulación**.

## 4. Validación estructural

La configuración por defecto se ha simulado por elementos finitos en FreeCAD 1.1.4, con malla Gmsh
de segundo orden y el solver CalculiX. Se aplicaron 25 N (taladro de 2,5 kg) con material PETG.
El detalle está en [simulation/soporte_pared_taladro_fem.md](../simulation/soporte_pared_taladro_fem.md).

| Caso | σ von Mises máx. | Flecha del borde frontal | Criterio | Cumple |
|------|------------------|--------------------------|----------|--------|
| Base (carga sobre la bandeja) | 0,49 MPa | 0,04 mm | σ ≤ 10 MPa, flecha ≤ 1 mm | SÍ |
| Conservador (apoyo solo en el borde inferior) | 1,25 MPa | 0,06 mm | ídem | SÍ |
| Pésimo (carga solo en el labio) | 2,18 MPa | 0,21 mm | ídem | SÍ |

El margen real frente a la resistencia del PETG impreso (30 MPa) es de 14 o más, muy por encima
del factor 3 exigido.

**Rango validado sin repetir la simulación:** `profundidad` ≤ 100 mm, `espesor` ≥ 6 mm,
`ancho` ≥ 80 mm, `espesor_cartela` ≥ 5 mm y material PETG o PLA. Fuera de ese rango hay que
repetirla:

```bash
.tools/bin/openscad -D profundidad=130 -o simulation/soporte_pared_taladro.csg src/soporte_pared_taladro.scad
```

```bash
.tools/bin/freecadcmd simulation/soporte_pared_taladro_fem.py
```

El script imprime una línea `RESULTADO … cumple=SI|NO`. Si el resultado es `NO`, aumenta
`espesor` o `espesor_cartela`, o reduce `profundidad`, y vuelve a simular antes de imprimir.
