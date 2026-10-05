---
description: "Lista de tareas para implementar el puntero láser estelar motorizado (alt-az)"
---

# Tareas: Puntero láser estelar motorizado (alt-az)

**Entrada**: documentos de diseño en `specs/002-puntero-laser-estelar/`

**Prerrequisitos**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/interfaz_generador.md](contracts/interfaz_generador.md),
[contracts/interfaz_firmware.md](contracts/interfaz_firmware.md) y [quickstart.md](quickstart.md)

**Pruebas**: la especificación no pide TDD. No se crea `tests/`. La verificación se hace con las
tareas de comprobación, que ejecutan los escenarios del [quickstart.md](quickstart.md) y cierran las
puertas de calidad de la constitución.

**Organización**: la constitución (Principio II) **obliga** a agrupar las tareas en las cuatro fases
del pipeline: Diseño → Simulación → Exportación → Documentación. Esta regla prevalece sobre la
agrupación por historia de la plantilla. Cada tarea lleva la etiqueta de su historia (`[US1]` …
`[US4]`) para mantener la trazabilidad.

## Formato: `[ID] [P?] [Historia] Descripción`

- **[P]**: puede ejecutarse en paralelo (archivos distintos y sin dependencias pendientes).
- **[USn]**: historia de usuario de [spec.md](spec.md).

## Convenciones comunes a todas las tareas

- Ejecutar todo desde la raíz del repositorio (`/home/nuc/piezas3D`) y usar **siempre**
  `.tools/bin/openscad`. Las salidas temporales van a `$TMPDIR`.
- Todo va en español: comentarios, mensajes de `assert` y documentos. Variables y módulos en
  `snake_case`.
- **Encabezado estándar** de .github/spec_kit_profile.md en cada `.scad`:
  - `Proyecto: piezas3D – Puntero láser estelar`.
  - `Componente: <pieza>`.
  - `Descripción: …`.
  - Después, `// --- PARÁMETROS Y CONSTANTES ---` y `// --- MÓDULOS PRINCIPALES Y ENSAMBLAJE ---`.
- **Estructura de cada archivo de pieza**:
  - Hace `include <puntero_laser_parametros.scad>` **dentro** de la sección
    `// --- PARÁMETROS Y CONSTANTES ---`. Así cumple el Principio I: es la forma en que el archivo
    declara todas sus dimensiones clave y `$fn`.
  - Su sección de parámetros contiene **solo** constantes locales con nombre, en `/* [Hidden] */`.
  - Define `module pieza_<nombre>()` **en orientación de impresión**: apoyada en Z = 0 y centrada en
    X = Y = 0.
  - Define `module ensamblaje_principal() { pieza_<nombre>(); }` y lo llama.
- **Sin números mágicos** dentro de los módulos. Se admiten `eps`, 0, ±1 de corte y factores `/2` o
  `*2`.
- **Agujeros horizontales** en la orientación de impresión: con `agujero_gota()` (forma de gota).
  **Hexágonos horizontales**: con un vértice hacia arriba.
- **Convención de ejes del conjunto** (research.md):
  - El origen está en la cara de apoyo de la base.
  - Z es vertical, y el eje de azimut coincide con Z.
  - El eje de altura es paralelo a X, a una altura `z_eje_altura`.
  - A 0° de altura el láser apunta hacia +Y.
  - Los motores van en +X y la electrónica en −X.
- **«Medir caja»** (caja envolvente de un STL ASCII):
  `python3 -c "import sys,re;v=[tuple(map(float,m)) for m in re.findall(r'vertex\s+(\S+)\s+(\S+)\s+(\S+)',open(sys.argv[1]).read())];print(*[round(max(c)-min(c),2) for c in zip(*v)])" <archivo.stl>`
- **«Render limpio»**: `.tools/bin/openscad --hardwarnings -o <salida> <archivo>`. Exige código 0 y
  ninguna línea `WARNING:` ni `ERROR:`.

---

## Fase 0: Preparación

**Propósito**: confirmar el entorno antes de modelar.

- [X] T001 Verificar `.tools/bin/openscad --version` (2021.01) y `python3 --version`, confirmar con `git branch --show-current` que se está en `002-puntero-laser-estelar` y comprobar que existen `src/`, `exports/` y `docs/`. Si OpenSCAD falta, reinstalarlo según «Requisitos previos» de specs/001-soporte-pared-taladro/quickstart.md.

---

## Fase 1: Diseño paramétrico (`src/puntero_laser_*.scad`)

**Propósito**: escribir los 12 `.scad` y cerrar la Puerta 1.

### Fundacional: `src/puntero_laser_parametros.scad` (bloquea a todas las piezas)

**⚠️ CRÍTICO**: ninguna pieza empieza hasta completar T002 a T008. Todas editan el mismo archivo y van
en orden.

- [X] T002 Crear src/puntero_laser_parametros.scad con el encabezado estándar (`Componente: Parámetros compartidos`) y `// --- PARÁMETROS Y CONSTANTES ---`. Declarar los parámetros públicos de la **Entidad 1** de data-model.md con sus grupos del Customizer y los valores y rangos **exactos** de la tabla:
  - **`/* [Componentes comprados] */`**: `diametro_laser = 30; // [20:0.5:40]`, `largo_laser = 190; // [120:1:260]`, `distancia_trasera_centro_masa = 95; // [48:1:156]`, `masa_laser_g = 180; // [80:5:400]`, `powerbank_largo = 100; // [60:1:150]`, `powerbank_ancho = 65; // [40:1:75]`, `powerbank_alto = 25; // [10:1:30]`, `esp32_largo = 55; // [48:0.5:60]`, `esp32_ancho = 28; // [25:0.5:32]`, `rele_largo = 50; // [35:0.5:55]`, `rele_ancho = 26; // [17:0.5:30]`, `uln2003_largo = 35; // [30:0.5:42]`, `uln2003_ancho = 32; // [20:0.5:35]`, `altura_placas = 18; // [10:1:25]`.
  - **`/* [Transmisión] */`**: `dientes_polea_conducida = 80; // [80:1:100]` (el mínimo de 80 garantiza la relación ≥ 1:4 de FR-005), `largo_correa = 200; // [160:2:240]`, `ancho_correa = 6; // [6:1:9]`, `recorrido_tensor = 3; // [2:0.5:6]`, `ajuste_diente_gt2 = 0; // [-0.15:0.01:0.15]`.
  - **`/* [Holguras] */`**: `holgura_encastre = 0.25; // [0.1:0.05:0.5]`, `holgura_tornillo_m3 = 0.3; // [0.1:0.05:0.6]`, `holgura_tuerca = 0.2; // [0.1:0.05:0.4]`, `holgura_perno_m8 = 0.4; // [0.2:0.05:0.8]`, `ajuste_608 = 0.10; // [-0.1:0.01:0.3]`, `holgura_barrido = 8; // [5:1:20]`.
  - **`/* [Estructura] */`**: `espesor_plataforma = 4; // [3:0.5:6]`, `espesor_brazo = 10; // [10:0.5:14]`, `ancho_brazo = 36; // [30:1:45]`, `pared_tubo_cuna = 3; // [2:0.5:4]`, `largo_tubo_cuna = 100; // [70:1:140]`, `holgura_colimacion = 2; // [1:0.25:3]`, `separacion_608_azimut = 16; // [10:1:30]`, `diametro_apoyo_tripode = 72; // [60:1:90]`, `con_contrapeso = true;`, `con_ventana_pulsador = true;`.
  - **`/* [Calidad] */`**: `$fn = 64; // [24:8:128]`.

  Cada parámetro lleva un comentario breve en español. Los de componentes comprados agregan «medir el ejemplar real».
- [X] T003 En src/puntero_laser_parametros.scad, añadir `/* [Hidden] */` con las **constantes de componentes estándar** de la Entidad 2 de data-model.md, con estos nombres y valores:
  - **608ZZ**: `rod608_d_ext = 22; rod608_d_int = 8; rod608_ancho = 7; rod608_d_aro_int = 12.1;`.
  - **M8**: `m8_cabeza_ec = 13; m8_cabeza_alto = 5.3; m8_tuerca_ec = 13; m8_autoblocante_alto = 8;`.
  - **M3**: `m3_tuerca_ec = 5.5; m3_tuerca_alto = 2.4; m3_cabeza_d = 5.5;`.
  - **3/8"-16**: `tuerca_3_8_ec = 14.29; tuerca_3_8_alto = 8.33; rosca_3_8_d = 9.525;`.
  - **28BYJ-48**: `motor_d_cuerpo = 28; motor_alto_cuerpo = 19; motor_entre_orejas = 35; motor_d_agujero_oreja = 4.2; motor_d_oreja = 7; motor_desplazamiento_eje = 8; motor_d_resalte = 9; motor_alto_resalte = 1.5; motor_largo_eje = 9.5; motor_tapa_ancho = 17; motor_tapa_saliente = 3;`.
  - **Polea 20T**: `dientes_polea_motriz = 20; polea20_d_brida = 18; polea20_alto_total = 16; polea20_alto_cubo = 7; polea20_d_cubo = 13; polea20_espesor_brida = 1;`.
  - **GT2**: `paso_gt2 = 2; profundidad_diente_gt2 = 0.75; pld_gt2 = 0.254; radio_hueco_gt2 = 0.555;`.
  - **Relación del motor**: `relacion_motor = (32/9)*(22/11)*(26/9)*(31/10); medios_pasos_motor = 64;`.
  - **Constantes internas de diseño**: `espesor_carro = 3; piso_munon = 2.2; holgura_munon_brazo = 0.5; labio_608 = 3; d_contacto_aro = 11; altura_libre_central = 5; espesor_min_pared = 1.2; eps = 0.01; cama_max = 200; plataforma_max = 196; holgura_zonas = 2; altura_max_canal = 4; pared_canal = 1.6; ancho_canal = 8; d_interruptor = 6.2; pared_max_interruptor = 4; distancia_min_cable_correa = 5;`.
  - **Pares (R9)**: `par_motor_mNm = 34; rendimiento_correa = 0.9; g_gravedad = 9.81;`.

  **Masas para R9**, en gramos: `masa_powerbank_g = 200; masa_motor_g = 35; masa_placas_g = 45; masa_cuna_g = 60;`.
- [X] T004 En src/puntero_laser_parametros.scad, añadir los **valores derivados** de la Entidad 3 de data-model.md con estas fórmulas literales:
  - **Poleas**: `d_primitivo_motriz = dientes_polea_motriz*paso_gt2/PI;`, `d_primitivo_conducida = dientes_polea_conducida*paso_gt2/PI;` y `d_exterior_conducida = d_primitivo_conducida - 2*pld_gt2;`.
  - **Distancia entre centros**: `function largo_correa_abierta(c) = let(dd = d_primitivo_conducida - d_primitivo_motriz, fi = asin(dd/(2*c))) 2*c*cos(fi) + PI*(d_primitivo_motriz + d_primitivo_conducida)/2 + dd*fi*PI/180;` y `function biseccion_centros(a, b, n) = n == 0 ? (a+b)/2 : (largo_correa_abierta((a+b)/2) > largo_correa ? biseccion_centros(a, (a+b)/2, n-1) : biseccion_centros((a+b)/2, b, n-1));`, con `distancia_centros = biseccion_centros(20, 200, 60);`. Debe dar 45,97 ± 0,05 con los valores por defecto.
  - **Pasos**: `relacion_correa = dientes_polea_conducida/dientes_polea_motriz;`, `pasos_por_vuelta_eje = relacion_motor*medios_pasos_motor*relacion_correa;`, `pasos_por_grado = pasos_por_vuelta_eje/360;` y `grados_por_paso = 360/pasos_por_vuelta_eje;`.
  - **Cuna y horquilla**: `diametro_interior_cuna = diametro_laser + 2*holgura_colimacion;`, `radio_exterior_cuna = diametro_interior_cuna/2 + pared_tubo_cuna;` `largo_munon = m8_cabeza_alto + holgura_tuerca - pared_tubo_cuna + piso_munon;` (derivado, así el piso que retiene la cabeza M8 nunca baja de `piso_munon` para ningún valor del rango; 4,7 mm por defecto) y `semiancho_interior_horquilla = radio_exterior_cuna + largo_munon + holgura_munon_brazo;` (25,2 mm por defecto).
  - **Barrido y altura del eje**: `l_trasero = distancia_trasera_centro_masa;`, `l_delantero = largo_laser - l_trasero;`, `radio_barrido = max(l_trasero, l_delantero) + diametro_laser/2*sin(5);`, `altura_eje = radio_barrido + holgura_barrido + altura_libre_central;` y `alto_brazo = altura_eje + rod608_d_ext/2 + 6;`.
  - **Motor de altura**: `alto_pilar_motor = motor_alto_cuerpo + 2;`.
  - **Plano de la correa de altura** (cotas X del lado del motor): `x_cara_ext_brazo = semiancho_interior_horquilla + espesor_brazo;`, `x_cara_int_carro_alt = x_cara_ext_brazo + alto_pilar_motor;`, `x_inicio_cubo20_alt = x_cara_int_carro_alt + espesor_carro;`, `plano_correa_altura = x_inicio_cubo20_alt + polea20_alto_cubo + polea20_espesor_brida + ancho_correa/2 + 0.5;` y `largo_cubo_polea_altitud = plano_correa_altura - ancho_correa/2 - 0.5 - polea20_espesor_brida - x_cara_ext_brazo;`.
  - **Eje dentro del cubo de la 20T** (los dos ejes): `eje_en_cubo20 = motor_largo_eje - espesor_carro;` (el resalte queda dentro del agujero del carro; 6,5 mm por defecto).
  - **Plano de la correa de azimut**, relativo a la cara inferior de la plataforma: `dz_correa_azimut = -(polea20_alto_cubo - espesor_plataforma) - polea20_espesor_brida - ancho_correa/2 - 0.5;`.
  - **Separador**: `largo_separador_azimut = separacion_608_azimut - 0.1;` (la precarga se logra porque mide 0,1 mm menos que el resalte).

  Las dimensiones de la plataforma (`largo_plataforma`, `ancho_plataforma`) y las zonas de R5 se derivan como listas de rectángulos `[x0, y0, x1, y1, altura, "nombre"]`:
  - `zona_powerbank`: power bank de pie, en la columna exterior de −X.
  - `zona_esp32`: en la columna exterior de −X, en el tramo de Y que no ocupa el power bank.
  - `zona_rele`, `zona_uln_azimut`, `zona_uln_altura`: en la columna interior de −X.
  - `zona_motor_azimut`: en +X, con el cuerpo centrado en `distancia_centros + motor_desplazamiento_eje`.
  - `zona_brazo_motor`, `zona_brazo_cable`.
  - `zona_barrido`: `|X| < semiancho_interior_horquilla`.
  - `zona_sobrante_cables`: hueco de al menos 40 × 25 mm en el lado −X, bajo la tapa, para enrollar el cable sobrante (FR-012).

  `largo_plataforma` y `ancho_plataforma` salen de la envolvente de las zonas más un borde de 4 mm.
- [X] T005 En src/puntero_laser_parametros.scad, escribir los **módulos utilitarios compartidos** (no dibujan nada al abrir el archivo solo):
  - `dentado_gt2(dientes, alto)`: un `cylinder(d = dientes*paso_gt2/PI - 2*pld_gt2, h = alto)` menos `dientes` huecos. Cada hueco es un `cylinder(r = radio_hueco_gt2 + ajuste_diente_gt2, h = alto + 2)` centrado a un radio `dientes*paso_gt2/PI/2 - pld_gt2 + radio_hueco_gt2 - profundidad_diente_gt2`, con redondeo de entrada (R3).
  - `pestanas_polea(d_ext, alto_dentado)`: una pestaña inferior de 1 mm de espesor con Ø `d_ext + 2` y una superior con chaflán de 45° por debajo, imprimible sin soportes.
  - `agujero_gota(d, largo)`: agujero horizontal en forma de gota para imprimir sin soportes.
  - `alojamiento_hex(ec, alto)`: prisma hexagonal de `ec + holgura_tuerca` entre caras.
  - `ranura(d, largo, alto)`: agujero alargado, para las ranuras del tensor.
- [X] T006 En src/puntero_laser_parametros.scad, añadir `// --- VALIDACIÓN DE PARÁMETROS ---` con los `assert(condición, mensaje)` de data-model.md, **en este orden**:
  - **V-01**: un assert por parámetro editable con `is_num(p) && p >= mín && p <= máx` (rangos de T002). Mensaje: `str("<nombre>=", valor, ": fuera de rango [mín, máx]")`.
  - **V-02**: `distancia_trasera_centro_masa >= 0.4*largo_laser && distancia_trasera_centro_masa <= 0.6*largo_laser`.
  - **V-03**: `largo_plataforma <= plataforma_max && ancho_plataforma <= plataforma_max`.
  - **V-04**: `alto_brazo <= plataforma_max`.
  - **V-05**: `distancia_centros - motor_desplazamiento_eje - motor_d_cuerpo/2 >= d_exterior_conducida/2 + 2`.
  - **V-06**: `distancia_centros >= (d_exterior_conducida + polea20_d_brida)/2 + 3`.
  - **V-10**: `eje_en_cubo20 >= 5`.
  - **V-11**: `min(todas las holguras) > 0`; `espesor_brazo >= rod608_ancho + labio_608` (el 608 y su labio entran en el brazo); y cada espesor mínimo de la lista de T025 es `>= espesor_min_pared`. El piso del muñón no necesita assert: vale `piso_munon` por construcción.
  - **V-12**: `atan(2*holgura_colimacion/(largo_tubo_cuna - 8)) >= 1`.
  - **V-13**: `abs(x_centro_masa_plataforma) <= 20`, con `echo` de aviso si > 5 y `con_contrapeso == false`.
  - **V-14**: `separacion_608_azimut + 2*rod608_ancho >= 20`.

  V-08 (las zonas no se solapan y caben con `holgura_zonas`) se comprueba aquí de forma analítica, recorriendo los pares de rectángulos de T004. V-07 y V-09 se completan en el ensamblaje (T019).

  Cada mensaje **empieza** por el parámetro principal implicado:
  - V-02 → `distancia_trasera_centro_masa=`.
  - V-03 → `powerbank_largo=` o el componente que define la envolvente.
  - V-04 → `largo_laser=`.
  - V-05 y V-06 → `largo_correa=`.
  - V-08 → `<componente>_ancho=`.
  - V-10 → `espesor_plataforma=`.
  - V-11 (brazo) → `espesor_brazo=`; V-11 (paredes) → el parámetro que define esa pared.
  - V-12 → `holgura_colimacion=`.
  - V-14 → `separacion_608_azimut=`.

  Después del parámetro, el mensaje explica el problema, da el límite numérico y sugiere qué ajustar. Ejemplo del contrato: `"powerbank_ancho=80: no entra en la zona −X (máx. 75); reduzca el ancho o use un power bank más delgado"`.
- [X] T007 [US4] En src/puntero_laser_parametros.scad, calcular la masa y el centro de masa de la plataforma: `x_centro_masa_plataforma` a partir de las masas de T003, `masa_laser_g` y las posiciones de las zonas (R9). Calcular también el **presupuesto de error** de la Entidad 7 como lista `[fuente, grados]` con los valores de research.md R4:
  - Resolución: `grados_por_paso`, en cada eje.
  - Repetibilidad de la caja: 0,1, en cada eje.
  - Correa: 0,1, en cada eje.
  - Inclinación: 0,1.
  - Perpendicularidad: 0,25.
  - Colimación: 0,2.
  - Alineación: 0,3.
  - Flexión: 0,01.
  - Hora: 0,05.

  Calcular también los **pares del eje de altura** de research.md R9 (FR-024): `par_disponible_mNm = par_motor_mNm*relacion_correa*rendimiento_correa`, `par_desbalance_10_mNm = (masa_laser_g + masa_cuna_g)/1000*g_gravedad*10` y `par_desbalance_20_mNm` (con 20 mm), cada uno con su factor de seguridad. Emitir `ECHO: "PARES disponible=…, desbalance_10=…, fs_10=…, desbalance_20=…, fs_20=…"` y un `echo` de aviso si `fs_10 < 3`. Es un aviso, no un assert, porque depende del equilibrado real.

  Con eso calcular `error_rss` (raíz de la suma de cuadrados) y `error_peor_caso` (suma lineal), con `assert(error_peor_caso < 2, ...)`. Emitir con `echo` las líneas `ECHO: "FIRMWARE pasos_por_grado=…, grados_por_paso=…, pasos_por_vuelta_eje=…"` y `ECHO: "DISEÑO distancia_centros=…, altura_eje=…, alto_brazo=…, plano_correa_altura=…, largo_cubo_polea_altitud=…, plataforma=…x…, x_centro_masa=…, masa_estimada_g=…"`, además de `ECHO: "ERROR rss=…, peor_caso=…"`.
- [X] T008 Comprobar el Escenario 1 de quickstart.md con `.tools/bin/openscad -o "$TMPDIR/parametros.echo" src/puntero_laser_parametros.scad`. Debe terminar con código 0, y los `ECHO` deben dar:

  | Valor | Esperado |
  |-------|----------|
  | `distancia_centros` | 45,97 ± 0,05 |
  | `pasos_por_grado` | 45,286 ± 0,001 |
  | `altura_eje` | ≈ 110 |
  | `error_rss` | ≤ 1 |
  | `error_peor_caso` | < 2 |
  | `plataforma` | ≤ 196 × 196 |

  Si OpenSCAD exige geometría para `-o` con extensión `.echo`, usar `-o "$TMPDIR/p.echo"` (2021.01 lo admite). Corregir hasta que se cumpla todo.

**Punto de control**: el archivo de parámetros se evalúa sin errores y con los valores esperados.
Desde aquí, T009 a T017 editan **archivos distintos** y pueden ir en paralelo.

### Piezas (US1 y US2)

- [X] T009 [P] [US2] Crear src/puntero_laser_probeta_ajuste_608.scad (R6, riesgo 1 del plan). `pieza_probeta_ajuste_608()` es una tira plana de 5 anillos de 8 mm de alto, con alojamiento `rod608_d_ext + a` para `a` en `[-0.1, 0, 0.1, 0.2, 0.3]`, paredes de 2,4 mm y el valor de `a` grabado en relieve con `text()` a 0,6 mm de altura sobre una pestaña. La caja debe ser ≤ 150 × 40 mm.
- [X] T010 [P] [US1] Crear src/puntero_laser_carro_motor.scad (R8, U-05, U-06). `pieza_carro_motor()` es una placa de `espesor_carro` en el plano XY:
  - **Origen**: en el eje del motor.
  - **Cuerpo del motor**: centrado en `(motor_desplazamiento_eje, 0)`. +X apunta hacia afuera, lejos de la polea conducida.
  - **Agujeros**: agujero pasante `motor_d_resalte + 2*holgura_encastre` en el origen, y 2 agujeros autorroscantes Ø 2,6 (85 % de M3) en `(motor_desplazamiento_eje, ±motor_entre_orejas/2)`.
  - **Ranuras de fijación**: 2 ranuras `ranura(3 + holgura_tornillo_m3, 2*recorrido_tensor)` a lo largo de X. Una antes del cuerpo y otra después del cuerpo y de la tapa de cables, con al menos 2 mm entre la cabeza M3 y el contorno del motor más la tapa. Calcular sus posiciones con constantes derivadas, no con literales.
  - **Tensor**: cara de empuje plana en el extremo −X, donde apoya la punta del tornillo M3 del tope tensor.
  - **Simetría**: la pieza debe poder usarse por las dos caras. En azimut las orejas van arriba; en altura van del lado de los pilares.
- [X] T011 [P] [US1] Crear src/puntero_laser_separador_azimut.scad (R6, U-03). `pieza_separador_azimut()` contiene, uno al lado del otro y separados 5 mm:
  - El **separador**: tubo Ø ext `d_contacto_aro + 0.5`, Ø int `rod608_d_int + holgura_perno_m8` y alto `largo_separador_azimut`.
  - **3 arandelas de contacto**: Ø ext `d_contacto_aro`, Ø int 8,4 y 2 mm de alto. Una va entre el cubo de la plataforma y el aro interior superior, otra entre la autoblocante y el aro interior inferior, y otra en el eje de altura del lado del cable.

  Las arandelas apoyan **solo** en el aro interior (`d_contacto_aro < rod608_d_aro_int`).
- [X] T012 [P] [US1] Crear src/puntero_laser_adaptador_tripode.scad (R6, U-01, U-02). `pieza_adaptador_tripode()` va con la cara de apoyo sobre la cama. Partes, de abajo hacia arriba:
  1. **Cuerpo**: Ø `diametro_apoyo_tripode`, con chaflán de 1 mm en la base.
  2. **Agujero del trípode**: Ø `rosca_3_8_d + 0.6`, a través de un piso de 4 mm.
  3. **Tuerca 3/8"**: `alojamiento_hex(tuerca_3_8_ec, tuerca_3_8_alto + 0.2)` **abierto hacia arriba**, apoyado sobre el piso.
  4. **Cámara**: Ø 26 desde la cara superior de la tuerca, con 6 mm libres para la punta del tornillo del trípode y espacio para `m8_autoblocante_alto`, una arandela de contacto de 2 mm y 2 mm de rosca sobrante. Tiene una **ventana lateral** de 24 mm de ancho × la altura de la cámara, con techo en arco o chaflán de 45° para imprimir sin soportes, para meter una llave de 13 mm y el 608 inferior.
  5. **608 inferior**: alojamiento Ø `rod608_d_ext + ajuste_608` y `rod608_ancho` de profundidad, abierto hacia la cámara.
  6. **Resalte central**: de alto `separacion_608_azimut` y agujero Ø 16, que apoya los aros exteriores y deja pasar el separador.
  7. **608 superior**: alojamiento de `rod608_ancho` de profundidad, enrasado con la cara superior.
  8. **Polea fija de azimut**: `dentado_gt2(dientes_polea_conducida, ancho_correa + 1)` + `pestanas_polea`, centrada en Z en el plano de la correa de azimut. Ese plano queda a `dz_correa_azimut` de la cara inferior de la plataforma, y la cara inferior de la plataforma queda 2 mm por encima de la cara superior de la base. Calcular `z_tope_base` y exponerlo con `echo` para el ensamblaje.

  Entre el dentado y el cuerpo de Ø `diametro_apoyo_tripode`, un cono a 45°. El cuerpo ancho debe quedar por debajo de `z_plano_correa_azimut - polea20_alto_total/2 - 3`, con un `assert` que compruebe que no toca la polea 20T del motor de azimut, situada a `distancia_centros`. Por el diámetro del dentado, esta es la pieza más pesada de renderizar.
- [X] T013 [P] [US1] Crear src/puntero_laser_polea_altitud.scad (R8, U-09). `pieza_polea_altitud()` va con el cubo hacia arriba:
  - **Dentado**: `dentado_gt2(dientes_polea_conducida, ancho_correa + 1)` + `pestanas_polea` en la base.
  - **Tuerca M8**: en la cara de abajo (la exterior en el conjunto), `alojamiento_hex(m8_tuerca_ec, m8_autoblocante_alto)`, que funciona como chaveta.
  - **Cubo**: Ø 14 de largo `largo_cubo_polea_altitud` (T004), terminado en un anillo de contacto Ø `d_contacto_aro` × 0,5 mm.
  - **Agujero**: pasante Ø `rod608_d_int + holgura_perno_m8`.
  - **Aligerado**: 6 agujeros de aligerado en el disco si `d_exterior_conducida > 45`, con 4 mm de material como mínimo.
- [X] T014 [P] [US2] Crear src/puntero_laser_cuna_laser.scad (R7, U-08, U-10). `pieza_cuna_laser()` va de pie, con el eje del tubo sobre Z y el láser en el ensamblaje a lo largo de +Y:
  - **Tubo**: Ø int `diametro_interior_cuna`, pared `pared_tubo_cuna`, alto `largo_tubo_cuna`.
  - **Anillos de colimación**: en cada extremo, a 4 mm del borde, un engrosamiento anular de 6 mm de alto con **3 agujeros radiales M3 a 120°**, cada uno con `alojamiento_hex(m3_tuerca_ec, m3_tuerca_alto + 0.4)` embebido en la pared (ranura de inserción desde arriba). Los dos anillos van girados 60° entre sí.
  - **Muñones**: a media altura, en ±X, con forma de gota para imprimir sin soportes. Ocupan de `radio_exterior_cuna` a `semiancho_interior_horquilla - holgura_munon_brazo`. Cada uno tiene un **hexágono para la cabeza M8** (`m8_cabeza_ec`, profundidad `m8_cabeza_alto + holgura_tuerca`) abierto hacia el interior del tubo, el agujero Ø 8,4 y, en la cara exterior, un anillo de contacto Ø `d_contacto_aro` que sobresale `labio_608 + holgura_munon_brazo` para alcanzar el aro interior a través del labio del brazo.
  - **Pulsador**: si `con_ventana_pulsador`, una ventana de 16 × 12 mm en +Z del conjunto, a 25 mm del centro.
  - **Cable**: ranura de 3 × 5 mm para los 2 hilos junto al muñón del lado −X.

  El piso del muñón queda en `piso_munon` (2,2 mm) por construcción, porque `largo_munon` es derivado (T004). Comprobarlo en la vista de corte.
- [X] T015 [P] [US1] Crear src/puntero_laser_brazo_horquilla.scad (R2, R8, U-04, U-07), con el parámetro propio `lado = "motor"; // ["motor", "cable"]`. `pieza_brazo_horquilla(lado)` se modela en orientación de impresión: cara interior sobre la cama, largo del brazo sobre +Y de impresión (= Z del conjunto), ancho `ancho_brazo` sobre X y espesor `espesor_brazo` sobre Z de impresión. Partes:
  - **Rodamiento**: alojamiento 608 desde la cara exterior (arriba en impresión), Ø `rod608_d_ext + ajuste_608` y `rod608_ancho` de profundidad, con labio interior de `labio_608` y agujero Ø 16, centrado a `altura_eje` del pie. Contorno redondeado alrededor.
  - **Pie**: en el extremo inferior, 2 agujeros M3 a lo largo del brazo (dirección Y de impresión, con `agujero_gota`) en ±10 mm, con ranura de tuerca M3 abierta hacia la cara superior a 6 mm del extremo. Lleva una **cartela exterior** triangular de 15 mm (pendiente de 45°, sin soportes) con un tercer M3.
  - **Solo `lado == "motor"`**: 2 **pilares** de `alto_pilar_motor` sobre la cara exterior, en las posiciones de las ranuras del carro (T010). El carro queda con su eje a `distancia_centros` por debajo del eje del 608, y su +X apunta hacia el pie. Cada pilar lleva una ranura de tuerca M3 lateral. Hay además un **tope tensor**: un bloque con un M3 pasante a lo largo del brazo y una tuerca embebida, que empuja la cara −X del carro. Agregar un canal para el cable del motor a lo largo de la cara exterior hasta el pie.
  - **Solo `lado == "cable"`**: un agujero Ø 4 que atraviesa el brazo a `altura_eje - 22`, y un canal de 3 × 2,5 mm en la cara exterior hasta el pie, con 3 resaltes de retención.

  `assert(alto_brazo <= cama_max)`.
- [X] T016 [US1] Crear src/puntero_laser_plataforma_azimut.scad (R5, R6, R11, U-03, U-04, U-06, U-11, U-12). Depende de T010, T014 y T015 por sus cotas, aunque solo usa derivados del archivo de parámetros. `pieza_plataforma_azimut()` va con la cara inferior sobre la cama y mide `largo_plataforma × ancho_plataforma × espesor_plataforma`, con esquinas redondeadas y un nervio perimetral de 6 mm en la cara superior fuera de `zona_barrido`. Partes:
  - **Cubo central**: hexágono `m8_cabeza_ec` × `m8_cabeza_alto + 0.3` desde arriba (la cabeza queda **enrasada**), agujero Ø 8,4 y engrosamiento inferior hasta `m8_cabeza_alto + 2` de espesor total, que sobresale **hacia arriba** si hace falta, nunca más de `altura_libre_central`.
  - **Rebajes de los brazos**: 2 rebajes de 2 mm de profundidad en `zona_brazo_motor` y `zona_brazo_cable`, con la holgura de encastre, y los 3 agujeros M3 pasantes con avellanado de cabeza por debajo.
  - **Azimut**: asiento del carro en `zona_motor_azimut`, con 2 hexágonos M3 abiertos hacia abajo bajo las ranuras del carro. **Abertura** para la polea de azimut: ranura Ø `polea20_d_brida + 3` alargada ± `recorrido_tensor` en X, centrada en `(distancia_centros, 0)`. **Tope tensor**: bloque con M3 horizontal y tuerca.
  - **Power bank**: bolsillo `zona_powerbank` con paredes de 2 mm y 30 mm de alto, con hueco para el conector USB en el extremo.
  - **Interruptor general (FR-013)**: agujero Ø `d_interruptor` en la pared del extremo del bolsillo opuesto al USB, a 15 mm de altura. La pared mide ≤ `pared_max_interruptor` en ese punto para que entre la rosca del interruptor. Se monta en la plataforma, no en la tapa, para que quitar la tapa no tire de los cables.
  - **Placas**: soportes de encastre con labio (U-12) para el ESP32, el relé y los 2 ULN2003, dimensionados desde los parámetros + `holgura_encastre`.
  - **Canal de cables (U1, FR-012, FR-021)**: **conducto elevado** sobre la cara superior. **No** se rebaja la placa, que conserva todo `espesor_plataforma` de piso. Tiene paredes de `pared_canal`, ancho interior `ancho_canal` y altura total ≤ `altura_max_canal` (< `altura_libre_central`). Cruza `zona_barrido` en Y = −30, lejos del cubo, y no pasa sobre la abertura de la polea de azimut.
  - **Sujeción de cables**: puentes para brida de 3 mm cada ≤ 40 mm a lo largo de los recorridos de R11, y el hueco `zona_sobrante_cables` libre de soportes de placas, para el cable sobrante (FR-012).
  - **Tapa**: guías y 2 hexágonos M3 para fijarla.
  - **Contrapeso**: si `con_contrapeso`, un alojamiento en +X para 4 tuercas M8 apiladas.

  Re-evaluar V-03 y V-08.
- [X] T017 [US1] Crear src/puntero_laser_tapa_electronica.scad (R5, U-11). `pieza_tapa_electronica()` va con el techo sobre la cama. Es una cáscara abierta por abajo que cubre `zona_powerbank`, `zona_esp32`, `zona_rele` y las dos `zona_uln_*`, con 2 mm de pared y una altura interior de `max(powerbank_ancho, altura_placas) + 5`. Lleva:
  - Rejillas de ventilación en las paredes verticales: ranuras de 2 × 15 mm a 45°, que no dejan pasar agua que cae vertical (FR-014).
  - Una abertura USB alineada con la del bolsillo, un recorte para la palanca del interruptor general (T016) y una entrada para los cables desde el brazo del cable y el canal.
  - Encastres en las guías de T016 y 2 orejas M3.

  Debe medir ≤ 200 × 200 en planta.

### Ensamblaje y comprobaciones (US1, US2 y US3)

- [X] T018 [US1] Crear src/puntero_laser_ensamblaje.scad. Hace `include <puntero_laser_parametros.scad>` y `use <…>` de los 9 archivos de pieza, y tiene el parámetro de vista previa `angulo_altura = 45; // [-10:1:95]`. En `ensamblaje_principal()`:
  - **Coloca cada pieza** en su posición del conjunto con la convención de ejes: base en el origen, plataforma, brazos girados desde la orientación de impresión, cuna en el eje de altura girada `angulo_altura`, polea de altura, 2 carros (uno sobre la plataforma y otro sobre los pilares), separador y arandelas, y tapa (con `%` para ver a través).
  - **Dibuja los componentes comprados** como volúmenes simplificados de color: 28BYJ-48 (cuerpo, tapa y eje), poleas 20T, correas (con `hull` de dos círculos menos el interior), 608ZZ, perno M8, ESP32, relé, ULN2003, power bank y láser (cilindro `diametro_laser` × `largo_laser` con el centro de masa en el eje). Dibuja el láser **fantasma** a −10° y a 95° con `%`.
- [X] T019 [US1] En src/puntero_laser_ensamblaje.scad, añadir los asserts de choque analíticos:
  - **V-07**: para `a` en `[-10:1:95]`, los extremos del láser y las esquinas del tubo de la cuna en el plano YZ mantienen una Z ≥ `cara superior de la plataforma + altura_libre_central` y no entran en el rectángulo del cubo central.
  - **V-08**: repetir la comprobación de las zonas.
  - **V-09**: `abs(z_dentado_base - z_dientes_polea20_azimut) <= 0.5` y `abs(x_dentado_polea_altitud - x_dientes_polea20_altura) <= 0.5`.
  - **Separación entre piezas**: las cotas de contacto entre piezas (muñón ↔ aro interior, cubo de polea ↔ aro interior, plataforma ↔ base con 2 mm) dan holguras > 0.
  - **Cables lejos de las correas (FR-012)**: `plano_correa_altura - ancho_correa/2 - polea20_espesor_brida - x_cara_ext_brazo >= distancia_min_cable_correa`, porque el canal del motor de altura va por la cara exterior del brazo. Además, el conducto de la plataforma no se solapa con la abertura de la polea de azimut, con ≥ `distancia_min_cable_correa` de borde a borde.
  - **Conducto elevado**: `altura_max_canal < altura_libre_central`, que se incluye en V-07.
  - **Presupuesto de error**: `echo` del presupuesto.
- [X] T020 [US1] Comprobar la Puerta 1 (Escenario 2 del quickstart, todavía con salida en `$TMPDIR`):
  - «Render limpio» de las 8 piezas simples y de las 2 variantes del brazo (`-D 'lado="motor"'` y `-D 'lado="cable"'`).
  - Escenario 4: `.tools/bin/openscad --hardwarnings --imgsize=1600,1200 --viewall --autocenter -o "$TMPDIR/ensamblaje.png" src/puntero_laser_ensamblaje.scad`, con código 0. Revisar la imagen con `Read` y repetir con `-D angulo_altura=95` y `-D angulo_altura=-10`.
  - Anotar el tiempo de render de cada pieza: el objetivo es < 2 min.

  Corregir los `.scad` hasta que todo pase.
- [X] T021 [US1] Comprobar con «medir caja» (Escenario 3) que cada STL de `$TMPDIR` mide ≤ 200 en X e Y, y que la plataforma mide ≤ 196 × 196. Revisar la imprimibilidad sin soportes (FR-020, SC-001) con un fragmento de `python3` que liste las facetas con `n_z < -0.72` por encima de Z = 0,3 en cada STL. Las únicas facetas admitidas son las de los puentes cortos ≤ 10 mm: techos de los hexágonos, de las ranuras de tuerca y de la ventana de la base si tiene techo plano. Como máximo una pieza puede necesitar soportes y debe quedar anotada para la guía. Corregir la geometría si hace falta.
- [X] T022 [P] [US2] Comprobar los mecanismos de precisión con los `ECHO` y el ensamblaje:
  - V-09: planos de la correa alineados ± 0,5.
  - V-10: ≥ 5 mm de eje dentro de la polea.
  - V-12: corrección de colimación ≥ 1°.
  - V-14: separación de los 608 ≥ 20.
  - `error_peor_caso < 2` y `error_rss ≤ 1`.
  - El tensor de cada eje tiene ± `recorrido_tensor` de carrera libre en el ensamblaje.
  - El equilibrado se logra deslizando el láser: el tubo deja al menos ± 20 mm de juego axial del láser respecto de su centro de masa.

  Anotar los valores para la guía.
- [X] T023 [P] [US3] Ejecutar el Escenario 5 de quickstart.md (variante `diametro_laser=26 largo_laser=240 distancia_trasera_centro_masa=110 powerbank_largo=140 powerbank_ancho=70 powerbank_alto=16`) sobre **todas** las piezas y el ensamblaje, con salida en `$TMPDIR`. Comprobar:
  - Renders limpios.
  - Interior de la cuna Ø 30.
  - `altura_eje` ≈ 145 en el `ECHO`.
  - Bolsillo y tapa agrandados.
  - Cajas ≤ 200 × 200 (SC-007, FR-018, FR-022).
- [X] T024 [P] [US3] Ejecutar el Escenario 6 de quickstart.md: las 6 combinaciones inválidas sobre src/puntero_laser_plataforma_azimut.scad, borrando antes `$TMPDIR/inv.stl`. En cada caso se exige código ≠ 0, `ERROR: Assertion` con un mensaje que empieza por el parámetro esperado y que no se cree la salida (FR-019). Ajustar el orden o el texto de los asserts en src/puntero_laser_parametros.scad hasta que las 6 pasen.
- [X] T025 [US3] Revisar la interfaz pública según contracts/interfaz_generador.md §1.2:
  - Todos los parámetros públicos están **solo** en src/puntero_laser_parametros.scad, con anotación de rango y grupo.
  - Las piezas no redefinen parámetros públicos, salvo `lado` en el brazo y `angulo_altura` en el ensamblaje.
  - No hay literales dimensionales en los módulos. Comprobarlo con `grep -nE '^[a-z_$]+ *=' src/puntero_laser_*.scad` y una lectura de los módulos.
  - Cada `.scad` tiene el encabezado y las secciones obligatorias (Principio I).

  **Espesores mínimos (FR-021, C4)**: en src/puntero_laser_parametros.scad, definir la lista `espesores_minimos = [["nombre", valor], …]` con al menos estas entradas:
  - Pared del tubo de la cuna: `pared_tubo_cuna`.
  - Piso del muñón: `piso_munon`.
  - Pared del separador: `(d_contacto_aro + 0.5 - rod608_d_int - holgura_perno_m8)/2`.
  - Pared de las arandelas de contacto: `(d_contacto_aro - rod608_d_int - holgura_perno_m8)/2`.
  - Pared del cubo de la polea de altura: `(14 - rod608_d_int - holgura_perno_m8)/2`.
  - Labio del 608: `(rod608_d_ext - 16)/2`.
  - Pared alrededor de los alojamientos 608 de la base y los brazos.
  - Pared del alojamiento de la tuerca 3/8".
  - Pared de las ranuras de tuerca M3 de los pies y los pilares.
  - Paredes del bolsillo, la tapa y el conducto.
  - Espesor del carro.
  - Piso de la plataforma bajo los hexágonos M3.

  Comprobar con un assert (V-11) que todas las entradas son ≥ `espesor_min_pared`. Probar los extremos del rango con `-D pared_tubo_cuna=2 -D holgura_perno_m8=0.8 -D holgura_tuerca=0.4` sobre todas las piezas: deben renderizar o fallar con un mensaje claro de V-11.

  Actualizar data-model.md si se agregaron derivados o constantes, y anotarlo en «Notas de implementación».

**Punto de control (cierre de la Fase 1)**: T020 a T025 en verde. La Puerta 1 queda cumplida.

---

## Fase 2: Simulación FEA (no aplica, con justificación)

**Propósito**: cerrar la Puerta 2 sin simular, verificando que la justificación de research.md R10
sigue siendo válida con la geometría final (Principio III).

- [X] T026 [US2] Con los `ECHO` finales (`alto_brazo`, `masa_estimada_g`, `masa_laser_g`) y las secciones reales del brazo (`ancho_brazo × espesor_brazo`), recalcular en `python3` los 3 casos de research.md R10:
  - **Golpe lateral**: 5 N en la punta, σ = M/W con W = b·h²/6.
  - **Compresión**: 15 N de compresión, δ = F·L/(E·A).
  - **Carga lateral**: 1,5 N laterales, δ = F·L³/(3·E·I) y su ángulo en grados.

  Recalcular también los **pares del eje de altura** (FR-024) con el `ECHO: "PARES …"` de T007: factor de seguridad ≥ 3 con 10 mm de desbalance y ≥ 2 con 20 mm. Agregar esos valores a la tabla de justificación del plan. Usar E = 2000 MPa y σ admisible entre capas de 20 MPa. Criterio: factor de seguridad ≥ 10 y error angular < 0,1°. Si se cumple, actualizar la tabla de justificación de specs/002-puntero-laser-estelar/plan.md (Principio III) con los valores recalculados y la condición de validez (`masa_laser_g ≤ 400`, `alto_brazo ≤ 160`). Si **no** se cumple, volver a la Fase 1 (aumentar `espesor_brazo`) y, si aun así no alcanza, plantear la simulación FEM al usuario. No se crean archivos en `simulation/`.

**Punto de control (cierre de la Fase 2)**: la justificación está vigente y registrada. La Puerta 2
queda cumplida.

---

## Fase 3: Exportación (`exports/`)

**Propósito**: los 10 STL oficiales con los valores por defecto (Principio IV, Puerta 3).

- [X] T027 [US1] Generar los 10 STL con los comandos del Escenario 2 de quickstart.md (bucle de 8 piezas + 2 variantes del brazo) en `exports/puntero_laser_*.stl`, con «render limpio». **No** exportar el ensamblaje ni el archivo de parámetros. Verificar con `ls exports/puntero_laser_*.stl | wc -l` = 10.
- [X] T028 [US1] Para cada STL de exports/, anotar con `python3`, sin crear archivos en el repositorio: caja envolvente (Escenario 3, todas ≤ 200 × 200), número de facetas, volumen en cm³ (fórmula del tetraedro con signo) y masa estimada en PETG (ρ = 1,27 g/cm³). Calcular además la masa total impresa (el carro cuenta 2 veces) y compararla con la estimación de R9 (~420 g). Registrar `sha256sum src/puntero_laser_*.scad` para la guía, de modo que se pueda saber si los STL están vigentes.

**Punto de control (cierre de la Fase 3)**: la Puerta 3 queda cumplida.

---

## Fase 4: Documentación (`docs/puntero_laser_guia.md`)

**Propósito**: una única guía de producción según la plantilla B de .github/spec_kit_profile.md
(Principio V, Puerta 4). Todas las tareas editan el mismo archivo y van en orden.

- [X] T029 [US1] Crear docs/puntero_laser_guia.md con el título `# Guía de Producción: Puntero láser estelar motorizado`, una descripción breve, un diagrama ASCII del conjunto (base, plataforma, horquilla, cuna, correas, lado ±X) y la tabla de valores por defecto de los parámetros de componentes comprados. Añadir `## 1. Especificaciones de Impresión 3D` (FR-025, R13) con la **tabla de piezas impresas**: pieza, STL, cantidad, orientación, relleno, perímetros, soportes, adherencia y masa (de T028). Valores:
  - **Poleas** (base y polea de altura): 4 perímetros, 40 % de relleno giroide, capa de 0,16 mm en la zona del dentado.
  - **Brazos y cuna**: 4 perímetros y 30 % de relleno.
  - **Plataforma y tapa**: 3 perímetros y 20 % de relleno.
  - **Soportes**: No, salvo la excepción anotada en T021.
  - **Adherencia**: brim de 5 mm en la cuna, que va de pie.

  **Material**: PETG (230–245 °C de boquilla, 70–85 °C de cama). Indicar que **primero se imprime la probeta del 608** (paso de calibración F1) y que, si cambia `ajuste_608`, se regeneran **todos** los STL.
- [X] T030 [US1] En docs/puntero_laser_guia.md, añadir `## 2. Ensamblaje y Lista de Materiales (BOM)`:
  - **Herrajes**: la BOM completa de la Entidad 6 de data-model.md, con cantidades y medidas exactas (p. ej., `4 × Rodamiento 608ZZ`, `2 × Correa GT2 cerrada 200 mm × 6 mm`, `1 × Tuerca 3/8"-16 UNC`), con los largos de los pernos M8 confirmados con las cotas de T019. Incluir la electrónica y los consumibles.
  - **Orden de armado** paso a paso y cronológico, diciendo qué pieza va con cuál y con qué (skill §5.7):
    1. Prensar los 608 en la base: el superior desde arriba y el inferior a través de la ventana, tirando con el perno M8 y arandelas.
    2. Colocar la tuerca 3/8" en su alojamiento.
    3. Pernos M8 en los muñones de la cuna.
    4. 608 en los brazos.
    5. Brazos a la plataforma.
    6. Motores a los carros.
    7. Carro de azimut a la plataforma y polea 20T.
    8. Plataforma sobre la base: perno, arandela de contacto, separador, arandela y autoblocante desde la ventana, apretando hasta eliminar el juego sin frenar el giro.
    9. Correa de azimut y tensado.
    10. Cuna entre los brazos con las arandelas de ajuste.
    11. Polea de altura y autoblocante.
    12. Carro de altura en los pilares, correa y tensado.
    13. Electrónica en los soportes.
    14. Cableado por los canales.
    15. Tapa.
  - **Montaje en el trípode**: enroscar a mano, < 1 min (SC-006).
- [X] T031 [US2] En docs/puntero_laser_guia.md, añadir `## 3. Puesta a punto mecánica para la precisión`:
  - **Calibración del 608**: la probeta.
  - **Tensado de las correas**: deflexión de ~2 mm con un dedo en el centro del tramo.
  - **Equilibrado del láser**: deslizarlo en la cuna hasta que quede quieto a 0°, 45° y 90° con los motores sin energía (F4).
  - **Colimación**: procedimiento F7, girar el láser apuntando a 10 m y ajustar los 6 M3 hasta un círculo ≤ 44 mm.
  - **Presupuesto de error**: tabla de research.md R4 con los valores finales de T022.
  - **Par del eje de altura (FR-024)**: tabla con el par disponible tras la reducción, el par de desbalance con 10 mm y con 20 mm y sus factores de seguridad (de T026), y por qué hay que equilibrar el láser.
  - **Cuándo repetir el cálculo estructural**: si `masa_laser_g > 400` o `alto_brazo > 160` (T026).
- [X] T032 [US3] En docs/puntero_laser_guia.md, añadir `## 4. Adaptación a tus componentes`:
  - **Qué medir y cómo**: diámetro y largo del láser, **punto de equilibrio** (apoyarlo sobre un borde), medidas del power bank y de las placas.
  - **Cómo cambiar los parámetros**: Customizer o `-D`, con los comandos de contracts/interfaz_generador.md §1.3.
  - **Tabla de errores** V-01…V-14: qué significan y cómo corregirlos.
  - **Recordatorio**: regenerar **todos** los STL tras cualquier cambio (skill §4).
- [X] T033 [US4] En docs/puntero_laser_guia.md, añadir `## 5. Electrónica y requisitos del firmware`, con el contenido de contracts/interfaz_firmware.md y los valores finales de T008:
  - **Tabla de conversión**: 45,286 pasos/° y 16 303,09 pasos/vuelta, y por qué **no** usar 4096.
  - **Llegada unidireccional**: sobrepaso de 2°.
  - **Rangos**: −10° … 95°.
  - **Sentidos**: calibración de `invertir_azimut` e `invertir_altura`.
  - **Alineación con 2 estrellas**.
  - **Esquema de conexiones y pines**.
  - **Relé**: compatible con 3,3 V y cómo identificarlo.
  - **Alimentación**: power bank ≥ 2 A y qué hacer si se apaga solo.
  - **Recorrido de cables**: qué canal usa cada cable y el bucle del láser de 40 mm.
  - **Pruebas de aceptación**: F5, F6 y F9 del quickstart.
- [X] T034 [US4] En docs/puntero_laser_guia.md, añadir `## 6. Seguridad del láser` (FR-027, R12):
  - Nunca apuntar a aeronaves, personas, animales ni vehículos.
  - Normativa local sobre punteros.
  - Apagado automático a los 30 s con enfriamiento.
  - Bloqueo por debajo de 10° de altura.
  - Apagado al arrancar o al perder la conexión.
  - Comportamiento con frío (< 0 °C).
  - Usar la llave del láser como corte manual de emergencia.
- [X] T035 [US1] Comprobar la Puerta 4 (Escenario 8): `grep -nE '\[(ej\.|Describir|Cant\.|Fragmento|Sí/No)' docs/puntero_laser_guia.md` no debe dar coincidencias. Están las secciones 1 (A) y 2 (B) completas, más la 3 a la 6. Los valores citados (pasos/°, distancia entre centros, altura del eje, masas y cantidades de la BOM) coinciden con los `ECHO` de T008, con T028 y con los STL de exports/.

**Punto de control (cierre de la Fase 4)**: la Puerta 4 queda cumplida.

---

## Fase final: Cierre y comprobaciones transversales

- [X] T036 Volver a ejecutar de principio a fin los Escenarios 1 a 6 y 8 de specs/002-puntero-laser-estelar/quickstart.md con el estado final del repositorio. El Escenario 7 (laminador) es opcional y su paso automático lo cubre T021. Comprobar además la lista de control §6 de la skill disenio-multipieza (.claude/skills/disenio-multipieza/SKILL.md). Si hay discrepancias, corregirlas en la fase que corresponda, respetando el orden del pipeline.
- [X] T037 Actualizar specs/002-puntero-laser-estelar/plan.md: en «Puertas de calidad», cambiar el estado de las puertas 1, 3 y 4 a ✅ con la evidencia de T020, T027 y T035. En specs/002-puntero-laser-estelar/spec.md, cambiar **Estado** a «Implementada (pendiente de las pruebas físicas)». Completar «Notas de implementación» al final de este archivo con las desviaciones respecto del plan.
- [X] T038 Informar al usuario de que quedan pendientes las pruebas físicas F1–F10 de quickstart.md, que requieren imprimir y armar, y las F5–F9, que además requieren firmware (fuera de alcance). Entregarle el resumen de los comandos para regenerar y validar, y el orden de impresión recomendado (la probeta primero).

---

## Dependencias y orden de ejecución

### Dependencias entre fases (Principio II: estrictamente lineales)

```text
Fase 0 (T001)
 └─> Fase 1: T002 ─> T003 ─> T004 ─> T005 ─> T006 ─> T007 ─> T008      (fundacional, mismo archivo)
             ├─> T009 ∥ T010 ∥ T011 ∥ T012 ∥ T013 ∥ T014 ∥ T015      (piezas, archivos distintos)
             ├─> T016 (después de T010, T014 y T015) ─> T017
             └─> T018 ─> T019 ─> T020 ─> T021 ─> (T022 ∥ T023 ∥ T024) ─> T025
 └─> Fase 2: T026
 └─> Fase 3: T027 ─> T028
 └─> Fase 4: T029 ─> T030 ─> T031 ─> T032 ─> T033 ─> T034 ─> T035
 └─> Final:  T036 ─> T037 ─> T038
```

- Si una comprobación posterior (T020–T026) obliga a cambiar un parámetro compartido, se vuelve a
  T008 y se repiten las comprobaciones de **todas** las piezas, no solo la tocada (skill §4).

### Dependencias entre historias

- **US1 (P1)**: piezas, ensamblaje, exportación y guía básica. Es la base de las demás.
- **US2 (P2)**: la probeta (T009) y la cuna con colimación (T014) son piezas propias. T022, T026 y
  T031 verifican y documentan la precisión sobre la geometría de US1.
- **US3 (P3)**: depende de que estén todas las piezas (T023–T025) y de la guía (T032).
- **US4 (P4)**: los valores salen del archivo de parámetros (T007). La documentación (T033–T034) es
  independiente de la geometría fina.

### Oportunidades de paralelismo

- **T009–T015**: 7 piezas en archivos distintos que solo leen el archivo de parámetros. Es el
  principal punto de paralelismo.
- **T022 ∥ T023 ∥ T024**: comprobaciones que solo escriben en `$TMPDIR`. Las correcciones que
  resulten se aplican en serie.

## Ejemplo de ejecución en paralelo: piezas de US1 y US2

```bash
# Con T008 en verde, lanzar juntas:
Tarea: "T010 carro_motor en src/puntero_laser_carro_motor.scad"
Tarea: "T011 separador_azimut en src/puntero_laser_separador_azimut.scad"
Tarea: "T012 adaptador_tripode en src/puntero_laser_adaptador_tripode.scad"
Tarea: "T013 polea_altitud en src/puntero_laser_polea_altitud.scad"
Tarea: "T014 cuna_laser en src/puntero_laser_cuna_laser.scad"
Tarea: "T015 brazo_horquilla en src/puntero_laser_brazo_horquilla.scad"
Tarea: "T009 probeta_ajuste_608 en src/puntero_laser_probeta_ajuste_608.scad"
```

---

## Estrategia de implementación

### MVP (conjunto por defecto fabricable y documentado)

Por el Principio II, el MVP recorre las cuatro fases con la configuración por defecto:

1. Fase 0 y fundacional (T001–T008).
2. Piezas y ensamblaje (T009–T021). Incluye la probeta y la cuna, que son de US2 pero hacen falta
   para tener un aparato armable.
3. Fase 2 (T026).
4. Fase 3 (T027–T028).
5. Fase 4, secciones de US1 (T029, T030 y T035).
6. **Parar y validar**: el conjunto por defecto es imprimible y armable (Escenarios 1–4 y 8).

### Entrega incremental

1. US2: T022 y T031 (verificación y puesta a punto de la precisión).
2. US3: T023–T025 y T032 (adaptación a los componentes reales). Si cambian parámetros, se repiten
   T020, T021 y T026–T028.
3. US4: T033–T034 (firmware y seguridad).
4. Cierre (T036–T038).

---

## Notas

- [P] = archivos distintos o solo lectura, sin dependencias pendientes.
- La etiqueta [USn] da la trazabilidad con spec.md. La agrupación por fases la impone la constitución.
- Hacer commit al cerrar cada fase del pipeline (solo si el usuario lo pide).
- Evitar:
  - Cambiar un parámetro compartido sin regenerar los 10 STL.
  - Exportar el ensamblaje.
  - Usar herramientas fuera de `.tools/bin/`.
  - Escribir archivos temporales en el repositorio.

## Notas de implementación (desviaciones respecto al plan)

Las cotas y reglas nuevas están en [data-model.md, «Cambios introducidos en la implementación»](data-model.md#cambios-introducidos-en-la-implementación).

**Disposición en planta**

- **T004/T016, disposición**: el motor de azimut va en **+Y** y las placas en **+X**. En +X el carro
  de azimut chocaba con el pie del brazo del motor. La franja +Y no la barre el extremo trasero del
  láser, que solo llega a y ≤ 23 mm al apuntar a 95°. Al pasar las placas a +X, junto con la tapa, el
  centro de masa quedó a ≈ 4 mm del eje (antes, ≈ 23 mm). Solo el power bank queda en −X.
- **T016/T017, interruptor (FR-013)**: va en un soporte propio dentro de la tapa, con la palanca
  saliendo por una ranura abierta desde abajo. Detrás de las paredes del bolsillo no hay espacio para
  el cuerpo del interruptor. La tapa lleva además la abertura USB del ESP32, en lugar de la del power
  bank.
- **T016/T017, sobrante de cable (FR-012)**: el hueco mide 69 × 25 mm, al final de las columnas de
  placas, bajo la tapa.

**Piezas y uniones**

- **T014, colimación**: 6 **prisioneros M3 × 8 roscados** en anillos enrasados con los extremos del
  tubo (no a 4 mm del borde), sin tuercas. Con tuercas el anillo debía medir r ≈ 25 mm, y las cabezas
  sobresalían contra los brazos. Se agregaron asserts de separación anillo–brazo ≥ 1,5 mm y de
  prisionero embutido. La punta de la gota del anillo de contacto se recorta al agujero del labio
  menos 1 mm, porque rozaba el labio (0,1 mm³) al alargarse.
- **T015, pilares y topes**: los tornillos del carro de altura y de los topes tensores son M3
  autorroscantes en el plástico, sin tuerca. El tope empuja la cara del carro más cercana al eje
  conducido y deja `recorrido_tensor` + 2 mm de carrera. La parte ancha del brazo del motor se arma
  con `hull` desde 1 mm por encima del marco, para no chocar con sus paredes.
- **T009, probeta**: el valor de cada anillo se marca con 1 a 5 puntos en relieve, en lugar de texto,
  para no depender de fuentes en OpenSCAD.
- **T011, arandelas de contacto**: `d_contacto_aro` = 11,5 (antes 11). Con 11, la pared bajaba a
  1,1 mm con `holgura_perno_m8 = 0.8`.

**Reglas de validación**

- **T006, V-05**: se redefinió como «entra el tope tensor entre el carro y el 608». La fórmula
  original tenía el desplazamiento del eje con el signo cambiado y fallaba sin choque real.
- **T006, V-07**: se evalúa en el archivo de parámetros, sobre todas las zonas, con secciones reales
  del láser y del tubo (el punto más bajo de cada disco es r·|cos a|).

**Comprobaciones**

- **T020, vista**: OpenSCAD no exporta PNG sin OpenGL. Se agregó
  [vista_stl.py](vista_stl.py), que usa el Python de FreeCAD con matplotlib, y una prueba de choques
  por `intersection()` pieza a pieza a −10°, 0°, 45°, 90° y 95°. El escenario 4 del quickstart quedó
  actualizado.
- **T026, rigidez**: el recálculo dio 0,159° de inclinación del eje con 1,5 N laterales sobre un
  brazo de 10 mm. research.md R10 había dividido la flecha por el largo del brazo en lugar de por la
  separación entre brazos. Se volvió a la Fase 1: `espesor_brazo` pasa de 10 a **12** (0,089°),
  `labio_608` pasa a ser derivado (`espesor_brazo − 7`) y `borde_plataforma` pasa de 4 a 3, para
  seguir en ≤ 196 mm. El plan y research.md R10 quedaron corregidos.
- **T021, voladizos**: ninguna pieza necesita soportes. La repisa anular de 3 mm sobre el 608
  inferior de la base se imprime como puente.

- **Constitución v1.1.0** (enmendada durante la implementación, el 2026-10-04): se aplicó lo nuevo
  que obliga a este diseño.
  - **Validación estricta** (`--check-parameters=true --check-parameter-ranges=true`): detectó la
    pestaña superior de las poleas con altura negativa. Se corrigió con `alto_brida_sup` = 2,0 (antes
    1,5) y un assert.
  - **Puentes de 10 mm como máximo**: la ventana del pulsador de la cuna y la abertura USB de la tapa
    (12 mm) pasaron a tener techo a dos aguas a 45°.
  - **Capturas PNG revisadas**, generadas fuera del sandbox según `CLAUDE.md`. Las isométricas
    finales están en `docs/img/`.
  - **Aviso de holguras sin medir** en la especificación y en la guía, porque todavía no existe
    `src/perfil_impresora.scad`.
  - Como cambió un parámetro compartido, se regeneraron los 10 STL.

**Huellas SHA-256** de las fuentes con las que se exportaron los STL finales:

| Fuente | SHA-256 (inicio) |
|--------|------------------|
| `puntero_laser_adaptador_tripode.scad` | `ad38f99f…` |
| `puntero_laser_brazo_horquilla.scad` | `72bc79c3…` |
| `puntero_laser_carro_motor.scad` | `a976131d…` |
| `puntero_laser_cuna_laser.scad` | `2a0c40aa…` |
| `puntero_laser_parametros.scad` | `e6e94be6…` |
| `puntero_laser_plataforma_azimut.scad` | `b5086b91…` |
| `puntero_laser_polea_altitud.scad` | `a529c14c…` |
| `puntero_laser_probeta_ajuste_608.scad` | `0fc2cb03…` |
| `puntero_laser_separador_azimut.scad` | `dc5292cf…` |
| `puntero_laser_tapa_electronica.scad` | `6a7d839e…` |
