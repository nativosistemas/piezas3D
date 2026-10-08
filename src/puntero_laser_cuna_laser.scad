// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Cuna del láser
// Descripción: Tubo donde el láser 303 se desliza para equilibrarlo sobre el eje de altura. Tiene
//              un anillo de 3 prisioneros M3 a 120° en cada extremo para la colimación del haz y
//              dos muñones laterales: el −X aloja la cabeza del perno M8 del lado del cable y el +X
//              una tuerca M8 donde se enrosca el perno del lado motor, que entra desde afuera por la
//              polea. Los dos alojamientos se abren hacia el interior del tubo. Se imprime de pie, con
//              el eje del tubo vertical.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
include <puntero_laser_parametros.scad>

/* [Hidden] */
r_int_cuna = diametro_interior_cuna/2;
r_anillo = radio_exterior_cuna + sobre_anillo_colim;
x_cara_munon = semiancho_interior_horquilla - holgura_munon_brazo;
largo_anillo_contacto = labio_608 + holgura_munon_brazo;
z_centro_cuna = largo_tubo_cuna/2;

// --- MÓDULOS PRINCIPALES Y ENSAMBLAJE ---
ensamblaje_principal();

module ensamblaje_principal() {
    pieza_cuna_laser();
}

// Sistema de impresión: eje del tubo sobre Z (en el conjunto, +Z de impresión = +Y, frente del
// láser; −Y de impresión = +Z del conjunto, arriba).
module pieza_cuna_laser() {
    difference() {
        union() {
            tubo();
            anillo_colimacion(0, false);
            anillo_colimacion(largo_tubo_cuna - alto_anillo_colim, true);
            for (s = [-1, 1]) munon(s);
        }
        translate([0, 0, -1]) cylinder(r = r_int_cuna, h = largo_tubo_cuna + 2, $fn = 96);
        agujeros_colimacion(alto_anillo_colim/2, 90);
        agujeros_colimacion(largo_tubo_cuna - alto_anillo_colim/2, 30);
        for (s = [-1, 1]) vaciado_munon(s);
        if (con_ventana_pulsador) ventana_pulsador();
        ranura_cable();
    }
}

module tubo() {
    cylinder(r = radio_exterior_cuna, h = largo_tubo_cuna, $fn = 96);
}

// Anillo engrosado de colimación. El superior lleva chaflán de 45° por debajo (sin soportes).
module anillo_colimacion(z0, superior) {
    translate([0, 0, z0]) cylinder(r = r_anillo, h = alto_anillo_colim, $fn = 96);
    if (superior)
        translate([0, 0, z0 - sobre_anillo_colim + eps])
            cylinder(r1 = radio_exterior_cuna, r2 = r_anillo, h = sobre_anillo_colim, $fn = 96);
}

// 3 agujeros radiales para prisioneros M3 (se roscan pasando primero un tornillo M3)
module agujeros_colimacion(z, angulo0) {
    for (i = [0:2])
        rotate([0, 0, angulo0 + i*120])
            translate([0, 0, z]) rotate([0, 90, 0])
                cylinder(d = diametro_autorroscante_m3, h = r_anillo + 1, $fn = 20);
}

// Muñón lateral (s = ±1 → ±X) con perfil en gota hacia abajo para imprimir sin soportes,
// y anillo de contacto que llega al aro interior del 608 a través del labio del brazo.
module munon(s) {
    mirror([s < 0 ? 1 : 0, 0, 0]) {
        translate([r_int_cuna + 1, 0, z_centro_cuna]) rotate([0, 90, 0])
            linear_extrude(height = x_cara_munon - r_int_cuna - 1)
                perfil_gota_abajo(d_munon);
        translate([x_cara_munon - eps, 0, z_centro_cuna]) rotate([0, 90, 0])
            linear_extrude(height = largo_anillo_contacto + eps)
                intersection() {   // la punta de la gota no debe tocar el labio del brazo
                    perfil_gota_abajo(d_contacto_aro);
                    circle(d = d_labio_608 - 1);
                }
    }
}

// Hexágono abierto hacia el interior del tubo y paso del perno (U-08): tuerca M8 en +X, cabeza en −X
module vaciado_munon(s) {
    x_fondo = s > 0 ? x_tuerca_m8_cuna : x_cabeza_m8_cuna;
    mirror([s < 0 ? 1 : 0, 0, 0]) {
        translate([r_int_cuna - 2, 0, z_centro_cuna]) rotate([0, 90, 0])   // un vértice hacia arriba
            alojamiento_hex(s > 0 ? m8_tuerca_ec : m8_cabeza_ec, x_fondo - r_int_cuna + 2);
        translate([(x_cara_munon + largo_anillo_contacto)/2, 0, z_centro_cuna])
            agujero_gota(rod608_d_int + holgura_perno_m8, x_cara_munon + largo_anillo_contacto);
    }
}

// Perfil 2D (en el plano de extrusión) de un círculo con una punta a 45° hacia −X local, que
// tras rotate([0, 90, 0]) apunta hacia −Z de impresión.
module perfil_gota_abajo(d) {
    hull() {
        circle(d = d);
        translate([d/2*sqrt(2), 0]) circle(d = eps);
    }
}

// Ventana para el pulsador del láser, del lado de arriba del conjunto (−Y de impresión), con techo
// a dos aguas a 45° (sin puentes de más de 10 mm al imprimir el tubo de pie)
module ventana_pulsador() {
    z0 = z_centro_cuna + dist_ventana_pulsador - largo_ventana_pulsador/2;
    translate([0, -radio_exterior_cuna - 1, z0]) rotate([-90, 0, 0])
        linear_extrude(height = radio_exterior_cuna)
            polygon([[-ancho_ventana_pulsador/2, 0], [ancho_ventana_pulsador/2, 0],
                     [ancho_ventana_pulsador/2, -largo_ventana_pulsador],
                     [0, -largo_ventana_pulsador - ancho_ventana_pulsador/2],
                     [-ancho_ventana_pulsador/2, -largo_ventana_pulsador]]);
}

// Ranura de salida de los 2 hilos del relé, junto al muñón del lado −X (cerca del eje)
module ranura_cable() {
    translate([-radio_exterior_cuna - 1, -ancho_ranura_cable/2, z_centro_cuna + d_munon/2 + 2])
        cube([radio_exterior_cuna - r_int_cuna + 2, ancho_ranura_cable, alto_ranura_cable]);
}
