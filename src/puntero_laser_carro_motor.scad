// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Carro del motor (×2)
// Descripción: Placa tensora que sujeta un 28BYJ-48 por sus orejas (M3 autorroscante) y se fija
//              con 2 M3 en ranuras de ±recorrido_tensor. La misma pieza sirve para los dos ejes:
//              en azimut se apoya sobre la plataforma con el motor encima; en altura se atornilla
//              a los pilares del brazo con el motor entre el carro y el brazo. El tornillo del tope
//              empuja la cara −X (la más cercana a la polea conducida).
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
include <puntero_laser_parametros.scad>

/* [Hidden] */
radio_esquina_carro = 3;

// --- MÓDULOS PRINCIPALES Y ENSAMBLAJE ---
ensamblaje_principal();

module ensamblaje_principal() {
    pieza_carro_motor();
}

// Sistema del carro: eje del motor en el origen, cuerpo del motor hacia +X, z = 0 cara de apoyo.
module pieza_carro_motor() {
    difference() {
        placa_carro();
        agujeros_orejas();
        ranuras_fijacion();
        // Paso del resalte y del eje del motor
        translate([0, 0, -1]) cylinder(d = motor_d_resalte + 2*holgura_encastre, h = espesor_carro + 2);
    }
}

module placa_carro() {
    placa_redondeada(carro_x_min, -carro_semiancho, carro_x_max, carro_semiancho,
                     radio_esquina_carro, espesor_carro);
}

// Orejas del 28BYJ-48: M3 autorroscante en el plástico (U-05)
module agujeros_orejas() {
    for (s = [-1, 1])
        translate([motor_desplazamiento_eje, s*motor_entre_orejas/2, -1])
            cylinder(d = diametro_autorroscante_m3, h = espesor_carro + 2, $fn = 24);
}

// Ranuras de fijación a lo largo de X: el carro se desliza ±recorrido_tensor (U-06)
module ranuras_fijacion() {
    for (s = [-1, 1])
        translate([ranura_carro_x, s*ranura_carro_y, -1])
            ranura(m3_d + holgura_tornillo_m3, 2*recorrido_tensor, espesor_carro + 2);
}
