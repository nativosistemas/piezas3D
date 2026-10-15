// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Ensamblaje (solo revisión, NO se exporta)
// Descripción: Coloca todas las piezas en su posición del conjunto, dibuja los componentes
//              comprados como volúmenes simplificados (motores, poleas 20T, correas, 608ZZ, pernos,
//              tornillería, placas, regulador, power bank y láser sin batería con su pila falsa, tapa
//              trasera, lastre, grapa y cable) y comprueba con asserts los choques y
//              alineaciones que no se pueden ver en una pieza sola (V-07, V-09 y separaciones entre
//              piezas). Las vistas explotadas y los datos del visor 3D salen de la tabla de pasos con la
//              biblioteca común armado_comun.scad.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
include <puntero_laser_parametros.scad>
use <puntero_laser_adaptador_tripode.scad>
use <puntero_laser_plataforma_azimut.scad>
use <puntero_laser_brazo_horquilla.scad>
use <puntero_laser_cuna_laser.scad>
use <puntero_laser_polea_altitud.scad>
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

// Recorridos de los cables de los motores (009, research R6; tabla de recorridos de la guía). El cable
// sale de la tapa azul del motor, a media altura del cuerpo; corre sobre la plataforma y termina en el
// enchufe de su ULN2003 (centro de la placa, a la altura del enchufe).
salida_cable_motor = [motor_desplazamiento_eje + motor_d_cuerpo/2 + motor_tapa_saliente, 0, -motor_alto_cuerpo/2];
z_cable_plataforma = z_sup + 2;
function aplicar_matriz(m, p) = [for (i = [0:2]) m[i][0]*p[0] + m[i][1]*p[1] + m[i][2]*p[2] + m[i][3]];
function largo_polilinea(p) = len(p) < 2 ? 0 : norm(p[1] - p[0]) + largo_polilinea([for (i = [1:len(p) - 1]) p[i]]);
function enchufe_uln(y0) = [x_col_a0 + m_placa + uln2003_ancho/2, y0 + m_placa + uln2003_largo/2, z_sup + alto_enchufes_motor];
function hasta_enchufe(y_entrada, enchufe) = [[x_tapa0, y_entrada, z_cable_plataforma],
    [enchufe[0], enchufe[1], z_cable_plataforma], enchufe];
// Altura: baja por el canal de la cara exterior del brazo motor y entra por la pared −X de la tapa.
// El motor va en el brazo: el recorrido no cambia con el ángulo de altura.
salida_cable_alt = aplicar_matriz(matriz_motor_alt, salida_cable_motor);
recorrido_cable_alt = concat([salida_cable_alt, [x_cara_ext_brazo, salida_cable_alt[1], salida_cable_alt[2]],
                              [x_cara_ext_brazo, y_entrada_motor_alt, z_cable_plataforma]],
                             hasta_enchufe(y_entrada_motor_alt, enchufe_uln(y_uln_alt0)));
// Azimut: del motor a la brida del puente de la plataforma y de ahí a la pared −X de la tapa
salida_cable_az = [salida_cable_motor[1], distancia_centros + salida_cable_motor[0],
                   z_sup + espesor_carro - salida_cable_motor[2]];
recorrido_cable_az = concat([salida_cable_az, [x_puente_brida_az, y_puente_brida_az, z_cable_plataforma]],
                            hasta_enchufe(y_entrada_motor_az, enchufe_uln(y_uln_az0)));
largo_cable_alt = largo_polilinea(recorrido_cable_alt);
largo_cable_az = largo_polilinea(recorrido_cable_az);

// Vista explotada: transparencia de lo ya armado, color y grosor de las flechas
alfa_contexto = 0.22;
color_flecha = "OrangeRed";
diametro_flecha = 2.4;
// Dirección del láser al entrar en la cuna (desde atrás, a lo largo de su eje)
v_laser = [0, -cos(angulo_altura), -sin(angulo_altura)];
// La polea y su perno se enroscan en la tuerca del muñón +X: dos vueltas alrededor del eje de altura
// (solo el visor 3D muestra el giro)
giro_enroscar = [[0, 0, z_eje_altura], [1, 0, 0], 720];

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
                   "perno_alt_motor", "perno_alt_cable", "arandela_cable", "autoblocante_cable", "polea_alt"];
grupo_motor_alt = ["carro_alt", "motor_alt", "tornillos_orejas_alt"];
paso_union_horquilla = 8;   // la horquilla armada se atornilla a la plataforma
paso_union_base = 11;       // la plataforma se monta sobre la base
paso_union_motor_alt = 13;  // el carro del motor de altura se monta en el brazo motor
subconjunto_plataforma = concat(grupo_horquilla,
                                ["plataforma", "tuercas_pie_motor", "tuercas_pie_cable", "tornillos_pie",
                                 "carro_az", "motor_az", "tornillos_orejas_az", "tuercas_carro_az",
                                 "tornillos_carro_az", "polea20_az"]);
// Placas electrónicas: un elemento por placa, para que el visor nombre cada una
placas = ["placa_uln_alt", "placa_uln_az", "placa_esp32", "placa_rele"];
pasos = [
    /* 1 */ [["base", [0, 0, 0], false], ["tuerca_tripode", [0, 0, 70], true]],
    /* 2 */ [["608_base_sup", [0, 0, 60], true], ["608_base_inf", [0, -60, 0], true]],
    /* 3 */ [["cuna", [0, 0, 0], false], ["perno_alt_cable", -130*v_laser, true]],
    /* 4 */ [["brazo_motor", [0, 0, 0], true], ["brazo_cable", [0, 0, 0], true],
             ["608_brazo_motor", [45, 0, 0], true], ["608_brazo_cable", [-45, 0, 0], true]],
    /* 5 */ [["brazo_motor", [50, 0, 0], true], ["brazo_cable", [-50, 0, 0], true],
             ["608_brazo_motor", [50, 0, 0], false], ["608_brazo_cable", [-50, 0, 0], false]],
    /* 6 */ [["arandela_cable", [-30, 0, 0], true], ["autoblocante_cable", [-50, 0, 0], true]],
    /* 7 */ [["tuerca_munon", -130*v_laser, true],
             ["polea_alt", [45, 0, 0], true, undef, giro_enroscar],
             ["perno_alt_motor", [45, 0, 0], true, undef, giro_enroscar]],
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
    /* 14 */ [["laser", [0, 0, 0], false], ["pila_falsa", 120*v_laser, true], ["lastre", 90*v_laser, true],
              ["tapa_trasera", 60*v_laser, true], ["grapa", [0, 0, 35], true]],
    /* 15 */ concat([["laser", 150*v_laser, true]],
                    [for (e = ["pila_falsa", "lastre", "tapa_trasera", "grapa"]) [e, 150*v_laser, false]]),
    /* 16 */ concat([for (e = placas) [e, [0, 0, 70], true]],
                    [["regulador", [0, 0, 150], true], ["powerbank", [0, 0, 100], true]]),
    /* 17 */ [["cable_laser", [-40, 0, 0], true], ["conectores", [0, 0, 0], true]],
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
// V-26: los cables de fábrica de los motores llegan a su ULN2003 por el recorrido de la guía (009, R6)
assert(largo_cable_alt + reserva_cable_motor <= largo_cable_motor,
    str("largo_cable_motor=", largo_cable_motor, ": el cable del motor de altura no llega (faltan ",
        largo_cable_alt + reserva_cable_motor - largo_cable_motor, " mm)"));
assert(largo_cable_az + reserva_cable_motor <= largo_cable_motor,
    str("largo_cable_motor=", largo_cable_motor, ": el cable del motor de azimut no llega (faltan ",
        largo_cable_az + reserva_cable_motor - largo_cable_motor, " mm)"));
echo(str("CABLES largo_alt=", largo_cable_alt, ", largo_az=", largo_cable_az,
         ", sobra_alt=", largo_cable_motor - largo_cable_alt, ", sobra_az=", largo_cable_motor - largo_cable_az));
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
// Tabla de pasos: un paso por cada instrucción de la guía (los elementos los comprueba armado())
assert(len(pasos) == 19, "pasos: la guía tiene 19 pasos de armado");

// --- MÓDULOS PRINCIPALES Y ENSAMBLAJE ---
armado();

module ensamblaje_principal() {
    for (e = elementos) if (e != "tapa" && e != "conectores") color(color_elemento(e)) elemento(e);
    if (ver_tapa) %elemento("tapa");
    %elemento("conectores");
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
             "perno_az", "autoblocante_az", "tuerca_munon", "perno_alt_motor", "perno_alt_cable",
             "autoblocante_cable", "motor_az", "motor_alt", "polea20_az", "polea20_alt", "correa_az", "correa_alt",
             "tornillos_pie", "tuercas_pie_motor", "tuercas_pie_cable", "tornillos_carro_az", "tuercas_carro_az",
             "tornillos_orejas_az", "tornillos_orejas_alt", "tornillos_carro_alt", "tornillos_tapa", "tuercas_tapa",
             "placa_uln_alt", "placa_uln_az", "placa_esp32", "placa_rele", "powerbank", "laser", "pila_falsa", "lastre", "tapa_trasera", "grapa", "regulador",
             "cable_laser", "conectores"];

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
    ["perno_alt_cable", "Perno M8 × 30 mm (eje de altura, lado cable)",   "comprada"],
    ["autoblocante_cable", "Tuerca autoblocante M8 (eje de altura, lado cable)", "comprada"],
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
    ["tornillos_tapa",  "Tornillo M3 × 10 mm: tapa (2)",                  "comprada"],
    ["tuercas_tapa",    "Tuerca M3: tapa (2)",                            "comprada"],
    // Electrónica y láser
    ["placa_esp32",     "ESP32 DevKit",                                   "comprada"],
    ["placa_rele",      "Módulo relé de 1 canal (lógica de 3,3 V)",       "comprada"],
    ["placa_uln_az",    "Placa driver ULN2003 (motor de azimut)",         "comprada"],
    ["placa_uln_alt",   "Placa driver ULN2003 (motor de altura)",         "comprada"],
    ["regulador",       "Módulo reductor de tensión MP1584EN (3,7 V)",    "comprada"],
    ["powerbank",       "Power bank USB de 5 V y ≥ 2 A",                  "comprada"],
    ["laser",           "Puntero láser verde \"303\" (sin su batería)",   "comprada"],
    ["cable_laser",     "Cable de silicona de 2 × 26 AWG (regulador → láser)", "comprada"],
    ["conectores",      "Cables Dupont y enchufes (espacio reservado)",   "comprada"]];

// --- SIMULACIÓN DE FUNCIONAMIENTO (visor 3D) ---
// Contrato: specs/007-simulacion-funcionamiento/contracts/ensamblaje.md. La base queda fija; el resto
// gira en azimut; la cuna y lo montado en ella giran en altura. Cada articulación parte del ángulo con
// que el catálogo dibuja sus elementos (reposo).
largo_haz_simulacion = 600;   // largo del haz del láser en el visor
elementos_altura = ["cuna", "laser", "pila_falsa", "tapa_trasera", "lastre", "grapa", "tuerca_munon",
                    "perno_alt_cable", "perno_alt_motor", "polea_alt"];
elementos_motor_azimut = ["polea20_az"];
elementos_motor_altura = ["polea20_alt"];
elementos_azimut = [for (e = elementos)
    if (!contiene(grupo_base, e) && !contiene(elementos_altura, e) && !contiene(elementos_motor_azimut, e)
        && !contiene(elementos_motor_altura, e) && e != "cable_laser") e];
// Azimut positivo: horario visto desde arriba; altura positiva: sube el láser (tabla del firmware)
articulaciones = [
    ["azimut", "Azimut", elementos_azimut, [0, 0, 0], [0, 0, -1], undef, 0, "",
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
// Objetivos de demostración del modo automático: [nombre, [azimut, altura]]
objetivos = [["Norte bajo", [0, 10]], ["Este", [90, 35]], ["Cenit", [180, 88]], ["Oeste alto", [270, 60]],
             ["Casi norte", [350, 25]], ["Noreste", [10, 45]]];
// El cable va en parte con el láser y en parte con la horquilla: se exporta cada 5° de altura
deformables = [["cable_laser", "altura", [for (a = [angulo_altura_min:5:angulo_altura_max]) a]]];
transparentes_simulacion = ["tapa", "conectores"];

function color_elemento(e) =
    e == "base" ? "SlateGray" : e == "plataforma" ? "DarkSeaGreen" :
    e == "brazo_motor" || e == "brazo_cable" ? "SteelBlue" : e == "cuna" ? "Peru" :
    e == "polea_alt" ? "Goldenrod" : e == "carro_az" || e == "carro_alt" ? "Khaki" :
    e == "separador" || e == "arandela_sup" || e == "arandela_inf" || e == "arandela_cable" ? "Wheat" :
    e == "tapa" ? "LightGray" : e == "motor_az" || e == "motor_alt" ? "Gold" :
    e == "correa_az" || e == "correa_alt" ? "Black" : e == "placa_uln_az" || e == "placa_uln_alt" ? "ForestGreen" :
    e == "placa_esp32" ? "DarkSlateGray" : e == "placa_rele" ? "Teal" :
    e == "powerbank" ? "DarkBlue" : e == "laser" ? "LimeGreen" :
    e == "pila_falsa" ? "Tomato" : e == "tapa_trasera" || e == "grapa" ? "Peru" : e == "regulador" ? "RoyalBlue" :
    e == "cable_laser" ? "Red" : e == "conectores" ? "LightSlateGray" :
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
    if (e == "arandela_cable") translate([-x_cara_ext_brazo - alto_arandela_contacto, 0, z_eje_altura])
        rotate([0, 90, 0]) cylinder(d = d_contacto_aro, h = alto_arandela_contacto);
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
    if (e == "perno_alt_cable") laser_en(angulo_altura) translate([-x_cabeza_m8_cuna, 0, 0]) {
        rotate([0, -90, 0]) cylinder(d = rod608_d_int, h = largo_perno_alt_cable);
        rotate([0, 90, 0]) tuerca(m8_cabeza_ec, m8_cabeza_alto);   // cabeza en el muñón −X
    }
    if (e == "autoblocante_cable") translate([-(x_cara_ext_brazo + alto_arandela_contacto), 0, z_eje_altura])
        rotate([0, -90, 0]) tuerca(m8_tuerca_ec, m8_autoblocante_alto);
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
        placa(x_col_a0, y_reg0, regulador_ancho, regulador_largo, alto_soporte_placa, 4);
    // Espacio reservado para los conectores con la curva de sus cables (009, data-model §3); no es una
    // pieza: el visor lo muestra en el paso de cableado
    if (e == "conectores") {
        // Dupont y enchufes hacia arriba, sobre toda la planta de las placas bajas
        for (c = [[x_col_a0, y_uln_alt0, uln2003_ancho, uln2003_largo], [x_col_a0, y_uln_az0, uln2003_ancho, uln2003_largo],
                  [x_col_b0, y_rele_0, rele_ancho, rele_largo]])
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
        // Tramo que gira con el láser: ventana de la tapa → grapa → canaleta → fin de la canaleta
        laser_en(angulo_altura) cordon([
            punto_cable(r_funda_ext + d_hilo, y_borde_tubo),
            punto_cable(r_cable_grapa, y_grapa + ancho_grapa/2),
            punto_cable(r_cable_canaleta, -largo_tubo_cuna/2),
            punto_cable(r_cable_canaleta, y_fin_canaleta)]);
        // Bucle hasta el agujero del brazo cable (fijo) y salida por su cara exterior
        cordon([
            en_conjunto(punto_cable(r_cable_canaleta, y_fin_canaleta), angulo_altura),
            [x_cara_int_brazo_cable + d_hilo + 0.5, -8, z_eje_altura - dist_agujero_cable - 8],
            [x_cara_int_brazo_cable, 0, z_eje_altura - dist_agujero_cable],
            [-x_cara_ext_brazo - 2, 0, z_eje_altura - dist_agujero_cable]]);
    }
}

// Puntos de cada elemento donde se dibuja la flecha de la vista explotada
function anclas(e) =
    e == "base" || e == "tuerca_tripode" ? [[0, 0, piso_base + tuerca_3_8_alto/2]] :
    e == "608_base_sup" ? [[0, 0, z_resalte_sup + rod608_ancho/2]] :
    e == "608_base_inf" ? [[0, 0, z_camara_sup + rod608_ancho/2]] :
    e == "tuerca_munon" ? [[diametro_interior_cuna/2 + m8_tuerca_alto/2, 0, z_eje_altura]] :
    e == "perno_alt_motor" ? [[x_punta_perno_alt_motor, 0, z_eje_altura]] :
    e == "perno_alt_cable" ? [[-x_cabeza_m8_cuna - largo_perno_alt_cable/2, 0, z_eje_altura]] :
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
    e == "arandela_cable" || e == "autoblocante_cable" ? [[-(x_cara_ext_brazo + alto_arandela_contacto), 0, z_eje_altura]] :
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
