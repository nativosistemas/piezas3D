// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Cuna del láser
// Descripción: Tubo donde el láser 303 se desliza para equilibrarlo sobre el eje de altura. Tiene
//              un anillo de 3 prisioneros M3 a 120° en cada extremo para la colimación del haz y
//              dos muñones laterales: el −X aloja la cabeza del perno M8 del lado del cable y el +X
//              una tuerca M8 donde se enrosca el perno del lado motor, que entra desde afuera por la
//              polea. Los dos alojamientos se abren hacia el interior del tubo. Desde la 006, el
//              cable del láser corre por fuera, en una canaleta a angulo_cable (lado −X, 30° bajo la
//              horizontal) desde el borde trasero hasta el muñón −X, con puentes para enhebrarlo.
//              Se imprime de pie, con el eje del tubo vertical.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
include <puntero_laser_parametros.scad>

/* [Hidden] */
r_int_cuna = diametro_interior_cuna/2;
r_anillo = radio_exterior_cuna + sobre_anillo_colim;
x_cara_munon = semiancho_interior_horquilla - holgura_munon_brazo;
largo_anillo_contacto = labio_608 + holgura_munon_brazo;
z_centro_cuna = largo_tubo_cuna/2;
z_fin_canaleta = z_centro_cuna - d_munon/2 - 2;
r_fondo_canaleta = r_anillo - prof_canaleta;
ancho_nervio_canaleta = ancho_ranura_canaleta + 2*pared_canaleta;
paso_puentes = z_fin_canaleta/(puentes_canaleta + 1);
angulos_prisioneros_trasero = [90, 210, 330];   // los de agujeros_colimacion(…, 90)

// --- VALIDACIONES ---
assert(min([for (a = angulos_prisioneros_trasero) abs(((angulo_cable - a + 540) % 360) - 180)]) >= 30,
    str("angulo_cable=", angulo_cable, ": la canaleta queda a menos de 30° de un prisionero del anillo trasero"));
assert(r_fondo_canaleta >= radio_exterior_cuna + 0.5,
    str("prof_canaleta=", prof_canaleta, ": la canaleta cortaría la pared del tubo"));
assert(z_fin_canaleta > alto_anillo_colim + puentes_canaleta*alto_puente_canaleta,
    str("d_munon=", d_munon, ": no hay lugar para la canaleta del cable entre el anillo trasero y el muñón"));

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
            canaleta_cable();
        }
        translate([0, 0, -1]) cylinder(r = r_int_cuna, h = largo_tubo_cuna + 2, $fn = 96);
        agujeros_colimacion(alto_anillo_colim/2, 90);
        agujeros_colimacion(largo_tubo_cuna - alto_anillo_colim/2, 30);
        for (s = [-1, 1]) vaciado_munon(s);
        if (con_ventana_pulsador) ventana_pulsador();
        ranura_canaleta();
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

// Nervio exterior de la canaleta del cable, a angulo_cable, del borde trasero (z = 0) hasta el muñón −X.
// No sobresale más que los anillos de colimación: no cambia el barrido.
module canaleta_cable() {
    rotate([0, 0, angulo_cable])
        translate([radio_exterior_cuna - 1, -ancho_nervio_canaleta/2, 0])
            cube([r_anillo - radio_exterior_cuna + 1, ancho_nervio_canaleta, z_fin_canaleta]);
}

// Ranura de la canaleta, con puentes cerrados donde se enhebra el cable
module ranura_canaleta() {
    rotate([0, 0, angulo_cable]) difference() {
        translate([r_fondo_canaleta, -ancho_ranura_canaleta/2, -eps])
            cube([r_anillo - r_fondo_canaleta + 1, ancho_ranura_canaleta, z_fin_canaleta + 2*eps]);
        for (i = [1:puentes_canaleta])
            translate([r_fondo_canaleta + d_hilo + 0.3, -ancho_ranura_canaleta/2 - 1, i*paso_puentes - alto_puente_canaleta/2])
                cube([r_anillo - r_fondo_canaleta, ancho_ranura_canaleta + 2, alto_puente_canaleta]);
    }
}
