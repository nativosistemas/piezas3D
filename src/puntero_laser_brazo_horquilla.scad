// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Brazo de la horquilla (variantes "motor" y "cable")
// Descripción: Brazo que sostiene un 608ZZ del eje de altura. Se imprime plano (cara interior sobre
//              la cama) para que las capas no trabajen a flexión y el alojamiento salga redondo.
//              Variante "motor": pilares para el carro del motor de altura, tope tensor y canal
//              del cable del motor. Variante "cable": agujero y canal para los 2 hilos del láser.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
include <puntero_laser_parametros.scad>

// Variante del brazo
lado = "motor"; // [motor, cable]

/* [Hidden] */
r_alojamiento = rod608_d_ext/2 + pared_alojamiento_608;
y_eje_motor_brazo = altura_eje - distancia_centros;      // eje del motor de altura (impresión)
y_pilares = y_eje_motor_brazo - ranura_carro_x;
alto_tope_brazo = alto_pilar_motor + espesor_carro;
z_tornillo_tope = espesor_brazo + alto_pilar_motor + espesor_carro/2;
largo_tornillo_pilar = 12;
y_ancho0 = y_eje_motor_brazo - carro_x_max - recorrido_tensor;
y_ancho1 = altura_eje - r_tope_int;
ancho_resalte_canal = 0.8;

// --- MÓDULOS PRINCIPALES Y ENSAMBLAJE ---
ensamblaje_principal();

module ensamblaje_principal() {
    pieza_brazo_horquilla(lado);
}

// Sistema de impresión: X = ancho del brazo (Y del conjunto), Y = largo (Z del conjunto, pie en
// y = 0 sobre la plataforma), Z = espesor (z = 0 cara interior, z = espesor_brazo cara exterior).
module pieza_brazo_horquilla(lado) {
    assert(lado == "motor" || lado == "cable", str("lado=", lado, ": debe ser \"motor\" o \"cable\""));
    assert(alto_brazo <= cama_max, str("largo_laser=", largo_laser, ": el brazo mide ", alto_brazo, " mm"));
    difference() {
        union() {
            cuerpo_brazo(lado);
            if (lado == "motor") {
                pilares_motor();
                tope_tensor_brazo();
            }
        }
        alojamiento_608();
        pie_brazo();
        if (lado == "motor") canal_cable_motor();
        if (lado == "cable") canal_cable_laser();
    }
    if (lado == "cable") resaltes_canal();
}

module cuerpo_brazo(lado) {
    linear_extrude(height = espesor_brazo) {
        translate([-ancho_brazo/2, 0]) square([ancho_brazo, alto_marco + 1]);
        hull() {
            translate([-ancho_brazo/2, alto_marco]) square([ancho_brazo, 1]);
            translate([0, altura_eje]) circle(r = r_alojamiento);
            if (lado == "motor")
                translate([-carro_semiancho, y_ancho0]) square([2*carro_semiancho, y_ancho1 - y_ancho0]);
        }
    }
}

// 608 a presión desde la cara exterior, con labio interior (U-07)
module alojamiento_608() {
    translate([0, altura_eje, labio_608]) cylinder(d = rod608_d_ext + ajuste_608, h = espesor_brazo);
    translate([0, altura_eje, -1]) cylinder(d = d_labio_608, h = espesor_brazo + 2);
}

// Pie: 2 agujeros M3 a lo largo del brazo con ranura de tuerca abierta hacia la cara exterior (U-04)
module pie_brazo() {
    for (s = [-1, 1]) {
        translate([s*separacion_tornillos_pie/2, prof_tornillo_pie/2 - 1, espesor_brazo/2])
            rotate([0, 0, 90]) agujero_gota(m3_d + holgura_tornillo_m3, prof_tornillo_pie + 2);
        translate([s*separacion_tornillos_pie/2 - (m3_tuerca_ec + holgura_tuerca)/2,
                   dist_tuerca_pie - (m3_tuerca_alto + 0.4)/2,
                   espesor_brazo/2 - (m3_tuerca_ec + holgura_tuerca)/cos(30)/2])
            cube([m3_tuerca_ec + holgura_tuerca, m3_tuerca_alto + 0.4, espesor_brazo]);
    }
}

// Pilares del carro del motor de altura (M3 autorroscante desde arriba)
module pilares_motor() {
    for (s = [-1, 1])
        translate([s*ranura_carro_y, y_pilares, espesor_brazo - eps])
            difference() {
                cylinder(d = d_pilar, h = alto_pilar_motor + eps);
                translate([0, 0, alto_pilar_motor - largo_tornillo_pilar])
                    cylinder(d = diametro_autorroscante_m3, h = largo_tornillo_pilar + 1, $fn = 20);
            }
}

// Tope tensor: bloque con un M3 autorroscante que empuja la cara del carro más cercana al eje
module tope_tensor_brazo() {
    difference() {
        translate([-ancho_tope/2, altura_eje - r_tope_ext, espesor_brazo - eps])
            cube([ancho_tope, largo_tope, alto_tope_brazo + eps]);
        translate([0, altura_eje - (r_tope_ext + r_tope_int)/2, z_tornillo_tope])
            rotate([0, 0, 90]) agujero_gota(diametro_autorroscante_m3, largo_tope + 2);
    }
}

// Canal para el cable del motor de altura en la cara exterior, hasta el pie
module canal_cable_motor() {
    y1 = y_eje_motor_brazo + carro_x_min - motor_d_cuerpo - motor_tapa_saliente;
    translate([-ancho_canal_motor/2, alto_marco + 1, espesor_brazo - prof_canal_motor])
        cube([ancho_canal_motor, max(y1 - alto_marco - 1, 1), prof_canal_motor + 1]);
}

// Agujero de paso y canal de los 2 hilos del láser en la cara exterior, hasta el pie
module canal_cable_laser() {
    y_agujero = altura_eje - dist_agujero_cable;
    translate([0, y_agujero, -1]) cylinder(d = d_agujero_cable_brazo, h = espesor_brazo + 2);
    translate([-ancho_canal_brazo/2, alto_marco + 1, espesor_brazo - prof_canal_brazo])
        cube([ancho_canal_brazo, y_agujero - alto_marco - 1, prof_canal_brazo + 1]);
}

// 3 resaltes alternados que retienen los hilos dentro del canal
module resaltes_canal() {
    y_agujero = altura_eje - dist_agujero_cable;
    for (i = [1:3])
        translate([(i % 2 == 0 ? 1 : -1)*(ancho_canal_brazo/2 - ancho_resalte_canal/2),
                   alto_marco + 1 + i*(y_agujero - alto_marco - 1)/4, espesor_brazo - 1])
            cube([ancho_resalte_canal, 2, 1], center = true);
}
