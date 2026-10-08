// ==========================================
// Proyecto: piezas3D – Caja de pilas
// Componente: Ensamblaje (solo revisión, NO se exporta)
// Descripción: Coloca la caja, las pilas y la tapa en su posición del conjunto, comprueba con
//              asserts el encastre y los choques (U-01) y, con paso_armado > 0, dibuja la vista
//              explotada de ese paso de la guía.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
include <caja_pilas_parametros.scad>
use <caja_pilas_caja.scad>
use <caja_pilas_tapa.scad>

// Dibujar la tapa (transparente) en el conjunto completo
ver_tapa = true;
// Paso de armado de la guía (0 = conjunto completo; -1 = listar los pasos con echo)
paso_armado = 0; // [-1:1:3]

/* [Hidden] */
// Vista explotada: transparencia del contexto, distancia de entrada y color de las flechas
alfa_contexto = 0.25;
distancia_explosion = 40;
color_flecha = "OrangeRed";

// Pasos de armado de la guía (docs/caja_pilas_guia.md, sección 2): por cada paso, la lista de
// [elemento, desplazamiento de la vista explotada, resaltar]. Lo armado antes se dibuja transparente.
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
// Tabla de pasos: un paso por cada instrucción de la guía y solo elementos conocidos
assert(len(pasos) == 3, "pasos: la guía tiene 3 pasos de armado");
for (p = pasos, e = p)
    assert(contiene(elementos, e[0]), str("pasos: elemento desconocido '", e[0], "'"));

echo(str("CONJUNTO cerrada=", alto_cerrada, ", reborde_z=", z_centro_reborde, ", ranura_z=", z_centro_ranura));

// --- ENSAMBLAJE ---
if (paso_armado == -1)
    for (n = [1:len(pasos)]) echo(str("PASO;", n, ";", len(pasos[n - 1])));
else if (paso_armado == 0)
    ensamblaje_principal();
else
    vista_paso(paso_armado);

module ensamblaje_principal() {
    for (e = elementos) if (e != "tapa") color(color_elemento(e)) elemento(e);
    if (ver_tapa) %elemento("tapa");
}

// Vista explotada del paso n: lo armado antes, transparente; lo nuevo, desplazado y con una flecha
module vista_paso(n) {
    assert(n >= 1 && n <= len(pasos), str("paso_armado=", n, ": la guía tiene ", len(pasos), " pasos"));
    actual = pasos[n - 1];
    nombres_actual = [for (e = actual) e[0]];
    previos = unicos([for (k = [0:1:n - 2]) for (e = pasos[k]) e[0]]);
    for (e = previos) if (!contiene(nombres_actual, e)) color(color_elemento(e), alfa_contexto) elemento(e);
    for (e = actual) {
        if (e[2]) color(color_elemento(e[0])) translate(e[1]) elemento(e[0]);
        else color(color_elemento(e[0]), alfa_contexto) translate(e[1]) elemento(e[0]);
        if (e[2] && norm(e[1]) > 0)
            for (p = anclas(e[0])) color(color_flecha) flecha(p + 0.85*e[1], p + 0.2*e[1]);
    }
}

// --- CATÁLOGO DE ELEMENTOS (posición final en el conjunto) ---
elementos = ["caja", "pilas", "tapa"];

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

// --- UTILIDADES ---
function contiene(lista, x) = len([for (e = lista) if (e == x) 0]) > 0;
function unicos(lista) = [for (i = [0:1:len(lista) - 1]) if (!contiene([for (j = [0:1:i - 1]) lista[j]], lista[i])) lista[i]];

// Flecha de la vista explotada, de "desde" a "hasta"
module flecha(desde, hasta) {
    v = hasta - desde;
    largo = norm(v);
    punta = min(6, largo/2);
    if (largo > 1)
        translate(desde) rotate([0, acos(v[2]/largo), atan2(v[1], v[0])]) {
            cylinder(d = 1.6, h = largo - punta, $fn = 16);
            translate([0, 0, largo - punta]) cylinder(d1 = 4, d2 = 0, h = punta, $fn = 16);
        }
}
