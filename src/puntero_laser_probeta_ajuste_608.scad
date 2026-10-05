// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Probeta de ajuste del 608
// Descripción: Tira de 5 anillos con alojamientos de 22 mm + ajuste (−0,1 … +0,3 mm) para elegir
//              el valor de ajuste_608 antes de imprimir las piezas grandes. Cada anillo lleva
//              tantos puntos en relieve como su número de orden (1 = −0,1 … 5 = +0,3).
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
include <puntero_laser_parametros.scad>

/* [Hidden] */
ajustes_probeta = [-0.1, 0, 0.1, 0.2, 0.3];
pared_probeta = 2.4;
alto_probeta = 8;
paso_probeta = rod608_d_ext + 0.3 + 2*pared_probeta + 3;
ancho_union_probeta = 6;
alto_union_probeta = 2;
d_punto = 1.6;
alto_punto = 0.6;
separacion_puntos = 2.6;
largo_pestana = 8;

// --- MÓDULOS PRINCIPALES Y ENSAMBLAJE ---
ensamblaje_principal();

module ensamblaje_principal() {
    pieza_probeta_ajuste_608();
}

module pieza_probeta_ajuste_608() {
    n = len(ajustes_probeta);
    translate([-(n - 1)*paso_probeta/2, 0, 0]) {
        for (i = [0:n-1]) translate([i*paso_probeta, 0, 0]) anillo_probeta(i);
        // Barra de unión entre anillos
        translate([0, -ancho_union_probeta/2, 0])
            cube([(n - 1)*paso_probeta, ancho_union_probeta, alto_union_probeta]);
    }
}

// Anillo i: alojamiento 22 + ajustes_probeta[i] y pestaña con i + 1 puntos
module anillo_probeta(i) {
    d_aloj = rod608_d_ext + ajustes_probeta[i];
    r_ext = d_aloj/2 + pared_probeta;
    difference() {
        union() {
            cylinder(r = r_ext, h = alto_probeta, $fn = 96);
            translate([-separacion_puntos*3, r_ext - 1, 0])
                cube([separacion_puntos*6, largo_pestana + 1, alto_union_probeta]);
        }
        translate([0, 0, -1]) cylinder(d = d_aloj, h = alto_probeta + 2, $fn = 96);
    }
    for (k = [0:i])
        translate([(k - i/2)*separacion_puntos, r_ext + largo_pestana/2, alto_union_probeta - eps])
            cylinder(d = d_punto, h = alto_punto + eps, $fn = 12);
}
