// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Grapa del cable del láser
// Descripción: Anillo abierto que se calza a presión sobre el tubo del láser, entre la tapa
//              trasera y la cuna, con un ojal exterior a angulo_cable donde los 2 hilos entran a
//              presión por una ranura. Mantiene el cable pegado al láser y hace de alivio de tensión:
//              un tirón del cable queda en la grapa y no llega a los contactos. Se imprime plana.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
include <puntero_laser_parametros.scad>

/* [Hidden] */
r_int_grapa = diametro_laser/2 - holgura("presion");
r_ext_grapa = r_int_grapa + pared_grapa;
r_int_ojal = (2*d_hilo + 0.2)/2;   // los 2 hilos lado a lado, ajustados: es el alivio de tensión
r_centro_ojal = r_ext_grapa + r_int_ojal;
ancho_entrada_ojal = d_hilo - 0.2;
angulo_abertura = angulo_cable + 180;   // la abertura queda del lado opuesto al cable
redondeo_grapa = 0.6;

// --- MÓDULOS PRINCIPALES Y ENSAMBLAJE ---
ensamblaje_principal();

module ensamblaje_principal() {
    pieza_grapa_cable();
}

module pieza_grapa_cable() {
    linear_extrude(height = ancho_grapa)
        offset(r = redondeo_grapa) offset(delta = -redondeo_grapa)
            difference() {
                union() {
                    circle(r = r_ext_grapa, $fn = 96);
                    rotate(angulo_cable) translate([r_centro_ojal, 0]) circle(r = r_int_ojal + pared_grapa, $fn = 48);
                }
                circle(r = r_int_grapa, $fn = 96);
                rotate(angulo_cable) translate([r_centro_ojal, 0]) circle(r = r_int_ojal, $fn = 48);
                // ranura de entrada del ojal, hacia afuera
                rotate(angulo_cable) translate([r_centro_ojal, -ancho_entrada_ojal/2])
                    square([r_int_ojal + pared_grapa + 1, ancho_entrada_ojal]);
                abertura_anillo();
            }
}

// Sector de abertura_grapa grados para calzar la grapa sobre el tubo
module abertura_anillo() {
    r = r_ext_grapa + 1;
    rotate(angulo_abertura)
        polygon([[0, 0],
                 for (a = [-abertura_grapa/2:abertura_grapa/10:abertura_grapa/2]) [r*cos(a)/cos(abertura_grapa/20), r*sin(a)/cos(abertura_grapa/20)]]);
}
