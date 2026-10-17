// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Ensamblaje (solo revisión, NO se exporta)
// Descripción: Coloca todas las piezas en su posición del conjunto, dibuja los componentes
//              comprados como volúmenes simplificados (motores, poleas 20T, correas, 608ZZ, pernos,
//              tornillería, placas, barra de distribución, regulador, power bank y láser sin batería
//              con su pila falsa, tapa trasera, lastre, grapa y cable, interruptor y resistencia del relé)
//              y comprueba con asserts los choques y alineaciones que no se pueden ver en una pieza sola
//              (V-07, V-09 y separaciones entre piezas). Declara los 26 cables de la electrónica de pin a
//              pin y comprueba que no atraviesen nada y que el cable comprado alcance (011). Las vistas
//              explotadas y los datos del visor 3D salen de la tabla de pasos con la biblioteca común
//              armado_comun.scad.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
include <puntero_laser_parametros.scad>
use <puntero_laser_adaptador_tripode.scad>
use <puntero_laser_plataforma_azimut.scad>
use <puntero_laser_brazo_horquilla.scad>
use <puntero_laser_cuna_laser.scad>
use <puntero_laser_polea_altitud.scad>
use <puntero_laser_disco_escala.scad>
use <puntero_laser_carro_motor.scad>
use <puntero_laser_separador_azimut.scad>
use <puntero_laser_tapa_electronica.scad>
use <puntero_laser_pila_falsa.scad>
use <puntero_laser_tapa_trasera.scad>
use <puntero_laser_grapa_cable.scad>
include <armado_comun.scad>

// Ángulo de altura del láser en la vista previa
angulo_altura = 45; // [-10:1:95] (angulo_altura_min a angulo_altura_max)
// Dibujar la tapa (transparente)
ver_tapa = true;
// Paso de armado de la guía (0 = conjunto completo; -1 = datos de los pasos con echo)
paso_armado = 0; // [-1:1:19]
// Dibujar solo este elemento, en su posición final y sin color (para exportar mallas al visor 3D)
solo_elemento = "";
// Dibujar los cables de pin a pin en el conjunto (solo para revisarlos; el visor los muestra en su modo Cableado)
ver_cables = false;

/* [Hidden] */
z_sup = z_plataforma_sup;
z_eje_motor_alt = z_eje_altura - distancia_centros;
grosor_correa = 1.4;
// Brazo del motor: X de impresión → Y, Y de impresión → Z, Z de impresión → +X
matriz_brazo_motor = [[0, 0, 1, semiancho_interior_horquilla], [1, 0, 0, 0], [0, 1, 0, z_sup], [0, 0, 0, 1]];
matriz_brazo_cable = [[0, 0, -1, -semiancho_interior_horquilla], [-1, 0, 0, 0], [0, 1, 0, z_sup], [0, 0, 0, 1]];
// Carro y motor de altura: Z propio → +X, X propio → −Z (hacia el pie), Y → Y
matriz_motor_alt = [[0, 0, 1, x_cara_int_carro_alt], [0, 1, 0, 0], [-1, 0, 0, z_eje_motor_alt], [0, 0, 0, 1]];
matriz_polea20_alt = [[0, 0, -1, x_inicio_cubo20_alt], [0, 1, 0, 0], [1, 0, 0, z_eje_motor_alt], [0, 0, 0, 1]];

// Tornillería M3 simplificada (cabeza cilíndrica)
alto_cabeza_m3 = 3;
espesor_oreja_motor = 1;   // las orejas del 28BYJ-48 se dibujan de 1 mm
x_pie_brazo = semiancho_interior_horquilla + espesor_brazo/2;
x_tapa_c = (x_tapa0 + x_tapa1)/2;
// Láser sin batería (006), en el sistema del láser: eje del láser sobre +Y, eje de altura en el origen
y_borde_tubo = -l_trasero + largo_tapa_fuera;
y_grapa = -l_trasero + largo_tapa_trasera + hueco_equilibrado/2 - ancho_grapa/2;
r_cable_canaleta = radio_exterior_cuna + sobre_anillo_colim - prof_canaleta + d_hilo/2 + 0.2;
r_cable_grapa = diametro_laser/2 - holgura("presion") + pared_grapa + d_hilo + 0.1;
y_fin_canaleta = -d_munon/2 - 2;
x_cara_int_brazo_cable = -semiancho_interior_horquilla;
// Punto del cable a angulo_cable, a radio r del eje del láser y a y del eje de altura
function punto_cable(r, y) = [r*cos(angulo_cable), y, -r*sin(angulo_cable)];
// Punto del sistema del láser pasado al conjunto con el láser a "a" grados
function en_conjunto(p, a) = [p[0], p[1]*cos(a) - p[2]*sin(a), p[1]*sin(a) + p[2]*cos(a) + z_eje_altura];
y_orejas_tapa = [y_tapa0 - largo_oreja_tapa/2, y_tapa1 + largo_oreja_tapa/2];
m_placa = pared_soporte + holgura_encastre;   // del borde del soporte al borde de la placa
largo_usb_fuera = 10;   // funda del enchufe USB que queda afuera de la tapa (solo para dibujarla)
alto_modulo_regulador = 4;     // MP1584EN con sus componentes, sobre su apoyo
largo_pin_macho = 6;           // pin de la tira de la barra, sobre el plástico

// Interruptor de palanca MTS-102 (011): cuerpo detrás del soporte (−X), buje roscado y palanca hacia +X
fondo_interruptor = 10;        // cuerpo, a lo largo del buje
ancho_cuerpo_interruptor = 13; // a lo largo de las patas (Y)
alto_cuerpo_interruptor = 8;
largo_patas_interruptor = 4.5;
separacion_patas_interruptor = 4.7;
ancho_pata_interruptor = 2;
espesor_pata_interruptor = 0.5;
largo_buje_interruptor = 9;    // atraviesa el soporte y la ranura de la tapa
d_palanca_interruptor = 2.5;
largo_palanca_interruptor = 10;
x_patas_interruptor = x_interruptor - fondo_interruptor - largo_patas_interruptor;   // punta de las patas
// Resistencia de 10 kΩ del relé (011): del lado de las soldaduras, bajo la placa, entre IN y GND
d_resistencia = 2.3;
largo_resistencia = 6.3;
d_pata_resistencia = 0.6;
corrimiento_resistencia = 2.5; // del eje de la tira hacia el centro de la placa
// Enchufe USB-A del cable de alimentación (011): en el puerto del power bank, con la funda hacia −Y; de
// su alivio de tracción salen los hilos rojo (+5 V) y negro (GND)
largo_funda_usb = 30;          // cuerpo plástico del enchufe, fuera del power bank
largo_alivio_usb = 8;
d_alivio_usb = 4;
puerto_usb_powerbank = [x_pb1 + pared_bolsillo + holgura_encastre + powerbank_alto/2, y_pb0 + pared_bolsillo + holgura_encastre,
                        z_sup + alto_bolsillo_usb + alto_enchufe_usb];

// --- Pines de las placas (011, research R4) ---
// [pin, [x, y] desde la esquina −X −Y de la placa]. Son posiciones de referencia: ubican los cables en el
// dibujo; la guía conecta por nombre de pin.
borde_pines = 2.5;             // del borde de una placa a su tira de pines
primer_pin_uln = 6;            // del borde −Y del ULN2003 a su IN1
x_ficha_uln = 3.5;             // del borde −X del ULN2003 al centro de la ficha del motor
paso_bornera = 5;
borde_bornera = 4;             // del borde +Y del relé al centro de su bornera
agujero_entrada_barra = 8;     // agujero de la placa perforada donde se suelda la entrada de cada tira
// ESP32 DevKitC V4 de 38 pines: 19 por lado, USB hacia −Y, pin 1 de cada columna hacia +Y
function pin_local_esp32(columna, n) = [(esp32_ancho + columna*separacion_filas_esp32)/2,
    esp32_largo/2 + (pines_por_lado_esp32 - 1)/2*paso_pines - (n - 1)*paso_pines];
pines_esp32 = [["VIN", pin_local_esp32(-1, 19)], ["GND", pin_local_esp32(-1, 14)],
               ["GPIO 33", pin_local_esp32(-1, 8)], ["GPIO 25", pin_local_esp32(-1, 9)],
               ["GPIO 26", pin_local_esp32(-1, 10)], ["GPIO 27", pin_local_esp32(-1, 11)],
               ["GPIO 23", pin_local_esp32(1, 2)], ["GPIO 19", pin_local_esp32(1, 8)],
               ["GPIO 18", pin_local_esp32(1, 9)], ["GPIO 17", pin_local_esp32(1, 11)],
               ["GPIO 16", pin_local_esp32(1, 12)]];
// ULN2003: ficha del motor hacia −X; entradas y alimentación en el borde +X, hacia el ESP32
pines_uln2003 = concat([for (k = [1:4]) [str("IN", k), [uln2003_ancho - borde_pines, primer_pin_uln + (k - 1)*paso_pines]]],
                       [["−", [uln2003_ancho - borde_pines, uln2003_largo - primer_pin_uln - paso_pines]],
                        ["+", [uln2003_ancho - borde_pines, uln2003_largo - primer_pin_uln]],
                        ["ficha", [x_ficha_uln, uln2003_largo/2]]]);
// Relé: tira IN, GND, VCC en el borde −Y (hacia el ESP32); bornera NA, COM, NC en el borde +Y
pines_rele = [["IN", [rele_ancho/2 - paso_pines, borde_pines]], ["GND", [rele_ancho/2, borde_pines]],
              ["VCC", [rele_ancho/2 + paso_pines, borde_pines]],
              ["NA", [rele_ancho/2 - paso_bornera, rele_largo - borde_bornera]],
              ["COM", [rele_ancho/2, rele_largo - borde_bornera]],
              ["NC", [rele_ancho/2 + paso_bornera, rele_largo - borde_bornera]]];
// MP1584EN: entrada en el borde −Y, salida en el +Y
pines_regulador = [["IN+", [borde_pines, borde_pines]], ["IN−", [regulador_ancho - borde_pines, borde_pines]],
                   ["OUT+", [borde_pines, regulador_largo - borde_pines]],
                   ["OUT−", [regulador_ancho - borde_pines, regulador_largo - borde_pines]]];
// Barra: tira +5 V en la columna −X y GND en la +X; pin k en el agujero k + 1 (010, research R2)
function pin_local_barra(columna, agujero) = [(columna + 0.5)*paso_pines, (agujero - 0.5)*paso_pines];

// Recorridos de los cables de los motores (009, research R6; 011, research R5; tabla de recorridos de la
// guía). El cable sale de la tapa azul del motor, a media altura del cuerpo, y corre sobre la plataforma
// hasta la pared −X de la tapa. Adentro sube entre la pared y las placas, pasa sobre los ULN2003 y baja a
// la ficha de su ULN2003 (borde −X de la placa).
salida_cable_motor = [motor_desplazamiento_eje + motor_d_cuerpo/2 + motor_tapa_saliente, 0, -motor_alto_cuerpo/2];
tramo_recto_motor = [4, 0, 0];   // el cable sale perpendicular a la tapa antes de doblar
z_cable_plataforma = z_sup + 2;
diametro_hilo_motor = 1;       // cada uno de los 5 hilos del cable de fábrica
x_subida_motor = (x_tapa0 + pared_tapa + x_col_a0 + m_placa)/2;   // entre la pared −X y las placas
function aplicar_matriz(m, p) = [for (i = [0:2]) m[i][0]*p[0] + m[i][1]*p[1] + m[i][2]*p[2] + m[i][3]];
function hasta_ficha(y_entrada, ficha) =
    let (z = ficha[2] + alto_enchufe_motor + radio_curva_cable + diametro_hilo_motor/2)
    [[x_tapa0, y_entrada, z_cable_plataforma], [x_subida_motor, y_entrada, z_cable_plataforma],
     [x_subida_motor, y_entrada, z], [x_subida_motor, ficha[1], z], [ficha[0], ficha[1], z], ficha];
// Altura: baja por el canal de la cara exterior del brazo motor y entra por la pared −X de la tapa.
// El motor va en el brazo: el recorrido no cambia con el ángulo de altura.
salida_cable_alt = aplicar_matriz(matriz_motor_alt, salida_cable_motor);
recorrido_cable_alt = concat([salida_cable_alt, aplicar_matriz(matriz_motor_alt, salida_cable_motor + tramo_recto_motor),
                              [x_cara_ext_brazo, salida_cable_alt[1], salida_cable_alt[2]],
                              [x_cara_ext_brazo, y_entrada_motor_alt, z_cable_plataforma]],
                             hasta_ficha(y_entrada_motor_alt, pin("ULN2003 altura", "ficha")));
// Azimut: del motor a la brida del puente de la plataforma y de ahí a la pared −X de la tapa
salida_cable_az = [salida_cable_motor[1], distancia_centros + salida_cable_motor[0],
                   z_sup + espesor_carro - salida_cable_motor[2]];
recorrido_cable_az = concat([salida_cable_az, salida_cable_az + [0, tramo_recto_motor[0], 0], [x_puente_brida_az, y_puente_brida_az, z_cable_plataforma]],
                            hasta_ficha(y_entrada_motor_az, pin("ULN2003 azimut", "ficha")));

// Vista explotada: transparencia de lo ya armado, color y grosor de las flechas
alfa_contexto = 0.22;
color_flecha = "OrangeRed";
diametro_flecha = 2.4;
// Dirección del láser al entrar en la cuna (desde atrás, a lo largo de su eje)
v_laser = [0, -cos(angulo_altura), -sin(angulo_altura)];
// La polea y su perno se enroscan en la tuerca del muñón +X: dos vueltas alrededor del eje de altura
// (solo el visor 3D muestra el giro)
giro_enroscar = [[0, 0, z_eje_altura], [1, 0, 0], 720];
giro_enroscar_cable = [[0, 0, z_eje_altura], [1, 0, 0], -720];   // el perno del lado cable entra hacia +X

// Pasos de armado de la guía (docs/puntero_laser_guia.md, sección 2): por cada paso, la lista de
// [elemento, desplazamiento de la vista explotada, resaltar, origen (opcional), giro (opcional)]
// (formato en armado_comun.scad). "resaltar = false" mueve o muestra un elemento sin destacarlo; el
// origen es el desplazamiento de la pieza que lo recibe (una tuerca que entra de costado en un brazo
// que baja). Un paso sin elementos (cableado, puesta a punto) no tiene vista.
// Subconjuntos: la base, la horquilla (brazos + cuna + polea) y la plataforma se arman por separado.
// La horquilla se atornilla a la plataforma (paso 8), la plataforma se monta sobre la base (paso 11) y
// el carro del motor de altura, armado en el banco, va al brazo motor en el paso 13.
grupo_base = ["base", "tuerca_tripode", "608_base_sup", "608_base_inf", "arandela_sup", "arandela_inf",
              "separador", "perno_az", "autoblocante_az"];
grupo_horquilla = ["brazo_motor", "brazo_cable", "608_brazo_motor", "608_brazo_cable", "cuna", "tuerca_munon",
                   "perno_alt_motor", "tuerca_munon_cable", "perno_alt_cable", "arandela_cable", "polea_alt",
                   "disco_escala", "tornillos_disco"];
grupo_motor_alt = ["carro_alt", "motor_alt", "tornillos_orejas_alt"];
con_lastre = tuercas_lastre_tapa > 0;   // sin tuercas, el lastre no se dibuja ni aparece en los pasos
paso_union_horquilla = 8;   // la horquilla armada se atornilla a la plataforma
paso_union_base = 11;       // la plataforma se monta sobre la base
paso_union_motor_alt = 13;  // el carro del motor de altura se monta en el brazo motor
subconjunto_plataforma = concat(grupo_horquilla,
                                ["plataforma", "tuercas_pie_motor", "tuercas_pie_cable", "tornillos_pie",
                                 "carro_az", "motor_az", "tornillos_orejas_az", "tuercas_carro_az",
                                 "tornillos_carro_az", "polea20_az"]);
// Placas electrónicas: un elemento por placa, para que el visor nombre cada una
placas = ["placa_uln_alt", "placa_uln_az", "placa_esp32", "placa_rele", "barra"];
pasos = [
    /* 1 */ [["base", [0, 0, 0], false], ["tuerca_tripode", [0, 0, 70], true]],
    /* 2 */ [["608_base_sup", [0, 0, 60], true], ["608_base_inf", [0, -60, 0], true]],
    /* 3 */ [["cuna", [0, 0, 0], false], ["tuerca_munon_cable", -130*v_laser, true]],
    /* 4 */ [["brazo_motor", [0, 0, 0], true], ["brazo_cable", [0, 0, 0], true],
             ["608_brazo_motor", [45, 0, 0], true], ["608_brazo_cable", [-45, 0, 0], true]],
    /* 5 */ [["brazo_motor", [50, 0, 0], true], ["brazo_cable", [-50, 0, 0], true],
             ["608_brazo_motor", [50, 0, 0], false], ["608_brazo_cable", [-50, 0, 0], false]],
    /* 6 */ [["arandela_cable", [-30, 0, 0], true], ["perno_alt_cable", [-50, 0, 0], true, undef, giro_enroscar_cable]],
    /* 7 */ [["tuerca_munon", -130*v_laser, true],
             ["polea_alt", [45, 0, 0], true, undef, giro_enroscar],
             ["perno_alt_motor", [45, 0, 0], true, undef, giro_enroscar],
             ["disco_escala", [70, 0, 0], true], ["tornillos_disco", [95, 0, 0], true]],
    /* 8 */ concat([["plataforma", [0, 0, 0], false]],
                   [for (e = grupo_horquilla) [e, [0, 0, 50], e == "brazo_motor" || e == "brazo_cable"]],
                   [["tuercas_pie_motor", [35, 0, 50], true, [0, 0, 50]],
                    ["tuercas_pie_cable", [-35, 0, 50], true, [0, 0, 50]], ["tornillos_pie", [0, 0, -35], true]]),
    /* 9 */ [["carro_az", [0, 0, 0], true], ["carro_alt", [0, 0, 0], true],
             ["motor_az", [0, 0, 40], true], ["tornillos_orejas_az", [0, 0, 70], true],
             ["motor_alt", [-30, 0, 0], true], ["tornillos_orejas_alt", [-55, 0, 0], true]],
    /* 10 */ [["tuercas_carro_az", [0, 0, -30], true], ["carro_az", [0, 0, 35], true], ["motor_az", [0, 0, 35], true],
              ["tornillos_orejas_az", [0, 0, 35], false], ["tornillos_carro_az", [0, 0, 65], true],
              ["polea20_az", [0, 0, -45], true]],
    /* 11 */ concat([for (e = subconjunto_plataforma) [e, [0, 0, 110], false]],
                    [["arandela_sup", [0, 0, 45], true], ["perno_az", [0, 0, 150], true],
                     ["separador", [0, -60, 0], true], ["arandela_inf", [0, -80, 0], true],
                     ["autoblocante_az", [0, -100, 0], true]]),
    /* 12 */ [["correa_az", [0, 0, -30], true]],
    /* 13 */ [["carro_alt", [45, 0, 0], true], ["motor_alt", [45, 0, 0], true], ["tornillos_orejas_alt", [45, 0, 0], false],
              ["tornillos_carro_alt", [80, 0, 0], true], ["polea20_alt", [65, 0, 0], true], ["correa_alt", [25, 0, 0], true]],
    /* 14 */ concat([["laser", [0, 0, 0], false], ["pila_falsa", 120*v_laser, true]],
                    con_lastre ? [["lastre", 90*v_laser, true]] : [],
                    [["tapa_trasera", 60*v_laser, true], ["grapa", [0, 0, 35], true]]),
    /* 15 */ concat([["laser", 150*v_laser, true]],
                    [for (e = ["pila_falsa", "lastre", "tapa_trasera", "grapa"]) if (e != "lastre" || con_lastre)
                        [e, 150*v_laser, false]]),
    /* 16 */ concat([for (e = placas) [e, [0, 0, 70], true]],
                    [["regulador", [0, 0, 150], true], ["powerbank", [0, 0, 100], true],
                     ["interruptor", [0, 0, 70], true], ["resistencia_rele", [0, 0, 70], true]]),
    /* 17 */ [["cable_laser", [-40, 0, 0], true], ["enchufe_usb", [0, -40, 0], true], ["conectores", [0, 0, 0], true]],
    /* 18 */ [["tapa", [0, 0, 50], true], ["tornillos_tapa", [0, 0, 80], true], ["tuercas_tapa", [0, 0, -30], true]],
    /* 19 */ []
];

// --- COMPROBACIONES DEL CONJUNTO ---
// V-09: planos de correa alineados
assert(abs(z_centro_dentado_base - z_dientes_polea20_az) <= 0.5,
    str("espesor_plataforma=", espesor_plataforma, ": plano de la correa de azimut desalineado ",
        z_centro_dentado_base - z_dientes_polea20_az, " mm"));
assert(abs(plano_correa_altura - x_dientes_polea20_alt) <= 0.5,
    str("alto_pilar_motor: plano de la correa de altura desalineado ", plano_correa_altura - x_dientes_polea20_alt, " mm"));
// Separaciones entre piezas
assert(holgura_munon_brazo > 0 && alto_arandela_contacto > 1,
    "holgura_encastre: el muñón toca el brazo o la plataforma toca la base");
assert(altura_eje - distancia_centros - carro_x_max - recorrido_tensor > espesor_carro + motor_alto_cuerpo + holgura_zonas,
    "largo_correa: la parte ancha del brazo del motor baja hasta el motor de azimut");
assert(alto_tapa + holgura_tapa_carro <= min(altura_eje - distancia_centros - carro_x_max,
                                            altura_eje - distancia_centros - (motor_desplazamiento_eje + motor_d_cuerpo/2 + motor_tapa_saliente)),
    str("altura_placas=", altura_placas, ", largo_dupont=", largo_dupont, ": la tapa (", alto_tapa,
        " mm) toca el carro o el motor de altura; use conectores más cortos o a 90°"));
assert(r_tope_ext + 1 < distancia_centros - polea20_d_brida/2,
    "largo_correa: el tope tensor toca la polea 20T del motor de altura");
// V-26 (009): los cables de fábrica de los motores llegan a su ULN2003. Desde la 011 la comprueba C-04
// en armado_comun.scad, con todos los cables (sección CABLEADO); acá se informa el largo de cada uno.
for (c = cables) if (!is_undef(c[7])) echo(str("CABLES largo_", c[0], "=", round(largo_polilinea(c[7]))));
// Hilos del láser completos: del regulador a la salida del brazo, más el tramo que acompaña al láser
echo(str("CABLES largo_hilos_laser_total=", round(largo_cable(cables[len(cables) - 1]))));
// Cables lejos de las correas (FR-012)
assert(plano_correa_altura - ancho_correa/2 - polea20_espesor_brida - x_cara_ext_brazo >= distancia_min_cable_correa,
    "alto_pilar_motor: el canal del cable del motor de altura queda a menos de 5 mm de la correa");
assert(y_conducto + ancho_canal/2 + pared_canal + distancia_min_cable_correa
       <= distancia_centros - recorrido_tensor - (polea20_d_brida + 3)/2,
    "y_conducto: el conducto pasa sobre la abertura de la polea de azimut");
// Conducto elevado por debajo de la altura libre central (forma parte de V-07)
assert(altura_max_canal < altura_libre_central, "altura_max_canal: el conducto invade la altura libre central");
// La parte ancha del brazo del motor no se mete en la tapa
assert(x_cara_ext_brazo < x_tapa0, "espesor_brazo: el brazo del motor se mete en la tapa");
// Marcas de orientación y de altura (012)
// M-03: la aguja de índice libra la correa de altura y el disco de la escala
assert(r_aguja_int - r_correa_ext_alt >= 2 && r_aguja_int > r_exterior_disco_escala,
    str("holgura_aguja=", holgura_aguja, ": la aguja de índice queda a ", r_aguja_int - r_correa_ext_alt,
        " mm de la correa de altura (mín. 2 mm)"));
// M-07: en reposo el láser (+Y) apunta a la «S» de la base, y la «O» está 90° en sentido horario
assert(abs(angulo_marca_sur - atan2(1, 0)) < 0.01 && abs(angulo_marca_sur - angulo_marca_oeste - 90) < 0.01,
    "angulo_marca_sur: la «S» no está en la dirección del láser en reposo o la «O» no está 90° en sentido horario");
// M-08: con la cuna a a grados, la raya de a grados del disco queda frente a la aguja (+Z). El disco va con
// rotate([0, 90, 0]): el (x, y) de la pieza pasa a (Y, Z) = (y, −x), y la cuna lo gira a grados alrededor de X.
function error_raya(a) = let (t = angulo_raya(a), y0 = sin(t), z0 = -cos(t),
                              y1 = y0*cos(a) - z0*sin(a), z1 = y0*sin(a) + z0*cos(a)) atan2(y1, z1);
for (a = [0:paso_escala:angulo_escala_max])
    assert(abs(error_raya(a)) < 0.1,
        str("disco de la escala: la raya de ", a, "° queda a ", error_raya(a), "° de la aguja con el láser a ", a, "°"));
if (angulo_escala_max % paso_escala != 0)
    echo(str("AVISO: paso_escala=", paso_escala, ": la última raya queda en ",
             angulo_escala_max - angulo_escala_max % paso_escala, "°, no en ", angulo_escala_max, "°"));
// Tabla de pasos: un paso por cada instrucción de la guía (los elementos los comprueba armado())
assert(len(pasos) == 19, "pasos: la guía tiene 19 pasos de armado");

// --- MÓDULOS PRINCIPALES Y ENSAMBLAJE ---
armado();

module ensamblaje_principal() {
    for (e = elementos) if (e != "tapa" && e != "conectores") color(color_elemento(e)) elemento(e);
    if (ver_tapa) %elemento("tapa");
    if (ver_cables) cables_modelados();
    else %elemento("conectores");
    %laser_en(angulo_altura_min) laser();
    %laser_en(angulo_altura_max) laser();
}

// Subconjunto al que pertenece un elemento en el paso n
function grupo(e, n) =
    let (g = contiene(grupo_base, e) ? "base" : contiene(grupo_horquilla, e) ? "horquilla"
             : contiene(grupo_motor_alt, e) ? "motor_alt" : "plataforma")
    g == "motor_alt" ? (n >= paso_union_motor_alt ? "conjunto" : g)
    : n >= paso_union_base ? "conjunto"
    : n >= paso_union_horquilla && g == "horquilla" ? "plataforma" : g;

// --- CATÁLOGO DE ELEMENTOS (posición final en el conjunto) ---
elementos = ["base", "plataforma", "brazo_motor", "brazo_cable", "cuna", "polea_alt", "carro_az", "carro_alt",
             "separador", "arandela_sup", "arandela_inf", "arandela_cable", "tapa",
             "tuerca_tripode", "608_base_sup", "608_base_inf", "608_brazo_motor", "608_brazo_cable",
             "perno_az", "autoblocante_az", "tuerca_munon", "perno_alt_motor", "tuerca_munon_cable", "perno_alt_cable",
             "motor_az", "motor_alt", "polea20_az", "polea20_alt", "correa_az", "correa_alt",
             "tornillos_pie", "tuercas_pie_motor", "tuercas_pie_cable", "tornillos_carro_az", "tuercas_carro_az",
             "tornillos_orejas_az", "tornillos_orejas_alt", "tornillos_carro_alt", "tornillos_tapa", "tuercas_tapa",
             "placa_uln_alt", "placa_uln_az", "placa_esp32", "placa_rele", "barra", "powerbank", "laser", "pila_falsa", "lastre", "tapa_trasera", "grapa", "regulador",
             "interruptor", "resistencia_rele", "enchufe_usb", "cable_laser", "conectores",
             "disco_escala", "tornillos_disco"];

// Nombre y tipo de cada elemento para el visor 3D (contrato: specs/008-identificacion-componentes/
// contracts/ensamblaje.md). Lo comprado usa la descripción de docs/puntero_laser_bom.csv.
nombres_elementos = [
    // Piezas impresas
    ["base",            "Adaptador del trípode (base)",                   "impresa"],
    ["plataforma",      "Plataforma de azimut",                           "impresa"],
    ["brazo_motor",     "Brazo de la horquilla, lado motor",              "impresa"],
    ["brazo_cable",     "Brazo de la horquilla, lado cable",              "impresa"],
    ["cuna",            "Cuna del láser",                                 "impresa"],
    ["polea_alt",       "Polea de altura",                                "impresa"],
    ["disco_escala",    "Disco de la escala de altura",                   "impresa"],
    ["carro_az",        "Carro del motor de azimut",                      "impresa"],
    ["carro_alt",       "Carro del motor de altura",                      "impresa"],
    ["separador",       "Separador de los rodamientos de azimut",         "impresa"],
    ["arandela_sup",    "Arandela de contacto (608 superior de la base)", "impresa"],
    ["arandela_inf",    "Arandela de contacto (608 inferior de la base)", "impresa"],
    ["arandela_cable",  "Arandela de contacto (eje de altura, lado cable)", "impresa"],
    ["tapa",            "Tapa de la electrónica",                         "impresa"],
    ["pila_falsa",      "Pila falsa del láser",                           "impresa"],
    ["tapa_trasera",    "Tapa trasera del láser",                         "impresa"],
    ["grapa",           "Grapa del cable",                                "impresa"],
    // Rodamientos, poleas y correas
    ["608_base_sup",    "Rodamiento 608ZZ (base, superior)",              "comprada"],
    ["608_base_inf",    "Rodamiento 608ZZ (base, inferior)",              "comprada"],
    ["608_brazo_motor", "Rodamiento 608ZZ (brazo, lado motor)",           "comprada"],
    ["608_brazo_cable", "Rodamiento 608ZZ (brazo, lado cable)",           "comprada"],
    ["polea20_az",      "Polea GT2 20 dientes (motor de azimut)",         "comprada"],
    ["polea20_alt",     "Polea GT2 20 dientes (motor de altura)",         "comprada"],
    ["correa_az",       "Correa GT2 cerrada de 200 mm × 6 mm (azimut)",   "comprada"],
    ["correa_alt",      "Correa GT2 cerrada de 200 mm × 6 mm (altura)",   "comprada"],
    // Pernos y tuercas M8 y del trípode
    ["tuerca_tripode",  "Tuerca 3/8\"-16 UNC (tornillo del trípode)",     "comprada"],
    ["perno_az",        "Perno M8 × 50 mm (eje de azimut)",               "comprada"],
    ["autoblocante_az", "Tuerca autoblocante M8 (eje de azimut)",         "comprada"],
    ["tuerca_munon",    "Tuerca M8 común (muñón de la cuna, lado motor)", "comprada"],
    ["perno_alt_motor", "Perno M8 × 55 mm (eje de altura, lado motor)",   "comprada"],
    ["tuerca_munon_cable", "Tuerca M8 común (muñón de la cuna, lado cable)", "comprada"],
    ["perno_alt_cable", str("Perno M8 × ", largo_perno_alt_cable, " mm (eje de altura, lado cable)"), "comprada"],
    ["lastre",          str("Tuerca M10 (DIN 934): lastre de la tapa trasera (", tuercas_lastre_tapa, ")"),
                        "comprada"],
    // Motores y tornillería M3
    ["motor_az",        "Motor paso a paso 28BYJ-48 (azimut)",            "comprada"],
    ["motor_alt",       "Motor paso a paso 28BYJ-48 (altura)",            "comprada"],
    ["tornillos_pie",   "Tornillo M3 × 12 mm: pies de los brazos (4)",    "comprada"],
    ["tuercas_pie_motor", "Tuerca M3: pie del brazo lado motor (2)",      "comprada"],
    ["tuercas_pie_cable", "Tuerca M3: pie del brazo lado cable (2)",      "comprada"],
    ["tornillos_carro_az", "Tornillo M3 × 10 mm: carro de azimut (2)",    "comprada"],
    ["tuercas_carro_az", "Tuerca M3: carro de azimut (2)",                "comprada"],
    ["tornillos_orejas_az", "Tornillo M3 × 8 mm: orejas del motor de azimut (2)", "comprada"],
    ["tornillos_orejas_alt", "Tornillo M3 × 8 mm: orejas del motor de altura (2)", "comprada"],
    ["tornillos_carro_alt", "Tornillo M3 × 12 mm: carro de altura (2)",   "comprada"],
    ["tornillos_disco", "Tornillo M3 × 8 mm + arandela: disco de la escala (2)", "comprada"],
    ["tornillos_tapa",  "Tornillo M3 × 10 mm: tapa (2)",                  "comprada"],
    ["tuercas_tapa",    "Tuerca M3: tapa (2)",                            "comprada"],
    // Electrónica y láser
    ["placa_esp32",     "ESP32 DevKit",                                   "comprada"],
    ["placa_rele",      "Módulo relé de 1 canal (lógica de 3,3 V)",       "comprada"],
    ["placa_uln_az",    "Placa driver ULN2003 (motor de azimut)",         "comprada"],
    ["placa_uln_alt",   "Placa driver ULN2003 (motor de altura)",         "comprada"],
    ["regulador",       "Módulo reductor de tensión MP1584EN (3,7 V)",    "comprada"],
    ["barra",           "Barra de distribución +5 V / GND (placa perforada)", "comprada"],
    ["interruptor",     "Interruptor de palanca miniatura con rosca M6 (tipo MTS-102)", "comprada"],
    ["resistencia_rele", "Resistencia de 10 kΩ 1/4 W, entre IN y GND del relé", "comprada"],
    ["enchufe_usb",     "Cable USB-A con salida a bornes (o cable USB cortado): enchufe en el power bank", "comprada"],
    ["powerbank",       "Power bank USB de 5 V y ≥ 2 A",                  "comprada"],
    ["laser",           "Puntero láser verde \"303\" (sin su batería)",   "comprada"],
    ["cable_laser",     "Cable de silicona de 2 × 26 AWG (regulador → láser)", "comprada"],
    ["conectores",      "Cables Dupont y enchufes (espacio reservado)",   "comprada"]];

// --- CABLEADO (modo Cableado del visor 3D) ---
// Contrato: specs/011-vista-cableado/contracts/ensamblaje.md. Cada cable es un renglón de la Tabla de
// cables de la guía (sección 5.4), con el mismo desde y hasta. Los recorridos salen de la posición de
// los pines (research R4) con la regla de research R5: los conectores de arriba suben hasta un nivel bajo
// el techo de la tapa (+5 V arriba, GND en el medio, señales abajo, para que no se superpongan); los del
// ESP32 bajan, van por debajo de la placa hacia su borde +Y y suben por el pasillo entre las dos columnas.
d_cable = diametro_cable_dupont;
largo_cable_dupont = 200;      // Dupont hembra-hembra del paquete de la lista de materiales
lado_bornera_cableado = 3;
lado_soldadura_cableado = 2;
ancho_ficha_motor = 6;         // ficha JST-XH de 5 pines, en planta
largo_ficha_motor = 12.5;
reserva_cable = 10;            // cable que queda sin tensar: curvas y holgura de cada enchufe
radio_curva_cableado = radio_curva_cable;
transparentes_cableado = ["tapa"];
ocultos_cableado = ["conectores"];
x_pasillo = (x_col_a1 + x_col_b0)/2;                     // entre la columna de los ULN2003 y la del ESP32
x_carril_esp32_arriba = x_pasillo + d_cable/2;           // VIN y GND del ESP32, junto a su soporte
x_carril_usb = x_pasillo + 1.5*d_cable;                  // cable USB, entre el pasillo y el ESP32
y_cruce_rele = (y_esp32_0 + largo_soporte_esp32 + y_rele_0)/2;   // entre los soportes del ESP32 y del relé
// Bajo el ESP32: 11 carriles entre las curvas de sus dos filas, en dos alturas alternadas
carriles_esp32 = 11;
paso_carril_esp32 = (separacion_filas_esp32 - 2*curva_cable - d_cable)/(carriles_esp32 - 1);
function x_carril_esp32(k) = x_col_b0 + m_placa + (esp32_ancho - separacion_filas_esp32)/2 + curva_cable + d_cable/2
    + k*paso_carril_esp32;
function z_bajo_esp32(k) = z_sup + holgura_conector + d_cable/2 + (k % 2)*d_cable;
// Salidas de abajo del ESP32 hacia el pasillo: por donde no hay Dupont (pines 3 a 7 y 15 a 18 de la fila −X)
function y_salida_esp32(j) = y_esp32_0 + largo_soporte_esp32 - pierna_soporte - d_cable - j*d_cable;
function y_salida_baja_esp32(j) = pin("ESP32", "GND")[1] - 2*d_cable - j*d_cable;
// Nivel de recorrido n (0 señales, 1 GND, 2 +5 V): sobre los Dupont de las placas bajas con su curva
function z_nivel(n) = z_sup + alto_soporte_placa + espesor_pcb + alto_tira_pines + largo_dupont + radio_curva_cable
    + d_cable/2 + n*d_cable;

// Posición de un pin en el conjunto (donde nace su conector)
function en_placa(x0, y0, local, z) = [x0 + m_placa + local[0], y0 + m_placa + local[1], z];
function buscar(lista, nombre) = [for (x = lista) if (x[0] == nombre) x[1]][0];
z_tiras = z_sup + alto_soporte_placa + espesor_pcb + alto_tira_pines;
function pin(componente, nombre) =
    componente == "ESP32" ? en_placa(x_col_b0, y_esp32_0, buscar(pines_esp32, nombre), z_sup + elevacion_esp32 - alto_tira_pines)
    : componente == "ULN2003 azimut" || componente == "ULN2003 altura" ?
        en_placa(x_col_a0, componente == "ULN2003 azimut" ? y_uln_az0 : y_uln_alt0, buscar(pines_uln2003, nombre),
                 nombre == "ficha" ? z_sup + alto_soporte_placa + espesor_pcb : z_tiras)
    : componente == "Relé" ? en_placa(x_col_b0, y_rele_0, buscar(pines_rele, nombre),
                                      contiene(["NA", "COM", "NC"], nombre) ? z_sup + altura_placas : z_tiras)
    : componente == "Regulador" ? en_placa(x_col_a0, y_reg0, buscar(pines_regulador, nombre),
                                           z_sup + alto_soporte_placa + alto_modulo_regulador)
    : componente == "Barra +5 V" || componente == "Barra GND" ?
        en_placa(x_barra0, y_barra0, pin_local_barra(componente == "Barra +5 V" ? 0 : 2,
                                                     nombre == "entrada" ? agujero_entrada_barra : nombre + 1),
                 nombre == "entrada" ? z_sup + alto_soporte_placa + espesor_pcb : z_tiras)
    : componente == "Interruptor" ? [x_patas_interruptor, y_interruptor - (nombre == "pata 1" ? separacion_patas_interruptor : 0),
                                     z_sup + alto_interruptor]
    : componente == "Enchufe USB" ? puerto_usb_powerbank + [(nombre - 0.5)*d_hilo, -largo_funda_usb - largo_alivio_usb, 0]
    : undef;

// Tramos de cada extremo, del pin hasta el nivel z
function subida(p, z) = [p, [p[0], p[1], z]];
function subida_interruptor(p, z) = let (q = p - [lado_soldadura_cableado, 0, 0]) [p, q, [q[0], q[1], z]];
function bajada_esp32(p, k, y_salida, x_subida, z) = let (zk = z_bajo_esp32(k), xk = x_carril_esp32(k))
    [p, [p[0], p[1], zk], [xk, p[1], zk], [xk, y_salida, zk], [x_subida, y_salida, zk], [x_subida, y_salida, z]];
function invertir(l) = [for (i = [len(l) - 1:-1:0]) l[i]];
function sin_repetidos(l) = [for (i = [0:len(l) - 1]) if (i == 0 || norm(l[i] - l[i - 1]) > 0.01) l[i]];
// Recorrido: tramo del primer extremo, puntos de paso [x, y] al nivel z y tramo del segundo extremo
function recorrido(desde, vias, hasta, z) = sin_repetidos(concat(desde, [for (v = vias) [v[0], v[1], z]], invertir(hasta)));
// Dupont entre dos pines de arriba, al nivel n, por los puntos de paso dados
function dupont_arriba(a, b, n, vias) = recorrido(subida(a, z_nivel(n)), vias, subida(b, z_nivel(n)), z_nivel(n));
// Señal del ESP32 (carril k, salida y_salida) a un pin de arriba, al nivel 0
function senal_esp32(gpio, k, y_salida, b, vias) = let (z = z_nivel(0))
    recorrido(bajada_esp32(pin("ESP32", gpio), k, y_salida, x_pasillo, z), vias, subida(b, z), z);
// En el conducto, los 2 hilos del USB van del lado −Y y los 2 del láser del lado +Y (no se cruzan)
z_conducto = z_sup + holgura_conector + d_hilo/2;
function y_usb(i) = y_conducto - (2.5 - i)*d_hilo;     // 0: +5 V, 1: GND
y_laser_conducto = y_conducto + d_hilo;
// Hilos del cable USB (0: rojo, +5 V; 1: negro, GND): salen del alivio del enchufe hacia −Y, rodean el
// bolsillo por +X, entran por el conducto, pasan bajo el ULN2003 de altura y suben junto al ESP32
function usb_hasta(i, z) =
    let (p = pin("Enchufe USB", i), y_fuera = p[1] - radio_curva_cable - i*d_hilo,
         x_fuera = x_pb0 + 1.5*d_cable + i*d_hilo)
    [p, [p[0], y_fuera, p[2]], [x_fuera, y_fuera, p[2]], [x_fuera, y_usb(i), p[2]], [x_fuera, y_usb(i), z_conducto],
     [x_carril_usb, y_usb(i), z_conducto], [x_carril_usb, y_usb(i), z]];
// Cable del láser (elemento cable_laser). Tramo que gira con el láser, en su sistema: ventana de la tapa →
// grapa → canaleta → fin de la canaleta. Tramo fijo: bucle hasta el agujero del brazo cable y salida por su
// cara exterior.
cable_laser_movil = [punto_cable(r_funda_ext + d_hilo, y_borde_tubo), punto_cable(r_cable_grapa, y_grapa + ancho_grapa/2),
                     punto_cable(r_cable_canaleta, -largo_tubo_cuna/2), punto_cable(r_cable_canaleta, y_fin_canaleta)];
function cable_laser_fijo(a) = [en_conjunto(punto_cable(r_cable_canaleta, y_fin_canaleta), a),
    [x_cara_int_brazo_cable + d_hilo + 0.5, -8, z_eje_altura - dist_agujero_cable - 8],
    [x_cara_int_brazo_cable, 0, z_eje_altura - dist_agujero_cable], [-x_cara_ext_brazo - 2, 0, z_eje_altura - dist_agujero_cable]];
largo_elementos_cableado = [["cable_laser", largo_polilinea(cable_laser_movil) + largo_polilinea(cable_laser_fijo(angulo_altura))]];
// Hilos del láser, del regulador a la salida del brazo cable (el tramo que acompaña al láser es el elemento
// cable_laser): bajan por la cara exterior del brazo, cruzan por el conducto, van bajo los ULN2003, suben
// entre el soporte del ULN2003 de azimut y el del regulador y llegan a OUT+ y OUT− (al medio de los dos)
salida_brazo_laser = [-x_cara_ext_brazo - 2, 0, z_eje_altura - dist_agujero_cable];
salida_regulador = (pin("Regulador", "OUT+") + pin("Regulador", "OUT−"))/2;
y_subida_laser = (y_uln_az0 + largo_soporte_uln + y_reg0)/2;
recorrido_hilos_laser =
    let (z = salida_regulador[2] + lado_soldadura_cableado + radio_curva_cable + d_hilo, x = salida_regulador[0])
    [salida_regulador, [x, salida_regulador[1], z], [x, y_subida_laser, z], [x, y_subida_laser, z_conducto],
     [x, y_laser_conducto, z_conducto], [salida_brazo_laser[0], y_laser_conducto, z_conducto],
     [salida_brazo_laser[0], 0, z_conducto], salida_brazo_laser];

senal = ["DodgerBlue", "Orange", "Gold", "MediumSeaGreen"];   // IN1…IN4 de cada ULN2003
x_in_uln = pin("ULN2003 azimut", "IN1")[0];
x_tira_5v = pin("Barra +5 V", 1)[0];
x_tira_gnd = pin("Barra GND", 1)[0];
y_paso_regulador = pin("Barra GND", 5)[1] + 1.2*d_cable;     // entre los pines 5 y 6, lejos del +5 V
y_paso_rele_regulador = pin("Barra +5 V", "entrada")[1] - 1.5*d_cable;
x_carril_usb_gnd = pin("Relé", "VCC")[0] + 3.5*d_cable;
x_carril_usb_5v = x_carril_usb_gnd + d_cable;

grupos_cableado = [
    ["alimentacion", "Alimentación: power bank e interruptor"],
    ["barra_5v", "Barra de distribución: +5 V"],
    ["barra_gnd", "Barra de distribución: GND"],
    ["esp32_az", "ESP32 → ULN2003 azimut"],
    ["esp32_alt", "ESP32 → ULN2003 altura"],
    ["rele_regulador", "ESP32, relé y regulador"],
    ["motores_laser", "Motores y láser"]];
conectores_cableado = [
    ["dupont", [paso_pines, paso_pines, largo_dupont], "Black"],
    ["jst", [ancho_ficha_motor, largo_ficha_motor, alto_enchufe_motor], "White"],
    ["usb", [0, 0, 0], "Silver"],   // el enchufe es el elemento enchufe_usb
    ["bornera", [lado_bornera_cableado, lado_bornera_cableado, lado_bornera_cableado], "RoyalBlue"],
    ["soldadura", [lado_soldadura_cableado, lado_soldadura_cableado, lado_soldadura_cableado], "Silver"],
    ["pila_falsa", [0, 0, 0], "Tomato"],
    ["motor", [0, 0, 0], "RoyalBlue"]];   // el cable sale directo de la tapa del motor: no hay ficha

// [id, desde, hasta, función, grupo, hilos, diámetro, recorrido, extremos, largo_comprado, elemento]
cables = [
    // Alimentación
    ["usb_5v", "Power bank USB +5 V", "Interruptor", "+5V", "alimentacion", ["Red"], d_hilo,
     recorrido(usb_hasta(0, z_nivel(2)),
               [[x_carril_usb, y_cruce_rele], [x_carril_usb_5v, y_cruce_rele], [x_carril_usb_5v, pin("Interruptor", "pata 1")[1]]],
               subida_interruptor(pin("Interruptor", "pata 1"), z_nivel(2)), z_nivel(2)),
     ["usb", "soldadura"], undef, undef],
    ["usb_gnd", "Power bank USB GND", "Barra GND (entrada)", "GND", "alimentacion", ["Black"], d_hilo,
     recorrido(usb_hasta(1, z_nivel(1)),
               [[x_carril_usb, y_cruce_rele], [x_carril_usb_gnd, y_cruce_rele], [x_carril_usb_gnd, pin("Barra GND", "entrada")[1]]],
               subida(pin("Barra GND", "entrada"), z_nivel(1)), z_nivel(1)),
     ["usb", "soldadura"], undef, undef],
    ["interruptor_barra", "Interruptor", "Barra +5 V (entrada)", "+5V", "alimentacion", ["Red"], d_hilo,
     recorrido(subida_interruptor(pin("Interruptor", "pata 2"), z_nivel(2)), [[x_tira_5v, y_interruptor]],
               subida(pin("Barra +5 V", "entrada"), z_nivel(2)), z_nivel(2)),
     ["soldadura", "soldadura"], undef, undef],
    // Barra +5 V
    ["v5_esp32", "Barra +5 V pin 1", "ESP32 VIN", "+5V", "barra_5v", ["Red"], d_cable,
     recorrido(subida(pin("Barra +5 V", 1), z_nivel(2)), [[x_carril_esp32_arriba, pin("Barra +5 V", 1)[1]]],
               bajada_esp32(pin("ESP32", "VIN"), 0, y_salida_baja_esp32(1), x_carril_esp32_arriba, z_nivel(2)), z_nivel(2)),
     ["dupont", "dupont"], largo_cable_dupont, undef],
    ["v5_uln_az", "Barra +5 V pin 2", "ULN2003 azimut +", "+5V", "barra_5v", ["Red"], d_cable,
     dupont_arriba(pin("Barra +5 V", 2), pin("ULN2003 azimut", "+"), 2,
                   [[x_tira_5v - d_cable, pin("Barra +5 V", 2)[1]], [x_tira_5v - d_cable, pin("ULN2003 azimut", "+")[1]]]),
     ["dupont", "dupont"], largo_cable_dupont, undef],
    ["v5_uln_alt", "Barra +5 V pin 3", "ULN2003 altura +", "+5V", "barra_5v", ["Red"], d_cable,
     dupont_arriba(pin("Barra +5 V", 3), pin("ULN2003 altura", "+"), 2,
                   [[x_tira_5v - 2*d_cable, pin("Barra +5 V", 3)[1]], [x_tira_5v - 2*d_cable, pin("ULN2003 altura", "+")[1]]]),
     ["dupont", "dupont"], largo_cable_dupont, undef],
    ["v5_rele_vcc", "Barra +5 V pin 4", "Relé VCC", "+5V", "barra_5v", ["Red"], d_cable,
     dupont_arriba(pin("Barra +5 V", 4), pin("Relé", "VCC"), 2, [[pin("Relé", "VCC")[0], pin("Barra +5 V", 4)[1]]]),
     ["dupont", "dupont"], largo_cable_dupont, undef],
    ["v5_rele_com", "Barra +5 V pin 5", "Relé COM", "+5V", "barra_5v", ["Red"], d_cable,
     dupont_arriba(pin("Barra +5 V", 5), pin("Relé", "COM"), 2, [[pin("Relé", "COM")[0], pin("Barra +5 V", 5)[1]]]),
     ["dupont", "bornera"], largo_cable_dupont, undef],
    // Barra GND
    ["gnd_esp32", "Barra GND pin 1", "ESP32 GND", "GND", "barra_gnd", ["Black"], d_cable,
     recorrido(subida(pin("Barra GND", 1), z_nivel(1)), [[x_carril_esp32_arriba, pin("Barra GND", 1)[1]]],
               bajada_esp32(pin("ESP32", "GND"), 1, y_salida_baja_esp32(0), x_carril_esp32_arriba, z_nivel(1)), z_nivel(1)),
     ["dupont", "dupont"], largo_cable_dupont, undef],
    ["gnd_uln_az", "Barra GND pin 2", "ULN2003 azimut −", "GND", "barra_gnd", ["Black"], d_cable,
     dupont_arriba(pin("Barra GND", 2), pin("ULN2003 azimut", "−"), 1,
                   [[x_tira_gnd - d_cable, pin("Barra GND", 2)[1]], [x_tira_gnd - d_cable, pin("ULN2003 azimut", "−")[1]]]),
     ["dupont", "dupont"], largo_cable_dupont, undef],
    ["gnd_uln_alt", "Barra GND pin 3", "ULN2003 altura −", "GND", "barra_gnd", ["Black"], d_cable,
     dupont_arriba(pin("Barra GND", 3), pin("ULN2003 altura", "−"), 1,
                   [[x_tira_gnd - 2*d_cable, pin("Barra GND", 3)[1]], [x_tira_gnd - 2*d_cable, pin("ULN2003 altura", "−")[1]]]),
     ["dupont", "dupont"], largo_cable_dupont, undef],
    ["gnd_rele", "Barra GND pin 4", "Relé GND", "GND", "barra_gnd", ["Black"], d_cable,
     dupont_arriba(pin("Barra GND", 4), pin("Relé", "GND"), 1, [[pin("Relé", "GND")[0], pin("Barra GND", 4)[1]]]),
     ["dupont", "dupont"], largo_cable_dupont, undef],
    ["gnd_regulador", "Barra GND pin 5", "Regulador IN−", "GND", "barra_gnd", ["Black"], d_cable,
     dupont_arriba(pin("Barra GND", 5), pin("Regulador", "IN−"), 1,
                   [[x_tira_gnd, y_paso_regulador], [pin("Regulador", "IN−")[0], y_paso_regulador]]),
     ["dupont", "soldadura"], largo_cable_dupont, undef],
    // ESP32 → ULN2003 azimut: IN4…IN1 por los carriles 81,4 / 80 / 78,6 / 77,2 (sin cruces)
    for (k = [1:4]) let (gpio = ["GPIO 16", "GPIO 17", "GPIO 18", "GPIO 19"][k - 1], b = pin("ULN2003 azimut", str("IN", k)),
                         ys = y_salida_esp32(4 - k), x = x_pasillo - (4 - k)*d_cable)
        [str("sen_az_in", k), str("ESP32 ", gpio), str("ULN2003 azimut IN", k), "señal", "esp32_az", [senal[k - 1]], d_cable,
         senal_esp32(gpio, 5 + k, ys, b, [[x, ys], [x, b[1]]]), ["dupont", "dupont"], largo_cable_dupont, undef],
    // ESP32 → ULN2003 altura
    for (k = [1:4]) let (gpio = ["GPIO 25", "GPIO 26", "GPIO 27", "GPIO 33"][k - 1], b = pin("ULN2003 altura", str("IN", k)),
                         j = [6, 5, 4, 7][k - 1], carril = [3, 4, 5, 2][k - 1],
                         ys = y_salida_esp32(j), x = x_pasillo - (k - 1)*d_cable)
        [str("sen_alt_in", k), str("ESP32 ", gpio), str("ULN2003 altura IN", k), "señal", "esp32_alt", [senal[k - 1]], d_cable,
         senal_esp32(gpio, carril, ys, b, [[x, ys], [x, b[1]]]), ["dupont", "dupont"], largo_cable_dupont, undef],
    // ESP32, relé y regulador
    ["sen_rele", "ESP32 GPIO 23", "Relé IN", "señal", "rele_regulador", ["Violet"], d_cable,
     recorrido(bajada_esp32(pin("ESP32", "GPIO 23"), 10, y_cruce_rele, pin("Relé", "IN")[0], z_nivel(0)), [],
               subida(pin("Relé", "IN"), z_nivel(0)), z_nivel(0)),
     ["dupont", "dupont"], largo_cable_dupont, undef],
    ["rele_regulador", "Relé NA", "Regulador IN+", "+5V", "rele_regulador", ["Red"], d_hilo,
     dupont_arriba(pin("Relé", "NA"), pin("Regulador", "IN+"), 2,
                   [[pin("Relé", "NA")[0], y_paso_rele_regulador], [pin("Regulador", "IN+")[0], y_paso_rele_regulador]]),
     ["bornera", "soldadura"], undef, undef],
    // Motores y láser
    ["cable_motor_az", "Motor de azimut", "ULN2003 azimut (ficha del motor)", "señal", "motores_laser",
     ["Blue", "HotPink", "Yellow", "Orange", "Red"], diametro_hilo_motor, recorrido_cable_az, ["motor", "jst"], largo_cable_motor, undef],
    ["cable_motor_alt", "Motor de altura", "ULN2003 altura (ficha del motor)", "señal", "motores_laser",
     ["Blue", "HotPink", "Yellow", "Orange", "Red"], diametro_hilo_motor, recorrido_cable_alt, ["motor", "jst"], largo_cable_motor, undef],
    ["hilos_laser", "Regulador OUT±", "Láser (pila falsa y tapa trasera)", "señal", "motores_laser", ["Red", "Black"], d_hilo,
     recorrido_hilos_laser, ["soldadura", "pila_falsa"], undef, "cable_laser"]];

// Obstáculos de los cables (C-03): placas, componentes, postes y apoyos de los soportes, plataforma y tapa.
// [nombre, mín, máx, componente]: un cable puede tocar su componente en los tramos de sus extremos.
function caja_placa(nombre, x0, y0, a, l, z_apoyo, alto, componente) =
    [nombre, [x0 + m_placa, y0 + m_placa, z_sup + z_apoyo], [x0 + m_placa + a, y0 + m_placa + l, z_sup + z_apoyo + alto], componente];
// Postes en L y apoyos de un soporte de placa (como soporte_placa() de la plataforma)
function postes_soporte(nombre, x0, y0, a, l, z_apoyo, pad, ancho_central = 0) =
    let (alto = z_apoyo + espesor_pcb + holgura_pcb + alto_labio_soporte)
    [for (i = [0, 1], j = [0, 1])
        let (cx = i == 0 ? x0 + pared_soporte : x0 + m_placa + a + holgura_encastre,
             cy = j == 0 ? y0 + pared_soporte : y0 + m_placa + l + holgura_encastre,
             px = i == 0 ? cx - pared_soporte : cx, py = j == 0 ? cy - pared_soporte : cy,
             lx = i == 0 ? px : px - pierna_soporte + pared_soporte, ly = j == 0 ? py : py - pierna_soporte + pared_soporte,
             ax = ancho_central > 0 ? x0 + m_placa + a/2 - ancho_central/2 : i == 0 ? cx : cx - pad,
             ay = j == 0 ? cy : cy - pad, aw = ancho_central > 0 ? ancho_central : pad)
        each [[str("los postes del soporte ", nombre), [px, ly, z_sup], [px + pared_soporte, ly + pierna_soporte, z_sup + alto], ""],
              [str("los postes del soporte ", nombre), [lx, py, z_sup], [lx + pierna_soporte, py + pared_soporte, z_sup + alto], ""],
              [str("los apoyos del soporte ", nombre), [ax, ay, z_sup], [ax + aw, ay + pad, z_sup + z_apoyo], ""]]];
obstaculos_cableado = concat(
    [caja_placa("el ESP32", x_col_b0, y_esp32_0, esp32_ancho, esp32_largo, elevacion_esp32, alto_modulo_esp32 + espesor_pcb, "ESP32"),
     caja_placa("el relé", x_col_b0, y_rele_0, rele_ancho, rele_largo, alto_soporte_placa, altura_placas - alto_soporte_placa, "Relé"),
     caja_placa("el ULN2003 de azimut", x_col_a0, y_uln_az0, uln2003_ancho, uln2003_largo, alto_soporte_placa,
                altura_placas - alto_soporte_placa, "ULN2003 azimut"),
     caja_placa("el ULN2003 de altura", x_col_a0, y_uln_alt0, uln2003_ancho, uln2003_largo, alto_soporte_placa,
                altura_placas - alto_soporte_placa, "ULN2003 altura"),
     caja_placa("el regulador", x_col_a0, y_reg0, regulador_ancho, regulador_largo, alto_soporte_placa, alto_modulo_regulador, "Regulador"),
     caja_placa("la barra de distribución", x_barra0, y_barra0, barra_ancho, barra_largo, alto_soporte_placa,
                espesor_pcb + alto_tira_pines, "Barra"),   // los pines son finos: no se cuentan
     ["el interruptor", [x_interruptor - fondo_interruptor, y_interruptor - ancho_cuerpo_interruptor/2, z_sup + alto_interruptor - alto_cuerpo_interruptor/2],
      [x_interruptor, y_interruptor + ancho_cuerpo_interruptor/2, z_sup + alto_interruptor + alto_cuerpo_interruptor/2], "Interruptor"],
     ["el soporte del interruptor", [x_interruptor, y_interruptor - ancho_soporte_interruptor/2, z_sup],
      [x_interruptor + espesor_soporte_interruptor, y_interruptor + ancho_soporte_interruptor/2,
       z_sup + alto_interruptor + d_interruptor/2 + 3], ""],
     ["el power bank", [x_pb1 + pared_bolsillo + holgura_encastre, y_pb0 + pared_bolsillo + holgura_encastre, z_sup],
      [x_pb1 + pared_bolsillo + holgura_encastre + powerbank_alto, y_pb0 + pared_bolsillo + holgura_encastre + powerbank_largo,
       z_sup + powerbank_ancho], "Power bank"],
     ["la plataforma", [x_pb1 - 100, y_pb0 - 100, z_plataforma_inf], [x_tapa1 + 100, y_tapa1 + 100, z_sup], ""],
     ["la pared −X de la tapa", [x_tapa0, y_tapa0, z_sup], [x_tapa0 + pared_tapa, y_tapa1, z_sup + alto_tapa], ""],
     ["la pared +X de la tapa", [x_tapa1 - pared_tapa, y_tapa0, z_sup], [x_tapa1, y_tapa1, z_sup + alto_tapa], ""],
     ["la pared −Y de la tapa", [x_tapa0, y_tapa0, z_sup], [x_tapa1, y_tapa0 + pared_tapa, z_sup + alto_tapa], ""],
     ["la pared +Y de la tapa", [x_tapa0, y_tapa1 - pared_tapa, z_sup], [x_tapa1, y_tapa1, z_sup + alto_tapa], ""],
     ["el techo de la tapa", [x_tapa0, y_tapa0, z_sup + alto_interior_tapa], [x_tapa1, y_tapa1, z_sup + alto_tapa], ""]],
    postes_soporte("del ULN2003 de altura", x_col_a0, y_uln_alt0, uln2003_ancho, uln2003_largo, alto_soporte_placa, pad_soporte),
    postes_soporte("del ULN2003 de azimut", x_col_a0, y_uln_az0, uln2003_ancho, uln2003_largo, alto_soporte_placa, pad_soporte),
    postes_soporte("del ESP32", x_col_b0, y_esp32_0, esp32_ancho, esp32_largo, elevacion_esp32, pad_soporte_esp32,
                   ancho_apoyo_esp32),
    postes_soporte("del relé", x_col_b0, y_rele_0, rele_ancho, rele_largo, alto_soporte_placa, pad_soporte),
    postes_soporte("del regulador", x_col_a0, y_reg0, regulador_ancho, regulador_largo, alto_soporte_placa, pad_soporte),
    postes_soporte("de la barra", x_barra0, y_barra0, barra_ancho, barra_largo, alto_soporte_placa, pad_soporte_barra));
// Aberturas de la pared −X de la tapa (puntero_laser_tapa_electronica.scad): conducto y cables de los motores
pasos_tapa_cableado = concat(
    [["el conducto", [x_tapa0 - 1, y_conducto - ancho_canal/2 - pared_canal, z_sup - 1],
      [x_tapa0 + pared_tapa + 1, y_conducto + ancho_canal/2 + pared_canal, z_sup + altura_max_canal + 1]]],
    [for (y = [y_entrada_motor_alt, y_entrada_motor_az])
        ["la entrada de un motor", [x_tapa0 - 1, y - ancho_entrada_cable/2, z_sup - 1],
         [x_tapa0 + pared_tapa + 1, y + ancho_entrada_cable/2, z_sup + alto_entrada_cable]]]);

// --- SIMULACIÓN DE FUNCIONAMIENTO (visor 3D) ---
// Contrato: specs/007-simulacion-funcionamiento/contracts/ensamblaje.md. La base queda fija; el resto
// gira en azimut; la cuna y lo montado en ella giran en altura. Cada articulación parte del ángulo con
// que el catálogo dibuja sus elementos (reposo).
largo_haz_simulacion = 600;   // largo del haz del láser en el visor
elementos_altura = ["cuna", "laser", "pila_falsa", "tapa_trasera", "lastre", "grapa", "tuerca_munon",
                    "tuerca_munon_cable", "perno_alt_cable", "perno_alt_motor", "polea_alt",
                    "disco_escala", "tornillos_disco"];
elementos_motor_azimut = ["polea20_az"];
elementos_motor_altura = ["polea20_alt"];
elementos_azimut = [for (e = elementos)
    if (!contiene(grupo_base, e) && !contiene(elementos_altura, e) && !contiene(elementos_motor_azimut, e)
        && !contiene(elementos_motor_altura, e) && e != "cable_laser") e];
// Azimut positivo: horario visto desde arriba; altura positiva: sube el láser (tabla del firmware)
articulaciones = [
    ["azimut", "Azimut", elementos_azimut, [0, 0, 0], [0, 0, -1], undef, azimut_reposo, "",
     velocidad_max_eje, "", pasos_por_grado],
    ["altura", "Altura", elementos_altura, [0, 0, z_eje_altura], [1, 0, 0],
     [angulo_altura_min, angulo_altura_max], angulo_altura, "azimut",
     velocidad_max_eje, "angulo_altura", pasos_por_grado]];
// Con correa, las dos poleas giran en el mismo sentido. En altura la polea grande gira con la cuna
// respecto de la horquilla (+); en azimut está fija a la base y el motor viaja con la plataforma (−).
motores = [
    ["motor_azimut", "Motor de azimut", elementos_motor_azimut, [0, distancia_centros, z_sup], [0, 0, 1],
     "azimut", -relacion_correa, "azimut"],
    ["motor_altura", "Motor de altura", elementos_motor_altura, [x_inicio_cubo20_alt, 0, z_eje_motor_alt],
     [1, 0, 0], "altura", relacion_correa, "azimut"]];
// La punta del láser está en +l_delantero sobre el eje del láser (+Y de su sistema)
emisores = [["laser", "Láser", en_conjunto([0, l_delantero, 0], angulo_altura),
             [0, cos(angulo_altura), sin(angulo_altura)], "Lime", "altura", largo_haz_simulacion]];
// Objetivos de demostración del modo automático: [nombre, [azimut, altura]]. El azimut es de brújula
// (0 = norte, horario); la posición modelada (láser hacia +Y, frente a la «S» de la base) es 180° (012).
objetivos = [["Norte bajo", [0, 10]], ["Este", [90, 35]], ["Cenit", [180, 88]], ["Oeste alto", [270, 60]],
             ["Casi norte", [350, 25]], ["Noreste", [10, 45]]];
// El cable va en parte con el láser y en parte con la horquilla: se exporta cada 5° de altura
deformables = [["cable_laser", "altura", [for (a = [angulo_altura_min:5:angulo_altura_max]) a]]];
transparentes_simulacion = ["tapa", "conectores"];

function color_elemento(e) =
    e == "base" ? "SlateGray" : e == "plataforma" ? "DarkSeaGreen" :
    e == "brazo_motor" || e == "brazo_cable" ? "SteelBlue" : e == "cuna" ? "Peru" :
    e == "polea_alt" ? "Goldenrod" : e == "disco_escala" ? "WhiteSmoke" : e == "carro_az" || e == "carro_alt" ? "Khaki" :
    e == "separador" || e == "arandela_sup" || e == "arandela_inf" || e == "arandela_cable" ? "Wheat" :
    e == "tapa" ? "LightGray" : e == "motor_az" || e == "motor_alt" ? "Gold" :
    e == "correa_az" || e == "correa_alt" ? "Black" : e == "placa_uln_az" || e == "placa_uln_alt" ? "ForestGreen" :
    e == "placa_esp32" ? "DarkSlateGray" : e == "placa_rele" ? "Teal" : e == "barra" ? "SaddleBrown" :
    e == "powerbank" ? "DarkBlue" : e == "laser" ? "LimeGreen" :
    e == "pila_falsa" ? "Tomato" : e == "tapa_trasera" || e == "grapa" ? "Peru" : e == "regulador" ? "RoyalBlue" :
    e == "cable_laser" ? "Red" : e == "conectores" ? "LightSlateGray" :
    e == "interruptor" ? "DimGray" : e == "resistencia_rele" ? "Tan" : e == "enchufe_usb" ? "Gainsboro" :
    e == "608_base_sup" || e == "608_base_inf" || e == "608_brazo_motor" || e == "608_brazo_cable"
        || e == "polea20_az" || e == "polea20_alt" ? "Silver" : "DimGray";

module elemento(e) {
    // Piezas impresas
    if (e == "base") pieza_adaptador_tripode();
    if (e == "plataforma") translate([0, 0, z_plataforma_inf]) pieza_plataforma_azimut();
    if (e == "brazo_motor") multmatrix(matriz_brazo_motor) pieza_brazo_horquilla("motor");
    if (e == "brazo_cable") multmatrix(matriz_brazo_cable) pieza_brazo_horquilla("cable");
    if (e == "cuna") laser_en(angulo_altura) cuna_en_conjunto();
    if (e == "polea_alt") translate([x_ext_polea_alt, 0, z_eje_altura]) rotate([angulo_altura, 0, 0])
        rotate([0, -90, 0]) pieza_polea_altitud();
    if (e == "carro_az") translate([0, distancia_centros, z_sup]) rotate([0, 0, 90]) pieza_carro_motor();
    if (e == "carro_alt") multmatrix(matriz_motor_alt) pieza_carro_motor();
    if (e == "separador") translate([0, 0, z_resalte_inf]) cylinder(d = d_contacto_aro, h = largo_separador_azimut);
    if (e == "arandela_sup") translate([0, 0, z_tope_base]) cylinder(d = d_contacto_aro, h = alto_arandela_contacto);
    if (e == "arandela_inf") translate([0, 0, z_camara_sup - alto_arandela_contacto])
        cylinder(d = d_contacto_aro, h = alto_arandela_contacto);
    if (e == "arandela_cable") translate([-x_cara_ext_brazo - alto_arandela_cable, 0, z_eje_altura])
        rotate([0, 90, 0]) cylinder(d = d_contacto_aro, h = alto_arandela_cable);
    if (e == "tapa") translate([0, 0, z_sup]) tapa_en_posicion();
    // Rodamientos, pernos y tuercas M8, tuerca del trípode
    if (e == "tuerca_tripode") translate([0, 0, piso_base]) tuerca(tuerca_3_8_ec, tuerca_3_8_alto);
    if (e == "608_base_sup") translate([0, 0, z_resalte_sup]) rodamiento_608();
    if (e == "608_base_inf") translate([0, 0, z_camara_sup]) rodamiento_608();
    if (e == "608_brazo_motor") translate([x_cara_ext_brazo - rod608_ancho, 0, z_eje_altura]) rotate([0, 90, 0])
        rodamiento_608();
    if (e == "608_brazo_cable") translate([-(x_cara_ext_brazo - rod608_ancho), 0, z_eje_altura]) rotate([0, 90, 0])
        translate([0, 0, -rod608_ancho]) rodamiento_608();
    if (e == "perno_az") translate([0, 0, z_plataforma_inf + espesor_cubo_plataforma - 0.3 - m8_cabeza_alto]) {
        tuerca(m8_cabeza_ec, m8_cabeza_alto);
        translate([0, 0, -largo_perno_azimut]) cylinder(d = rod608_d_int, h = largo_perno_azimut);
    }
    if (e == "autoblocante_az") translate([0, 0, z_camara_sup - alto_arandela_contacto - m8_autoblocante_alto])
        tuerca(m8_tuerca_ec, m8_autoblocante_alto);
    // Lado motor: tuerca en el muñón +X y perno desde afuera, con la cabeza en el hexágono de la polea
    // (gira con ella)
    if (e == "tuerca_munon") laser_en(angulo_altura) translate([diametro_interior_cuna/2, 0, 0]) rotate([0, 90, 0])
        tuerca(m8_tuerca_ec, m8_tuerca_alto);
    if (e == "perno_alt_motor") translate([0, 0, z_eje_altura]) rotate([angulo_altura, 0, 0]) rotate([0, 90, 0]) {
        translate([0, 0, x_punta_perno_alt_motor]) cylinder(d = rod608_d_int, h = largo_perno_alt_motor);
        translate([0, 0, x_punta_perno_alt_motor + largo_perno_alt_motor]) tuerca(m8_cabeza_ec, m8_cabeza_alto);
    }
    // Lado cable: igual, con la cabeza sobre la arandela de contacto
    if (e == "tuerca_munon_cable") laser_en(angulo_altura) translate([-diametro_interior_cuna/2, 0, 0])
        rotate([0, -90, 0]) tuerca(m8_tuerca_ec, m8_tuerca_alto);
    if (e == "perno_alt_cable") translate([0, 0, z_eje_altura]) rotate([angulo_altura, 0, 0]) rotate([0, -90, 0]) {
        translate([0, 0, x_punta_perno_alt_motor]) cylinder(d = rod608_d_int, h = largo_perno_alt_cable);
        translate([0, 0, x_punta_perno_alt_motor + largo_perno_alt_cable]) tuerca(m8_cabeza_ec, m8_cabeza_alto);
    }
    // Disco de la escala (012): sobre la cara exterior de la polea, con la escala hacia +X; gira con la cuna
    if (e == "disco_escala") translate([x_ext_polea_alt, 0, z_eje_altura]) rotate([angulo_altura, 0, 0])
        rotate([0, 90, 0]) pieza_disco_escala();
    if (e == "tornillos_disco") translate([x_punta_aguja, 0, z_eje_altura]) rotate([angulo_altura, 0, 0])
        for (s = [-1, 1]) translate([0, 0, s*r_agujeros_disco]) rotate([0, 90, 0]) {
            cylinder(d = d_arandela_m3, h = alto_arandela_m3, $fn = 20);
            translate([0, 0, alto_arandela_m3]) tornillo_m3(8);
        }
    // Motores, poleas 20T y correas
    if (e == "motor_az") translate([0, distancia_centros, z_sup + espesor_carro]) rotate([0, 0, 90]) rotate([180, 0, 0])
        motor_28byj();
    if (e == "motor_alt") multmatrix(matriz_motor_alt) motor_28byj();
    if (e == "polea20_az") translate([0, distancia_centros, z_sup]) polea20();
    if (e == "polea20_alt") multmatrix(matriz_polea20_alt) polea20();
    if (e == "correa_az") translate([0, 0, z_dientes_polea20_az - ancho_correa/2]) linear_extrude(height = ancho_correa)
        correa_2d();
    if (e == "correa_alt") translate([plano_correa_altura - ancho_correa/2, 0, z_eje_altura]) rotate([0, 90, 0])
        linear_extrude(height = ancho_correa) rotate([0, 0, -90]) correa_2d();
    // Tornillería M3
    if (e == "tornillos_pie") for (s = [-1, 1], t = [-1, 1])
        translate([s*x_pie_brazo, t*separacion_tornillos_pie/2, z_plataforma_inf]) rotate([180, 0, 0])
            tornillo_m3(12);
    // Tuercas del pie: en la ranura de cada brazo, que se abre hacia su cara exterior
    if (e == "tuercas_pie_motor" || e == "tuercas_pie_cable") let (s = e == "tuercas_pie_motor" ? 1 : -1)
        for (t = [-1, 1])
            translate([s*x_pie_brazo, t*separacion_tornillos_pie/2, z_sup + dist_tuerca_pie - m3_tuerca_alto/2])
                tuerca(m3_tuerca_ec, m3_tuerca_alto);
    if (e == "tornillos_carro_az") for (s = [-1, 1])
        translate([s*ranura_carro_y, distancia_centros + ranura_carro_x, z_sup + espesor_carro]) tornillo_m3(10);
    if (e == "tuercas_carro_az") for (s = [-1, 1])
        translate([s*ranura_carro_y, distancia_centros + ranura_carro_x, z_plataforma_inf])
            tuerca(m3_tuerca_ec, m3_tuerca_alto);
    if (e == "tornillos_orejas_az") for (s = [-1, 1])
        translate([s*motor_entre_orejas/2, distancia_centros + motor_desplazamiento_eje,
                   z_sup + espesor_carro + espesor_oreja_motor]) tornillo_m3(8);
    if (e == "tornillos_orejas_alt") multmatrix(matriz_motor_alt) for (s = [-1, 1])
        translate([motor_desplazamiento_eje, s*motor_entre_orejas/2, -espesor_oreja_motor]) rotate([180, 0, 0])
            tornillo_m3(8);
    if (e == "tornillos_carro_alt") multmatrix(matriz_motor_alt) for (s = [-1, 1])
        translate([ranura_carro_x, s*ranura_carro_y, espesor_carro]) tornillo_m3(12);
    if (e == "tornillos_tapa") for (y = y_orejas_tapa)
        translate([x_tapa_c, y, z_sup + espesor_oreja_tapa]) tornillo_m3(10);
    if (e == "tuercas_tapa") for (y = y_orejas_tapa)
        translate([x_tapa_c, y, z_plataforma_inf]) tuerca(m3_tuerca_ec, m3_tuerca_alto);
    // Electrónica y láser
    if (e == "placa_uln_alt")
        placa(x_col_a0, y_uln_alt0, uln2003_ancho, uln2003_largo, alto_soporte_placa, altura_placas - alto_soporte_placa);
    if (e == "placa_uln_az")
        placa(x_col_a0, y_uln_az0, uln2003_ancho, uln2003_largo, alto_soporte_placa, altura_placas - alto_soporte_placa);
    if (e == "placa_esp32")
        placa(x_col_b0, y_esp32_0, esp32_ancho, esp32_largo, elevacion_esp32, alto_modulo_esp32 + espesor_pcb);
    if (e == "placa_rele")
        placa(x_col_b0, y_rele_0, rele_ancho, rele_largo, alto_soporte_placa, altura_placas - alto_soporte_placa);
    // Barra de distribución (010, research R2): placa perforada con una tira de pines en cada columna de
    // los costados, en los agujeros 2 a pines_barra + 1 (el 1 y el último quedan sobre los apoyos)
    if (e == "barra") {
        placa(x_barra0, y_barra0, barra_ancho, barra_largo, alto_soporte_placa, espesor_pcb);
        for (c = [0, 2], i = [1:pines_barra])
            translate([x_barra0 + m_placa + (c + 0.5)*paso_pines, y_barra0 + m_placa + (i + 0.5)*paso_pines,
                       z_sup + alto_soporte_placa + espesor_pcb]) {
                translate([-paso_pines/2, -paso_pines/2, 0]) cube([paso_pines, paso_pines, alto_tira_pines]);
                translate([-0.32, -0.32, 0]) cube([0.64, 0.64, alto_tira_pines + largo_pin_macho]);
            }
    }
    if (e == "powerbank")
        translate([x_pb1 + pared_bolsillo + holgura_encastre, y_pb0 + pared_bolsillo + holgura_encastre, z_sup])
            cube([powerbank_alto, powerbank_largo, powerbank_ancho]);
    if (e == "laser") laser_en(angulo_altura) laser();
    if (e == "pila_falsa") laser_en(angulo_altura) translate([0, y_borde_tubo, 0]) rotate([-90, 0, 0])
        rotate([0, 0, angulo_cable]) pieza_pila_falsa();
    if (e == "tapa_trasera") laser_en(angulo_altura) translate([0, -l_trasero, 0]) rotate([-90, 0, 0])
        pieza_tapa_trasera();
    if (e == "lastre" && tuercas_lastre_tapa > 0) laser_en(angulo_altura) translate([0, -l_trasero, 0]) rotate([-90, 0, 0])
        for (i = [0:tuercas_lastre_tapa - 1]) translate([0, 0, piso_tapa_trasera + i*m10_tuerca_alto]) difference() {
            tuerca(m10_tuerca_ec, m10_tuerca_alto);
            translate([0, 0, -1]) cylinder(d = 10, h = m10_tuerca_alto + 2);
        }
    if (e == "grapa") laser_en(angulo_altura) translate([0, y_grapa, 0]) rotate([-90, 0, 0]) pieza_grapa_cable();
    if (e == "regulador")
        placa(x_col_a0, y_reg0, regulador_ancho, regulador_largo, alto_soporte_placa, alto_modulo_regulador);
    // Interruptor general (011): en su soporte, con las patas hacia −X y la palanca hacia +X
    if (e == "interruptor") {
        z = z_sup + alto_interruptor;
        translate([x_interruptor - fondo_interruptor, y_interruptor - ancho_cuerpo_interruptor/2, z - alto_cuerpo_interruptor/2])
            cube([fondo_interruptor, ancho_cuerpo_interruptor, alto_cuerpo_interruptor]);
        for (dy = [-separacion_patas_interruptor, 0, separacion_patas_interruptor])
            translate([x_patas_interruptor, y_interruptor + dy - ancho_pata_interruptor/2, z - espesor_pata_interruptor/2])
                cube([largo_patas_interruptor, ancho_pata_interruptor, espesor_pata_interruptor]);
        translate([x_interruptor, y_interruptor, z]) rotate([0, 90, 0]) {
            cylinder(d = d_interruptor, h = largo_buje_interruptor);
            translate([0, 0, largo_buje_interruptor]) cylinder(d = d_palanca_interruptor, h = largo_palanca_interruptor);
        }
    }
    // Enchufe USB-A (011): funda en el puerto del power bank y alivio de tracción del cable
    if (e == "enchufe_usb") {
        translate(puerto_usb_powerbank - [ancho_enchufe_usb/2, largo_funda_usb, alto_enchufe_usb/2])
            cube([ancho_enchufe_usb, largo_funda_usb, alto_enchufe_usb]);
        translate(puerto_usb_powerbank - [0, largo_funda_usb, 0]) rotate([90, 0, 0])
            cylinder(d = d_alivio_usb, h = largo_alivio_usb);
    }
    // Resistencia de 10 kΩ (011): del lado de las soldaduras del relé, con las patas a IN y GND
    if (e == "resistencia_rele") {
        a = pin("Relé", "IN");
        b = pin("Relé", "GND");
        z_pcb = z_sup + alto_soporte_placa;
        centro = [(a[0] + b[0])/2, a[1] + corrimiento_resistencia, z_pcb - d_resistencia/2 - d_pata_resistencia];
        translate(centro - [largo_resistencia/2, 0, 0]) rotate([0, 90, 0]) cylinder(d = d_resistencia, h = largo_resistencia);
        for (x = [[a, -1], [b, 1]]) hull() {
            translate(centro + [x[1]*largo_resistencia/2, 0, 0]) sphere(d = d_pata_resistencia, $fn = 8);
            translate([x[0][0], x[0][1], z_pcb]) sphere(d = d_pata_resistencia, $fn = 8);
        }
    }
    // Espacio reservado para los conectores con la curva de sus cables (009, data-model §3); no es una
    // pieza: el visor lo muestra en el paso de cableado
    if (e == "conectores") {
        // Dupont y enchufes hacia arriba, sobre toda la planta de las placas bajas
        for (c = [[x_col_a0, y_uln_alt0, uln2003_ancho, uln2003_largo], [x_col_a0, y_uln_az0, uln2003_ancho, uln2003_largo],
                  [x_col_b0, y_rele_0, rele_ancho, rele_largo], [x_barra0, y_barra0, barra_ancho, barra_largo]])
            translate([c[0] + m_placa, c[1] + m_placa, z_sup + alto_soporte_placa + espesor_pcb])
                cube([c[2], c[3], alto_dupont_conectado]);
        // Dupont del ESP32 hacia abajo: una franja por fila, con la curva del cable hacia el centro
        for (lado = [0, 1])
            translate([lado == 0 ? x_esp32_0 : x_esp32_0 + esp32_ancho - ancho_franja_esp32,
                       y_esp32_0 + m_placa + (esp32_largo - largo_fila_esp32)/2, z_sup + elevacion_esp32 - alto_dupont_conectado])
                cube([ancho_franja_esp32, largo_fila_esp32, alto_dupont_conectado]);
        // Enchufe USB con su funda, del borde del ESP32 hasta afuera de la tapa
        translate([x_esp32_c - ancho_enchufe_usb/2, y_tapa0 - largo_usb_fuera, z_sup + z_usb_esp32 - alto_enchufe_usb/2])
            cube([ancho_enchufe_usb, y_esp32_0 + m_placa - y_tapa0 + largo_usb_fuera, alto_enchufe_usb]);
    }
    if (e == "cable_laser") {
        laser_en(angulo_altura) cordon(cable_laser_movil);
        cordon(cable_laser_fijo(angulo_altura));
    }
}

// Puntos de cada elemento donde se dibuja la flecha de la vista explotada
function anclas(e) =
    e == "base" || e == "tuerca_tripode" ? [[0, 0, piso_base + tuerca_3_8_alto/2]] :
    e == "608_base_sup" ? [[0, 0, z_resalte_sup + rod608_ancho/2]] :
    e == "608_base_inf" ? [[0, 0, z_camara_sup + rod608_ancho/2]] :
    e == "tuerca_munon" ? [[diametro_interior_cuna/2 + m8_tuerca_alto/2, 0, z_eje_altura]] :
    e == "perno_alt_motor" ? [[x_punta_perno_alt_motor, 0, z_eje_altura]] :
    // Disco de la escala y sus tornillos (012): la flecha llega a la cara exterior de la polea, en el
    // agujero central del disco y en cada tornillo
    e == "disco_escala" ? [[x_punta_aguja, 0, z_eje_altura]] :
    e == "tornillos_disco" ? [for (s = [-1, 1]) [x_punta_aguja + alto_arandela_m3 + alto_cabeza_m3, 0, z_eje_altura]
                                                  + s*r_agujeros_disco*[0, -sin(angulo_altura), cos(angulo_altura)]] :
    e == "tuerca_munon_cable" ? [[-diametro_interior_cuna/2 - m8_tuerca_alto/2, 0, z_eje_altura]] :
    e == "perno_alt_cable" ? [[-x_punta_perno_alt_motor - largo_perno_alt_cable, 0, z_eje_altura]] :
    e == "608_brazo_motor" ? [[x_cara_ext_brazo, 0, z_eje_altura]] :
    e == "608_brazo_cable" ? [[-x_cara_ext_brazo, 0, z_eje_altura]] :
    e == "brazo_motor" ? [[x_pie_brazo, 0, z_sup], [x_pie_brazo, 0, z_eje_altura]] :   // pie y eje
    e == "brazo_cable" ? [[-x_pie_brazo, 0, z_sup], [-x_pie_brazo, 0, z_eje_altura]] :
    e == "tornillos_pie" ? [for (s = [-1, 1]) [s*x_pie_brazo, 0, z_plataforma_inf - alto_cabeza_m3]] :
    e == "tuercas_pie_motor" ? [[x_pie_brazo, 0, z_sup + dist_tuerca_pie]] :
    e == "tuercas_pie_cable" ? [[-x_pie_brazo, 0, z_sup + dist_tuerca_pie]] :
    e == "motor_az" || e == "carro_az" ? [[0, distancia_centros + motor_desplazamiento_eje, z_sup + espesor_carro]] :
    e == "tornillos_orejas_az" ? [for (s = [-1, 1]) [s*motor_entre_orejas/2, distancia_centros + motor_desplazamiento_eje, z_sup + 10]] :
    e == "motor_alt" || e == "carro_alt" ? [[x_cara_int_carro_alt, 0, z_eje_motor_alt - motor_desplazamiento_eje]] :
    e == "tornillos_orejas_alt" ? [for (s = [-1, 1]) [x_cara_int_carro_alt - 10, s*motor_entre_orejas/2, z_eje_motor_alt - motor_desplazamiento_eje]] :
    e == "tornillos_carro_az" ? [for (s = [-1, 1]) [s*ranura_carro_y, distancia_centros + ranura_carro_x, z_sup + 10]] :
    e == "tuercas_carro_az" ? [for (s = [-1, 1]) [s*ranura_carro_y, distancia_centros + ranura_carro_x, z_plataforma_inf]] :
    e == "tornillos_carro_alt" ? [for (s = [-1, 1]) [x_cara_int_carro_alt + espesor_carro, s*ranura_carro_y, z_eje_motor_alt - ranura_carro_x]] :
    e == "polea20_az" ? [[0, distancia_centros, z_sup - polea20_alto_total]] :
    e == "polea20_alt" ? [[x_inicio_cubo20_alt + polea20_alto_total, 0, z_eje_motor_alt]] :
    e == "correa_az" ? [[0, distancia_centros/2, z_dientes_polea20_az]] :
    e == "correa_alt" ? [[plano_correa_altura, 0, z_eje_altura - distancia_centros/2]] :
    e == "arandela_sup" ? [[0, 0, z_tope_base]] :
    e == "perno_az" ? [[0, 0, z_plataforma_inf + espesor_cubo_plataforma]] :
    e == "separador" ? [[0, 0, z_resalte_inf]] :
    e == "arandela_inf" || e == "autoblocante_az" ? [[0, 0, z_camara_sup - alto_arandela_contacto]] :
    e == "cuna" ? [[0, 0, z_eje_altura]] :
    e == "arandela_cable" ? [[-(x_cara_ext_brazo + alto_arandela_cable), 0, z_eje_altura]] :
    e == "polea_alt" ? [[x_cara_ext_brazo, 0, z_eje_altura + d_exterior_conducida/3]] :   // sobre el perno
    e == "laser" ? [[0, 0, z_eje_altura] + (l_trasero + 130)*v_laser] :   // detrás del láser, no dentro
    e == "pila_falsa" || e == "lastre" || e == "tapa_trasera" ? [[0, 0, z_eje_altura] + (l_trasero + 3)*v_laser] :
    e == "grapa" ? [en_conjunto([0, y_grapa + ancho_grapa/2, diametro_laser/2 + pared_grapa + 1], angulo_altura)] :
    e == "regulador" ? let (m = pared_soporte + holgura_encastre)
        [[x_col_a0 + m + regulador_ancho/2, y_reg0 + m + regulador_largo/2, z_sup + alto_soporte_placa + 4]] :
    e == "cable_laser" ? [[x_cara_int_brazo_cable, 0, z_eje_altura - dist_agujero_cable]] :
    // Placas: centro de cada una, bajo su apoyo
    e == "placa_uln_alt" ? [[x_col_a0 + m_placa + uln2003_ancho/2, y_uln_alt0 + m_placa + uln2003_largo/2, z_sup]] :
    e == "placa_uln_az" ? [[x_col_a0 + m_placa + uln2003_ancho/2, y_uln_az0 + m_placa + uln2003_largo/2, z_sup]] :
    e == "placa_esp32" ? [[x_col_b0 + m_placa + esp32_ancho/2, y_esp32_0 + m_placa + esp32_largo/2, z_sup]] :
    e == "placa_rele" ? [[x_col_b0 + m_placa + rele_ancho/2, y_rele_0 + m_placa + rele_largo/2, z_sup]] :
    e == "barra" ? [[x_barra0 + m_placa + barra_ancho/2, y_barra0 + m_placa + barra_largo/2, z_sup]] :
    e == "enchufe_usb" ? [puerto_usb_powerbank - [0, largo_funda_usb/2, -alto_enchufe_usb/2]] :
    e == "interruptor" ? [[x_interruptor - fondo_interruptor/2, y_interruptor, z_sup + alto_interruptor + alto_cuerpo_interruptor/2]] :
    e == "resistencia_rele" ? [[(pin("Relé", "IN")[0] + pin("Relé", "GND")[0])/2, pin("Relé", "IN")[1] + corrimiento_resistencia,
                                z_sup + altura_placas]] :
    e == "powerbank" ? [[x_pb1 + pared_bolsillo + holgura_encastre + powerbank_alto/2, y_pb0 + powerbank_largo/2, z_sup]] :
    e == "tapa" ? [[x_tapa_c, (y_tapa0 + y_tapa1)/2, z_sup + alto_tapa]] :
    e == "tornillos_tapa" ? [for (y = y_orejas_tapa) [x_tapa_c, y, z_sup + 10]] :
    e == "tuercas_tapa" ? [for (y = y_orejas_tapa) [x_tapa_c, y, z_plataforma_inf]] :
    [[0, 0, 0]];

// --- UTILIDADES ---
// Gira un objeto definido en el sistema del láser (eje del láser sobre +Y, eje de altura en el origen)
module laser_en(a) {
    translate([0, 0, z_eje_altura]) rotate([a, 0, 0]) children();
}
module cuna_en_conjunto() {
    rotate([-90, 0, 0]) translate([0, 0, -largo_tubo_cuna/2]) pieza_cuna_laser();
}
// Tubo del láser sin la tapa original: del borde trasero (y_borde_tubo) al frente, hueco donde iba la batería
module laser() {
    rotate([-90, 0, 0]) translate([0, 0, y_borde_tubo]) difference() {
        cylinder(d = diametro_laser, h = largo_laser_sin_tapa);
        translate([0, 0, -1]) cylinder(d = diametro_hueco_bateria, h = profundidad_hueco_bateria + 1);
    }
}
// Cable de 2 hilos (un cordón de 2·d_hilo) por una lista de puntos
module cordon(puntos) {
    for (i = [0:len(puntos) - 2]) hull() {
        translate(puntos[i]) sphere(d = 2*d_hilo, $fn = 12);
        translate(puntos[i + 1]) sphere(d = 2*d_hilo, $fn = 12);
    }
}

module rodamiento_608() {
    difference() {
        cylinder(d = rod608_d_ext, h = rod608_ancho);
        translate([0, 0, -1]) cylinder(d = rod608_d_int, h = rod608_ancho + 2);
    }
}

// Tuerca o cabeza hexagonal: entre caras "ec", base en z = 0
module tuerca(ec, alto) {
    cylinder(d = ec/cos(30), h = alto, $fn = 6);
}

// Tornillo M3: cabeza sobre z = 0, vástago hacia −Z
module tornillo_m3(largo) {
    cylinder(d = m3_cabeza_d, h = alto_cabeza_m3, $fn = 20);
    translate([0, 0, -largo]) cylinder(d = m3_d, h = largo, $fn = 16);
}

// Sistema del motor: eje sobre +Z desde la cara de las orejas (z = 0); cuerpo hacia −Z y +X.
module motor_28byj() {
    translate([motor_desplazamiento_eje, 0, -motor_alto_cuerpo]) cylinder(d = motor_d_cuerpo, h = motor_alto_cuerpo);
    translate([motor_desplazamiento_eje + motor_d_cuerpo/2 - 2, -motor_tapa_ancho/2, -motor_alto_cuerpo])
        cube([motor_tapa_saliente + 2, motor_tapa_ancho, motor_alto_cuerpo]);
    translate([motor_desplazamiento_eje, 0, -espesor_oreja_motor]) hull()
        for (s = [-1, 1]) translate([0, s*motor_entre_orejas/2, 0]) cylinder(d = motor_d_oreja, h = espesor_oreja_motor);
    cylinder(d = motor_d_resalte, h = motor_alto_resalte);
    cylinder(d = motor_d_eje, h = motor_largo_eje);
}

// Sistema de la polea 20T: cara superior del cubo en z = 0, la polea hacia −Z.
module polea20() {
    translate([0, 0, -polea20_alto_cubo]) cylinder(d = polea20_d_cubo, h = polea20_alto_cubo);
    translate([0, 0, -polea20_alto_cubo - polea20_espesor_brida]) cylinder(d = polea20_d_brida, h = polea20_espesor_brida);
    translate([0, 0, -polea20_alto_total + polea20_espesor_brida]) cylinder(d = d_primitivo_motriz, h = h_dentado);
    translate([0, 0, -polea20_alto_total]) cylinder(d = polea20_d_brida, h = polea20_espesor_brida);
}

// Correa en 2D: polea conducida en el origen y motriz en [0, distancia_centros]
module correa_2d() {
    difference() {
        hull() {
            circle(d = d_primitivo_conducida + grosor_correa);
            translate([0, distancia_centros]) circle(d = d_primitivo_motriz + grosor_correa);
        }
        hull() {
            circle(d = d_primitivo_conducida - grosor_correa);
            translate([0, distancia_centros]) circle(d = d_primitivo_motriz - grosor_correa);
        }
    }
}

module placa(x0, y0, a, l, z_apoyo, alto) {
    translate([x0 + pared_soporte + holgura_encastre, y0 + pared_soporte + holgura_encastre, z_sup + z_apoyo])
        cube([a, l, alto]);
}
