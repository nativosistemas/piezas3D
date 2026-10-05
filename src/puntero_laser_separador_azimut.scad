// ==========================================
// Proyecto: piezas3D – Puntero láser estelar
// Componente: Separador de azimut y arandelas de contacto
// Descripción: Separador entre los aros interiores de los dos 608 de azimut (0,1 mm más corto que
//              el resalte de la base, para precargarlos) y 3 arandelas de contacto que apoyan solo
//              en el aro interior: entre la plataforma y el 608 superior, entre la autoblocante y
//              el 608 inferior, y en el eje de altura del lado del cable.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
include <puntero_laser_parametros.scad>

/* [Hidden] */
d_ext_separador = d_contacto_aro;
d_agujero_m8 = rod608_d_int + holgura_perno_m8;
separacion_piezas = 5;
cantidad_arandelas = 3;

// --- MÓDULOS PRINCIPALES Y ENSAMBLAJE ---
ensamblaje_principal();

module ensamblaje_principal() {
    pieza_separador_azimut();
}

module pieza_separador_azimut() {
    separador();
    for (i = [1:cantidad_arandelas])
        translate([i*(d_ext_separador + separacion_piezas), 0, 0]) arandela_contacto();
}

module separador() {
    difference() {
        cylinder(d = d_ext_separador, h = largo_separador_azimut);
        translate([0, 0, -1]) cylinder(d = d_agujero_m8, h = largo_separador_azimut + 2);
    }
}

module arandela_contacto() {
    difference() {
        cylinder(d = d_contacto_aro, h = alto_arandela_contacto);
        translate([0, 0, -1]) cylinder(d = d_agujero_m8, h = alto_arandela_contacto + 2);
    }
}
