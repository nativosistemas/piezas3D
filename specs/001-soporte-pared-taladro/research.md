# Investigación (Fase 0): Soporte de pared paramétrico para taladro

**Funcionalidad**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md) | **Fecha**: 2026-10-04

Cada apartado sigue el formato Decisión / Justificación / Alternativas consideradas.
Convención de ejes usada en todo el diseño: **X** = ancho (paralelo a la pared), **Y** = profundidad
(perpendicular a la pared, la pared está en el plano Y = 0), **Z** = altura.

---

## R1. Arquitectura geométrica de la pieza

**Decisión**: pieza única en «L» con la **bandeja abajo** y la **placa trasera hacia arriba**:

- Placa trasera vertical de `ancho × espesor × altura_placa` apoyada en la pared.
- Bandeja horizontal de `ancho × profundidad × espesor` en la base de la placa (Z = 0).
- Ranura en U centrada en X, abierta hacia el frente (+Y), con fondo semicircular.
- Dos **cartelas triangulares** en los bordes laterales (X = 0 y X = ancho), **por encima** de la
  bandeja, unidas a la placa; terminan antes del labio de retención.
- Filete interior en la unión placa–bandeja para reducir la concentración de tensiones.
- Dos orificios avellanados en la parte alta de la placa, por encima de las cartelas.

**Justificación**:

- El taladro cuelga con el portabrocas hacia abajo atravesando la ranura; la empuñadura y la batería
  quedan **por encima** de la bandeja apuntando hacia el frente. Las cartelas en los bordes laterales
  no interfieren con el cuerpo (centrado) ni con la empuñadura (ancho ~40 mm, centrada).
- Esta disposición permite imprimir la pieza **tal como se instala**, apoyada sobre la cara inferior
  de la bandeja (ver R2), sin soportes y con el labio de retención en la cara superior.
- Los tornillos quedan arriba, que es donde el momento de vuelco tira de la placa; la parte baja de
  la placa trabaja a compresión contra la pared.

**Alternativas consideradas**:

- *Bandeja arriba y placa colgando hacia abajo con cartelas inferiores (puntales a compresión)*:
  estructuralmente algo mejor, pero obliga a imprimir boca abajo (bandeja contra la cama), lo que
  impide el labio de retención en la cara superior sin soportes. Rechazada.
- *Soporte de dos piezas o con abrazadera*: más complejo de imprimir y montar sin aportar valor para
  un taladro de 2,5 kg. Rechazada.

---

## R2. Orientación de impresión

**Decisión**: imprimir **en la posición de uso**, con la cara inferior de la bandeja (Z = 0) sobre la
cama. Placa y cartelas crecen en vertical.

**Justificación**:

- La bandeja, que es el voladizo cargado, trabaja a flexión con tensiones en dirección Y, **dentro del
  plano de las capas** (dirección más resistente en FDM).
- Las cartelas son rampas cuya sección disminuye con la altura: sin voladizos.
- La ranura es un vaciado vertical: sin voladizos. El chaflán superior de la ranura amplía el hueco
  hacia arriba: sin voladizos.
- Los orificios de los tornillos son horizontales a través de la placa vertical. Con Ø ≤ 9 mm el
  puente superior se imprime sin soporte; el avellanado a 90° deja una pared superior a 45°, límite
  admisible sin soportes.
- Huella en cama: `ancho × profundidad` ≤ 150 × 160 mm, cabe en una cama de 180 × 180 mm (FR-011).

**Alternativas consideradas**:

- *Placa trasera sobre la cama*: la bandeja crecería en vertical y su flexión cargaría la adhesión
  entre capas (la dirección más débil). Rechazada.
- *De lado (cara lateral sobre la cama)*: el borde de la ranura quedaría como techo horizontal en
  voladizo de ~50 mm sobre el hueco. Necesitaría soportes. Rechazada.

---

## R3. Sujeción y retención del taladro

**Decisión**: ranura en U abierta al frente más un **labio de retención** chaflanado a 45° en el
borde frontal de cada carril (`altura_labio`, 3 mm por defecto; 0 lo desactiva).

**Justificación**:

- Con la empuñadura hacia el frente, el centro de gravedad queda por delante del eje del portabrocas:
  el taladro tiende a inclinarse hacia fuera, lo que empuja el portabrocas contra el fondo de la
  ranura. Es un efecto autobloqueante.
- El labio evita que el cuerpo se deslice hacia el frente por un golpe accidental. Para retirar el
  taladro basta con levantarlo unos milímetros, que es el gesto natural (SC-007).
- Los chaflanes de 45° del labio y de la ranura guían la inserción y no rayan la herramienta (FR-003).

**Alternativas consideradas**: bandeja inclinada hacia arriba (complica la orientación de impresión),
ranura con estrechamiento elástico (sensible al material y a la tolerancia), y anillo cerrado (obliga
a insertar el taladro estrictamente en vertical). Todas rechazadas.

---

## R4. Posición de la ranura y papel de la «profundidad»

**Decisión**: el centro del fondo semicircular de la ranura se sitúa en el **punto medio de la
bandeja útil**: `centro_ranura_y = espesor + (profundidad − espesor) / 2`. Se añade el parámetro de
referencia `diametro_cuerpo_taladro` (60 mm por defecto), que sirve solo para validar holguras.

**Justificación**: así la profundidad tiene un efecto funcional directo: un taladro con el cuerpo más
grueso necesita más profundidad. Las validaciones que se derivan de ello son estas:

- Holgura cuerpo–placa y cuerpo–labio ≥ `longitud_labio + 2 mm` ⇒
  `profundidad ≥ espesor + diametro_cuerpo_taladro + 2·(longitud_labio + 2)`. Con los valores por
  defecto da 82 mm ≤ 100 mm. Cubre el caso límite «profundidad insuficiente».
- El cuerpo apoya en los carriles: `diametro_cuerpo_taladro ≥ ancho_ranura + 8 mm`.
- El cuerpo no choca con las cartelas: `diametro_cuerpo_taladro ≤ ancho − 2·espesor_cartela − 2 mm`.

**Alternativas consideradas**: dejar la ranura a una distancia fija de la pared. Así la profundidad
solo alargaría los carriles, sin utilidad para el usuario. Rechazada.

---

## R5. Tornillería y avellanado

**Decisión**:

- `diametro_orificio = diametro_tornillo + holgura_tornillo` (FR-007).
- Cabeza avellanada estándar a 90° con `diametro_cabeza = 2 · diametro_tornillo`. Es la relación
  típica de los tornillos de cabeza plana para madera o taco (DIN 7997 / ISO 10642 ≈ 2d).
- `profundidad_avellanado = (diametro_cabeza − diametro_orificio) / 2`. Se añade 0,3 mm de
  rebaje adicional para que la cabeza quede por debajo de la superficie.
- Posición: centros a `diametro_cabeza` de cada borde lateral y a `diametro_cabeza` del borde
  superior (FR-009). Las cartelas terminan al menos `diametro_cabeza` por debajo de los centros.
- Valor por defecto: tornillo Ø5 con taco de nailon Ø8. BOM: 2 × tornillo avellanado 5 × 50 mm y
  2 × taco Ø8 × 40 mm.

**Justificación**: valores estándar de ferretería. El esfuerzo de arranque por tornillo con la carga
de diseño es de ~10 N (≈30 N con FS 3), muy por debajo de la capacidad de un taco Ø8 (> 500 N).

**Alternativas consideradas**: cabeza cilíndrica con alojamiento cilíndrico. Necesita más espesor de
placa y deja un escalón con voladizo horizontal al imprimir en vertical. Queda fuera del alcance
(posible opción futura).

---

## R6. Validación de parámetros

**Decisión**: usar `assert(condición, "mensaje")` de OpenSCAD (disponible desde la versión 2019.05)
al inicio del archivo, tras los parámetros. Cada mensaje está en español y nombra el parámetro, el
valor recibido y el límite. Las reglas están en [data-model.md](data-model.md#reglas-de-validación).

**Justificación**: detiene la generación con un error explícito (FR-010, SC-005) sin código externo.

**Alternativas consideradas**: `echo()` con advertencias, que no detiene la generación ni garantiza
SC-005, o un validador externo en Python, que añade una dependencia. Rechazadas.

---

## R7. Interfaz de parámetros para el usuario

**Decisión**: declarar los parámetros con anotaciones del **Customizer** de OpenSCAD (grupos
`/* [Grupo] */` y rangos `// [min:paso:max]`). Los valores derivados y las constantes internas van en
`/* [Hidden] */`. Los mismos nombres sirven para sobrescribir valores desde la línea de comandos con
`-D nombre=valor`.

**Justificación**: el usuario ajusta la pieza con deslizadores y sin editar código (SC-006). La
sección `// --- PARÁMETROS Y CONSTANTES ---` exigida por la constitución se mantiene: los grupos del
Customizer van dentro de ella.

**Alternativas consideradas**: solo variables sin anotar (usable pero menos amigable) o un archivo
JSON de presets (útil más adelante, fuera de alcance).

---

## R8. Material

**Decisión**: **PETG** por defecto y **PLA** como alternativa para interiores a temperatura
ambiente. Propiedades de cálculo del PETG impreso:

| Propiedad | Valor de cálculo |
|-----------|------------------|
| Módulo de Young E | 2000 MPa |
| Coeficiente de Poisson ν | 0,38 |
| Densidad | 1,27 g/cm³ |
| Resistencia efectiva en FDM (en el plano de capa) σ_lim | 30 MPa (conservador frente a ~50 MPa nominal) |
| Tensión admisible con FS 3 | σ_adm = 10 MPa con la carga de diseño |

**Justificación**: el PETG tiene mejor resistencia a la fluencia bajo carga permanente y mejor
tenacidad que el PLA, y se imprime sin cámara cerrada. El ABS no aporta ventajas aquí y el TPU no es
rígido.

---

## R9. Precálculo analítico (comprobación previa a la simulación)

Modelo de viga en voladizo **sin contar las cartelas** (conservador). La carga de diseño
F = 25 N se aplica en el centro de la ranura. Configuración por defecto: palanca
L = `centro_ranura_y − espesor` = 53 − 6 = 47 mm.

| Sección | Inercia I | Momento M | σ con F = 25 N | σ con 3F |
|---------|-----------|-----------|----------------|----------|
| Unión con la placa (80 × 6 mm) | 1440 mm⁴ | 1175 N·mm | 2,4 MPa | 7,3 MPa |
| Inicio de la ranura, 2 carriles de 17 × 6 mm | 612 mm⁴ | 575 N·mm | 2,8 MPa | 8,5 MPa |

- La flecha del borde frontal sin cartelas es ≈ 0,75–0,9 mm (flexión + giro): **en el límite** de
  1 mm. Las cartelas son **necesarias** para tener margen y limitar la fluencia del PETG a largo
  plazo.
- Con la configuración máxima (profundidad 160 mm, L = 77 mm) y sin cartelas, la flecha superaría
  1 mm. Por eso **la guía exige repetir la simulación** si aumenta la profundidad o disminuyen el
  espesor, el ancho o el espesor de las cartelas respecto a los valores validados.
- Tensión de arranque en los tornillos: M / brazo ≈ 1175 / 57 ≈ 21 N en total con la carga de
  diseño. Es despreciable.

**Conclusión**: la configuración por defecto cumple con holgura el criterio de tensión
(≤ 10 MPa). El criterio de flecha depende de las cartelas y debe confirmarse con elementos finitos.
Por eso la simulación **aplica** (Principio III).

---

## R10. Cadena de simulación en FreeCAD

**Decisión**:

1. Exportar desde OpenSCAD a **`.csg`** (`simulation/soporte_pared_taladro.csg`) e importarlo en
   FreeCAD con el banco *OpenSCAD* («Import CSG»). Así se obtiene un sólido B-rep a partir de
   primitivas. **Vía alternativa**: importar el `.stl`, convertirlo con *Part → Create shape from mesh*
   → *Convert to solid* → *Refine shape*.
2. Banco de trabajo **FEM**:
   - Material: PETG con las propiedades de R8.
   - Fijación (*ConstraintFixed*): caras cónicas de los avellanados.
   - Apoyo en pared (*ConstraintDisplacement*): cara trasera de la placa con desplazamiento Y = 0
     (aproximación lineal del contacto con la pared). Como variante conservadora, el apoyo se reduce a la
     arista inferior trasera, de modo que la placa pivota sobre su borde inferior. En la
     implementación sustituyó a la «franja inferior», que habría obligado a partir la cara.
   - Carga (*ConstraintForce*): 25 N en −Z sobre la cara superior de la bandeja. Como variante
     pésima, se aplica sobre las caras superiores del labio.
   - Malla: Gmsh, tetraedros de segundo orden, tamaño máximo 2 mm.
   - Solver: CalculiX, análisis estático lineal.
3. Criterios de aceptación: σ von Mises máx. ≤ 10 MPa (ignorando picos singulares a menos de un
   elemento de las fijaciones) y desplazamiento del borde frontal ≤ 1 mm (SC-003).
4. Guardar `simulation/soporte_pared_taladro.FCStd` y anotar los resultados en
   `simulation/soporte_pared_taladro_fem.md`.

**Justificación**: OpenSCAD no exporta STEP. La importación de CSG reconstruye la geometría con
precisión si el modelo usa primitivas 3D (`cube`, `cylinder` y `polyhedron`) y evita `minkowski`
y `hull`, que el importador resuelve como malla. **Hallazgo de la implementación**: en FreeCAD 1.1.4
`linear_extrude` y los `circle` 2D fallan dentro de booleanas anidadas («Null input shape» o
volumen 0), así que los prismas se construyen como `polyhedron`. Este requisito restringe el estilo
de modelado (ver [data-model.md](data-model.md)).

**Automatización** (actualizado 2026-10-04): los pasos 1 a 4 se implementan en el script
`simulation/soporte_pared_taladro_fem.py`, que se ejecuta con `.tools/bin/freecadcmd`. El script:

- Selecciona las caras **por geometría** (normal y posición), no por nombre `FaceN`, para seguir
  funcionando aunque cambien los parámetros.
- Guarda el `.FCStd`.
- Imprime σ máx. y la flecha del borde frontal.

La guía `.md` reproduce los mismos pasos para hacerlos en la interfaz gráfica.

**Alternativas consideradas**: solo la guía manual en la interfaz gráfica. Es menos repetible y
obliga a rehacer la selección de caras cada vez que cambian los parámetros. Se mantiene como
complemento, no como vía principal.

---

## R11. Herramientas disponibles en el entorno de desarrollo

**Hallazgos** (Ubuntu 26.04 en WSL2, dentro del sandbox):

- `sudo` está bloqueado en el sandbox, así que no se puede instalar con `apt`. Las herramientas se
  instalaron con sus **AppImage oficiales extraídas** en `.tools/`, que está ignorado por git:

| Herramienta | Versión | Lanzador |
|-------------|---------|----------|
| OpenSCAD | 2021.01 | `.tools/bin/openscad` |
| FreeCAD | 1.1.4 (SHA-256 verificado) | `.tools/bin/freecadcmd` y `.tools/bin/freecad` |
| Gmsh | 4.15.0 (incluido en FreeCAD) | `.tools/bin/gmsh` |
| CalculiX | 2.23 (incluido en FreeCAD) | `.tools/bin/ccx` |

- Comprobaciones realizadas:
  - OpenSCAD exporta STL y CSG sin interfaz gráfica.
  - Si un `assert` falla, termina con código 1 y no escribe el STL.
  - FEM de una viga de prueba en voladizo con 25 N: 15,48 MPa y 4,99 mm, frente a 15,0 MPa y
    5,00 mm analíticos.
  - Un CSG de OpenSCAD se importa con `importCSG` como sólido válido con el volumen exacto.
- `freecadcmd` necesita que su configuración de usuario esté en una ruta con permiso de escritura.
  El lanzador la redirige a `.tools/freecad-home`.
- `python3` 3.14 está disponible para comprobar la caja envolvente del STL.

**Decisión**:

- Usar siempre los lanzadores de `.tools/bin/`.
- Escribir el `.scad` compatible con OpenSCAD 2021.01, sin funciones exclusivas de versiones
  nightly.
- La fase 2 se **ejecuta** dentro del entorno con el script FEM (R10). El `.FCStd` y los resultados
  numéricos se generan durante la implementación.

---

## R12. Estrategia de verificación

**Decisión**: verificación por línea de comandos, sin directorio de tests adicional porque la
constitución limita el árbol del repositorio. Todos los comandos están en [quickstart.md](quickstart.md):

1. Renderizado por defecto con `--hardwarnings` → STL sin errores (puerta 1).
2. Caja envolvente del STL = (`ancho`, `profundidad`, `altura_placa`) ± 0,1 mm (SC-004), medida con
   un fragmento de Python sobre el STL ASCII.
3. Barrido de combinaciones válidas en los extremos de los rangos → todas renderizan.
4. Combinaciones inválidas (casos límite de la especificación) → cada una falla con un
   `ERROR: Assertion` que nombra el parámetro (SC-005).
5. Comprobación visual o en el laminador: sin voladizos > 45° y sin soportes (SC-001).
