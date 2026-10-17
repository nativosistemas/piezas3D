# Plan de implementación: Marcas de orientación y de altura del puntero láser

**Rama**: `012-marcas-orientacion` | **Fecha**: 2026-10-17 | **Especificación**: [spec.md](spec.md)

**Entrada**: especificación de la funcionalidad en `specs/012-marcas-orientacion/spec.md`

## Resumen

El aparato suma marcas para dejarlo en una posición de partida conocida:

- **Base fija**: una «S» (cara +Y) y una «O» (cara +X) grabadas, con su línea vertical.
- **Plataforma**: un índice de azimut en su borde +Y, que es la dirección del láser.
- **Altura**: una escala de 0° a 90° cada 15° y una aguja de índice en el brazo del motor.

La investigación encontró que la escala **no puede grabarse directamente en la polea**. El ángulo de la
polea respecto de la cuna depende de cuánto se aprieta el perno M8 que la enchaveta, así que el cero
quedaría corrido hasta ±30° (R1). Por eso la escala va en un **disco de la escala**, pieza impresa
nueva atornillada a la polea con 2 ranuras en arco. Su cero se pone una sola vez al armar, con el haz
en una pared (R6).

La aguja es una columna integrada en el brazo del motor, a las 12. Llega al plano de la escala para que
no haya paralaje (R2).

La posición modelada (láser hacia +Y) pasa a ser el sur, azimut 180°. En el visor, el `reposo` de la
articulación de azimut pasa a 180 y los objetivos de demostración apuntan a sus puntos cardinales
reales (R5).

La guía suma:

- la orientación al sur con brújula o celular, con la declinación;
- el cero de la escala;
- la posición de partida para el firmware;
- consejos para leer las marcas de noche.

Enfoque y alternativas: [research.md](research.md).

## Contexto técnico

**Lenguaje/Versión**: OpenSCAD 2021.01 (piezas y ensamblaje). Python 3 sin cambios en los scripts.

**Dependencias principales**:
- `src/puntero_laser_parametros.scad`, `src/perfil_impresora.scad` y `src/armado_comun.scad`.
- La tipografía «Liberation Sans:style=Bold», disponible en el entorno.
- Las skills `pieza-openscad`, `disenio-multipieza`, `guia-produccion` y `web-armado`.

**Almacenamiento**: archivos del repositorio.

**Pruebas**:
- `verificar_pieza.sh` sobre las 5 piezas tocadas y el ensamblaje.
- Las validaciones M-01 a M-09 y los casos que fallan a propósito ([quickstart.md](quickstart.md) §3).
- Las capturas revisadas.
- La comparación por vértices de las 9 STL que no cambian.
- `generar_web.py --comprobar`.
- El visor revisado en el Edge.

**Plataforma**: impresora FDM (Bambu Lab A1, perfil `perfil_impresora.scad`, todavía no medido) y
navegador con WebGL para el visor.

**Tipo de proyecto**: diseño paramétrico de varias piezas, con generadores de la web y del visor.

**Objetivos**:
- Posición de partida con ±5° de azimut y ±2° de altura (SC-002 y SC-003).
- Grabados legibles: letras de 10 mm y rayas de 1 mm a 0,6 mm de profundidad.

**Restricciones**:
- Sin soportes nuevos.
- Sin cambios en los encajes ni en el recorrido de correas y cables.
- La variante cable del brazo, igual por vértices.
- `--hardwarnings` sin avisos.

**Escala**:
- 1 pieza nueva y 4 piezas modificadas.
- 2 elementos nuevos en el ensamblaje.
- 13 parámetros nuevos y 9 validaciones.
- 1 renglón nuevo en la lista de materiales.
- 6 secciones de la guía tocadas.

## Verificación de la constitución

*Puerta: se cumple antes de la investigación y se vuelve a revisar después del diseño.*

| Principio / puerta | Cómo se cumple | Estado |
|---|---|---|
| I. Diseño paramétrico | Todas las medidas de las marcas son parámetros con nombre en `/* [Marcas] */` ([data-model.md](data-model.md)). Las posiciones salen de radios y caras existentes (`r_borde_polea_alt`, `r_aligerado`, `diametro_apoyo_tripode`, `y_plat1`), no de coordenadas sueltas. Los grabados se restan al final del `difference()` y sobresalen `eps`. El texto y el perfil de la oreja son 2D extruidos. Las validaciones M-01 a M-09 son `assert` en español | ✅ |
| II. Pipeline de cinco fases | Tareas por fase: 1) piezas y ensamblaje; 2) FEM, que no aplica (R9); 3) las 5 STL más la comparación de las 9; 4) guía y lista de materiales; 5) web, visor y vistas explotadas | ✅ |
| III. Simulación FEM | **No aplica**: grabados de 0,6 mm en zonas sin esfuerzo; la aguja y el disco no llevan carga; los agujeros guía dejan ≥ 2,9 mm de pared en una zona que transmite < 0,15 N·m (R9) | ✅ (justificado) |
| IV. Manufactura aditiva | Cada pieza mantiene su orientación. Las letras y las rayas caen en paredes verticales o en la cara superior. La aguja es vertical, como los pilares. El disco se imprime plano. Sin soportes nuevos. Las holguras salen de `perfil_impresora.scad` (`diametro_autorroscante_m3`). El disco no tiene encajes que dependan del perfil | ✅ |
| V. Documentación y web | Las secciones nuevas de la guía, según [contracts/guia.md](contracts/guia.md). El renglón nuevo va en el CSV, no a mano en la guía. La declinación lleva su fuente y su fecha si se dan valores (R8). Se regeneran la web, el visor y todas las vistas explotadas | ✅ |
| Gobernanza | Los parámetros viven en `puntero_laser_parametros.scad` y las reglas no se copian en las skills. No cambian la constitución ni las skills | ✅ |
| Puerta 1 (diseño) | `verificar_pieza.sh` sobre las 5 piezas y el ensamblaje, con las capturas revisadas | ✅ planificado |
| Puerta 2 (simulación) | La justificación de arriba | ✅ |
| Puerta 3 (exportación) | Las 5 STL regeneradas y las 9 comparadas por vértices | ✅ planificado |
| Puerta 4 (documentación) | Guía sin marcadores; lista de materiales desde el CSV | ✅ planificado |
| Puerta 5 (web) | `--comprobar` sin errores, las vistas explotadas revisadas una por una y el visor revisado en el Edge ([quickstart.md](quickstart.md) §6) | ✅ planificado |

**Revisión después del diseño**: sin violaciones. Quedan dos riesgos, que se controlan en la
implementación:

- **Holgura de la aguja a la correa** (≈ 2,1 mm): M-03 la controla. Si no alcanza, se sube
  `holgura_aguja`, y el único efecto es una aguja un poco más lejos de las rayas.
- **Paralaje del índice de azimut** (R4): no se puede eliminar sin otra pieza. Entra en el margen de
  ±5°, que la especificación ya refleja.

## Estructura del proyecto

### Documentación (esta funcionalidad)

```text
specs/012-marcas-orientacion/
├── spec.md
├── plan.md               # este archivo
├── research.md           # fase 0: R1 a R10
├── data-model.md         # fase 1: parámetros, derivados, geometría por pieza, validaciones M-01 a M-09
├── quickstart.md         # fase 1: escenarios de validación
├── contracts/
│   ├── ensamblaje.md     # piezas, elementos nuevos, reposo del azimut, exportación
│   └── guia.md           # renglón de la lista de materiales y secciones de la guía
├── checklists/requirements.md
└── tasks.md              # fase 2 (/speckit-tasks)
```

### Código y datos

```text
src/
├── puntero_laser_parametros.scad       # /* [Marcas] */, derivados, r_aligerado compartido, azimut_reposo
├── puntero_laser_adaptador_tripode.scad  # marcas_cardinales(), M-01, M-02
├── puntero_laser_plataforma_azimut.scad  # indice_azimut(), M-09
├── puntero_laser_brazo_horquilla.scad    # oreja y aguja_indice_altura() (variante motor), M-04
├── puntero_laser_polea_altitud.scad      # 2 agujeros guía, M-05
├── puntero_laser_disco_escala.scad       # NUEVO: pieza_disco_escala(), M-06
└── puntero_laser_ensamblaje.scad         # disco_escala, tornillos_disco, grupos, paso, reposo 180, M-03, M-07, M-08
exports/
└── puntero_laser_{adaptador_tripode,plataforma_azimut,brazo_horquilla_motor,polea_altitud,disco_escala}.stl
docs/
├── puntero_laser_guia.md               # secciones de contracts/guia.md
├── puntero_laser_bom.csv               # renglón de los tornillos del disco
└── img/                                # capturas de las 5 piezas, conjunto y vistas explotadas
specs/002-puntero-laser-estelar/web/    # index.html y armado_3d.html regenerados
```

**Decisión de estructura**: se sigue el árbol de la constitución. La única pieza nueva va en su propio
archivo de `src/` porque se imprime aparte, y comparte medidas a través de `puntero_laser_parametros.scad`.

## Seguimiento de complejidad

| Agregado | Por qué hace falta | Alternativa más simple descartada |
|---|---|---|
| Pieza nueva (disco de la escala) y 2 tornillos | El cero de una escala grabada en la polea quedaría corrido hasta ±30° y cambiaría en cada armado (R1) | Grabar en la polea: no cumple FR-005 ni SC-003 |
