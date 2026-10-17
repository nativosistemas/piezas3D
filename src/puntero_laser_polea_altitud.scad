// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Polea de altura (GT2, dientes_polea_conducida)
// Descripción: Polea conducida del eje de altura. Va por fuera del brazo del motor, montada en el
//              perno M8 del lado motor, que entra desde afuera y se enrosca en la tuerca del muñón +X
//              de la cuna. La cabeza del perno queda en el hexágono de la cara exterior y hace de
//              chaveta. El cubo largo llega hasta el aro interior del 608.
//              Desde la 012 tiene 2 agujeros guía en la cara exterior, entre aligerados, para los
//              tornillos autorroscantes del disco de la escala de altura.
//              Se imprime con la cara exterior sobre la cama y el cubo hacia arriba.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
include <puntero_laser_parametros.scad>

/* [Hidden] */
alto_anillo_contacto = 0.5;
cantidad_aligerados = 6;
prof_agujero_disco = 8;                 // M3 × 8 menos el disco y la arandela, con margen
angulos_agujeros_disco = [0, 180];      // entre aligerados (a 30° + k·60°)

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
        // Cabeza del perno M8 (chaveta) desde la cara exterior; su profundidad ajusta el largo comercial
        translate([0, 0, -eps]) alojamiento_hex(m8_cabeza_ec, prof_cabeza_polea_alt + eps);
        // Aligerados en el disco
        if (d_exterior_conducida > 45) {
            for (i = [0:cantidad_aligerados-1])
                rotate([0, 0, i*360/cantidad_aligerados + 30])
                    translate([r_aligerado, 0, -1]) cylinder(d = d_aligerado, h = z_cubo + 2);
        }
        // Agujeros guía del disco de la escala (012)
        for (a = angulos_agujeros_disco)
            rotate([0, 0, a]) translate([r_agujeros_disco, 0, -eps])
                cylinder(d = diametro_autorroscante_m3, h = prof_agujero_disco + eps, $fn = 24);
    }
    // Comprobaciones de la pieza
    // M-05: pared de los agujeros guía a los aligerados y a la raíz del dentado
    assert(d_exterior_conducida <= 45
           || norm([r_agujeros_disco, 0] - r_aligerado*[cos(30), sin(30)]) - d_aligerado/2 - diametro_autorroscante_m3/2
              >= espesor_min_pared,
           "r_agujeros_disco: el agujero guía del disco queda muy cerca de un aligerado");
    assert(r_raiz_polea_alt - r_agujeros_disco - diametro_autorroscante_m3/2 >= espesor_min_pared,
           "r_agujeros_disco: el agujero guía del disco queda muy cerca de la raíz del dentado");
    assert(prof_agujero_disco <= z_cubo - espesor_min_pared,
           "prof_agujero_disco: el agujero guía atraviesa el disco de la polea");
    assert(prof_cabeza_polea_alt <= z_cubo - espesor_min_pared,
           str("margen_punta_perno=", margen_punta_perno, ": el alojamiento de la cabeza (", prof_cabeza_polea_alt,
               " mm) deja menos de ", espesor_min_pared, " mm de disco bajo el cubo"));
    assert(abs(z_cubo + alto_cubo + alto_anillo_contacto - (x_ext_polea_alt - x_cara_ext_brazo)) < 0.01,
           "largo_cubo_polea_altitud: el cubo no llega exactamente al aro interior del 608");
}
