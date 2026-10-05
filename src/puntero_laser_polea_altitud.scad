// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Polea de altura (GT2, dientes_polea_conducida)
// Descripción: Polea conducida del eje de altura. Va por fuera del brazo del motor, montada en el
//              perno M8 de la cuna; la tuerca autoblocante M8 queda en el hexágono de la cara
//              exterior y hace de chaveta. El cubo largo llega hasta el aro interior del 608.
//              Se imprime con la cara exterior sobre la cama y el cubo hacia arriba.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
include <puntero_laser_parametros.scad>

/* [Hidden] */
alto_anillo_contacto = 0.5;
cantidad_aligerados = 6;

// --- MÓDULOS PRINCIPALES Y ENSAMBLAJE ---
ensamblaje_principal();

module ensamblaje_principal() {
    pieza_polea_altitud();
}

// z = 0: cara exterior (x = x_ext_polea_alt en el conjunto); +z hacia el brazo.
module pieza_polea_altitud() {
    z_dentado = espesor_brida;
    z_cubo = z_dentado + h_dentado + alto_brida_sup;
    alto_cubo = largo_cubo_polea_altitud - alto_anillo_contacto - (alto_brida_sup - espesor_brida);
    r_raiz = d_exterior_conducida/2 - profundidad_diente_gt2;
    difference() {
        union() {
            translate([0, 0, z_dentado]) {
                dentado_gt2(dientes_polea_conducida, h_dentado);
                pestanas_polea(d_exterior_conducida, h_dentado);
            }
            // Cubo largo hasta el aro interior del 608
            translate([0, 0, z_cubo - eps]) cylinder(d = d_cubo_polea_alt, h = alto_cubo + eps);
            translate([0, 0, z_cubo + alto_cubo - eps])
                cylinder(d = d_contacto_aro, h = alto_anillo_contacto + eps);
        }
        // Paso del perno M8
        translate([0, 0, -1]) cylinder(d = rod608_d_int + holgura_perno_m8, h = z_cubo + alto_cubo + 2);
        // Tuerca autoblocante M8 (chaveta) desde la cara exterior
        translate([0, 0, -eps]) alojamiento_hex(m8_tuerca_ec, m8_autoblocante_alto);
        // Aligerados en el disco
        if (d_exterior_conducida > 45) {
            r_hex = (m8_tuerca_ec + holgura_tuerca)/cos(30)/2;
            r_aligerado = (r_hex + r_raiz)/2;
            for (i = [0:cantidad_aligerados-1])
                rotate([0, 0, i*360/cantidad_aligerados + 30])
                    translate([r_aligerado, 0, -1]) cylinder(d = d_aligerado, h = z_cubo + 2);
        }
    }
    // Comprobaciones de la pieza
    assert(abs(z_cubo + alto_cubo + alto_anillo_contacto - (x_ext_polea_alt - x_cara_ext_brazo)) < 0.01,
           "largo_cubo_polea_altitud: el cubo no llega exactamente al aro interior del 608");
}
