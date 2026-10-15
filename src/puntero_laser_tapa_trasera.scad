// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Tapa trasera del láser
// Descripción: Reemplaza la tapa original del láser 303 (la de la llave). Es una funda sin rosca
//              que calza sobre la rosca del tubo y se fija con 2 prisioneros M3 × 12 de punta
//              cónica: el que está a angulo_cable + 45° muerde el tubo y es el contacto negativo
//              (lleva el ojal del hilo negro y una contratuerca). Debajo del escalón donde apoya el
//              borde del tubo va el lastre de tuercas M10, sobre el que apoya la pila falsa. El hilo
//              positivo pasa bajo el borde del tubo por una ranura del escalón y sale por una
//              ventana a angulo_cable; el alivio de tensión lo da la grapa del cable, sobre el mismo
//              tubo. Se imprime de pie, con el piso trasero sobre la cama.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
include <puntero_laser_parametros.scad>

/* [Hidden] */
z_escalon = largo_tapa_fuera;
z_prisioneros = z_prisioneros_tapa;
angulo_prisionero_neg = angulo_cable + desfase_prisionero_tapa;
r_inicio_ranura = tuercas_lastre_tapa > 0 ? ec_lastre/2 - 0.3 : d_pila_falsa/2 - 1.5;
chaflan_tapa = 0.5;

// --- MÓDULOS PRINCIPALES Y ENSAMBLAJE ---
ensamblaje_principal();

module ensamblaje_principal() {
    pieza_tapa_trasera();
}

module pieza_tapa_trasera() {
    difference() {
        union() {
            cuerpo_tapa();
            for (a = [angulo_prisionero_neg, angulo_prisionero_neg + 180]) resalte_prisionero(a);
        }
        interior_funda();
        if (tuercas_lastre_tapa > 0) alojamiento_lastre();
        for (a = [angulo_prisionero_neg, angulo_prisionero_neg + 180]) agujero_prisionero(a);
        ranura_escalon();
        ventana_cable();
    }
}

// Cilindro con chaflán en el borde que apoya en la cama (perfil 2D girado)
module cuerpo_tapa() {
    rotate_extrude($fn = 96)
        polygon([[0, 0], [r_funda_ext - chaflan_tapa, 0], [r_funda_ext, chaflan_tapa],
                 [r_funda_ext, largo_tapa_trasera], [0, largo_tapa_trasera]]);
}

// Resalte radial de un prisionero, con chaflán de 45° por debajo (sin soportes)
module resalte_prisionero(a) {
    alto = ancho_resalte_prisionero;
    r0 = r_funda_ext - 1;
    r1 = r_funda_ext + espesor_resalte_prisionero;
    rotate([0, 0, a]) rotate([90, 0, 0])
        linear_extrude(height = ancho_resalte_prisionero, center = true)
            polygon([[r0, z_prisioneros - alto/2 - (r1 - r0)], [r1, z_prisioneros - alto/2],
                     [r1, z_prisioneros + alto/2], [r0, z_prisioneros + alto/2]]);
}

// --- Elementos que restan material ---
// Funda que calza sobre la rosca del tubo, con entrada achaflanada
module interior_funda() {
    translate([0, 0, z_escalon]) cylinder(r = r_funda_int, h = largo_zona_tapa + eps, $fn = 96);
    translate([0, 0, largo_tapa_trasera - chaflan_tapa])
        cylinder(r1 = r_funda_int, r2 = r_funda_int + chaflan_tapa + eps, h = chaflan_tapa + eps, $fn = 96);
}

// Hexágono de las tuercas M10, con una cara plana hacia angulo_cable (150°) para la ranura del hilo
module alojamiento_lastre() {
    translate([0, 0, piso_tapa_trasera])
        cylinder(r = r_esquina_lastre, h = z_escalon - piso_tapa_trasera + eps, $fn = 6);
}

module agujero_prisionero(a) {
    r1 = r_funda_ext + espesor_resalte_prisionero;
    rotate([0, 0, a]) translate([(r_funda_int - 1 + r1 + 1)/2, 0, z_prisioneros])
        agujero_gota(diametro_autorroscante_m3, r1 - r_funda_int + 2 + 2*eps);
}

// Ranura del hilo positivo bajo el borde del tubo, desde el lastre hasta la funda
module ranura_escalon() {
    rotate([0, 0, angulo_cable])
        translate([r_inicio_ranura, -ancho_ranura_cable_tapa/2, z_escalon - prof_ranura_cable])
            cube([r_funda_int - r_inicio_ranura + 1, ancho_ranura_cable_tapa, prof_ranura_cable + eps]);
}

// Ventana de salida del hilo, con techo a dos aguas a 45°
module ventana_cable() {
    z0 = z_escalon - prof_ranura_cable;
    alto = prof_ranura_cable + alto_ventana_cable;
    rotate([0, 0, angulo_cable]) translate([r_funda_int - 1, 0, 0]) rotate([90, 0, 90])
        linear_extrude(height = r_funda_ext - r_funda_int + 2)
            polygon([[-ancho_ventana_cable/2, z0], [ancho_ventana_cable/2, z0],
                     [ancho_ventana_cable/2, z0 + alto], [0, z0 + alto + ancho_ventana_cable/2],
                     [-ancho_ventana_cable/2, z0 + alto]]);
}

