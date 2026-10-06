// ==========================================
// Proyecto: [Nombre del Proyecto]
// Componente: [Nombre del Componente]
// Descripción: [Breve Descripción]
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
// El comentario [mín:paso:máx] habilita el personalizador de OpenSCAD y el chequeo de rangos.
largo = 60;                 // [mm] [30:1:150]
ancho = 40;                 // [mm] [20:1:100]
espesor_pared = 3.0;        // [mm] [1.2:0.1:6]
diametro_tornillo = 4;      // [mm] [3:0.5:8]
margen_borde = 8;           // [mm] [5:0.5:20] distancia del agujero al borde
$fn = 64;                   // Resolución de curvas (≥ 64 en el .stl final)
eps = 0.01;                 // Solape para que los cortes no dejen caras coplanarias

// --- PERFIL DE IMPRESORA (holguras y límites) ---
// Da holgura("presion" | "justo" | "deslizante" | "suelto"), espesor_min_pared, cama, etc.
// No volver a declarar esos nombres en este archivo.
include <perfil_impresora.scad>

// --- DIMENSIONES DERIVADAS ---
diametro_orificio = diametro_tornillo + holgura("justo");
x_orificio = largo - margen_borde;              // posición relativa al borde, no absoluta

// --- VALIDACIONES ---
assert(espesor_pared >= espesor_min_pared,
       str("espesor_pared=", espesor_pared, ": menor que el mínimo FDM (", espesor_min_pared, " mm)"));
assert(margen_borde > diametro_orificio / 2 + espesor_pared,
       str("margen_borde=", margen_borde, ": el agujero queda demasiado cerca del borde"));
assert(largo <= cama_util()[0] && ancho <= cama_util()[1], "la pieza no entra en la cama");

// --- ENSAMBLAJE ---
ensamblaje_principal();

module ensamblaje_principal() {
    difference() {
        union() {
            cuerpo();
            elementos_suma();
        }
        elementos_resta();   // los cortes van siempre al final
    }
}

// --- MÓDULOS ---
module cuerpo() {
    // Preferir perfil 2D extruido: polygon()/offset() + linear_extrude()
    linear_extrude(height = espesor_pared)
        offset(r = 2) offset(delta = -2) square([largo, ancho]);
}

module elementos_suma() {
    // Refuerzos, cartelas, salientes
}

module elementos_resta() {
    // Agujeros, ranuras, vaciados. Sobresalir con eps por ambos lados.
    translate([x_orificio, ancho / 2, -eps])
        cylinder(h = espesor_pared + 2 * eps, d = diametro_orificio);
}
