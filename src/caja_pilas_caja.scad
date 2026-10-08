// ==========================================
// Proyecto: piezas3D – Caja de pilas
// Componente: Caja
// Descripción: Caja con un alojamiento por pila (acostadas en fila), tabiques entre alojamientos,
//              ranuras del encastre a 45° en el centro de las paredes largas y muesca de apertura
//              en una pared corta. Se imprime con la abertura hacia arriba, sin soportes.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
// Todas las medidas y validaciones están en el archivo compartido (las usa también la tapa).
include <caja_pilas_parametros.scad>

// --- ENSAMBLAJE ---
ensamblaje_principal();

module ensamblaje_principal() {
    pieza_caja();
}

// Orientación de impresión = posición en el conjunto: esquina exterior en el origen, base en Z = 0.
module pieza_caja() {
    difference() {
        union() {
            cuerpo_caja();
            tabiques();
        }
        // Los cortes van siempre al final
        ranuras_encastre();
        muesca_apertura();
    }
}

// --- MÓDULOS ---
// Cuerpo principal: piso y paredes con el chaflán de la base
module cuerpo_caja() {
    difference() {
        prisma_achaflanado(alto_caja);
        translate([0, 0, espesor_piso]) linear_extrude(height = alto_caja - espesor_piso + eps) contorno_interior();
    }
}

// Suma: tabiques entre alojamientos, de pared larga a pared larga
module tabiques() {
    for (i = [1:1:cantidad_pilas - 1])
        translate([espesor_pared + i*paso_alojamiento - espesor_tabique, espesor_pared - eps, espesor_piso - eps])
            cube([espesor_tabique, interior_y + 2*eps, alto_tabique + eps]);
}

// Resta: ranura trapezoidal en la cara interior de cada pared larga, donde engancha el reborde
module ranuras_encastre() {
    // [cara interior de la pared, sentido hacia afuera]
    for (pared = [[espesor_pared, -1], [espesor_pared + interior_y, 1]])
        translate([centro_x - largo_ranura/2, pared[0], alto_caja - z_reborde])
            scale([1, pared[1], 1]) rotate([90, 0, 90])
                linear_extrude(height = largo_ranura) trapecio_encastre(profundidad_ranura, plano_ranura);
}

// Resta: muesca con fondo redondeado en la pared corta X = 0, para meter la uña bajo la tapa
module muesca_apertura() {
    alto_corte = profundidad_muesca + 2*radio_fondo_muesca + 1;   // sobresale por encima del borde
    translate([-eps, 0, 0]) rotate([90, 0, 90]) linear_extrude(height = espesor_pared + 2*eps)
        translate([centro_y - ancho_muesca/2, alto_caja - profundidad_muesca])
            offset(r = radio_fondo_muesca) offset(delta = -radio_fondo_muesca) square([ancho_muesca, alto_corte]);
}
