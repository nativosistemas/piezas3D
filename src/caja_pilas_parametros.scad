// ==========================================
// Proyecto: piezas3D – Caja de pilas
// Componente: Parámetros compartidos
// Descripción: Medidas compartidas por la caja y la tapa a presión para pilas cilíndricas (por
//              defecto 4 AA): parámetros editables, derivados, reglas de validación V-01…V-09 y
//              perfiles 2D comunes. No dibuja nada; al renderizarlo solo imprime los derivados.
// ==========================================
//
// Convención de ejes del conjunto (data-model.md): origen en la esquina inferior de la caja,
// X a lo largo de la fila de pilas, Y a lo largo del eje de cada pila, Z hacia arriba.

// --- PARÁMETROS Y CONSTANTES ---

/* [Pilas] */
// Cantidad de pilas, acostadas en una fila
cantidad_pilas = 4; // [1:1:10]
// Diámetro máximo de la pila (AA: 14,5 según IEC 60086)
diametro_pila = 14.5; // [8:0.1:20]
// Largo máximo de la pila (AA: 50,5 según IEC 60086)
largo_pila = 50.5; // [30:0.1:70]

/* [Caja] */
// Espesor de las paredes de la caja
espesor_pared = 2.0; // [1.6:0.1:4]
// Espesor del piso de la caja y de la placa de la tapa
espesor_piso = 2.0; // [1.2:0.1:4]
// Espesor de los tabiques entre alojamientos
espesor_tabique = 1.2; // [1.2:0.1:3]
// Alto de los tabiques sobre el piso (debe superar el juego vertical de la pila)
alto_tabique = 10; // [4:0.5:20]
// Radio de las esquinas verticales exteriores
radio_esquina = 3; // [1:0.5:6]

/* [Encastre] */
// Alto de la pollera de la tapa que entra en la caja
alto_pollera = 8; // [5:0.5:12]
// Espesor de la pollera y de las pestañas
espesor_pollera = 1.2; // [1.2:0.1:2]
// Ancho de cada pestaña flexible
ancho_pestana = 20; // [10:1:40]
// Cuánto sobresale el reborde de la pestaña (PLA: 0,35)
saliente_reborde = 0.5; // [0.3:0.05:0.8]
// Ancho de la muesca de apertura
ancho_muesca = 16; // [10:1:25]
// Profundidad de la muesca de apertura desde el borde
profundidad_muesca = 2.5; // [1.5:0.5:5]

/* [Calidad] */
// Resolución de los círculos (≥ 64 en el STL final)
$fn = 64; // [32:8:128]

/* [Hidden] */
eps = 0.01;                     // Solape para que los cortes no dejen caras coplanarias
chaflan_cama = 0.6;             // Chaflán de los bordes sobre la cama (pata de elefante)
plano_reborde = 0.4;            // Cara plana del trapecio del reborde
ranura_pestana = 1.0;           // Ancho de las ranuras que separan cada pestaña de la pollera
rebaje_ranura_pestana = 0.2;    // Las ranuras bajan un poco en la placa: la pestaña flexiona desde la raíz
distancia_reborde_punta = 1.0;  // Del centro del reborde a la punta de la pollera
radio_fondo_muesca = 1.5;       // Redondeo del fondo de la muesca
deformacion_admisible = 0.015;  // PETG impreso, uso repetido (research.md R4)
modulo_material = 2000;         // [MPa] PETG impreso, solo para el echo de la fuerza

// --- PERFIL DE IMPRESORA (holguras y límites) ---
include <perfil_impresora.scad>

// --- DIMENSIONES DERIVADAS (Entidad 2 de data-model.md) ---
holgura_alojamiento = holgura("suelto");
ancho_alojamiento = diametro_pila + holgura_alojamiento;
largo_alojamiento = largo_pila + holgura_alojamiento;
paso_alojamiento = ancho_alojamiento + espesor_tabique;
interior_x = cantidad_pilas*ancho_alojamiento + (cantidad_pilas - 1)*espesor_tabique;
interior_y = largo_alojamiento;
exterior_x = interior_x + 2*espesor_pared;
exterior_y = interior_y + 2*espesor_pared;
radio_interior = max(radio_esquina - espesor_pared, 0);
alto_zona_pilas = ancho_alojamiento;
alto_caja = espesor_piso + alto_zona_pilas + alto_pollera;
alto_tapa = espesor_piso + alto_pollera;
alto_cerrada = alto_caja + espesor_piso;

holgura_pollera = holgura("justo")/2;                 // por lado
flecha_pestana = saliente_reborde - holgura_pollera;  // lo que flexiona la pestaña al cerrar
largo_pestana = alto_pollera - distancia_reborde_punta;
deformacion_pestana = 1.5*espesor_pollera*flecha_pestana/pow(largo_pestana, 2);
fuerza_pestana = 3*modulo_material*(ancho_pestana*pow(espesor_pollera, 3)/12)*flecha_pestana/pow(largo_pestana, 3);
juego_vertical_pila = holgura_alojamiento + alto_pollera;

profundidad_ranura = saliente_reborde;
alto_base_reborde = plano_reborde + 2*saliente_reborde;   // flancos a 45°
plano_ranura = plano_reborde + holgura("justo");
largo_ranura = ancho_pestana + 2*ranura_pestana;
z_reborde = alto_pollera - distancia_reborde_punta;       // centro del reborde, desde el borde de la caja
centro_x = exterior_x/2;                                  // pestañas, ranuras centradas en las paredes largas
centro_y = exterior_y/2;                                  // muesca centrada en la pared corta

// --- VALIDACIONES (Entidad 3 de data-model.md) ---
// V-02
assert(espesor_piso >= espesor_min_piso,
    str("espesor_piso=", espesor_piso, ": menor que el mínimo FDM (", espesor_min_piso, " mm)"));
assert(espesor_tabique >= espesor_min_pared && espesor_pollera >= espesor_min_pared,
    str("espesor_tabique/espesor_pollera: menor que el mínimo FDM (", espesor_min_pared, " mm)"));
// V-01
assert(espesor_pared - profundidad_ranura >= espesor_min_pared,
    str("espesor_pared=", espesor_pared, ": la ranura del encastre deja ", espesor_pared - profundidad_ranura,
        " mm de pared (mínimo ", espesor_min_pared, " mm)"));
// V-03
assert((exterior_x <= cama_util()[0] && exterior_y <= cama_util()[1])
       || (exterior_x <= cama_util()[1] && exterior_y <= cama_util()[0]),
    str("cantidad_pilas=", cantidad_pilas, ": la caja (", exterior_x, " × ", exterior_y,
        " mm) no entra en la cama útil (", cama_util()[0], " × ", cama_util()[1], " mm)"));
assert(alto_caja <= cama[2], str("alto_pollera: la caja (", alto_caja, " mm) supera el alto de impresión"));
// V-04
assert(flecha_pestana > 0,
    str("saliente_reborde=", saliente_reborde, ": no supera la holgura de la pollera (", holgura_pollera,
        " mm); la tapa no engancharía"));
// V-05
assert(deformacion_pestana <= deformacion_admisible,
    str("saliente_reborde=", saliente_reborde, ": la pestaña se deformaría ", round(deformacion_pestana*1000)/10,
        " % al cerrar (máximo ", deformacion_admisible*100, " %); bajar saliente_reborde o espesor_pollera, o subir alto_pollera"));
// V-06
assert(alto_tabique > juego_vertical_pila,
    str("alto_tabique=", alto_tabique, ": la pila puede subir ", juego_vertical_pila,
        " mm con la tapa puesta y saltar el tabique"));
assert(alto_tabique < alto_zona_pilas,
    str("alto_tabique=", alto_tabique, ": supera el alto de la zona de pilas (", alto_zona_pilas,
        " mm) y choca con la pollera"));
// V-07
assert(largo_ranura <= interior_x - 2*radio_interior - 2*espesor_pollera,
    str("ancho_pestana=", ancho_pestana, ": la pestaña y sus ranuras no entran en la pared larga (",
        interior_x - 2*radio_interior - 2*espesor_pollera, " mm libres)"));
// V-08
assert(ancho_muesca <= interior_y - 2*radio_interior - 2,
    str("ancho_muesca=", ancho_muesca, ": no entra en la pared corta"));
assert(profundidad_muesca < z_reborde,
    str("profundidad_muesca=", profundidad_muesca, ": baja hasta la zona del encastre (", z_reborde, " mm)"));
// V-09
assert(saliente_reborde + plano_reborde/2 < distancia_reborde_punta,
    str("saliente_reborde=", saliente_reborde, ": el reborde no entra entre su centro y la punta de la pollera"));

// --- SALIDA DE DERIVADOS (echo) ---
echo(str("MEDIDAS exterior=", exterior_x, " x ", exterior_y, ", alto_caja=", alto_caja, ", alto_tapa=", alto_tapa,
         ", cerrada=", alto_cerrada));
echo(str("ENCASTRE flecha=", flecha_pestana, ", deformacion_pestana=", deformacion_pestana,
         ", fuerza_por_pestana_N=", fuerza_pestana));
echo(str("PILAS alojamiento=", ancho_alojamiento, " x ", largo_alojamiento, ", juego_vertical_pila=", juego_vertical_pila,
         ", alto_tabique=", alto_tabique));

// --- PERFILES 2D COMUNES ---
// Rectángulo de esquinas redondeadas con la esquina inferior izquierda en el origen
module contorno_redondeado(dx, dy, r) {
    if (r > 0) translate([r, r]) offset(r = r) square([dx - 2*r, dy - 2*r]);
    else square([dx, dy]);
}

// Contorno exterior de la caja y de la tapa
module contorno_exterior() {
    contorno_redondeado(exterior_x, exterior_y, radio_esquina);
}

// Boca de la caja (contorno interior de las paredes)
module contorno_interior() {
    translate([espesor_pared, espesor_pared]) contorno_redondeado(interior_x, interior_y, radio_interior);
}

// Trapecio del reborde y de la ranura en el plano (u, v): u hacia afuera de la pollera (hacia la pared),
// v vertical centrada en el reborde. Sobresale "eps" hacia u < 0 para solapar con la pieza o con el aire.
module trapecio_encastre(saliente, plano) {
    base = plano + 2*saliente;
    polygon([[-eps, -base/2], [0, -base/2], [saliente, -plano/2], [saliente, plano/2],
             [0, base/2], [-eps, base/2]]);
}

// Prisma con el contorno exterior y el chaflán de la cara apoyada en la cama
module prisma_achaflanado(alto) {
    hull() {
        linear_extrude(height = eps) offset(delta = -chaflan_cama) contorno_exterior();
        translate([0, 0, chaflan_cama]) linear_extrude(height = alto - chaflan_cama) contorno_exterior();
    }
}
