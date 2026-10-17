// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Adaptador del trípode (base fija)
// Descripción: Base fija que se enrosca al tornillo 3/8"-16 del trípode (tuerca embebida cargada
//              desde arriba). Aloja los dos 608ZZ de azimut a presión, separados por un resalte,
//              una cámara con ventana lateral para la tuerca autoblocante M8 y el 608 inferior, y
//              lleva integrada la polea GT2 fija del eje de azimut. Desde la 012 lleva grabadas una «S»
//              (+Y) y una «O» (+X) con su línea de referencia vertical, para orientarla al sur.
//              Se imprime apoyada en la cama.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
include <puntero_laser_parametros.scad>

/* [Hidden] */
d_agujero_tripode = rosca_3_8_d + 0.6;
d_alojamiento_608 = rod608_d_ext + ajuste_608;
d_cubo_base = d_exterior_conducida - 2*profundidad_diente_gt2;   // raíz del dentado
// Marcas cardinales (012): letra arriba y línea de referencia debajo, en el cilindro de apoyo
r_apoyo_marcas = diametro_apoyo_tripode/2;
margen_marcas = 3;                                      // a los bordes del cilindro y entre letra y línea
ancho_letra_max = 0.8*alto_letra;                       // ancho de «S» y «O» en Liberation Sans Bold
z_centro_letra = z_cuerpo_base_sup - margen_marcas - alto_letra/2;
z_linea_inf = chaflan_base + margen_marcas;
z_linea_sup = z_centro_letra - alto_letra/2 - margen_marcas;
semiangulo_letra = asin(ancho_letra_max/2/r_apoyo_marcas);
semiangulo_ventana = asin(ancho_ventana/2/r_apoyo_marcas);
// Validaciones de las marcas (M-01, M-02)
assert(z_linea_sup - z_linea_inf >= alto_letra/2,
       str("alto_letra=", alto_letra, ": la letra y su línea no caben en el cilindro de apoyo (",
           z_cuerpo_base_sup - chaflan_base, " mm de alto)"));
assert(min([for (a = [angulo_marca_sur, angulo_marca_oeste]) abs(((a - 270) % 360 + 540) % 360 - 180)])
           > semiangulo_letra + semiangulo_ventana,
       "angulo_marca_sur: una letra cae sobre la ventana de la llave (−Y)");
assert(r_apoyo_marcas - profundidad_grabado - d_camara/2 >= espesor_min_pared,
       str("profundidad_grabado=", profundidad_grabado, ": deja menos de ", espesor_min_pared,
           " mm de pared hasta la cámara"));

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
        marcas_cardinales();
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

// «S» y «O» con su línea de referencia, grabadas profundidad_grabado en el cilindro de apoyo (012)
module marcas_cardinales() {
    for (m = [["S", angulo_marca_sur], ["O", angulo_marca_oeste]])
        grabado_cilindrico(r_apoyo_marcas, m[1]) {
            translate([0, z_centro_letra])
                text(m[0], size = alto_letra, font = fuente_marcas, halign = "center", valign = "center");
            translate([-ancho_linea_referencia/2, z_linea_inf]) square([ancho_linea_referencia, z_linea_sup - z_linea_inf]);
        }
}

// Grabado de un dibujo 2D (x horizontal, y = z del conjunto) en la cara de un cilindro de radio r, centrado en
// el ángulo dado y legible desde afuera, con profundidad uniforme
module grabado_cilindrico(r, angulo) {
    intersection() {
        rotate([0, 0, angulo - 90]) rotate([90, 0, 180])
            translate([0, 0, r - profundidad_grabado - 1]) linear_extrude(height = profundidad_grabado + 2) children();
        difference() {
            translate([0, 0, -1]) cylinder(r = r + 1, h = z_cuerpo_base_sup + 2);
            translate([0, 0, -2]) cylinder(r = r - profundidad_grabado, h = z_cuerpo_base_sup + 4);
        }
    }
}
