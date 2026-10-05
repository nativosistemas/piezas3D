// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Ensamblaje (solo revisión, NO se exporta)
// Descripción: Coloca todas las piezas en su posición del conjunto, dibuja los componentes
//              comprados como volúmenes simplificados (motores, poleas 20T, correas, 608ZZ, pernos,
//              placas, power bank y láser) y comprueba con asserts los choques y alineaciones que
//              no se pueden ver en una pieza sola (V-07, V-09 y separaciones entre piezas).
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

// --- MÓDULOS PRINCIPALES Y ENSAMBLAJE ---
ensamblaje_principal();

module ensamblaje_principal() {
    // Piezas impresas
    color("SlateGray") pieza_adaptador_tripode();
    color("DarkSeaGreen") translate([0, 0, z_plataforma_inf]) pieza_plataforma_azimut();
    color("SteelBlue") multmatrix(matriz_brazo_motor) pieza_brazo_horquilla("motor");
    color("SteelBlue") multmatrix(matriz_brazo_cable) pieza_brazo_horquilla("cable");
    color("Peru") laser_en(angulo_altura) cuna_en_conjunto();
    color("Goldenrod") translate([x_ext_polea_alt, 0, z_eje_altura]) rotate([angulo_altura, 0, 0])
        rotate([0, -90, 0]) pieza_polea_altitud();
    color("Khaki") translate([0, distancia_centros, z_sup]) rotate([0, 0, 90]) pieza_carro_motor();
    color("Khaki") multmatrix(matriz_motor_alt) pieza_carro_motor();
    color("Wheat") separador_y_arandelas();
    if (ver_tapa) %translate([0, 0, z_sup]) tapa_en_posicion();
    // Componentes comprados
    componentes_comprados();
    color("LimeGreen") laser_en(angulo_altura) laser();
    %laser_en(-10) laser();
    %laser_en(95) laser();
}

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

module separador_y_arandelas() {
    translate([0, 0, z_resalte_inf]) cylinder(d = d_contacto_aro, h = largo_separador_azimut);
    translate([0, 0, z_tope_base]) cylinder(d = d_contacto_aro, h = alto_arandela_contacto);
    translate([0, 0, z_camara_sup - alto_arandela_contacto]) cylinder(d = d_contacto_aro, h = alto_arandela_contacto);
    translate([-x_cara_ext_brazo - alto_arandela_contacto, 0, z_eje_altura]) rotate([0, 90, 0])
        cylinder(d = d_contacto_aro, h = alto_arandela_contacto);
}

module componentes_comprados() {
    // 608ZZ
    color("Silver") {
        for (z = [z_camara_sup, z_resalte_sup]) translate([0, 0, z]) rodamiento_608();
        for (s = [-1, 1])
            translate([s*(x_cara_ext_brazo - rod608_ancho), 0, z_eje_altura]) rotate([0, 90, 0])
                translate([0, 0, s < 0 ? -rod608_ancho : 0]) rodamiento_608();
    }
    // Pernos M8 y tuercas
    color("DimGray") {
        translate([0, 0, z_plataforma_inf + espesor_cubo_plataforma - 0.3 - m8_cabeza_alto]) {
            cylinder(d = m8_cabeza_ec/cos(30), h = m8_cabeza_alto, $fn = 6);
            translate([0, 0, -largo_perno_azimut]) cylinder(d = rod608_d_int, h = largo_perno_azimut);
        }
        translate([0, 0, z_camara_sup - alto_arandela_contacto - m8_autoblocante_alto])
            cylinder(d = m8_tuerca_ec/cos(30), h = m8_autoblocante_alto, $fn = 6);
        laser_en(angulo_altura) {
            translate([x_cabeza_m8_cuna, 0, 0]) rotate([0, 90, 0]) cylinder(d = rod608_d_int, h = largo_perno_alt_motor);
            translate([-x_cabeza_m8_cuna, 0, 0]) rotate([0, -90, 0]) cylinder(d = rod608_d_int, h = largo_perno_alt_cable);
        }
        translate([-(x_cara_ext_brazo + alto_arandela_contacto), 0, z_eje_altura]) rotate([0, -90, 0])
            cylinder(d = m8_tuerca_ec/cos(30), h = m8_autoblocante_alto, $fn = 6);
    }
    // Motores 28BYJ-48
    color("Gold") {
        translate([0, distancia_centros, z_sup + espesor_carro]) rotate([0, 0, 90]) rotate([180, 0, 0]) motor_28byj();
        multmatrix(matriz_motor_alt) motor_28byj();
    }
    // Poleas 20T
    color("Silver") {
        translate([0, distancia_centros, z_sup]) polea20();
        multmatrix(matriz_polea20_alt) polea20();
    }
    // Correas
    color("Black") {
        translate([0, 0, z_dientes_polea20_az - ancho_correa/2]) linear_extrude(height = ancho_correa) correa_2d();
        translate([plano_correa_altura - ancho_correa/2, 0, z_eje_altura]) rotate([0, 90, 0])
            linear_extrude(height = ancho_correa) rotate([0, 0, -90]) correa_2d();
    }
    // Electrónica
    color("DarkBlue") translate([x_pb1 + pared_bolsillo + holgura_encastre, y_pb0 + pared_bolsillo + holgura_encastre, z_sup])
        cube([powerbank_alto, powerbank_largo, powerbank_ancho]);
    color("ForestGreen") {
        placa(x_col_a0, y_uln_alt0, uln2003_ancho, uln2003_largo, alto_soporte_placa, altura_placas - alto_soporte_placa);
        placa(x_col_a0, y_uln_az0, uln2003_ancho, uln2003_largo, alto_soporte_placa, altura_placas - alto_soporte_placa);
        placa(x_col_b0, y_esp32_0, esp32_ancho, esp32_largo, elevacion_esp32, alto_modulo_esp32 + espesor_pcb);
        placa(x_col_b0, y_rele_0, rele_ancho, rele_largo, alto_soporte_placa, altura_placas - alto_soporte_placa);
    }
}

module rodamiento_608() {
    difference() {
        cylinder(d = rod608_d_ext, h = rod608_ancho);
        translate([0, 0, -1]) cylinder(d = rod608_d_int, h = rod608_ancho + 2);
    }
}

// Sistema del motor: eje sobre +Z desde la cara de las orejas (z = 0); cuerpo hacia −Z y +X.
module motor_28byj() {
    translate([motor_desplazamiento_eje, 0, -motor_alto_cuerpo]) cylinder(d = motor_d_cuerpo, h = motor_alto_cuerpo);
    translate([motor_desplazamiento_eje + motor_d_cuerpo/2 - 2, -motor_tapa_ancho/2, -motor_alto_cuerpo])
        cube([motor_tapa_saliente + 2, motor_tapa_ancho, motor_alto_cuerpo]);
    translate([motor_desplazamiento_eje, 0, -1]) hull()
        for (s = [-1, 1]) translate([0, s*motor_entre_orejas/2, 0]) cylinder(d = motor_d_oreja, h = 1);
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
