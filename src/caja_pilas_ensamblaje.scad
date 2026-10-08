// ==========================================
// Proyecto: piezas3D – Caja de pilas
// Componente: Ensamblaje (solo revisión, NO se exporta)
// Descripción: Coloca la caja, las pilas y la tapa en su posición del conjunto, comprueba con
//              asserts el encastre y los choques (U-01). Las vistas explotadas y los datos del visor
//              3D salen de la tabla de pasos con la biblioteca común armado_comun.scad.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
include <caja_pilas_parametros.scad>
use <caja_pilas_caja.scad>
use <caja_pilas_tapa.scad>
include <armado_comun.scad>

// Dibujar la tapa (transparente) en el conjunto completo
ver_tapa = true;
// Paso de armado de la guía (0 = conjunto completo; -1 = datos de los pasos con echo)
paso_armado = 0; // [-1:1:3]
// Dibujar solo este elemento, en su posición final y sin color (para exportar mallas al visor 3D)
solo_elemento = "";

/* [Hidden] */
// Vista explotada: transparencia del contexto, distancia de entrada, color y grosor de las flechas
alfa_contexto = 0.25;
distancia_explosion = 40;
color_flecha = "OrangeRed";
diametro_flecha = 1.6;

// Pasos de armado de la guía (docs/caja_pilas_guia.md, sección 2): por cada paso, la lista de
// [elemento, desplazamiento de la vista explotada, resaltar] (formato en armado_comun.scad). Lo
// armado antes se dibuja transparente.
pasos = [
    /* 1 */ [["caja", [0, 0, 0], false], ["pilas", [0, 0, distancia_explosion], true]],
    /* 2 */ [["tapa", [0, 0, distancia_explosion], true]],
    /* 3 */ []
];

// --- DIMENSIONES DERIVADAS DEL CONJUNTO ---
z_tapa_sup = alto_caja + espesor_piso;    // la placa apoya sobre el borde; la pollera queda dentro
z_punta_pollera = alto_caja - alto_pollera;
z_centro_ranura = alto_caja - z_reborde;               // en la caja
z_centro_reborde = z_tapa_sup - (espesor_piso + z_reborde);   // en la tapa ya girada
y_cara_pollera = espesor_pared + holgura_pollera;

// --- COMPROBACIONES DEL CONJUNTO (U-01) ---
assert(abs(z_tapa_sup - alto_cerrada) < eps, "alto_tapa: la tapa no apoya sobre el borde de la caja");
assert(holgura_pollera > 0 && y_cara_pollera > espesor_pared,
    "holgura_pollera: la pollera toca la pared interior de la caja");
assert(abs(z_centro_reborde - z_centro_ranura) < eps,
    str("z_reborde: el reborde (", z_centro_reborde, ") no cae en la ranura (", z_centro_ranura, ")"));
assert(saliente_reborde - holgura_pollera <= profundidad_ranura,
    "profundidad_ranura: el reborde no entra entero en la ranura y la pestaña queda forzada");
assert(plano_ranura > plano_reborde, "plano_ranura: la ranura es más baja que el reborde");
assert(z_punta_pollera > espesor_piso + alto_tabique,
    "alto_tabique: la punta de la pollera choca con los tabiques");
assert(z_punta_pollera > espesor_piso + diametro_pila,
    "alto_pollera: la punta de la pollera toca las pilas");
assert(ancho_pestana <= largo_ranura, "largo_ranura: el reborde es más largo que la ranura");
// Tabla de pasos: un paso por cada instrucción de la guía (los elementos los comprueba armado())
assert(len(pasos) == 3, "pasos: la guía tiene 3 pasos de armado");

echo(str("CONJUNTO cerrada=", alto_cerrada, ", reborde_z=", z_centro_reborde, ", ranura_z=", z_centro_ranura));

// --- ENSAMBLAJE ---
armado();

module ensamblaje_principal() {
    for (e = elementos) if (e != "tapa") color(color_elemento(e)) elemento(e);
    if (ver_tapa) %elemento("tapa");
}

// --- CATÁLOGO DE ELEMENTOS (posición final en el conjunto) ---
elementos = ["caja", "pilas", "tapa"];

// Sin subconjuntos: todo se arma sobre la caja
function grupo(e, n) = "conjunto";

function color_elemento(e) = e == "caja" ? "SteelBlue" : e == "tapa" ? "LightSkyBlue" : "DimGray";

module elemento(e) {
    if (e == "caja") pieza_caja();
    // La tapa se imprime boca abajo: se gira 180° alrededor de X y se apoya sobre el borde
    if (e == "tapa") translate([0, exterior_y, z_tapa_sup]) rotate([180, 0, 0]) pieza_tapa();
    if (e == "pilas") for (i = [0:1:cantidad_pilas - 1])
        translate([espesor_pared + i*paso_alojamiento + ancho_alojamiento/2, espesor_pared + holgura_alojamiento/2,
                   espesor_piso + ancho_alojamiento/2])   // centrada en su alojamiento, sin tocar el piso
            rotate([-90, 0, 0]) cylinder(d = diametro_pila, h = largo_pila);
}

// Puntos de cada elemento donde se dibuja la flecha (fuera de cualquier sólido): la parte de abajo
// de cada pila y la punta de la pollera, así la flecha va de la pieza desplazada a su lugar.
function anclas(e) =
    e == "pilas" ? [for (i = [0:1:cantidad_pilas - 1])
        [espesor_pared + i*paso_alojamiento + ancho_alojamiento/2, centro_y, espesor_piso]] :
    e == "tapa" ? [[centro_x, centro_y, z_punta_pollera]] :
    [[centro_x, centro_y, alto_caja]];
