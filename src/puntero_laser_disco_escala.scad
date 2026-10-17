// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Disco de la escala de altura
// Descripción: Anillo plano que apoya en la cara exterior de la polea de altura y gira con ella. Lleva
//              grabadas rayas cada paso_escala grados, de 0° a angulo_escala_max, que se leen contra la
//              aguja de índice del brazo del motor. Se fija con 2 tornillos M3 autorroscantes que pasan
//              por 2 ranuras en arco: así el cero se pone una vez al armar, porque el ángulo de la polea
//              respecto de la cuna depende del apriete del perno M8 (research 012, R1).
//              Se imprime plano, con la escala hacia arriba (mejor en un color claro).
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
include <puntero_laser_parametros.scad>

/* [Hidden] */
r_raya_larga = 19;                       // inicio de las rayas múltiplo de 45°
r_raya_corta = 21.5;                     // inicio de las demás
ancho_ranura_disco = m3_d + holgura_tornillo_m3;
angulos_ranuras = [0, 180];              // coinciden con los agujeros guía de la polea
// En el conjunto (rotate([0, 90, 0])), el −X de la pieza queda arriba (la aguja) y el +Y hacia +Y. Con el
// láser a 0°, la raya de un ángulo a va a a grados de la vertical hacia +Y: al subir el láser a grados,
// la polea gira y la lleva a la aguja (research 012, R7).
function angulo_raya(a) = 180 - a;
angulos_escala = [for (a = [0:paso_escala:angulo_escala_max]) a];

// --- VALIDACIONES (M-06) ---
assert(giro_ranura_disco >= 30,
       str("giro_ranura_disco=", giro_ranura_disco, ": las ranuras no cubren el escalón de 60° del hexágono",
           " del perno (hace falta ±30°)"));
assert(r_raya_larga - (r_agujeros_disco + ancho_ranura_disco/2) >= espesor_min_pared,
       "r_raya_larga: las rayas largas tocan las ranuras del disco");
assert(r_agujeros_disco - ancho_ranura_disco/2 - d_interior_disco_escala/2 >= espesor_min_pared,
       "d_interior_disco_escala: el agujero central toca las ranuras del disco");
assert(profundidad_grabado <= espesor_disco_escala - espesor_min_pared/2,
       "profundidad_grabado: las rayas atraviesan casi todo el disco");
assert(2*r_exterior_disco_escala <= cama_max, "el disco no entra en la cama");

// --- MÓDULOS PRINCIPALES Y ENSAMBLAJE ---
ensamblaje_principal();

module ensamblaje_principal() {
    pieza_disco_escala();
}

// z = 0: cara que apoya en la polea; la escala queda en z = espesor_disco_escala.
module pieza_disco_escala() {
    difference() {
        linear_extrude(height = espesor_disco_escala)
            difference() {
                circle(r = r_exterior_disco_escala);
                circle(d = d_interior_disco_escala);
                for (a = angulos_ranuras) ranura_arco(a);
            }
        escala();
    }
}

// Ranura en arco de ±giro_ranura_disco centrada en el ángulo a, a r_agujeros_disco
module ranura_arco(a) {
    rotate(a) {
        intersection() {
            difference() {
                circle(r = r_agujeros_disco + ancho_ranura_disco/2);
                circle(r = r_agujeros_disco - ancho_ranura_disco/2);
            }
            r_sector = 2*r_exterior_disco_escala;
            polygon(concat([[0, 0]], [for (g = [-giro_ranura_disco:2:giro_ranura_disco])
                                         r_sector*[cos(g), sin(g)]]));
        }
        for (s = [-1, 1]) rotate(s*giro_ranura_disco) translate([r_agujeros_disco, 0]) circle(d = ancho_ranura_disco);
    }
}

// Rayas grabadas desde la cara de arriba hasta el borde
module escala() {
    translate([0, 0, espesor_disco_escala - profundidad_grabado])
        linear_extrude(height = profundidad_grabado + 1)
            for (a = angulos_escala) {
                r0 = a % 45 == 0 ? r_raya_larga : r_raya_corta;
                rotate(angulo_raya(a)) translate([r0, -ancho_raya/2]) square([r_exterior_disco_escala - r0 + 1, ancho_raya]);
            }
}
