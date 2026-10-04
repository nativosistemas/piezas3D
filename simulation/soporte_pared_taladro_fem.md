# Simulación FEA: Soporte de pared para taladro

Validación estructural del soporte con la configuración por defecto (Principio III de la
constitución, FR-014, FR-015 y SC-003). Fuente paramétrica: `src/soporte_pared_taladro.scad`.

## 1. Objetivo y criterios de aceptación

| Concepto | Valor |
|----------|-------|
| Carga de diseño | 25 N hacia −Z (taladro de 2,5 kg con batería) |
| Material | PETG impreso: E = 2000 MPa, ν = 0,38, ρ = 1270 kg/m³ |
| Resistencia efectiva en FDM | σ_lim = 30 MPa (conservador frente a ~50 MPa nominal) |
| Factor de seguridad exigido | 3 |
| **Criterio de tensión** | σ von Mises máx. ≤ σ_lim / 3 = **10 MPa** con 25 N |
| **Criterio de flecha** | desplazamiento vertical del borde frontal ≤ **1 mm** con 25 N |

Al calcular la tensión máxima no se tienen en cuenta los nodos situados a menos de 2 mm de las
fijaciones rígidas. Ahí aparecen picos singulares propios del modelo, que no existen en la pieza
real. El script informa también del máximo bruto.

## 2. Exportación del modelo a FreeCAD

OpenSCAD no exporta STEP, así que el modelo se pasa a FreeCAD como árbol CSG, que se reconstruye
como sólido B-rep exacto:

```bash
.tools/bin/openscad -o simulation/soporte_pared_taladro.csg src/soporte_pared_taladro.scad
```

El `.scad` solo usa primitivas que el importador CSG de FreeCAD 1.1 reconstruye bien: `cube`,
`cylinder` y `polyhedron`, combinadas con transformaciones y operaciones booleanas. No usa
`linear_extrude` ni primitivas 2D, porque en FreeCAD 1.1.4 fallan dentro de booleanas anidadas
(«Null input shape»). Con la configuración por defecto, la importación da un único sólido válido
de 34 caras y 79 511,5 mm³. El volumen difiere un 0,011 % del STL; la diferencia se debe a las
facetas de los cilindros.

**Vía alternativa** (si alguna vez el CSG no se importa bien): *File → Import* el STL de `exports/`
→ banco *Part* → *Part → Create shape from mesh* → *Part → Convert to solid* → *Part → Refine
shape*. Se obtiene un sólido facetado; las caras se eligen igual, aunque cada superficie curva
queda dividida en muchas facetas.

## 3. Ejecución automatizada (recomendada)

```bash
.tools/bin/freecadcmd simulation/soporte_pared_taladro_fem.py
```

El script `simulation/soporte_pared_taladro_fem.py` hace lo siguiente:

1. Importa el CSG y crea el objeto «Soporte» con la forma refinada.
2. Elige las caras **por geometría**, no por nombre `FaceN`, para que siga funcionando aunque
   cambien los parámetros:
   - Avellanados: caras cónicas con Y ≤ espesor.
   - Cara trasera: plana, con normal −Y y en Y = 0.
   - Cara superior de la bandeja: plana, con normal +Z y en Z = espesor.
   - Caras superiores de los labios: planas, con normal +Z, por encima de la bandeja y en el borde
     frontal.
3. Monta el análisis, malla con Gmsh, resuelve con CalculiX e imprime una línea `RESULTADO`.
4. En la variante base, con la malla por defecto, guarda `simulation/soporte_pared_taladro.FCStd`
   en versión **liviana** (~22 KB). El archivo conserva el análisis completo (geometría, material,
   fijaciones, apoyo, carga, solver y parámetros de malla), pero no la malla ni los resultados, que
   ocuparían ~40 MB. Con `FEM_GUARDAR_RESULTADOS=1` se guarda también la malla y los resultados.

| Variable de entorno | Valores | Efecto |
|---------------------|---------|--------|
| `FEM_VARIANTE` | `base` (por defecto) | Avellanados fijos, cara trasera con Y = 0 y carga sobre la cara superior de la bandeja |
| | `conservadora` | Como `base`, pero el apoyo en la pared se reduce a la arista inferior trasera (la placa pivota sobre su borde inferior) |
| | `pesima` | Como `base`, pero la carga se concentra en las caras superiores de los labios (borde frontal) |
| `FEM_MALLA_MM` | número (por defecto `2`) | Tamaño máximo de elemento, para el estudio de convergencia |
| `FEM_GUARDAR_RESULTADOS` | `0` (por defecto) o `1` | `1` guarda el `.FCStd` con malla y resultados (~40 MB) |

Ejemplo de la variante pésima con malla fina:

```bash
FEM_VARIANTE=pesima FEM_MALLA_MM=1.5 .tools/bin/freecadcmd simulation/soporte_pared_taladro_fem.py
```

## 4. Pasos equivalentes en la interfaz gráfica

Para revisar el análisis guardado o rehacerlo a mano con `.tools/bin/freecad`:

1. **Importar**: banco *OpenSCAD* → *File → Import* `simulation/soporte_pared_taladro.csg`.
   Después *Part → Refine shape*.
2. **Análisis**: banco *FEM* → *Analysis container*, que crea también el solver *CalculiX
   standard*. En el solver se elige *Analysis type = static*.
3. **Material**: *Material for solid* → PETG con `YoungsModulus = 2000 MPa`,
   `PoissonRatio = 0.38` y `Density = 1270 kg/m^3`.
4. **Fijación**: *Fixed boundary condition* → las dos caras cónicas de los avellanados.
5. **Apoyo en pared**: *Displacement boundary condition* → cara trasera de la placa (Y = 0).
   Solo se marca **Y** como fija con valor 0; X, Z y los giros quedan libres. Esta restricción
   aproxima linealmente el contacto con la pared.
6. **Carga**: *Force load* → cara superior de la bandeja, 25 N. Como dirección se elige una arista
   vertical y se marca *Reverse direction* si la flecha apunta hacia arriba.
7. **Malla**: *FEM mesh from shape by Gmsh* → *Element order = 2nd*,
   *Max element size = 2 mm* → *Apply*.
8. **Resolver**: doble clic en el solver → *Write .inp file* → *Run CalculiX*.
9. **Resultados**: doble clic en *CCX_Results* → *von Mises stress* y *Displacement Z*.

Para abrir el análisis guardado, que ya está listo para mallar y resolver:

```bash
.tools/bin/freecad simulation/soporte_pared_taladro.FCStd
```

Como se guarda sin malla, antes de ver resultados hay que hacer doble clic en *Malla* → *Apply* y
después doble clic en *CalculiX* → *Write .inp file* → *Run CalculiX* (pasos 7 a 9). Otra opción es
generar una copia completa con
`FEM_GUARDAR_RESULTADOS=1 .tools/bin/freecadcmd simulation/soporte_pared_taladro_fem.py`.

## 5. Resultados (configuración por defecto, 2026-10-04)

Modelo simulado (huellas SHA-256):

| Archivo | SHA-256 |
|---------|---------|
| `src/soporte_pared_taladro.scad` | `e02f77ccbbe6e698455e5f6d2bcbb29666815ce3ba3c50d3715ff4092aebd184` |
| `simulation/soporte_pared_taladro.csg` | `0db6c6449ebd37f301f149e0ddd633580954a4b64e34982b220f9e48a8953e83` |

Herramientas: FreeCAD 1.1.4, Gmsh 4.15.0 (tetraedros de segundo orden) y CalculiX 2.23.

| Variante | Malla | Nodos | σ máx. (MPa) | σ bruta (MPa) | Flecha frontal (mm) | Cumple |
|----------|-------|-------|--------------|---------------|---------------------|--------|
| base | 2 mm | 102 144 | 0,486 | 0,486 | 0,0405 | SÍ |
| base (convergencia) | 1,5 mm | 200 499 | 0,491 | 0,492 | 0,0406 | SÍ |
| conservadora | 2 mm | 102 012 | 1,248 | 1,536 | 0,0604 | SÍ |
| pésima | 2 mm | 102 022 | 2,177 | 2,177 | 0,2113 | SÍ |

- **Reproducibilidad**: Gmsh genera mallas ligeramente distintas en cada ejecución (entre 101 993 y
  102 144 nodos con 2 mm). En las ejecuciones repetidas, σ máx. de la variante base osciló entre
  0,476 y 0,486 MPa (≈ 2 %) y la flecha se mantuvo en 0,0405 mm. La conclusión no cambia.
- **Convergencia**: al pasar de 2 mm a 1,5 mm, σ máx. varía un 1,0 % y la flecha un 0,25 %. Ambas
  variaciones quedan por debajo del 5 % exigido, así que la malla de 2 mm es suficiente.
- **Ubicación de los máximos**:
  - Base: la tensión máxima está en el filete placa–bandeja, en el centro del ancho
    (≈ X 39, Y 8, Z 6).
  - Conservadora: el máximo está en el vértice superior de la cartela, en su unión con la placa
    (≈ X 75, Y 7, Z 50).
  - Pésima: el máximo está en la punta frontal de la cartela, junto al labio (≈ X 75, Y 91, Z 6).
- **Margen de seguridad real**: σ_lim / σ máx. es 62 en la variante base y 14 en la pésima. En
  todos los casos supera con holgura el factor 3 exigido.

### Comparación con el precálculo analítico (research.md, R9)

| Magnitud (25 N) | Precálculo sin cartelas | FEM con cartelas (base) |
|-----------------|-------------------------|-------------------------|
| σ máx. | 2,4–2,8 MPa | 0,49 MPa |
| Flecha del borde frontal | 0,75–0,9 mm | 0,04 mm |

La diferencia era de esperar y confirma la decisión de diseño de R9. Las cartelas convierten la
bandeja en una viga de gran canto: cada cartela mide ~44 mm de alto junto a la placa, con una
inercia de ≈ 5 · 44³ / 12 ≈ 35 500 mm⁴, frente a 1440 mm⁴ de la bandeja sola.

### Conclusión

La configuración por defecto **cumple** los criterios de SC-003 en las tres variantes y con la
malla convergida. Se puede pasar a la exportación (Puerta 2 cumplida).

## 6. Cuándo repetir la simulación

La validación anterior cubre sin repetir la simulación el **rango validado**:

- `profundidad ≤ 100 mm`
- `espesor ≥ 6 mm`
- `ancho ≥ 80 mm`
- `espesor_cartela ≥ 5 mm`
- material PETG o PLA

Fuera de ese rango (por ejemplo, con más vuelo o una bandeja más fina) hay que volver a exportar el
CSG con los nuevos parámetros y ejecutar el script. Si los parámetros cambian también es necesario
regenerar el STL de `exports/` (Principio IV). Con PLA, para usarlo en interiores, basta con
cambiar `MATERIAL` en el script (E ≈ 3500 MPa, ν = 0,36); su menor resistencia a la fluencia no
cambia la conclusión, dado el margen obtenido.
