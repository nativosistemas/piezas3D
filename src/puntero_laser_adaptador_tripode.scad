// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Adaptador del trípode (base fija)
// Descripción: Base fija que se enrosca al tornillo 3/8"-16 del trípode (tuerca embebida cargada
//              desde arriba). Aloja los dos 608ZZ de azimut a presión, separados por un resalte,
//              una cámara con ventana lateral para la tuerca autoblocante M8 y el 608 inferior, y
//              lleva integrada la polea GT2 fija del eje de azimut. Se imprime apoyada en la cama.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
include <puntero_laser_parametros.scad>

/* [Hidden] */
d_agujero_tripode = rosca_3_8_d + 0.6;
d_alojamiento_608 = rod608_d_ext + ajuste_608;
d_cubo_base = d_exterior_conducida - 2*profundidad_diente_gt2;   // raíz del dentado

// --- MÓDULOS PRINCIPALES Y ENSAMBLAJE ---
ensamblaje_principal();

module ensamblaje_principal() {
    pieza_adaptador_tripode();
}

module pieza_adaptador_tripode() {
    difference() {
        union() {
            cuerpo_base();
            translate([0, 0, z_dentado_inf]) {
                dentado_gt2(dientes_polea_conducida, h_dentado);
                pestanas_polea(d_exterior_conducida, h_dentado);
            }
        }
        // Agujero del tornillo del trípode a través del piso
        translate([0, 0, -1]) cylinder(d = d_agujero_tripode, h = piso_base + 2);
        alojamiento_tuerca_tripode();
        camara_tuerca_m8();
        ventana_llave();
        cubo_rodamientos();
    }
}

// Cuerpo: cilindro de apoyo con chaflán, cono a 45° hasta la pestaña inferior de la polea
// y cubo central hasta el dentado.
module cuerpo_base() {
    r_apoyo = diametro_apoyo_tripode/2;
    r_brida = d_exterior_conducida/2 + espesor_brida;
    cylinder(r1 = r_apoyo - chaflan_base, r2 = r_apoyo, h = chaflan_base + eps);
    translate([0, 0, chaflan_base]) cylinder(r = r_apoyo, h = z_cuerpo_base_sup - chaflan_base);
    translate([0, 0, z_cuerpo_base_sup - eps])
        cylinder(r1 = r_apoyo, r2 = r_brida, h = z_brida_inf_base - z_cuerpo_base_sup + 2*eps);
    cylinder(d = d_cubo_base, h = z_tope_base);
}

// Tuerca 3/8"-16 cargada desde arriba: el tornillo del trípode la tira contra el piso (U-01)
module alojamiento_tuerca_tripode() {
    translate([0, 0, piso_base]) alojamiento_hex(tuerca_3_8_ec, z_tuerca_tripode_sup - piso_base + eps);
}

// Cámara para la punta del tornillo del trípode, la punta del perno M8, la autoblocante y la
// arandela de contacto
module camara_tuerca_m8() {
    translate([0, 0, z_tuerca_tripode_sup - eps]) cylinder(d = d_camara, h = altura_camara + 2*eps);
}

// Ventana lateral (hacia −Y) con techo a dos aguas a 45°: llave de 13 mm y entrada del 608 inferior
module ventana_llave() {
    alto_recto = altura_camara - ancho_ventana/2;
    translate([0, 0, z_tuerca_tripode_sup])
        rotate([90, 0, 0])
            linear_extrude(height = diametro_apoyo_tripode)
                polygon([[-ancho_ventana/2, 0], [ancho_ventana/2, 0], [ancho_ventana/2, alto_recto],
                         [0, alto_recto + ancho_ventana/2], [-ancho_ventana/2, alto_recto]]);
    assert(alto_recto >= rod608_ancho + 1,
           str("separacion_608_azimut=", separacion_608_azimut, ": la ventana de la cámara mide ", alto_recto,
               " mm de alto recto; el 608 inferior (", rod608_ancho, " mm) no entra"));
}

// Alojamientos a presión de los 608 (inferior desde la cámara, superior desde arriba) y resalte
// central con agujero de labio (U-02)
module cubo_rodamientos() {
    translate([0, 0, z_camara_sup - eps]) cylinder(d = d_alojamiento_608, h = rod608_ancho + eps);
    translate([0, 0, z_resalte_inf - eps]) cylinder(d = d_labio_608, h = separacion_608_azimut + 2*eps);
    translate([0, 0, z_resalte_sup]) cylinder(d = d_alojamiento_608, h = rod608_ancho + 1);
}
