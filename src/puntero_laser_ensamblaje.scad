// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Ensamblaje (solo revisión, NO se exporta)
// Descripción: Coloca todas las piezas en su posición del conjunto, dibuja los componentes
//              comprados como volúmenes simplificados (motores, poleas 20T, correas, 608ZZ, pernos,
//              tornillería, placas, power bank y láser) y comprueba con asserts los choques y
//              alineaciones que no se pueden ver en una pieza sola (V-07, V-09 y separaciones entre
//              piezas). Con paso_armado > 0 dibuja la vista explotada de ese paso de la guía.
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

// Ángulo de altura del láser en la vista previa
angulo_altura = 45; // [-10:1:95]
// Dibujar la tapa (transparente)
ver_tapa = true;
// Paso de armado de la guía (0 = conjunto completo; -1 = listar los pasos con echo)
paso_armado = 0; // [-1:1:18]

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
y_orejas_tapa = [y_tapa0 - largo_oreja_tapa/2, y_tapa1 + largo_oreja_tapa/2];

// Vista explotada: transparencia de lo ya armado, distancia y color de las flechas
alfa_contexto = 0.22;
color_flecha = "OrangeRed";
// Dirección del láser al entrar en la cuna (desde atrás, a lo largo de su eje)
v_laser = [0, -cos(angulo_altura), -sin(angulo_altura)];

// Pasos de armado de la guía (docs/puntero_laser_guia.md, sección 2): por cada paso, la lista de
// [elemento, desplazamiento de la vista explotada, resaltar]. Los elementos de pasos anteriores del
// mismo subconjunto se dibujan transparentes. "resaltar = false" mueve o muestra un elemento sin
// destacarlo. Un paso sin elementos (cableado, puesta a punto) no tiene vista.
// Subconjuntos: la base, la cuna y la plataforma se arman por separado hasta que se unen (pasos 8 y 10).
grupo_base = ["base", "tuerca_tripode", "608_base_sup", "608_base_inf", "arandela_sup", "arandela_inf",
              "separador", "perno_az", "autoblocante_az"];
grupo_cuna = ["cuna", "perno_alt_motor", "perno_alt_cable"];
paso_union_base = 8;    // la plataforma se monta sobre la base
paso_union_cuna = 10;   // la cuna se monta entre los brazos
subconjunto_plataforma = ["plataforma", "brazo_motor", "brazo_cable", "608_brazo_motor", "608_brazo_cable",
                          "tuercas_pie", "tornillos_pie", "carro_az", "motor_az", "tornillos_orejas_az",
                          "tuercas_carro_az", "tornillos_carro_az", "polea20_az"];
pasos = [
    /* 1 */ [["base", [0, 0, 0], false], ["tuerca_tripode", [0, 0, 70], true]],
    /* 2 */ [["608_base_sup", [0, 0, 60], true], ["608_base_inf", [0, -60, 0], true]],
    /* 3 */ [["cuna", [0, 0, 0], false], ["perno_alt_motor", -130*v_laser, true],
             ["perno_alt_cable", -130*v_laser, true]],
    /* 4 */ [["brazo_motor", [0, 0, 0], true], ["brazo_cable", [0, 0, 0], true],
             ["608_brazo_motor", [45, 0, 0], true], ["608_brazo_cable", [-45, 0, 0], true]],
    /* 5 */ [["plataforma", [0, 0, 0], false], ["brazo_motor", [0, 0, 50], true], ["brazo_cable", [0, 0, 50], true],
             ["608_brazo_motor", [0, 0, 50], false], ["608_brazo_cable", [0, 0, 50], false],
             ["tuercas_pie", [0, 0, 50], true], ["tornillos_pie", [0, 0, -35], true]],
    /* 6 */ [["carro_az", [0, 0, 0], true], ["carro_alt", [0, 0, 0], true],
             ["motor_az", [0, 0, 40], true], ["tornillos_orejas_az", [0, 0, 70], true],
             ["motor_alt", [-30, 0, 0], true], ["tornillos_orejas_alt", [-55, 0, 0], true]],
    /* 7 */ [["tuercas_carro_az", [0, 0, -30], true], ["carro_az", [0, 0, 35], true], ["motor_az", [0, 0, 35], true],
             ["tornillos_orejas_az", [0, 0, 35], false], ["tornillos_carro_az", [0, 0, 65], true],
             ["polea20_az", [0, 0, -45], true]],
    /* 8 */ concat([for (e = subconjunto_plataforma) [e, [0, 0, 110], false]],
                   [["arandela_sup", [0, 0, 45], true], ["perno_az", [0, 0, 150], true],
                    ["separador", [0, -60, 0], true], ["arandela_inf", [0, -80, 0], true],
                    ["autoblocante_az", [0, -100, 0], true]]),
    /* 9 */ [["correa_az", [0, 0, -30], true]],
    /* 10 */ [["cuna", [0, 0, 120], true], ["perno_alt_motor", [0, 0, 120], true], ["perno_alt_cable", [0, 0, 120], true]],
    /* 11 */ [["arandela_cable", [-30, 0, 0], true], ["autoblocante_cable", [-50, 0, 0], true]],
    /* 12 */ [["polea_alt", [45, 0, 0], true], ["autoblocante_polea", [75, 0, 0], true]],
    /* 13 */ [["carro_alt", [45, 0, 0], true], ["motor_alt", [45, 0, 0], true], ["tornillos_orejas_alt", [45, 0, 0], false],
              ["tornillos_carro_alt", [80, 0, 0], true], ["polea20_alt", [65, 0, 0], true], ["correa_alt", [25, 0, 0], true]],
    /* 14 */ [["laser", 150*v_laser, true]],
    /* 15 */ [["placas", [0, 0, 40], true], ["powerbank", [0, 0, 60], true]],
    /* 16 */ [],
    /* 17 */ [["tapa", [0, 0, 50], true], ["tornillos_tapa", [0, 0, 80], true], ["tuercas_tapa", [0, 0, -30], true]],
    /* 18 */ []
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
    str("altura_placas=", altura_placas, ": la tapa (", alto_tapa, " mm) toca el carro o el motor de altura"));
assert(r_tope_ext + 1 < distancia_centros - polea20_d_brida/2,
    "largo_correa: el tope tensor toca la polea 20T del motor de altura");
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
// Tabla de pasos: un paso por cada instrucción de la guía y solo elementos conocidos
assert(len(pasos) == 18, "pasos: la guía tiene 18 pasos de armado");
for (p = pasos, e = p)
    assert(contiene(elementos, e[0]), str("pasos: elemento desconocido '", e[0], "'"));

// --- MÓDULOS PRINCIPALES Y ENSAMBLAJE ---
if (paso_armado == -1)
    for (n = [1:len(pasos)]) echo(str("PASO;", n, ";", len(pasos[n - 1])));
else if (paso_armado == 0)
    ensamblaje_principal();
else
    vista_paso(paso_armado);

module ensamblaje_principal() {
    for (e = elementos) if (e != "tapa") color(color_elemento(e)) elemento(e);
    if (ver_tapa) %elemento("tapa");
    %laser_en(-10) laser();
    %laser_en(95) laser();
}

// Vista explotada del paso n: lo armado antes, transparente; lo nuevo, desplazado y con una flecha
module vista_paso(n) {
    assert(n >= 1 && n <= len(pasos), str("paso_armado=", n, ": la guía tiene ", len(pasos), " pasos"));
    actual = pasos[n - 1];
    nombres_actual = [for (e = actual) e[0]];
    grupos_actual = [for (e = actual) grupo(e[0], n)];
    previos = unicos([for (k = [0:1:n - 2]) for (e = pasos[k]) e[0]]);
    for (e = previos) if (!contiene(nombres_actual, e) && contiene(grupos_actual, grupo(e, n)))
        color(color_elemento(e), alfa_contexto) elemento(e);
    for (e = actual) {
        if (e[2]) color(color_elemento(e[0])) translate(e[1]) elemento(e[0]);
        else color(color_elemento(e[0]), alfa_contexto) translate(e[1]) elemento(e[0]);
        if (e[2] && norm(e[1]) > 0)
            for (p = anclas(e[0])) color(color_flecha) flecha(p + 0.85*e[1], p + 0.2*e[1]);
    }
}

// Subconjunto al que pertenece un elemento en el paso n
function grupo(e, n) =
    let (g = contiene(grupo_base, e) ? "base" : contiene(grupo_cuna, e) ? "cuna" : "plataforma")
    n >= paso_union_cuna || (n >= paso_union_base && g != "cuna") ? "conjunto" : g;

// --- CATÁLOGO DE ELEMENTOS (posición final en el conjunto) ---
elementos = ["base", "plataforma", "brazo_motor", "brazo_cable", "cuna", "polea_alt", "carro_az", "carro_alt",
             "separador", "arandela_sup", "arandela_inf", "arandela_cable", "tapa",
             "tuerca_tripode", "608_base_sup", "608_base_inf", "608_brazo_motor", "608_brazo_cable",
             "perno_az", "autoblocante_az", "perno_alt_motor", "perno_alt_cable", "autoblocante_cable",
             "autoblocante_polea", "motor_az", "motor_alt", "polea20_az", "polea20_alt", "correa_az", "correa_alt",
             "tornillos_pie", "tuercas_pie", "tornillos_carro_az", "tuercas_carro_az", "tornillos_orejas_az",
             "tornillos_orejas_alt", "tornillos_carro_alt", "tornillos_tapa", "tuercas_tapa",
             "placas", "powerbank", "laser"];

function color_elemento(e) =
    e == "base" ? "SlateGray" : e == "plataforma" ? "DarkSeaGreen" :
    e == "brazo_motor" || e == "brazo_cable" ? "SteelBlue" : e == "cuna" ? "Peru" :
    e == "polea_alt" ? "Goldenrod" : e == "carro_az" || e == "carro_alt" ? "Khaki" :
    e == "separador" || e == "arandela_sup" || e == "arandela_inf" || e == "arandela_cable" ? "Wheat" :
    e == "tapa" ? "LightGray" : e == "motor_az" || e == "motor_alt" ? "Gold" :
    e == "correa_az" || e == "correa_alt" ? "Black" : e == "placas" ? "ForestGreen" :
    e == "powerbank" ? "DarkBlue" : e == "laser" ? "LimeGreen" :
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
    if (e == "perno_alt_motor") laser_en(angulo_altura) translate([x_cabeza_m8_cuna, 0, 0]) rotate([0, 90, 0])
        cylinder(d = rod608_d_int, h = largo_perno_alt_motor);
    if (e == "perno_alt_cable") laser_en(angulo_altura) translate([-x_cabeza_m8_cuna, 0, 0]) rotate([0, -90, 0])
        cylinder(d = rod608_d_int, h = largo_perno_alt_cable);
    if (e == "autoblocante_cable") translate([-(x_cara_ext_brazo + alto_arandela_contacto), 0, z_eje_altura])
        rotate([0, -90, 0]) tuerca(m8_tuerca_ec, m8_autoblocante_alto);
    if (e == "autoblocante_polea") translate([x_ext_polea_alt - m8_autoblocante_alto, 0, z_eje_altura])
        rotate([0, 90, 0]) tuerca(m8_tuerca_ec, m8_autoblocante_alto);
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
    if (e == "tuercas_pie") for (s = [-1, 1], t = [-1, 1])
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
    if (e == "placas") {
        placa(x_col_a0, y_uln_alt0, uln2003_ancho, uln2003_largo, alto_soporte_placa, altura_placas - alto_soporte_placa);
        placa(x_col_a0, y_uln_az0, uln2003_ancho, uln2003_largo, alto_soporte_placa, altura_placas - alto_soporte_placa);
        placa(x_col_b0, y_esp32_0, esp32_ancho, esp32_largo, elevacion_esp32, alto_modulo_esp32 + espesor_pcb);
        placa(x_col_b0, y_rele_0, rele_ancho, rele_largo, alto_soporte_placa, altura_placas - alto_soporte_placa);
    }
    if (e == "powerbank")
        translate([x_pb1 + pared_bolsillo + holgura_encastre, y_pb0 + pared_bolsillo + holgura_encastre, z_sup])
            cube([powerbank_alto, powerbank_largo, powerbank_ancho]);
    if (e == "laser") laser_en(angulo_altura) laser();
}

// Puntos de cada elemento donde se dibuja la flecha de la vista explotada
function anclas(e) =
    e == "base" || e == "tuerca_tripode" ? [[0, 0, piso_base + tuerca_3_8_alto/2]] :
    e == "608_base_sup" ? [[0, 0, z_resalte_sup + rod608_ancho/2]] :
    e == "608_base_inf" ? [[0, 0, z_camara_sup + rod608_ancho/2]] :
    e == "perno_alt_motor" ? [[x_cabeza_m8_cuna + largo_perno_alt_motor/2, 0, z_eje_altura]] :
    e == "perno_alt_cable" ? [[-x_cabeza_m8_cuna - largo_perno_alt_cable/2, 0, z_eje_altura]] :
    e == "608_brazo_motor" ? [[x_cara_ext_brazo, 0, z_eje_altura]] :
    e == "608_brazo_cable" ? [[-x_cara_ext_brazo, 0, z_eje_altura]] :
    e == "brazo_motor" ? [[x_pie_brazo, 0, z_sup + 30]] :
    e == "brazo_cable" ? [[-x_pie_brazo, 0, z_sup + 30]] :
    e == "tornillos_pie" ? [for (s = [-1, 1]) [s*x_pie_brazo, 0, z_plataforma_inf - alto_cabeza_m3]] :
    e == "tuercas_pie" ? [for (s = [-1, 1]) [s*x_pie_brazo, 0, z_sup + dist_tuerca_pie]] :
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
    e == "polea_alt" || e == "autoblocante_polea" ? [[x_ext_polea_alt, 0, z_eje_altura]] :
    e == "laser" ? [[0, 0, z_eje_altura] + (l_trasero + 130)*v_laser] :   // detrás del láser, no dentro
    e == "placas" ? [[x_col_b0 + esp32_ancho/2, y_esp32_0 + esp32_largo/2, z_sup + altura_placas]] :
    e == "powerbank" ? [[x_pb1 + powerbank_alto/2, y_pb0 + powerbank_largo/2, z_sup + powerbank_ancho]] :
    e == "tapa" ? [[x_tapa_c, (y_tapa0 + y_tapa1)/2, z_sup + alto_tapa]] :
    e == "tornillos_tapa" ? [for (y = y_orejas_tapa) [x_tapa_c, y, z_sup + 10]] :
    e == "tuercas_tapa" ? [for (y = y_orejas_tapa) [x_tapa_c, y, z_plataforma_inf]] :
    [[0, 0, 0]];

// --- UTILIDADES ---
function contiene(lista, x) = len([for (e = lista) if (e == x) 0]) > 0;
function unicos(lista) = [for (i = [0:1:len(lista) - 1]) if (!contiene([for (j = [0:1:i - 1]) lista[j]], lista[i])) lista[i]];

// Gira un objeto definido en el sistema del láser (eje del láser sobre +Y, eje de altura en el origen)
module laser_en(a) {
    translate([0, 0, z_eje_altura]) rotate([a, 0, 0]) children();
}
module cuna_en_conjunto() {
    rotate([-90, 0, 0]) translate([0, 0, -largo_tubo_cuna/2]) pieza_cuna_laser();
}
module laser() {
    rotate([-90, 0, 0]) translate([0, 0, -l_trasero]) cylinder(d = diametro_laser, h = largo_laser);
}

// Flecha de la vista explotada, de "desde" a "hasta"
module flecha(desde, hasta) {
    v = hasta - desde;
    largo = norm(v);
    punta = min(8, largo/2);
    if (largo > 1)
        translate(desde) rotate([0, acos(v[2]/largo), atan2(v[1], v[0])]) {
            cylinder(d = 2.4, h = largo - punta, $fn = 16);
            translate([0, 0, largo - punta]) cylinder(d1 = 6, d2 = 0, h = punta, $fn = 16);
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
