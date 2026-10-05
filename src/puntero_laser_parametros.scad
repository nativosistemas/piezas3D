// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Parámetros compartidos
// Descripción: Medidas compartidas por todas las piezas del puntero láser motorizado alt-az:
//              parámetros editables, constantes de componentes estándar, valores derivados,
//              reglas de validación (V-01…V-14) y módulos utilitarios (dentado GT2, etc.).
//              No dibuja nada; al renderizarlo solo imprime los derivados con echo.
// ==========================================
//
// Convención de ejes del conjunto (research.md):
//   Origen en la cara de apoyo de la base sobre el trípode. Z vertical = eje de azimut.
//   Eje de altura paralelo a X, a la altura z_eje_altura. A 0° de altura el láser apunta a +Y.
//   Lado +X: motor de altura y placas electrónicas (bajo la tapa). Lado −X: power bank.
//   Motor de azimut en +Y (franja que el extremo trasero del láser no barre).

// --- PARÁMETROS Y CONSTANTES ---

/* [Componentes comprados] */
// Diámetro del cuerpo del láser 303 (medir el ejemplar real)
diametro_laser = 30; // [20:0.5:40]
// Largo total del láser (medir el ejemplar real)
largo_laser = 190; // [120:1:260]
// Distancia del extremo trasero del láser a su punto de equilibrio (medir apoyándolo sobre un borde)
distancia_trasera_centro_masa = 95; // [48:1:156]
// Masa del láser con su batería, en gramos (solo para los cálculos)
masa_laser_g = 180; // [80:5:400]
// Largo del power bank (medir el ejemplar real)
powerbank_largo = 100; // [60:1:150]
// Ancho del power bank; queda vertical porque el power bank va de pie (medir)
powerbank_ancho = 65; // [40:1:75]
// Espesor del power bank (medir)
powerbank_alto = 25; // [10:1:30]
// Largo de la placa ESP32 DevKit (medir)
esp32_largo = 55; // [48:0.5:60]
// Ancho de la placa ESP32 DevKit (medir)
esp32_ancho = 28; // [25:0.5:32]
// Largo del módulo relé (medir)
rele_largo = 50; // [35:0.5:55]
// Ancho del módulo relé (medir)
rele_ancho = 26; // [17:0.5:30]
// Largo de la placa ULN2003 (medir)
uln2003_largo = 35; // [30:0.5:42]
// Ancho de la placa ULN2003 (medir)
uln2003_ancho = 32; // [20:0.5:35]
// Altura máxima de una placa con sus componentes (relé y ULN2003)
altura_placas = 18; // [10:1:25]

/* [Transmisión] */
// Dientes de la polea conducida impresa (≥ 80 para la relación ≥ 1:4 de FR-005)
dientes_polea_conducida = 80; // [80:1:100]
// Largo de la correa GT2 cerrada comercial, en mm
largo_correa = 200; // [160:2:240]
// Ancho de la correa GT2
ancho_correa = 6; // [6:1:9]
// Recorrido del tensor a cada lado de la posición nominal
recorrido_tensor = 3; // [2:0.5:6]
// Corrección del radio del hueco del diente GT2 impreso (ajuste de la impresora)
ajuste_diente_gt2 = 0; // [-0.15:0.01:0.15]

/* [Holguras] */
// Holgura de encastre entre piezas y de los soportes de placas
holgura_encastre = 0.25; // [0.1:0.05:0.5]
// Holgura de paso de los tornillos M3
holgura_tornillo_m3 = 0.3; // [0.1:0.05:0.6]
// Holgura entre caras de los alojamientos de tuercas y cabezas hexagonales
holgura_tuerca = 0.2; // [0.1:0.05:0.4]
// Holgura de paso de los pernos M8
holgura_perno_m8 = 0.4; // [0.2:0.05:0.8]
// Ajuste a presión de los 608ZZ (se suma a 22 mm; calibrar con la probeta)
ajuste_608 = 0.10; // [-0.1:0.01:0.3]
// Holgura mínima entre el láser y lo que hay debajo al apuntar al cenit
holgura_barrido = 8; // [5:1:20]

/* [Estructura] */
// Espesor de la placa de la plataforma de azimut
espesor_plataforma = 4; // [3:0.5:6]
// Espesor de los brazos de la horquilla (≥ ancho del 608 + labio)
espesor_brazo = 12; // [10:0.5:14]
// Ancho de los brazos de la horquilla
ancho_brazo = 36; // [30:1:45]
// Pared del tubo de la cuna del láser
pared_tubo_cuna = 3; // [2:0.5:4]
// Largo del tubo de la cuna del láser
largo_tubo_cuna = 100; // [70:1:140]
// Holgura radial entre el láser y la cuna (rango de colimación por lado)
holgura_colimacion = 2; // [1:0.25:3]
// Alto del resalte que separa los dos 608 de azimut
separacion_608_azimut = 16; // [10:1:30]
// Diámetro de la cara de apoyo de la base sobre el trípode
diametro_apoyo_tripode = 72; // [60:1:90]
// Alojamiento para contrapeso (tuercas M8) en la plataforma
con_contrapeso = true;
// Ventana en la cuna para llegar al pulsador del láser
con_ventana_pulsador = true;

/* [Calidad] */
// Resolución de los círculos
$fn = 64; // [24:8:128]

/* [Hidden] */
// ---------- Constantes de componentes estándar (Entidad 2 de data-model.md) ----------
// Rodamiento 608ZZ
rod608_d_ext = 22;
rod608_d_int = 8;
rod608_ancho = 7;
rod608_d_aro_int = 12.1;
// Perno y tuerca M8
m8_cabeza_ec = 13;
m8_cabeza_alto = 5.3;
m8_tuerca_ec = 13;
m8_autoblocante_alto = 8;
// M3
m3_d = 3;
m3_tuerca_ec = 5.5;
m3_tuerca_alto = 2.4;
m3_cabeza_d = 5.5;
diametro_autorroscante_m3 = 2.6;   // 85 % de M3
// Tuerca 3/8"-16 UNC del trípode
tuerca_3_8_ec = 14.29;
tuerca_3_8_alto = 8.33;
rosca_3_8_d = 9.525;
// Motor 28BYJ-48 (sistema propio: eje en el origen, cuerpo desplazado hacia +X)
motor_d_cuerpo = 28;
motor_alto_cuerpo = 19;
motor_entre_orejas = 35;
motor_d_agujero_oreja = 4.2;
motor_d_oreja = 7;
motor_desplazamiento_eje = 8;
motor_d_resalte = 9;
motor_alto_resalte = 1.5;
motor_largo_eje = 9.5;
motor_d_eje = 5;
motor_tapa_ancho = 17;
motor_tapa_saliente = 3;
// Polea GT2 20T comprada (agujero 5 mm, correa 6 mm)
dientes_polea_motriz = 20;
polea20_d_brida = 18;
polea20_alto_total = 16;
polea20_alto_cubo = 7;
polea20_d_cubo = 13;
polea20_espesor_brida = 1;
// Perfil GT2
paso_gt2 = 2;
profundidad_diente_gt2 = 0.75;
pld_gt2 = 0.254;
radio_hueco_gt2 = 0.555;
// Relación interna real del 28BYJ-48
relacion_motor = (32/9)*(22/11)*(26/9)*(31/10);
medios_pasos_motor = 64;

// ---------- Constantes internas de diseño ----------
espesor_carro = 3;
piso_munon = 2.2;              // piso que retiene la cabeza M8 dentro del muñón
holgura_munon_brazo = 0.5;
labio_608_min = 3;             // labio interior mínimo que apoya el aro exterior del 608 en el brazo
d_labio_608 = 16;              // agujero del labio (no toca el aro interior)
d_contacto_aro = 11.5;         // anillos y arandelas que apoyan SOLO en el aro interior (< rod608_d_aro_int)
holgura_pcb = 0.2;             // holgura vertical de las placas bajo el labio de sus soportes
altura_libre_central = 5;
espesor_min_pared = 1.2;
eps = 0.01;
cama_max = 200;
plataforma_max = 196;
holgura_zonas = 2;
altura_max_canal = 4;
pared_canal = 1.6;
ancho_canal = 8;
d_interruptor = 6.2;           // interruptor de palanca miniatura con rosca M6
pared_max_interruptor = 4;
distancia_min_cable_correa = 5;
// Pares (R9)
par_motor_mNm = 34;
rendimiento_correa = 0.9;
g_gravedad = 9.81;
// Masas estimadas para el centro de masa (R9), en gramos
masa_powerbank_g = 200;
masa_motor_g = 35;
masa_placas_g = 45;
masa_cuna_g = 60;
masa_polea20_g = 8;
masa_carro_g = 6;
masa_polea80_g = 20;
masa_brazo_g = 30;
masa_bolsillo_g = 15;
densidad_petg = 1.27e-3;       // g/mm³
relleno_medio = 0.5;           // fracción sólida media de una pieza impresa
// Base (adaptador del trípode)
piso_base = 4;
libre_tornillo_tripode = 6;    // espacio libre para la punta del tornillo del trípode
d_camara = 26;
ancho_ventana = 24;
alto_brida_sup = 2.0;          // pestaña superior: chaflán a 45° (1,75 mm) + 0,25 mm recto
espesor_brida = 1;
chaflan_base = 1;
// Plataforma
borde_plataforma = 3;
radio_esquina_plataforma = 6;
d_cubo_plataforma = 26;
pared_marco = 3;
alto_marco = 10;
pared_bolsillo = 2;
alto_bolsillo = 30;
alto_bolsillo_usb = 8;         // pared baja del extremo del conector USB del power bank
alto_interruptor = 12;
espesor_soporte_interruptor = 3;
ancho_soporte_interruptor = 20;
alto_sobrante_cables = 25;
largo_oreja_tapa = 7;
largo_puente_brida = 8;
ancho_puente_brida = 4;
alto_puente_brida = 3.5;
paso_brida = 2.3;
x_puente_brida_az = 20;
ancho_oreja_tapa = 10;
espesor_oreja_tapa = 3;
y_conducto = -30;
alto_tope = 10;
largo_tope = 8;
ancho_tope = 12;
separacion_tope = 2;
alto_soporte_placa = 3;
espesor_pcb = 1.6;
pared_soporte = 1.6;
labio_soporte = 0.6;
elevacion_esp32 = 15;          // el ESP32 va elevado: los pines quedan hacia abajo
alto_modulo_esp32 = 4;
alto_borde_tapa = 3;           // reborde de la plataforma que guía la tapa
pared_tapa = 2;
techo_tapa = 2;
holgura_tapa_carro = 2;
d_contrapeso = m8_tuerca_ec / cos(30) + 2*holgura_tuerca;
tuercas_contrapeso = 4;
alto_tuerca_m8 = 6.5;
// Brazos
pared_alojamiento_608 = 5;
d_pilar = 9;
d_cubo_polea_alt = 14;
separacion_tornillos_pie = 20;
prof_tornillo_pie = 12;
dist_tuerca_pie = 6;
d_agujero_cable_brazo = 4;
dist_agujero_cable = 22;
ancho_canal_brazo = 3;
prof_canal_brazo = 2.5;
ancho_canal_motor = 6;
prof_canal_motor = 3;
// Cuna
alto_anillo_colim = 6;
sobre_anillo_colim = 3.5;      // engrosamiento radial de los anillos de colimación (prisioneros M3 roscados)
largo_prisionero = 8;          // prisionero M3 × 8 de colimación (queda embutido en el anillo)
holgura_anillo_brazo = 1.5;    // separación mínima entre los anillos de la cuna y los brazos
d_munon = 22;
largo_ventana_pulsador = 16;
ancho_ventana_pulsador = 12;
dist_ventana_pulsador = 25;
ancho_ranura_cable = 3;
alto_ranura_cable = 8;
// Polea de altura
d_aligerado = 8;
material_min_aligerado = 4;

// ---------- Valores derivados (Entidad 3 de data-model.md) ----------
function largo_estandar(x) = ceil(x/5)*5;   // largos comerciales de perno cada 5 mm

// Poleas y correa
d_primitivo_motriz = dientes_polea_motriz*paso_gt2/PI;
d_primitivo_conducida = dientes_polea_conducida*paso_gt2/PI;
d_exterior_conducida = d_primitivo_conducida - 2*pld_gt2;
function largo_correa_abierta(c) =
    let(dd = d_primitivo_conducida - d_primitivo_motriz, fi = asin(dd/(2*c)))
    2*c*cos(fi) + PI*(d_primitivo_motriz + d_primitivo_conducida)/2 + dd*fi*PI/180;
function biseccion_centros(a, b, n) =
    n == 0 ? (a+b)/2
    : (largo_correa_abierta((a+b)/2) > largo_correa ? biseccion_centros(a, (a+b)/2, n-1)
                                                    : biseccion_centros((a+b)/2, b, n-1));
distancia_centros = biseccion_centros(
    (d_primitivo_conducida - d_primitivo_motriz)/2 + 0.5, 200, 60);
relacion_correa = dientes_polea_conducida/dientes_polea_motriz;
pasos_por_vuelta_eje = relacion_motor*medios_pasos_motor*relacion_correa;
pasos_por_grado = pasos_por_vuelta_eje/360;
grados_por_paso = 360/pasos_por_vuelta_eje;
h_dentado = ancho_correa + 1;

// Cuna y horquilla
labio_608 = espesor_brazo - rod608_ancho;   // el 608 queda enrasado con la cara exterior del brazo
diametro_interior_cuna = diametro_laser + 2*holgura_colimacion;
radio_exterior_cuna = diametro_interior_cuna/2 + pared_tubo_cuna;
largo_munon = m8_cabeza_alto + holgura_tuerca - pared_tubo_cuna + piso_munon;
semiancho_interior_horquilla = radio_exterior_cuna + largo_munon + holgura_munon_brazo;

// Barrido del láser y altura del eje de altura (sobre la cara superior de la plataforma)
l_trasero = distancia_trasera_centro_masa;
l_delantero = largo_laser - l_trasero;
radio_barrido = max(l_trasero, l_delantero) + diametro_laser/2*sin(5);
altura_eje = radio_barrido + holgura_barrido + altura_libre_central;
alto_brazo = altura_eje + rod608_d_ext/2 + pared_alojamiento_608 + 1;

// Carro del motor (sistema del carro: eje del motor en el origen, +X hacia afuera de la polea conducida)
carro_x_min = -(motor_d_resalte/2 + holgura_encastre + 3);
carro_x_max = motor_desplazamiento_eje + motor_d_cuerpo/2 + motor_tapa_saliente + 2;
ranura_carro_x = motor_desplazamiento_eje;
ranura_carro_y = motor_entre_orejas/2 + motor_d_oreja/2 + 2 + d_pilar/2;
carro_semiancho = ranura_carro_y + d_pilar/2 + 1;

// Motor de altura (cotas X del lado del motor)
alto_pilar_motor = motor_alto_cuerpo + 2;
x_cara_ext_brazo = semiancho_interior_horquilla + espesor_brazo;
x_cara_int_carro_alt = x_cara_ext_brazo + alto_pilar_motor;
x_inicio_cubo20_alt = x_cara_int_carro_alt + espesor_carro;
plano_correa_altura = x_inicio_cubo20_alt + polea20_alto_cubo + polea20_espesor_brida + ancho_correa/2 + 0.5;
largo_cubo_polea_altitud = plano_correa_altura - ancho_correa/2 - 0.5 - polea20_espesor_brida - x_cara_ext_brazo;
x_ext_polea_alt = plano_correa_altura + h_dentado/2 + espesor_brida;
x_dientes_polea20_alt = x_inicio_cubo20_alt + polea20_alto_cubo + polea20_espesor_brida + h_dentado/2;
eje_en_cubo20 = motor_largo_eje - espesor_carro;

// Eje de azimut: pila vertical de la base (de abajo hacia arriba)
dz_correa_azimut = -(polea20_alto_cubo - espesor_plataforma) - polea20_espesor_brida - ancho_correa/2 - 0.5;
alto_arandela_contacto = -dz_correa_azimut - h_dentado/2 - alto_brida_sup;
espesor_cubo_plataforma = m8_cabeza_alto + 0.3 + 2;
largo_fijo_azimut = 2 + alto_arandela_contacto + 2*rod608_ancho + separacion_608_azimut;
largo_perno_azimut = largo_estandar(largo_fijo_azimut + alto_arandela_contacto + m8_autoblocante_alto + 2);
altura_camara = (largo_perno_azimut - largo_fijo_azimut) + libre_tornillo_tripode;
z_tuerca_tripode_sup = piso_base + tuerca_3_8_alto + holgura_tuerca;
z_camara_sup = z_tuerca_tripode_sup + altura_camara;
z_resalte_inf = z_camara_sup + rod608_ancho;
z_resalte_sup = z_resalte_inf + separacion_608_azimut;
z_tope_base = z_resalte_sup + rod608_ancho;
z_dentado_sup = z_tope_base - alto_brida_sup;
z_dentado_inf = z_dentado_sup - h_dentado;
z_centro_dentado_base = (z_dentado_sup + z_dentado_inf)/2;
z_brida_inf_base = z_dentado_inf - espesor_brida;
z_cuerpo_base_sup = z_brida_inf_base - (diametro_apoyo_tripode/2 - (d_exterior_conducida/2 + espesor_brida));
z_plataforma_inf = z_tope_base + alto_arandela_contacto;
z_plataforma_sup = z_plataforma_inf + espesor_plataforma;
z_dientes_polea20_az = z_plataforma_inf + dz_correa_azimut;
z_polea20_az_inf = z_plataforma_sup - polea20_alto_total;
z_eje_altura = z_plataforma_sup + altura_eje;
largo_separador_azimut = separacion_608_azimut - 0.1;   // 0,1 mm menos que el resalte: precarga

// Pernos del eje de altura
x_cabeza_m8_cuna = diametro_interior_cuna/2 + m8_cabeza_alto + holgura_tuerca;
largo_perno_alt_motor = largo_estandar(x_ext_polea_alt - x_cabeza_m8_cuna);
largo_perno_alt_cable = largo_estandar(x_cara_ext_brazo + alto_arandela_contacto + m8_autoblocante_alto + 2 - x_cabeza_m8_cuna);

// Topes tensores (distancia desde el eje conducido)
r_carro_int = distancia_centros + carro_x_min;
r_tope_ext = r_carro_int - recorrido_tensor - separacion_tope;   // el carro puede acercarse recorrido_tensor
r_tope_int = r_tope_ext - largo_tope;

// ---------- Disposición en planta (R5 con la corrección de la implementación) ----------
// Zona: [x0, y0, x1, y1, altura sobre la cara superior de la plataforma, "nombre"]
x_marco_int = semiancho_interior_horquilla - holgura_encastre - pared_marco;
x_marco_ext = x_cara_ext_brazo + holgura_encastre + pared_marco;
y_marco = ancho_brazo/2 + holgura_encastre + pared_marco;
// Columnas de placas (+X)
x_col_a0 = x_marco_ext + holgura_zonas + pared_tapa + holgura_encastre;
ancho_col_a = uln2003_ancho + 2*holgura_encastre + 2*pared_soporte;
x_col_a1 = x_col_a0 + ancho_col_a;
x_col_b0 = x_col_a1 + holgura_zonas;
ancho_col_b = max(esp32_ancho, rele_ancho) + 2*holgura_encastre + 2*pared_soporte;
x_col_b1 = x_col_b0 + ancho_col_b;
largo_soporte_uln = uln2003_largo + 2*holgura_encastre + 2*pared_soporte;
largo_soporte_esp32 = esp32_largo + 2*holgura_encastre + 2*pared_soporte;
largo_soporte_rele = rele_largo + 2*holgura_encastre + 2*pared_soporte;
alto_col_a = 2*largo_soporte_uln + holgura_zonas;
alto_col_b = largo_soporte_esp32 + largo_soporte_rele + holgura_zonas;
y_uln_alt0 = -alto_col_a/2;
y_uln_az0 = y_uln_alt0 + largo_soporte_uln + holgura_zonas;
y_esp32_0 = -alto_col_b/2;
y_rele_0 = y_esp32_0 + largo_soporte_esp32 + holgura_zonas;
alto_esp32_total = elevacion_esp32 + espesor_pcb + alto_modulo_esp32;
alto_interior_tapa = max(altura_placas, alto_esp32_total) + 5;
alto_tapa = alto_interior_tapa + techo_tapa;
x_tapa0 = x_col_a0 - holgura_encastre - pared_tapa;
x_tapa1 = x_col_b1 + holgura_encastre + pared_tapa;
y_tapa0 = min(y_uln_alt0, y_esp32_0) - holgura_encastre - pared_tapa;
// Hueco para el cable sobrante (FR-012) e interruptor general (FR-013), dentro de la tapa
y_sob0 = max(y_uln_az0 + largo_soporte_uln, y_rele_0 + largo_soporte_rele) + holgura_zonas;
y_sob1 = y_sob0 + alto_sobrante_cables;
x_interruptor = x_col_b1 - espesor_soporte_interruptor;
y_interruptor = (y_sob0 + y_sob1)/2;
y_tapa1 = y_sob1 + holgura_encastre + pared_tapa;
// Power bank (−X), centrado en Y para equilibrar el grupo del motor de azimut
x_pb0 = -x_marco_ext - holgura_zonas;
ancho_bolsillo = powerbank_alto + 2*holgura_encastre + 2*pared_bolsillo;
x_pb1 = x_pb0 - ancho_bolsillo;
largo_bolsillo = powerbank_largo + 2*holgura_encastre + 2*pared_bolsillo;
masa_grupo_az_g = masa_motor_g + masa_polea20_g + masa_carro_g;
y_pb_c = -masa_grupo_az_g*(distancia_centros + motor_desplazamiento_eje)/(masa_powerbank_g + masa_bolsillo_g);
y_pb0 = y_pb_c - largo_bolsillo/2;
y_pb1 = y_pb_c + largo_bolsillo/2;
// Carro y tope del motor de azimut (+Y)
y_carro_az0 = distancia_centros + carro_x_min - recorrido_tensor;
y_carro_az1 = distancia_centros + carro_x_max + recorrido_tensor;
// Contrapeso (esquina −X, +Y)
x_contrapeso = x_pb1 + d_contrapeso/2 + 2;
y_contrapeso = y_pb1 + holgura_zonas + d_contrapeso/2 + 2;

zona_cubo = [-d_cubo_plataforma/2, -d_cubo_plataforma/2, d_cubo_plataforma/2, d_cubo_plataforma/2,
             espesor_cubo_plataforma - espesor_plataforma, "cubo central"];
zona_brazo_motor = [x_marco_int, -y_marco, x_marco_ext, y_marco, alto_marco, "brazo motor"];
zona_brazo_cable = [-x_marco_ext, -y_marco, -x_marco_int, y_marco, alto_marco, "brazo cable"];
zona_motor_azimut = [-carro_semiancho, y_carro_az0, carro_semiancho, y_carro_az1,
                     espesor_carro + motor_alto_cuerpo, "motor azimut"];
zona_tope_azimut = [-ancho_tope/2, r_tope_int, ancho_tope/2, r_tope_ext, alto_tope, "tope azimut"];
zona_powerbank = [x_pb1, y_pb0, x_pb0, y_pb1, powerbank_ancho, "powerbank"];
zona_uln_altura = [x_col_a0, y_uln_alt0, x_col_a1, y_uln_alt0 + largo_soporte_uln, altura_placas, "uln altura"];
zona_uln_azimut = [x_col_a0, y_uln_az0, x_col_a1, y_uln_az0 + largo_soporte_uln, altura_placas, "uln azimut"];
zona_esp32 = [x_col_b0, y_esp32_0, x_col_b1, y_esp32_0 + largo_soporte_esp32, alto_esp32_total, "esp32"];
zona_rele = [x_col_b0, y_rele_0, x_col_b1, y_rele_0 + largo_soporte_rele, altura_placas, "rele"];
y_puente_brida_az = y_carro_az1 + holgura_zonas + ancho_puente_brida/2 + 1;   // brida del cable del motor de azimut
zona_sobrante_cables = [x_col_a0, y_sob0, x_col_b1, y_sob1, 0, "sobrante de cables"];
zona_tapa = [x_tapa0, y_tapa0 - largo_oreja_tapa, x_tapa1, y_tapa1 + largo_oreja_tapa, alto_tapa, "tapa"];
zona_conducto = [x_pb0, y_conducto - ancho_canal/2 - pared_canal, x_tapa0,
                 y_conducto + ancho_canal/2 + pared_canal, altura_max_canal, "conducto"];
zona_contrapeso = [x_contrapeso - d_contrapeso/2, y_contrapeso - d_contrapeso/2,
                   x_contrapeso + d_contrapeso/2, y_contrapeso + d_contrapeso/2,
                   tuercas_contrapeso*alto_tuerca_m8 + 1, "contrapeso"];

zonas_componentes = concat(
    [zona_cubo, zona_brazo_motor, zona_brazo_cable, zona_motor_azimut, zona_tope_azimut,
     zona_powerbank, zona_uln_altura, zona_uln_azimut, zona_esp32, zona_rele],
    con_contrapeso ? [zona_contrapeso] : []);
zonas_todas = concat(zonas_componentes, [zona_tapa, zona_conducto]);

function minimo(v) = min([for (x = v) x]);
function maximo(v) = max([for (x = v) x]);
x_plat0 = minimo([for (z = zonas_todas) z[0]]) - borde_plataforma;
x_plat1 = maximo([for (z = zonas_todas) z[2]]) + borde_plataforma;
y_plat0 = minimo([for (z = zonas_todas) z[1]]) - borde_plataforma;
y_plat1 = maximo([for (z = zonas_todas) z[3]]) + borde_plataforma;
largo_plataforma = x_plat1 - x_plat0;
ancho_plataforma = y_plat1 - y_plat0;

// Solapamiento de dos zonas (con separación g)
function solapan(a, b, g) = !(a[2] + g <= b[0] || b[2] + g <= a[0] || a[3] + g <= b[1] || b[3] + g <= a[1]);
choques_componentes = [for (i = [0:len(zonas_componentes)-1]) for (j = [0:len(zonas_componentes)-1])
    if (j > i && solapan(zonas_componentes[i], zonas_componentes[j], holgura_zonas))
        str(zonas_componentes[i][5], " ↔ ", zonas_componentes[j][5])];
choques_tapa = [for (z = [zona_cubo, zona_brazo_motor, zona_brazo_cable, zona_motor_azimut,
                          zona_tope_azimut, zona_powerbank, zona_contrapeso])
    if (solapan(z, zona_tapa, 0)) z[5]];
choques_conducto = [for (z = [zona_cubo, zona_brazo_motor, zona_brazo_cable, zona_motor_azimut, zona_tope_azimut])
    if (solapan(z, zona_conducto, 0)) z[5]];

// Barrido del láser (V-07): secciones del láser y del tubo de la cuna cada 5 mm, de −10° a 95°.
// Cada sección es un disco perpendicular al eje del láser: su punto más bajo está r·|cos a| por
// debajo del centro y se extiende r·|sin a| en Y.
function secciones(a) = concat(
    [for (t = [-l_trasero:5:l_delantero]) [t*cos(a), altura_eje + t*sin(a), diametro_laser/2]],
    [for (t = [-largo_tubo_cuna/2:5:largo_tubo_cuna/2]) [t*cos(a), altura_eje + t*sin(a), radio_exterior_cuna + sobre_anillo_colim]],
    [[-l_trasero*cos(a), altura_eje - l_trasero*sin(a), diametro_laser/2],
     [l_delantero*cos(a), altura_eje + l_delantero*sin(a), diametro_laser/2]]);
function holgura_barrido_zona(z) = minimo(concat([999], [for (a = [-10:1:95]) for (s = secciones(a))
    if (z[0] < s[2] && z[2] > -s[2] && s[0] + s[2]*abs(sin(a)) > z[1] && s[0] - s[2]*abs(sin(a)) < z[3])
        s[1] - s[2]*abs(cos(a)) - z[4]]));
choques_barrido = [for (z = concat(zonas_todas, [[-ancho_tope/2, r_tope_int, ancho_tope/2, r_tope_ext, alto_tope, "tope"]]))
    if (holgura_barrido_zona(z) < 2) str(z[5], " (", holgura_barrido_zona(z), " mm)")];

// Centro de masa de la parte giratoria (R9): [masa_g, x, y]
area_plataforma = largo_plataforma*ancho_plataforma;
masa_plataforma_g = area_plataforma*espesor_plataforma*densidad_petg*relleno_medio + 40;
masa_tapa_g = (2*((x_tapa1-x_tapa0)+(y_tapa1-y_tapa0))*alto_tapa*pared_tapa
               + (x_tapa1-x_tapa0)*(y_tapa1-y_tapa0)*techo_tapa)*densidad_petg;
masas_giratorias = [
    [masa_powerbank_g + masa_bolsillo_g, (x_pb0+x_pb1)/2, y_pb_c],
    [10, (x_col_a0+x_col_a1)/2, y_uln_alt0 + largo_soporte_uln/2],
    [10, (x_col_a0+x_col_a1)/2, y_uln_az0 + largo_soporte_uln/2],
    [masa_placas_g - 35, (x_col_b0+x_col_b1)/2, y_esp32_0 + largo_soporte_esp32/2],
    [15, (x_col_b0+x_col_b1)/2, y_rele_0 + largo_soporte_rele/2],
    [masa_tapa_g, (x_tapa0+x_tapa1)/2, (y_tapa0+y_tapa1)/2],
    [masa_grupo_az_g, 0, distancia_centros + motor_desplazamiento_eje],
    [masa_motor_g + masa_carro_g + masa_polea20_g, x_cara_int_carro_alt - motor_alto_cuerpo/2, 0],
    [masa_polea80_g, x_ext_polea_alt - h_dentado, 0],
    [masa_brazo_g, x_cara_ext_brazo - espesor_brazo/2, 0],
    [masa_brazo_g, -(x_cara_ext_brazo - espesor_brazo/2), 0],
    [masa_cuna_g + masa_laser_g, 0, 0],
    [masa_plataforma_g, (x_plat0+x_plat1)/2, (y_plat0+y_plat1)/2]];
masa_giratoria_g = sum_lista([for (m = masas_giratorias) m[0]]);
function sum_lista(v, i = 0) = i >= len(v) ? 0 : v[i] + sum_lista(v, i+1);
x_centro_masa_plataforma = sum_lista([for (m = masas_giratorias) m[0]*m[1]])/masa_giratoria_g;
y_centro_masa_plataforma = sum_lista([for (m = masas_giratorias) m[0]*m[2]])/masa_giratoria_g;
masa_base_g = PI*pow(diametro_apoyo_tripode/2, 2)*z_cuerpo_base_sup*densidad_petg*relleno_medio;
masa_estimada_g = masa_giratoria_g + masa_base_g;

// Pares del eje de altura (FR-024)
par_disponible_mNm = par_motor_mNm*relacion_correa*rendimiento_correa;
par_desbalance_10_mNm = (masa_laser_g + masa_cuna_g)/1000*g_gravedad*10;
par_desbalance_20_mNm = (masa_laser_g + masa_cuna_g)/1000*g_gravedad*20;
fs_par_10 = par_disponible_mNm/par_desbalance_10_mNm;
fs_par_20 = par_disponible_mNm/par_desbalance_20_mNm;

// Presupuesto de error (Entidad 7, research.md R4), en grados
presupuesto_error = [
    ["resolucion azimut", grados_por_paso], ["resolucion altura", grados_por_paso],
    ["repetibilidad caja azimut", 0.1], ["repetibilidad caja altura", 0.1],
    ["correa azimut", 0.1], ["correa altura", 0.1],
    ["inclinacion plataforma", 0.1], ["perpendicularidad ejes", 0.25],
    ["colimacion", 0.2], ["alineacion", 0.3], ["flexion", 0.01], ["hora", 0.05]];
error_rss = sqrt(sum_lista([for (e = presupuesto_error) e[1]*e[1]]));
error_peor_caso = sum_lista([for (e = presupuesto_error) e[1]]);

// Espesores mínimos por pieza (FR-021, V-11)
espesores_minimos = [   // [parámetro principal, valor, pared, espesor]
    ["pared_tubo_cuna", pared_tubo_cuna, "pared del tubo de la cuna", pared_tubo_cuna],
    ["holgura_tuerca", holgura_tuerca, "piso del muñón", piso_munon],
    ["holgura_perno_m8", holgura_perno_m8, "pared del separador", (d_contacto_aro - rod608_d_int - holgura_perno_m8)/2],
    ["holgura_perno_m8", holgura_perno_m8, "pared de la arandela de contacto", (d_contacto_aro - rod608_d_int - holgura_perno_m8)/2],
    ["holgura_perno_m8", holgura_perno_m8, "pared del cubo de la polea de altura", (d_cubo_polea_alt - rod608_d_int - holgura_perno_m8)/2],
    ["ajuste_608", ajuste_608, "labio del 608 en el brazo", (rod608_d_ext + ajuste_608 - d_labio_608)/2],
    ["ajuste_608", ajuste_608, "pared del 608 en el brazo", pared_alojamiento_608 - ajuste_608/2],
    ["dientes_polea_conducida", dientes_polea_conducida, "pared del 608 en la base", (d_exterior_conducida - 2*profundidad_diente_gt2 - rod608_d_ext - ajuste_608)/2],
    ["holgura_tuerca", holgura_tuerca, "pared entre la tuerca 3/8 y la cámara", (d_camara - (tuerca_3_8_ec + holgura_tuerca)/cos(30))/2],
    ["espesor_brazo", espesor_brazo, "pared de la ranura de tuerca del pie", (espesor_brazo - (m3_tuerca_ec + holgura_tuerca)/cos(30))/2],
    ["holgura_colimacion", holgura_colimacion, "rosca del prisionero en el anillo", pared_tubo_cuna + sobre_anillo_colim - holgura_colimacion],
    ["espesor_plataforma", espesor_plataforma, "piso de la plataforma bajo las tuercas M3", espesor_plataforma - (m3_tuerca_alto + 0.2)],
    ["espesor_plataforma", espesor_plataforma, "piso del cubo de la plataforma", espesor_cubo_plataforma - m8_cabeza_alto - 0.3],
    ["holgura_tornillo_m3", holgura_tornillo_m3, "pared del carro junto a las ranuras", carro_semiancho - ranura_carro_y - (m3_d + holgura_tornillo_m3)/2],
    ["pared_bolsillo", pared_bolsillo, "pared del bolsillo", pared_bolsillo],
    ["pared_tapa", pared_tapa, "pared de la tapa", pared_tapa],
    ["pared_canal", pared_canal, "pared del conducto", pared_canal],
    ["espesor_carro", espesor_carro, "espesor del carro", espesor_carro],
    ["material_min_aligerado", material_min_aligerado, "material junto a los aligerados de la polea", material_min_aligerado]];
espesores_bajos = [for (e = espesores_minimos) if (e[3] < espesor_min_pared)
    str(e[0], "=", e[1], ": ", e[2], " = ", e[3], " mm")];

// --- VALIDACIÓN DE PARÁMETROS ---
module comprobar_rango(nombre, v, mn, mx) {
    assert(is_num(v) && v >= mn && v <= mx,
           str(nombre, "=", v, ": fuera de rango [", mn, ", ", mx, "]"));
}
// V-01: rangos
comprobar_rango("diametro_laser", diametro_laser, 20, 40);
comprobar_rango("largo_laser", largo_laser, 120, 260);
comprobar_rango("distancia_trasera_centro_masa", distancia_trasera_centro_masa, 48, 156);
comprobar_rango("masa_laser_g", masa_laser_g, 80, 400);
comprobar_rango("powerbank_largo", powerbank_largo, 60, 150);
comprobar_rango("powerbank_ancho", powerbank_ancho, 40, 75);
comprobar_rango("powerbank_alto", powerbank_alto, 10, 30);
comprobar_rango("esp32_largo", esp32_largo, 48, 60);
comprobar_rango("esp32_ancho", esp32_ancho, 25, 32);
comprobar_rango("rele_largo", rele_largo, 35, 55);
comprobar_rango("rele_ancho", rele_ancho, 17, 30);
comprobar_rango("uln2003_largo", uln2003_largo, 30, 42);
comprobar_rango("uln2003_ancho", uln2003_ancho, 20, 35);
comprobar_rango("altura_placas", altura_placas, 10, 25);
comprobar_rango("dientes_polea_conducida", dientes_polea_conducida, 80, 100);
comprobar_rango("largo_correa", largo_correa, 160, 240);
comprobar_rango("ancho_correa", ancho_correa, 6, 9);
comprobar_rango("recorrido_tensor", recorrido_tensor, 2, 6);
comprobar_rango("ajuste_diente_gt2", ajuste_diente_gt2, -0.15, 0.15);
comprobar_rango("holgura_encastre", holgura_encastre, 0.1, 0.5);
comprobar_rango("holgura_tornillo_m3", holgura_tornillo_m3, 0.1, 0.6);
comprobar_rango("holgura_tuerca", holgura_tuerca, 0.1, 0.4);
comprobar_rango("holgura_perno_m8", holgura_perno_m8, 0.2, 0.8);
comprobar_rango("ajuste_608", ajuste_608, -0.1, 0.3);
comprobar_rango("holgura_barrido", holgura_barrido, 5, 20);
comprobar_rango("espesor_plataforma", espesor_plataforma, 3, 6);
comprobar_rango("espesor_brazo", espesor_brazo, 10, 14);
comprobar_rango("ancho_brazo", ancho_brazo, 30, 45);
comprobar_rango("pared_tubo_cuna", pared_tubo_cuna, 2, 4);
comprobar_rango("largo_tubo_cuna", largo_tubo_cuna, 70, 140);
comprobar_rango("holgura_colimacion", holgura_colimacion, 1, 3);
comprobar_rango("separacion_608_azimut", separacion_608_azimut, 10, 30);
comprobar_rango("diametro_apoyo_tripode", diametro_apoyo_tripode, 60, 90);
assert(is_bool(con_contrapeso), str("con_contrapeso=", con_contrapeso, ": debe ser true o false"));
assert(is_bool(con_ventana_pulsador), str("con_ventana_pulsador=", con_ventana_pulsador, ": debe ser true o false"));

// V-02: centro de masa del láser cerca del medio
assert(distancia_trasera_centro_masa >= 0.4*largo_laser && distancia_trasera_centro_masa <= 0.6*largo_laser,
    str("distancia_trasera_centro_masa=", distancia_trasera_centro_masa, ": debe estar entre ",
        0.4*largo_laser, " y ", 0.6*largo_laser, " (40–60 % de largo_laser); revise la medición del punto de equilibrio"));
// V-03: la plataforma entra en la cama
assert(largo_plataforma <= plataforma_max && ancho_plataforma <= plataforma_max,
    str("powerbank_alto=", powerbank_alto, ": la plataforma mide ", largo_plataforma, " × ", ancho_plataforma,
        " mm (máx. ", plataforma_max, "); reduzca el power bank, las placas o largo_correa"));
// V-04: el brazo (impreso plano) entra en la cama
assert(alto_brazo <= plataforma_max,
    str("largo_laser=", largo_laser, ": el brazo mide ", alto_brazo, " mm (máx. ", plataforma_max,
        "); use un láser más corto o equilibre con el centro de masa más al medio"));
// V-05: entre el carro y el eje conducido entran el tope tensor y el alojamiento del 608
assert(r_tope_int >= rod608_d_ext/2 + pared_alojamiento_608 + 2,
    str("largo_correa=", largo_correa, ": distancia entre centros ", distancia_centros,
        " mm; el tope tensor no entra entre el carro y el rodamiento (mín. ",
        rod608_d_ext/2 + pared_alojamiento_608 + 2 + recorrido_tensor + separacion_tope + largo_tope - carro_x_min,
        " mm); use una correa más larga"));
// V-06: la polea 20T no toca la polea conducida
assert(distancia_centros >= (d_exterior_conducida + polea20_d_brida)/2 + 3,
    str("largo_correa=", largo_correa, ": distancia entre centros ", distancia_centros, " mm < ",
        (d_exterior_conducida + polea20_d_brida)/2 + 3, " mm; las poleas se tocan, use una correa más larga"));
// V-08: zonas de la plataforma sin solaparse
assert(len(choques_componentes) == 0,
    str(len(choques_componentes) > 0 ? choques_componentes[0] : "", "_ancho: componentes solapados en la plataforma: ",
        choques_componentes, "; reduzca las medidas del componente"));
assert(espesor_soporte_interruptor <= pared_max_interruptor && alto_interruptor + d_interruptor/2 + 2 <= alto_interior_tapa,
    str("altura_placas=", altura_placas, ": el interruptor no entra en el soporte o bajo la tapa"));
assert((x_col_b1 - x_col_a0) >= 40 && alto_sobrante_cables >= 25, "uln2003_ancho: el hueco del cable sobrante es menor que 40 × 25 mm");
assert(len(choques_tapa) == 0, str("altura_placas=", altura_placas, ": la tapa se solapa con ", choques_tapa));
assert(len(choques_conducto) == 0, str("espesor_plataforma=", espesor_plataforma, ": el conducto se solapa con ", choques_conducto));
// V-07 (planta): nada de la plataforma entra en el barrido del láser
assert(len(choques_barrido) == 0,
    str("holgura_barrido=", holgura_barrido, ": el láser toca ", choques_barrido,
        " en algún ángulo entre −10° y 95°; aumente holgura_barrido o revise el centro de masa"));
// V-10: el eje del motor entra en el cubo de la polea 20T
assert(eje_en_cubo20 >= 5,
    str("espesor_plataforma=", espesor_plataforma, ": el eje del motor entra solo ", eje_en_cubo20,
        " mm en el cubo de la polea 20T (mín. 5)"));
// V-11: holguras, brazo y espesores mínimos
assert(min([holgura_encastre, holgura_tornillo_m3, holgura_tuerca, holgura_perno_m8, holgura_barrido]) > 0,
    "holgura_encastre: todas las holguras deben ser > 0");
assert(espesor_brazo >= rod608_ancho + labio_608_min,
    str("espesor_brazo=", espesor_brazo, ": no entran el 608 (", rod608_ancho, ") y su labio (", labio_608_min,
        "); mínimo ", rod608_ancho + labio_608_min));
assert(len(espesores_bajos) == 0,
    str(len(espesores_bajos) > 0 ? espesores_bajos[0] : "", " (mínimo ", espesor_min_pared,
        " mm, FR-021); todas: ", espesores_bajos));
assert(semiancho_interior_horquilla - (radio_exterior_cuna + sobre_anillo_colim) >= holgura_anillo_brazo,
    str("pared_tubo_cuna=", pared_tubo_cuna, ": los anillos de colimación quedan a ",
        semiancho_interior_horquilla - (radio_exterior_cuna + sobre_anillo_colim), " mm de los brazos (mín. ", holgura_anillo_brazo, ")"));
assert(pared_tubo_cuna + sobre_anillo_colim + 2*holgura_colimacion >= largo_prisionero,
    str("holgura_colimacion=", holgura_colimacion, ": el prisionero de ", largo_prisionero,
        " mm sobresale del anillo con el láser centrado"));
assert(d_contacto_aro < rod608_d_aro_int, "d_contacto_aro: los anillos de contacto tocarían más que el aro interior del 608");
assert(alto_brida_sup - espesor_brida - profundidad_diente_gt2 >= 0,
    "alto_brida_sup: no entra el chaflán a 45° de la pestaña superior de las poleas");
// V-12: corrección de colimación
assert(atan(2*holgura_colimacion/(largo_tubo_cuna - alto_anillo_colim)) >= 1,
    str("holgura_colimacion=", holgura_colimacion, ": la corrección del haz es de ",
        atan(2*holgura_colimacion/(largo_tubo_cuna - alto_anillo_colim)), "° (mín. 1°)"));
// V-13: centro de masa de la parte giratoria
assert(norm([x_centro_masa_plataforma, y_centro_masa_plataforma]) <= 20,
    str("powerbank_largo=", powerbank_largo, ": el centro de masa está a ",
        norm([x_centro_masa_plataforma, y_centro_masa_plataforma]), " mm del eje (máx. 20)"));
if (norm([x_centro_masa_plataforma, y_centro_masa_plataforma]) > 5 && !con_contrapeso)
    echo(str("AVISO: el centro de masa está a ", norm([x_centro_masa_plataforma, y_centro_masa_plataforma]),
             " mm del eje; active con_contrapeso"));
// V-14: separación de los 608 de azimut
assert(separacion_608_azimut + 2*rod608_ancho >= 20,
    str("separacion_608_azimut=", separacion_608_azimut, ": las caras exteriores de los 608 quedan a ",
        separacion_608_azimut + 2*rod608_ancho, " mm (mín. 20)"));
// La base no toca la polea 20T del motor de azimut
assert(diametro_apoyo_tripode/2 <= distancia_centros - polea20_d_brida/2 - 2 || z_cuerpo_base_sup <= z_polea20_az_inf - 3,
    str("diametro_apoyo_tripode=", diametro_apoyo_tripode, ": el cuerpo de la base toca la polea 20T de azimut"));
assert(z_cuerpo_base_sup > z_camara_sup,
    str("diametro_apoyo_tripode=", diametro_apoyo_tripode, ": el cono de la base baja hasta la cámara; reduzca el diámetro"));
// Presupuesto de error
assert(error_peor_caso < 2, str("error_peor_caso=", error_peor_caso, "°: supera el límite de 2°"));
if (error_rss > 1) echo(str("AVISO: error_rss=", error_rss, "° supera el objetivo de 1°"));
if (fs_par_10 < 3) echo(str("AVISO: con 10 mm de desbalance el factor de seguridad del par es ", fs_par_10, " (< 3); equilibre bien el láser"));

// --- SALIDA DE DERIVADOS (echo) ---
echo(str("FIRMWARE pasos_por_grado=", pasos_por_grado, ", grados_por_paso=", grados_por_paso,
         ", pasos_por_vuelta_eje=", pasos_por_vuelta_eje));
echo(str("DISEÑO distancia_centros=", distancia_centros, ", altura_eje=", altura_eje, ", alto_brazo=", alto_brazo,
         ", plano_correa_altura=", plano_correa_altura, ", largo_cubo_polea_altitud=", largo_cubo_polea_altitud,
         ", plataforma=", largo_plataforma, "x", ancho_plataforma,
         ", x_centro_masa=", x_centro_masa_plataforma, ", y_centro_masa=", y_centro_masa_plataforma,
         ", masa_estimada_g=", masa_estimada_g));
echo(str("COTAS z_tope_base=", z_tope_base, ", z_plataforma_sup=", z_plataforma_sup, ", z_eje_altura=", z_eje_altura,
         ", semiancho_horquilla=", semiancho_interior_horquilla, ", alto_tapa=", alto_tapa));
echo(str("PERNOS azimut=M8x", largo_perno_azimut, ", altura_motor=M8x", largo_perno_alt_motor,
         ", altura_cable=M8x", largo_perno_alt_cable));
echo(str("PARES disponible=", par_disponible_mNm, ", desbalance_10=", par_desbalance_10_mNm, ", fs_10=", fs_par_10,
         ", desbalance_20=", par_desbalance_20_mNm, ", fs_20=", fs_par_20));
echo(str("PRESUPUESTO rss=", error_rss, ", peor_caso=", error_peor_caso));

// --- MÓDULOS UTILITARIOS COMPARTIDOS ---
// Dentado GT2 de una polea impresa (cilindro con los huecos de los dientes), de z = 0 a alto.
module dentado_gt2(dientes, alto) {
    r_ext = dientes*paso_gt2/PI/2 - pld_gt2;
    r_hueco = radio_hueco_gt2 + ajuste_diente_gt2;
    difference() {
        cylinder(r = r_ext, h = alto, $fn = dientes*4);
        for (i = [0:dientes-1])
            rotate([0, 0, i*360/dientes])
                translate([r_ext - profundidad_diente_gt2 + r_hueco, 0, -1])
                    cylinder(r = r_hueco, h = alto + 2, $fn = 16);
    }
}
// Pestañas de una polea impresa con dentado de z = 0 a alto_dentado: inferior plana y superior
// con chaflán de 45° por debajo (imprimible sin soportes).
module pestanas_polea(d_ext, alto_dentado) {
    translate([0, 0, -espesor_brida]) cylinder(d = d_ext + 2*espesor_brida, h = espesor_brida + eps);
    translate([0, 0, alto_dentado - eps])
        cylinder(d1 = d_ext - 2*profundidad_diente_gt2, d2 = d_ext + 2*espesor_brida, h = espesor_brida + profundidad_diente_gt2 + eps);
    translate([0, 0, alto_dentado + espesor_brida + profundidad_diente_gt2 - eps])
        cylinder(d = d_ext + 2*espesor_brida, h = alto_brida_sup - espesor_brida - profundidad_diente_gt2 + 2*eps);
}
// Agujero horizontal en forma de gota (eje a lo largo de X), con la punta hacia +Z.
module agujero_gota(d, largo) {
    // Tras rotate([0, 90, 0]) el −X local del perfil queda hacia +Z: la punta se dibuja hacia −X.
    rotate([0, 90, 0])
        linear_extrude(height = largo, center = true)
            union() {
                circle(d = d);
                rotate([0, 0, 135]) square(d/2);
            }
}
// Alojamiento hexagonal de tuerca o cabeza (ec entre caras), eje Z, de z = 0 a alto.
module alojamiento_hex(ec, alto) {
    cylinder(d = (ec + holgura_tuerca)/cos(30), h = alto, $fn = 6);
}
// Ranura alargada en X (agujero de diámetro d desplazable ±largo/2), eje Z.
module ranura(d, largo, alto) {
    hull() for (s = [-1, 1]) translate([s*largo/2, 0, 0]) cylinder(d = d, h = alto);
}
// Rectángulo de esquinas redondeadas (extruido), desde [x0, y0] hasta [x1, y1].
module placa_redondeada(x0, y0, x1, y1, r, alto) {
    hull() for (x = [x0 + r, x1 - r], y = [y0 + r, y1 - r]) translate([x, y, 0]) cylinder(r = r, h = alto);
}
