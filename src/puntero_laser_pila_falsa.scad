// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Pila falsa
// Descripción: Reemplaza la batería del láser 303. En la cara delantera lleva el contacto positivo:
//              un tornillo M3 × 8 de cabeza alomada, roscado en una tuerca M3 embutida por una
//              ranura lateral, que aprieta el terminal de ojal del hilo rojo. El hilo baja por un
//              agujero axial descentrado y sale por una ranura radial de la cara trasera, que se
//              alinea con la ventana de la tapa trasera. Se imprime de pie, con la cara trasera
//              sobre la cama.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
include <puntero_laser_parametros.scad>

/* [Hidden] */
r_pila = d_pila_falsa/2;
chaflan_pila = 0.5;
d_paso_tornillo = m3_d + holgura_tornillo_m3;
prof_agujero_tornillo = largo_tornillo_contacto - espesor_ojal + 1.3;   // la punta pasa la tuerca
ec_tuerca_contacto = m3_tuerca_ec + holgura_tuerca;
alto_ranura_tuerca = m3_tuerca_alto + holgura_tuerca;
largo_marca = 3;
ancho_marca = 0.8;
prof_marca = 0.6;
x_marca = -(r_pila + iso7380_m3_cabeza_d/2)/2;   // entre la cabeza del tornillo y el borde, del lado de la tuerca

// --- MÓDULOS PRINCIPALES Y ENSAMBLAJE ---
ensamblaje_principal();

module ensamblaje_principal() {
    pieza_pila_falsa();
}

module pieza_pila_falsa() {
    difference() {
        cuerpo_pila();
        agujero_tornillo_contacto();
        ranura_tuerca_contacto();
        paso_hilo();
        ranura_hilo_trasera();
        marca_positivo();
    }
}

// Cilindro con chaflán en los dos bordes (perfil 2D girado)
module cuerpo_pila() {
    rotate_extrude($fn = 96)
        polygon([[0, 0], [r_pila - chaflan_pila, 0], [r_pila, chaflan_pila],
                 [r_pila, largo_pila_falsa - chaflan_pila], [r_pila - chaflan_pila, largo_pila_falsa],
                 [0, largo_pila_falsa]]);
}

// --- Elementos que restan material ---
module agujero_tornillo_contacto() {
    translate([0, 0, largo_pila_falsa - prof_agujero_tornillo])
        cylinder(d = d_paso_tornillo, h = prof_agujero_tornillo + eps, $fn = 24);
}

// Tuerca M3 acostada (eje Z), con la ranura de entrada hacia −X (lado opuesto al hilo)
module ranura_tuerca_contacto() {
    translate([0, 0, largo_pila_falsa - prof_tuerca_contacto - alto_ranura_tuerca])
        linear_extrude(height = alto_ranura_tuerca)
            union() {
                circle(d = ec_tuerca_contacto/cos(30), $fn = 6);
                translate([-r_pila - 1, -ec_tuerca_contacto/2]) square([r_pila + 1, ec_tuerca_contacto]);
            }
}

module paso_hilo() {
    translate([descentrado_hilo_pila, 0, -1])
        cylinder(d = d_paso_hilo, h = largo_pila_falsa + 2, $fn = 24);
}

module ranura_hilo_trasera() {
    translate([descentrado_hilo_pila, -d_paso_hilo/2, -eps])
        cube([r_pila, d_paso_hilo, prof_ranura_cable + eps]);
}

// "+" en bajorrelieve en la cara delantera
module marca_positivo() {
    translate([x_marca, 0, largo_pila_falsa - prof_marca])
        linear_extrude(height = prof_marca + eps)
            union() {
                square([largo_marca, ancho_marca], center = true);
                square([ancho_marca, largo_marca], center = true);
            }
}
