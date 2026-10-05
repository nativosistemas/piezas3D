// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Tapa de la electrónica
// Descripción: Cáscara abierta por abajo que cubre las placas (ESP32, relé y 2 ULN2003), el
//              interruptor general y el hueco del cable sobrante, en el lado +X de la plataforma.
//              Rejillas inclinadas a 45° (el agua que cae vertical no entra), abertura para el USB
//              del ESP32, ranura abierta desde abajo para la palanca del interruptor, entradas de
//              cables en la pared −X y 2 orejas M3. Se imprime con el techo sobre la cama.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
include <puntero_laser_parametros.scad>

/* [Hidden] */
ancho_rejilla = 2;
largo_rejilla = 15;
paso_rejilla = 6;
z_rejilla = 14;
margen_rejilla = 8;
ancho_usb_esp32 = 12;
alto_usb_esp32 = 9;
margen_usb_esp32 = 2;
ancho_entrada_cable = 8;
alto_entrada_cable = 6;
ancho_ranura_interruptor = d_interruptor + 2;
y_entrada_motor_az = (y_sob0 + y_sob1)/2;   // entra por la pared −X a la altura del hueco del sobrante

// --- MÓDULOS PRINCIPALES Y ENSAMBLAJE ---
ensamblaje_principal();

module ensamblaje_principal() {
    pieza_tapa_electronica();
}

// Orientación de impresión: techo sobre la cama, centrada en X e Y.
module pieza_tapa_electronica() {
    translate([0, 0, alto_tapa]) rotate([180, 0, 0])
        translate([-(x_tapa0 + x_tapa1)/2, -(y_tapa0 + y_tapa1)/2, 0])
            tapa_en_posicion();
}

// Tapa en su posición del conjunto (z = 0 sobre la cara superior de la plataforma).
module tapa_en_posicion() {
    difference() {
        union() {
            cascara();
            encastres();
        }
        translate([x_tapa0 + pared_tapa, y_tapa0 + pared_tapa, -1])
            cube([x_tapa1 - x_tapa0 - 2*pared_tapa, y_tapa1 - y_tapa0 - 2*pared_tapa, alto_interior_tapa + 1]);
        rejillas_ventilacion();
        abertura_usb();
        ranura_interruptor();
        entradas_cables();
        for (y = [y_tapa0 - largo_oreja_tapa/2, y_tapa1 + largo_oreja_tapa/2])
            translate([(x_tapa0 + x_tapa1)/2, y, -1]) cylinder(d = m3_d + holgura_tornillo_m3, h = espesor_oreja_tapa + 2, $fn = 20);
    }
}

module cascara() {
    translate([x_tapa0, y_tapa0, 0]) cube([x_tapa1 - x_tapa0, y_tapa1 - y_tapa0, alto_tapa]);
}

// Orejas M3 en los extremos ±Y, con cartela a 45° (sin soportes al imprimir boca abajo) (U-11)
module encastres() {
    xc = (x_tapa0 + x_tapa1)/2;
    for (s = [-1, 1]) {
        y_pared = s < 0 ? y_tapa0 : y_tapa1;
        translate([xc - ancho_oreja_tapa/2, s < 0 ? y_pared - largo_oreja_tapa : y_pared - eps, 0])
            cube([ancho_oreja_tapa, largo_oreja_tapa + eps, espesor_oreja_tapa]);
        translate([xc - ancho_oreja_tapa/2, y_pared, espesor_oreja_tapa - eps])
            rotate([90, 0, 90]) linear_extrude(height = ancho_oreja_tapa)
                polygon(s < 0 ? [[0, 0], [-largo_oreja_tapa, 0], [0, largo_oreja_tapa]]
                              : [[0, 0], [largo_oreja_tapa, 0], [0, largo_oreja_tapa]]);
    }
}

// Rejillas inclinadas a 45°: la boca exterior queda más abajo que la interior (FR-014)
module rejillas_ventilacion() {
    // Pared +X
    for (y = [y_tapa0 + margen_rejilla : paso_rejilla : y_sob0 - margen_rejilla])
        translate([x_tapa1 - pared_tapa/2, y, z_rejilla]) rotate([0, 45, 0])
            cube([ancho_rejilla, largo_rejilla/3, 3*pared_tapa], center = true);
    // Paredes ±Y
    for (x = [x_tapa0 + margen_rejilla : paso_rejilla : x_tapa1 - margen_rejilla])
        if (abs(x - (x_tapa0 + x_tapa1)/2) > ancho_oreja_tapa)
            for (s = [-1, 1])
                translate([x, s < 0 ? y_tapa0 + pared_tapa/2 : y_tapa1 - pared_tapa/2, z_rejilla])
                    rotate([s*45, 0, 0]) cube([largo_rejilla/3, ancho_rejilla, 3*pared_tapa], center = true);
}

// Abertura para el conector USB del ESP32 (extremo −Y de su celda). El borde inferior (que queda
// arriba al imprimir la tapa boca abajo) termina a dos aguas a 45°: sin puentes de más de 10 mm.
module abertura_usb() {
    z0 = elevacion_esp32 - margen_usb_esp32;
    translate([(x_col_b0 + x_col_b1)/2, y_tapa0 + pared_tapa + 1, 0]) rotate([90, 0, 0])
        linear_extrude(height = pared_tapa + 2)
            polygon([[-ancho_usb_esp32/2, z0 + alto_usb_esp32], [ancho_usb_esp32/2, z0 + alto_usb_esp32],
                     [ancho_usb_esp32/2, z0], [0, z0 - ancho_usb_esp32/2], [-ancho_usb_esp32/2, z0]]);
}

// Ranura abierta desde abajo para la palanca del interruptor (la tapa sale sin desmontarlo)
module ranura_interruptor() {
    translate([x_tapa1 - pared_tapa - 1, y_interruptor - ancho_ranura_interruptor/2, -1])
        cube([pared_tapa + 2, ancho_ranura_interruptor, alto_interruptor + 1 + ancho_ranura_interruptor/2]);
}

// Entradas de cables en la pared −X: conducto, cable del motor de altura y del motor de azimut
module entradas_cables() {
    translate([x_tapa0 - 1, y_conducto - ancho_canal/2 - pared_canal - 1, -1])
        cube([pared_tapa + 2, ancho_canal + 2*pared_canal + 2, altura_max_canal + 2]);
    for (y = [0, y_entrada_motor_az])
        translate([x_tapa0 - 1, y - ancho_entrada_cable/2, -1])
            cube([pared_tapa + 2, ancho_entrada_cable, alto_entrada_cable + 1]);
    assert(y_entrada_motor_az + ancho_entrada_cable/2 < y_tapa1 - pared_tapa,
           "alto_sobrante_cables: la entrada del cable del motor de azimut queda fuera de la tapa");
}
