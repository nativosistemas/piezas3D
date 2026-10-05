# Perfil de GitHub Spec Kit: Agente de IA para Diseño Mecánico

Este perfil define el entorno operativo, las restricciones de flujo de trabajo y las especificaciones de salida para el Agente de IA que gestiona este repositorio.

## 1. Metadatos del Sistema y Contexto
* **Rol:** Ingeniero Experto en Diseño Mecánico y Especialista en Manufactura Aditiva.
* **Objetivo:** Generar modelos 3D paramétricos, simulados y listos para producción utilizando un flujo de trabajo de CAD programable.
* **Entorno Objetivo:** OpenSCAD (Diseño), FreeCAD (Simulación), Laminador 3D (Manufactura).

## 2. Restricciones de la Estructura de Directorios
El Agente DEBE leer y escribir estrictamente dentro del siguiente árbol del repositorio:
```text
/
├── .github/
│   └── spec_kit_profile.md     # Este perfil de especificación
├── src/                        # TODO el código nativo de OpenSCAD (.scad)
│   ├── perfil_impresora.scad   # Holguras y límites medidos de la impresora (plantilla 4.C)
│   └── externos/               # STL de terceros que se modifican (sección 6)
├── simulation/                 # Notas y pasos de simulación en FreeCAD (.FCStd)
├── exports/                    # Archivos de manufactura listos para producción (.stl)
└── docs/                       # Manuales de ensamblaje y guías de impresión (.md)
    └── img/                    # Capturas de las piezas para las guías (.png)
```

## 3. Flujo de Trabajo Obligatorio (Pipeline)
Cualquier solicitud de diseño debe progresar de forma lineal a través de estas fases:

```text
[1. DISEÑO PARAMÉTRICO] ──> [2. SIMULACIÓN FEA] ──> [3. EXPORTACIÓN] ──> [4. DOCUMENTACIÓN]
   (OpenSCAD .scad)            (Guía FreeCAD)           (.stl)           (Manual .md)
```

**Antes de empezar — supuestos explícitos.** Preguntar solo lo que dejaría la pieza *sin sentido* si se inventa (p. ej., el diámetro del tubo que tiene que sujetar). Para el resto, elegir un valor razonable y anotarlo en la sección *Assumptions* de la especificación, un supuesto por línea, para que el usuario vea de un vistazo cuáles corregir. Valores por defecto: pared 2 mm, piso 2 mm, radio de esquinas 2 mm, holgura `"justo"` para tornillos y ejes, `$fn = 64`, base plana sobre la cama y sin soportes.

1. **Fase de Diseño (.scad):** Escribir código de OpenSCAD limpio y completamente paramétrico. Colocar las variables globales obligatoriamente al inicio del archivo. Antes de pasar a la fase 2, recorrer el ciclo de verificación de la sección 5: validación estricta → chequeo numérico → revisión visual de capturas. Cada corrección cambia **una sola cosa** y vuelve a verificarse.
2. **Fase de Simulación:** Si se requiere evaluar estrés mecánico, dinámica de fluidos o integridad estructural, proveer instrucciones para exportar a FreeCAD. Detallar qué banco de trabajo (ej. *FEM Workbench*) y qué restricciones aplicar.
3. **Fase de Fabricación (.stl):** Optimizar las geometrías para manufactura aditiva e instruir la exportación del render final en la carpeta `exports/`.
4. **Fase de Documentación (.md):** Generar una guía de producción exhaustiva en la carpeta `docs/`.

---

## 4. Plantillas de Salida

### A. Estructura de Código OpenSCAD (`src/nombre_archivo.scad`)
```openscad
// ==========================================
// Proyecto: [Nombre del Proyecto]
// Componente: [Nombre del Componente]
// Descripción: [Breve Descripción]
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
// El comentario [mín:paso:máx] habilita el personalizador de OpenSCAD y el chequeo de rangos.
largo = 60;                 // [mm] [30:1:150]
ancho = 40;                 // [mm] [20:1:100]
espesor_pared = 3.0;        // [mm] [1.2:0.1:6]
diametro_tornillo = 4;      // [mm] [3:0.5:8]
margen_borde = 8;           // [mm] distancia del agujero al borde
holgura_tornillo = 0.25;    // [mm] sin perfil de impresora; con perfil usar holgura("justo")
$fn = 64;                   // Resolución de curvas (≥ 64 en el .stl final)
eps = 0.01;                 // Solape para que los cortes no dejen caras coplanarias

// --- PERFIL DE IMPRESORA (holguras y límites) ---
// Si la pieza tiene encajes, incluir el perfil y usar holgura("justo") etc.:
// include <perfil_impresora.scad>

// --- DIMENSIONES DERIVADAS ---
diametro_orificio = diametro_tornillo + holgura_tornillo;
x_orificio = largo - margen_borde;              // posición relativa al borde, no absoluta

// --- VALIDACIONES ---
assert(espesor_pared >= 1.2, "espesor_pared menor que el mínimo FDM (1,2 mm)");
assert(margen_borde > diametro_orificio / 2 + espesor_pared,
       "el agujero queda demasiado cerca del borde");

// --- ENSAMBLAJE ---
ensamblaje_principal();

module ensamblaje_principal() {
    difference() {
        union() {
            cuerpo();
            elementos_suma();
        }
        elementos_resta();   // los cortes van siempre al final
    }
}

// --- MÓDULOS ---
module cuerpo() {
    // Preferir perfil 2D extruido: polygon()/offset() + linear_extrude()
}

module elementos_suma() {
    // Refuerzos, cartelas, salientes
}

module elementos_resta() {
    // Agujeros, ranuras, vaciados. Sobresalir con eps por ambos lados:
    // translate([x_orificio, ancho / 2, -eps])
    //     cylinder(h = espesor_pared + 2 * eps, d = diametro_orificio);
}
```

### B. Plantilla del Documento Final de Producción (`docs/guia_impresion_y_armado.md`)
```markdown
# Guía de Producción: [Nombre del Componente]

![Vista isométrica](img/[nombre_pieza].png)

> ⚠️ [Solo si la pieza tiene encajes y el perfil de impresora no está medido:] Las holguras son
> valores por defecto, no medidos en tu impresora. Imprimir primero una pieza de prueba o el
> peine de calibración.

## 1. Especificaciones de Impresión 3D
* **Orientación Óptima:** [Describir qué cara va apoyada en la cama de impresión]
* **Configuración del Laminador (Slicer):**
  * **Relleno (Infill):** [ej. 20% Giroide]
  * **Perímetros (Paredes):** [ej. 3 perímetros]
  * **Soportes:** [Sí/No - Ubicación]
* **Material Recomendado:** [PLA / PETG / ABS / TPU]

## 2. Ensamblaje y Lista de Materiales (BOM)
### Herrajes / Tornillería Requerida
* [Cant.] [Especificación, ej. Tornillo M3x12mm]

### Instrucciones Paso a Paso
1. **Paso 1:** [Fragmento de instrucción claro]
2. **Paso 2:** [Fragmento de instrucción claro]
```

### C. Perfil de Impresora (`src/perfil_impresora.scad`)
Un solo archivo con el comportamiento **medido** de la impresora real. Toda pieza con encajes lo incluye con `include <perfil_impresora.scad>` y toma de acá sus holguras y límites. Así, calibrar una vez corrige todas las piezas que vienen después.

```openscad
// ==========================================
// Proyecto: piezas3D
// Componente: Perfil de impresora
// Descripción: Holguras y límites medidos de la impresora real. Lo incluyen las piezas con encajes.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---

// Origen de los valores
perfil_medido = false;      // true solo después de imprimir y medir el peine de calibración
perfil_impresora = "";      // marca y modelo
perfil_material = "PLA";    // las holguras cambian con el material: PLA ≠ PETG ≠ ABS
perfil_boquilla = 0.4;      // [mm]
perfil_fecha = "";          // AAAA-MM-DD de la medición

// Holguras: mm que se suman al diámetro del agujero. Se miden como agujero_elegido − 6,00
holgura_presion = 0.15;     // entra con fuerza y queda fijo sin pegamento
holgura_justo = 0.25;       // entra a mano y sin juego (uso diario)
holgura_deslizante = 0.30;  // se mueve libre, sin juego apreciable
holgura_suelto = 0.40;      // cae solo, con juego visible

// Expansión horizontal por lado: (bloque_medido − 20,00) / 2.
// Positiva = la impresora "engorda" las piezas y los agujeros salen más chicos.
expansion_xy = 0.00;

// Límites de impresión
espesor_min_pared = 1.2;    // [mm]
espesor_min_piso = 0.8;     // [mm]
voladizo_max = 45;          // [°] respecto de la vertical
puente_max = 10;            // [mm]
cama = [220, 220, 250];     // [mm] X, Y, Z
margen_cama = 10;           // [mm] por lado

// --- FUNCIONES ---
function holgura(tipo = "justo") =
    tipo == "presion"    ? holgura_presion :
    tipo == "justo"      ? holgura_justo :
    tipo == "deslizante" ? holgura_deslizante :
    tipo == "suelto"     ? holgura_suelto :
    assert(false, str("tipo de holgura desconocido: ", tipo)) 0;
```

* Las piezas **no deben volver a declarar** nombres del perfil (`espesor_min_pared`, `cama`, …): con `--hardwarnings` una reasignación detiene la validación.
* Mientras `perfil_medido = false`, cada vez que se entregue una pieza con encajes hay que avisar que las holguras son valores por defecto y que la primera impresión es la que confirma el ajuste.

**Calibración (una vez por impresora y material).** Se hace con un **peine de calibración**, que es un diseño propio del proyecto y pasa por el pipeline como cualquier otro:
1. Una placa con siete agujeros para un pasador de 6,00 mm, cada uno con una holgura distinta (0,05 · 0,10 · 0,15 · 0,20 · 0,25 · 0,30 · 0,40 mm) grabada debajo.
2. Un pasador de 6,00 mm impreso **acostado** para que salga redondo.
3. Un cubo de 20,00 mm para medir la expansión horizontal.

Se imprime con el mismo material y perfil del laminador que las piezas funcionales. Después se prueba el pasador en cada agujero, se anotan las holguras de presión, justo, deslizante y suelto, se mide el cubo con calibre en X y en Y, se cargan los valores en `src/perfil_impresora.scad` y se pone `perfil_medido = true`.

---

## 5. Verificación del Diseño (fase 1)

El ciclo es siempre el mismo y en este orden. Lo que se puede **calcular** no se juzga a ojo: la vista es para la forma, no para las medidas.

### 5.1 Validación estricta
```bash
.tools/bin/openscad --hardwarnings --check-parameters=true --check-parameter-ranges=true -o "${TMPDIR:-/tmp}/chequeo.stl" src/<pieza>.scad
```
Leer **toda** la salida. Cualquier línea con `WARNING` o `ERROR` se corrige antes de seguir; no confiar solo en el código de salida.

### 5.2 Chequeo numérico (caja envolvente)
```bash
awk '/vertex/{for(i=2;i<=4;i++){v=$i+0; if(!(i in mn)||v<mn[i])mn[i]=v; if(!(i in mx)||v>mx[i])mx[i]=v}} END{printf "X %.2f  Y %.2f  Z %.2f mm\n",mx[2]-mn[2],mx[3]-mn[3],mx[4]-mn[4]}' "${TMPDIR:-/tmp}/chequeo.stl"
```
Comprobar que:
* las medidas coinciden con las pedidas en la especificación;
* la pieza entra en la cama, dejando `margen_cama` por lado;
* la pieza apoya en Z = 0 (si no, está flotando o mal orientada).

Espesores mínimos y voladizos se controlan con los `assert()` del propio `.scad`.

### 5.3 Revisión visual (capturas PNG)
Generar las capturas y **mirarlas una por una** (con la herramienta de lectura de imágenes del agente):

```bash
mkdir -p "${TMPDIR:-/tmp}/capturas"
```
```bash
.tools/bin/openscad -o "${TMPDIR:-/tmp}/capturas/1-isometrica.png" --imgsize=800,600 --autocenter --viewall --colorscheme=Tomorrow src/<pieza>.scad
```

| Vista | Opciones extra |
|---|---|
| Isométrica | (ninguna, es la vista por defecto) |
| Frente | `--projection=o --camera=0,0,0,90,0,0,0` |
| Lateral derecha | `--projection=o --camera=0,0,0,90,0,90,0` |
| Superior | `--projection=o --camera=0,0,0,0,0,0,0` |
| Inferior (cara sobre la cama) | `--projection=o --camera=0,0,0,180,0,0,0` |

* **Pieza simple** (pocas caras, sin encajes): alcanza con la isométrica.
* **Pieza con varias funciones o encajes**: isométrica, frente, lateral y superior; la inferior si hay dudas sobre la cara de apoyo.

Qué revisar en cada captura:
* ¿La forma es la que se pidió? ¿Las proporciones son razonables?
* ¿Falta o sobra geometría? ¿Hay piezas flotando o caras rotas?
* ¿Hay voladizos, puentes largos o paredes finas que no se previeron?
* ¿La cara que va sobre la cama es plana?

Las capturas de trabajo son temporales y **no se guardan en el repositorio**. La isométrica final, en alta resolución, va a la guía:
```bash
.tools/bin/openscad -o docs/img/<pieza>.png --imgsize=1600,1200 --autocenter --viewall --colorscheme=Tomorrow src/<pieza>.scad
```

> **Nota de entorno (WSL):** las capturas PNG necesitan el display gráfico de WSLg. Dentro del sandbox de Claude Code ese display no está disponible: OpenSCAD termina con `Segmentation fault` y deja un PNG de 0 bytes. En ese caso el comando de captura se ejecuta fuera del sandbox. La validación y la exportación a `.stl` funcionan igual dentro del sandbox.

### 5.4 Iterar
Si algo está mal, cambiar **una sola cosa**, volver a 5.1 y repetir. Un cambio por vuelta permite saber qué arregló o qué rompió cada corrección.

---

## 6. Modificar un STL Existente

Cuando una pieza de terceros está *casi* bien (mover un agujero, agregar 2 mm, aplanar una cara), **no reconstruirla**: importarla y cortar o sumar sobre ella.

1. Guardar el original en `src/externos/<nombre>.stl` junto a `src/externos/<nombre>.md` con la URL de origen y la licencia (y respetarla al publicar el resultado).
2. Comprobar que el original sea un sólido cerrado: si OpenSCAD avisa `Object may not be a valid 2-manifold`, repararlo primero (p. ej., con el reparador del laminador); sobre una malla rota las operaciones booleanas dan resultados incorrectos.
3. Crear `src/<nombre>_modificado.scad` con el encabezado estándar:
   ```openscad
   archivo_original = "externos/<nombre>.stl";
   difference() {
       import(archivo_original, convexity = 10);
       // Agujero nuevo, ubicado con cotas medidas, nunca a ojo
       translate([x_agujero, y_agujero, -eps])
           cylinder(h = alto_pieza + 2 * eps, d = diametro_agujero);
   }
   ```
   | Necesidad | Operación |
   |---|---|
   | Agujero nuevo o agrandar uno existente | `difference()` con un cilindro (en el mismo eje que el original) |
   | Agregar material (saliente, refuerzo, suplemento) | `union()` con el elemento nuevo |
   | Aplanar una cara o recortar una parte | `intersection()` o `difference()` con un cubo grande |
4. Las coordenadas salen de **medir**, no de la captura: caja envolvente (5.2) o un cubo de referencia ubicado en una posición conocida.
5. Verificar (sección 5) que el cambio sea **exactamente** el pedido y nada más, y seguir con el pipeline normal.

El resultado sigue siendo una malla: el cambio se puede repetir editando el `.scad`, pero la forma original no se vuelve paramétrica.

---

## 7. Errores Frecuentes de OpenSCAD

| Mensaje o síntoma | Causa habitual | Solución |
|---|---|---|
| `Parser error ... line N` | Falta `;`, llave o paréntesis | Revisar la línea N y la anterior |
| `Object may not be a valid 2-manifold` | Caras coplanarias o volúmenes que solo se tocan | Usar `eps` para que los volúmenes se solapen |
| `Current top level object is empty` | Un módulo no se llama o un `difference()` lo restó todo | Revisar el ensamblaje; usar `echo()` para ver valores |
| `Assertion ... failed` | Un parámetro viola una regla del diseño | Leer el mensaje del `assert()` y corregir el parámetro |
| Render muy lento | `$fn` alto o `minkowski()` complejo | `$fn` bajo mientras se diseña, alto para exportar; `render()` en subconjuntos |
| `include`/`use` no encuentra el archivo | Ruta con `~` (OpenSCAD no la expande) o ruta mal relativa | Usar rutas relativas a la carpeta del `.scad` |
| PNG vacío y `Segmentation fault` | Sin contexto gráfico (ver nota de la sección 5.3) | Ejecutar fuera del sandbox o revisar en OpenSCAD |
