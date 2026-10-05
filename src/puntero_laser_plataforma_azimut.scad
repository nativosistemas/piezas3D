// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Plataforma de azimut
// Descripción: Plataforma giratoria que lleva los dos brazos de la horquilla (en marcos de
//              alineación), el carro y el tope tensor del motor de azimut (+Y), el bolsillo del
//              power bank (−X), los soportes de las placas y del interruptor bajo la tapa (+X), el
//              conducto elevado de cables que cruza la franja del láser y el alojamiento del
//              contrapeso. Gira sobre el perno M8 central, con la cabeza embutida en el cubo.
//              Se imprime con la cara inferior sobre la cama.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
include <puntero_laser_parametros.scad>

/* [Hidden] */
ancho_nervio = 2;
alto_nervio = 6;
alto_puente_canal = 1.2;
ancho_puente_canal = 4;
cantidad_puentes_canal = 3;
pad_soporte = 3;
pad_soporte_esp32 = 2.5;
pierna_soporte = 5;
alto_labio_soporte = 1;
ancho_reborde_tapa = 1.6;

// --- MÓDULOS PRINCIPALES Y ENSAMBLAJE ---
ensamblaje_principal();

module ensamblaje_principal() {
    pieza_plataforma_azimut();
}

// Sistema: XY del conjunto (eje de azimut en el origen), z = 0 cara inferior de la plataforma.
module pieza_plataforma_azimut() {
    difference() {
        union() {
            placa_nervada();
            cubo_central();
            for (s = [-1, 1]) marco_brazo(s);
            tope_azimut();
            bolsillo_powerbank();
            soportes_placas();
            soporte_interruptor();
            canal_cables();
            puente_brida(x_puente_brida_az, y_puente_brida_az, 0);
            reborde_tapa();
            if (con_contrapeso) alojamiento_contrapeso();
        }
        vaciado_cubo_central();
        for (s = [-1, 1]) agujeros_brazo(s);
        asiento_carro_azimut();
        abertura_polea_azimut();
        orejas_tapa_tuercas();
        if (con_contrapeso)
            translate([x_contrapeso, y_contrapeso, espesor_plataforma])
                alojamiento_hex(m8_tuerca_ec, tuercas_contrapeso*alto_tuerca_m8 + 2);
    }
}

// Placa con esquinas redondeadas y nervio perimetral
module placa_nervada() {
    placa_redondeada(x_plat0, y_plat0, x_plat1, y_plat1, radio_esquina_plataforma, espesor_plataforma);
    difference() {
        placa_redondeada(x_plat0, y_plat0, x_plat1, y_plat1, radio_esquina_plataforma, espesor_plataforma + alto_nervio);
        translate([0, 0, -1])
            placa_redondeada(x_plat0 + ancho_nervio, y_plat0 + ancho_nervio, x_plat1 - ancho_nervio, y_plat1 - ancho_nervio,
                             radio_esquina_plataforma - ancho_nervio, espesor_plataforma + alto_nervio + 2);
    }
}

// Cubo central: la cabeza del perno M8 queda embutida y gira con la plataforma (U-03)
module cubo_central() {
    cylinder(d = d_cubo_plataforma, h = espesor_cubo_plataforma);
}
module vaciado_cubo_central() {
    translate([0, 0, -1]) cylinder(d = rod608_d_int + holgura_perno_m8, h = espesor_cubo_plataforma + 2);
    translate([0, 0, espesor_cubo_plataforma - m8_cabeza_alto - 0.3])
        alojamiento_hex(m8_cabeza_ec, m8_cabeza_alto + 1);
}

// Marco de alineación del pie de un brazo (s = +1 motor, −1 cable) (U-04, FR-003)
module marco_brazo(s) {
    mirror([s < 0 ? 1 : 0, 0, 0])
        translate([0, 0, espesor_plataforma - eps])
            difference() {
                translate([x_marco_int, -y_marco, 0])
                    cube([x_marco_ext - x_marco_int, 2*y_marco, alto_marco + eps]);
                translate([semiancho_interior_horquilla - holgura_encastre, -ancho_brazo/2 - holgura_encastre, -1])
                    cube([espesor_brazo + 2*holgura_encastre, ancho_brazo + 2*holgura_encastre, alto_marco + 2]);
            }
}
module agujeros_brazo(s) {
    for (t = [-1, 1])
        translate([s*(semiancho_interior_horquilla + espesor_brazo/2), t*separacion_tornillos_pie/2, -1])
            cylinder(d = m3_d + holgura_tornillo_m3, h = espesor_plataforma + 2, $fn = 20);
}

// Carro del motor de azimut: tuercas M3 desde abajo bajo las ranuras del carro (U-06)
module asiento_carro_azimut() {
    for (s = [-1, 1])
        translate([s*ranura_carro_y, distancia_centros + ranura_carro_x, 0]) {
            translate([0, 0, -eps]) alojamiento_hex(m3_tuerca_ec, m3_tuerca_alto + 0.2);
            translate([0, 0, -1]) cylinder(d = m3_d + holgura_tornillo_m3, h = espesor_plataforma + 2, $fn = 20);
        }
}
// Abertura alargada en Y donde entra el cubo de la polea 20T de azimut
module abertura_polea_azimut() {
    translate([0, distancia_centros, -1]) rotate([0, 0, 90])
        ranura(polea20_d_brida + 3, 2*recorrido_tensor, espesor_plataforma + 2);
}
// Tope tensor del motor de azimut: M3 autorroscante a lo largo de Y, a media altura del carro
module tope_azimut() {
    difference() {
        translate([-ancho_tope/2, r_tope_int, espesor_plataforma - eps]) cube([ancho_tope, largo_tope, alto_tope + eps]);
        translate([0, (r_tope_int + r_tope_ext)/2, espesor_plataforma + espesor_carro/2])
            rotate([0, 0, 90]) agujero_gota(diametro_autorroscante_m3, largo_tope + 2);
    }
}

// Bolsillo del power bank de pie; la pared del extremo −Y es baja para el conector USB
module bolsillo_powerbank() {
    translate([0, 0, espesor_plataforma - eps])
        difference() {
            translate([x_pb1, y_pb0, 0]) cube([ancho_bolsillo, largo_bolsillo, alto_bolsillo + eps]);
            translate([x_pb1 + pared_bolsillo, y_pb0 + pared_bolsillo, -1])
                cube([ancho_bolsillo - 2*pared_bolsillo, largo_bolsillo - 2*pared_bolsillo, alto_bolsillo + 2]);
            translate([x_pb1 - 1, y_pb0 - 1, alto_bolsillo_usb])
                cube([ancho_bolsillo + 2, pared_bolsillo + 2, alto_bolsillo]);
        }
}

// Soportes de encastre con labio para las placas (U-12)
module soportes_placas() {
    soporte_placa(x_col_a0, y_uln_alt0, uln2003_ancho, uln2003_largo, alto_soporte_placa, pad_soporte);
    soporte_placa(x_col_a0, y_uln_az0, uln2003_ancho, uln2003_largo, alto_soporte_placa, pad_soporte);
    soporte_placa(x_col_b0, y_esp32_0, esp32_ancho, esp32_largo, elevacion_esp32, pad_soporte_esp32);
    soporte_placa(x_col_b0, y_rele_0, rele_ancho, rele_largo, alto_soporte_placa, pad_soporte);
}
// Celda que empieza en [x0, y0]; placa de a × l (a en X, l en Y) apoyada a z_apoyo sobre la plataforma
module soporte_placa(x0, y0, a, l, z_apoyo, pad) {
    bx0 = x0 + pared_soporte + holgura_encastre;
    by0 = y0 + pared_soporte + holgura_encastre;
    alto_poste = z_apoyo + espesor_pcb + holgura_pcb + alto_labio_soporte;
    translate([0, 0, espesor_plataforma - eps])
        for (i = [0, 1], j = [0, 1]) {
            cx = i == 0 ? bx0 - holgura_encastre : bx0 + a + holgura_encastre;
            cy = j == 0 ? by0 - holgura_encastre : by0 + l + holgura_encastre;
            sx = i == 0 ? 1 : -1;
            sy = j == 0 ? 1 : -1;
            // Poste en L por fuera de la esquina de la placa
            translate([cx - (i == 0 ? pared_soporte : 0), cy - (j == 0 ? pared_soporte : 0), 0]) {
                translate([0, j == 0 ? 0 : -pierna_soporte + pared_soporte, 0])
                    cube([pared_soporte, pierna_soporte, alto_poste + eps]);
                translate([i == 0 ? 0 : -pierna_soporte + pared_soporte, 0, 0])
                    cube([pierna_soporte, pared_soporte, alto_poste + eps]);
            }
            // Apoyo bajo la esquina de la placa
            translate([i == 0 ? cx : cx - pad, j == 0 ? cy : cy - pad, 0]) cube([pad, pad, z_apoyo + eps]);
            // Labio con chaflán de entrada sobre la placa
            translate([cx, cy, z_apoyo + espesor_pcb + holgura_pcb])
                hull() {
                    translate([i == 0 ? -eps : -labio_soporte, j == 0 ? -eps : -labio_soporte, 0])
                        cube([labio_soporte + eps, labio_soporte + eps, eps]);
                    translate([i == 0 ? -eps : 0, j == 0 ? -eps : 0, alto_labio_soporte - eps])
                        cube([eps, eps, eps]);
                }
        }
}

// Soporte del interruptor general dentro de la tapa (FR-013): la palanca sale por la pared +X
module soporte_interruptor() {
    difference() {
        translate([x_interruptor, y_interruptor - ancho_soporte_interruptor/2, espesor_plataforma - eps])
            cube([espesor_soporte_interruptor, ancho_soporte_interruptor, alto_interruptor + d_interruptor/2 + 3]);
        translate([x_interruptor + espesor_soporte_interruptor/2, y_interruptor, espesor_plataforma + alto_interruptor])
            agujero_gota(d_interruptor, espesor_soporte_interruptor + 2);
    }
}

// Conducto elevado que cruza la franja del láser; la placa no se rebaja (U1, FR-012, FR-021)
module canal_cables() {
    largo = x_tapa0 - x_pb0;
    translate([x_pb0, y_conducto, espesor_plataforma - eps]) {
        for (s = [-1, 1])
            translate([0, s*(ancho_canal + pared_canal)/2 - pared_canal/2, 0])
                cube([largo, pared_canal, altura_max_canal + eps]);
        for (i = [1:cantidad_puentes_canal])
            translate([i*largo/(cantidad_puentes_canal + 1) - ancho_puente_canal/2, -ancho_canal/2 - eps,
                       altura_max_canal - alto_puente_canal])
                cube([ancho_puente_canal, ancho_canal + 2*eps, alto_puente_canal]);
    }
}

// Puente para brida de cable (arco de dos patas)
module puente_brida(x, y, angulo) {
    translate([x, y, espesor_plataforma - eps]) rotate([0, 0, angulo])
        difference() {
            translate([-largo_puente_brida/2, -ancho_puente_brida/2, 0])
                cube([largo_puente_brida, ancho_puente_brida, alto_puente_brida]);
            translate([-largo_puente_brida/2 + pared_canal, -ancho_puente_brida/2 - 1, -1])
                cube([largo_puente_brida - 2*pared_canal, ancho_puente_brida + 2, paso_brida + 1]);
        }
}

// Reborde que guía la tapa por dentro de sus paredes (lados +X, −Y y +Y; el lado −X queda libre
// para la entrada de cables)
module reborde_tapa() {
    xi0 = x_tapa0 + pared_tapa + holgura_encastre;
    xi1 = x_tapa1 - pared_tapa - holgura_encastre;
    yi0 = y_tapa0 + pared_tapa + holgura_encastre;
    yi1 = y_tapa1 - pared_tapa - holgura_encastre;
    translate([0, 0, espesor_plataforma - eps]) {
        translate([xi1 - ancho_reborde_tapa, yi0, 0]) cube([ancho_reborde_tapa, yi1 - yi0, alto_borde_tapa]);
        translate([xi0 + ancho_tope, yi0, 0]) cube([xi1 - xi0 - ancho_tope, ancho_reborde_tapa, alto_borde_tapa]);
        translate([xi0 + ancho_tope, yi1 - ancho_reborde_tapa, 0]) cube([xi1 - xi0 - ancho_tope, ancho_reborde_tapa, alto_borde_tapa]);
    }
}
// Tuercas M3 desde abajo para las orejas de la tapa (U-11)
module orejas_tapa_tuercas() {
    for (y = [y_tapa0 - largo_oreja_tapa/2, y_tapa1 + largo_oreja_tapa/2])
        translate([(x_tapa0 + x_tapa1)/2, y, 0]) {
            translate([0, 0, -eps]) alojamiento_hex(m3_tuerca_ec, m3_tuerca_alto + 0.2);
            translate([0, 0, -1]) cylinder(d = m3_d + holgura_tornillo_m3, h = espesor_plataforma + 2, $fn = 20);
        }
}

// Alojamiento del contrapeso (tuercas M8 apiladas)
module alojamiento_contrapeso() {
    translate([x_contrapeso, y_contrapeso, espesor_plataforma - eps])
        cylinder(d = d_contrapeso + 2*pared_soporte, h = tuercas_contrapeso*alto_tuerca_m8 + 1);
}
