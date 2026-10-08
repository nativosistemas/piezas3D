# Guía de Producción: [Nombre del diseño]

[Qué es y para qué sirve, en 2 a 4 oraciones.]

![Vista isométrica](img/[diseño].png)

> ⚠️ [Solo si hay encajes y el perfil de impresora no está medido:] **Holguras por defecto, no
> medidas.** Los encajes usan valores genéricos para FDM con boquilla de 0,4 mm. Imprimir primero
> [la pieza de prueba / el peine de calibración] y ajustar antes de imprimir el resto.

## Primeros pasos

1. **[Medir / calibrar].** [Qué medir de los componentes propios y dónde cargarlo.]
2. **Imprimir [la pieza de prueba].** [Si aplica.]
3. **Imprimir las piezas** (sección 1).
4. **Comprar los componentes** de la lista de materiales (sección 2).
5. **Armar** siguiendo los pasos de la sección 2 [y hacer la puesta a punto (sección 3)].

## 1. Especificaciones de Impresión 3D

| Pieza | STL | Cant. | Orientación (cara sobre la cama) | Relleno | Perímetros | Soportes | Adherencia |
|-------|-----|-------|----------------------------------|---------|------------|----------|------------|
| [Pieza] | `[diseño]_[pieza].stl` | 1 | [Cara] | [20 % giroide] | [3] | [No] | [—] |

**Configuración común del laminador**: [altura de capa, capas superiores e inferiores, etc.]

**Material recomendado**: [PLA / PETG / ABS / TPU], [con temperaturas y por qué].

## 2. Ensamblaje y Lista de Materiales (BOM)

### Herrajes / Tornillería Requerida

<!-- BOM:inicio (generado desde docs/[diseño]_bom.csv con scripts/generar_web.py: no editar a mano) -->
<!-- BOM:fin -->

### Herramientas

* [Llave de 13 mm, destornillador Phillips, calibre, etc.]

### Instrucciones Paso a Paso

1. **[Título corto].** [Qué pieza, con qué herraje, desde dónde entra y cuándo apretar.]
2. **[Título corto].** [...]

## 3. Puesta a punto

[Si aplica: ajustes, tensado, calibración, pruebas de aceptación.]

## 4. Adaptación a tus componentes

[Si aplica: qué medir, qué parámetro cambiar y cómo regenerar los STL.]

## 5. Seguridad

[Si aplica.]

## 6. Consejos y buenas prácticas

- **[Consejo].** [Por qué, citando la sección de esta guía de donde sale.]
