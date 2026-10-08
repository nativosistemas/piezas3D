// ==========================================
// Proyecto: piezas3D – Caja de pilas
// Componente: Tapa
// Descripción: Placa con una pollera interior que entra en la boca de la caja. En el centro de cada
//              lado largo, la pollera tiene una pestaña flexible, separada por dos ranuras, con un
//              reborde trapezoidal a 45° que engancha en la ranura de la caja. Se imprime con la cara
//              exterior sobre la cama y la pollera hacia arriba, sin soportes.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
// Todas las medidas y validaciones están en el archivo compartido (las usa también la caja).
include <caja_pilas_parametros.scad>

// --- ENSAMBLAJE ---
ensamblaje_principal();

module ensamblaje_principal() {
    pieza_tapa();
}

// Orientación de impresión: cara exterior en Z = 0. La tapa es simétrica en X e Y, así que su
// contorno coincide con el de la caja y encastra en las dos orientaciones.
module pieza_tapa() {
    difference() {
        union() {
            placa_tapa();
            pollera();
            rebordes();
        }
        // Los cortes van siempre al final
        ranuras_pestanas();
    }
}

// --- MÓDULOS ---
// Cuerpo principal: placa con el chaflán de la cara exterior
module placa_tapa() {
    prisma_achaflanado(espesor_piso);
}

// Suma: pollera que entra en la boca de la caja con holgura_pollera por lado
module pollera() {
    translate([0, 0, espesor_piso - eps]) linear_extrude(height = alto_pollera + eps)
        difference() {
            offset(delta = -holgura_pollera) contorno_interior();
            offset(delta = -(holgura_pollera + espesor_pollera)) contorno_interior();
        }
}

// Suma: reborde en la cara exterior de cada pestaña, cerca de la punta de la pollera
module rebordes() {
    // [cara exterior de la pollera, sentido hacia la pared de la caja]
    for (cara = [[espesor_pared + holgura_pollera, -1], [espesor_pared + interior_y - holgura_pollera, 1]])
        translate([centro_x - ancho_pestana/2, cara[0], espesor_piso + z_reborde])
            scale([1, cara[1], 1]) rotate([90, 0, 90])
                linear_extrude(height = ancho_pestana) trapecio_encastre(saliente_reborde, plano_reborde);
}

// Resta: dos ranuras a cada lado de cada pestaña, de la punta hasta un poco dentro de la placa
module ranuras_pestanas() {
    for (y_cara = [espesor_pared + holgura_pollera, espesor_pared + interior_y - holgura_pollera - espesor_pollera],
         lado = [-1, 1])
        translate([centro_x + lado*(ancho_pestana + ranura_pestana)/2 - ranura_pestana/2, y_cara - eps,
                   espesor_piso - rebaje_ranura_pestana])
            cube([ranura_pestana, espesor_pollera + 2*eps, alto_pollera + rebaje_ranura_pestana + eps]);
}
