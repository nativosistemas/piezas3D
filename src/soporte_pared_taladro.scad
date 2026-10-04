// ==========================================
// Proyecto: piezas3D
// Componente: Soporte de pared para taladro
// Descripción: soporte paramétrico de pared para colgar un taladro inalámbrico por el portabrocas
// ==========================================
//
// Ejes: X = ancho (paralelo a la pared), Y = profundidad (la pared está en Y = 0),
// Z = altura (la cara inferior de la bandeja está en Z = 0). La pieza se modela en la
// orientación de impresión: bandeja sobre la cama, placa trasera y cartelas en vertical.
// Especificación: specs/001-soporte-pared-taladro/

// --- PARÁMETROS Y CONSTANTES ---

/* [Dimensiones principales] */
// Ancho total de la pieza a lo largo de la pared (mm)
ancho = 80; // [50:1:150]
// Vuelo de la bandeja medido desde la pared (mm)
profundidad = 100; // [60:1:160]
// Diámetro nominal de los tornillos de fijación a pared (mm)
diametro_tornillo = 5; // [3:0.5:8]

/* [Taladro] */
// Ancho de la ranura por la que pasa el portabrocas (mm)
ancho_ranura = 46; // [30:1:60]
// Diámetro del cuerpo o caja de engranajes del taladro; solo se usa para validar holguras (mm)
diametro_cuerpo_taladro = 60; // [40:1:90]

/* [Estructura] */
// Espesor de la bandeja y de la placa trasera (mm)
espesor = 6; // [4:0.5:10]
// Altura total de la placa trasera (mm)
altura_placa = 70; // [50:1:120]
// Espesor de cada cartela lateral de refuerzo (mm)
espesor_cartela = 5; // [3:0.5:10]

/* [Detalles] */
// Holgura de paso añadida al diámetro del tornillo (mm)
holgura_tornillo = 0.4; // [0.2:0.05:1.0]
// Altura del labio de retención frontal; 0 lo desactiva (mm)
altura_labio = 3; // [0:0.5:4.5]
// Chaflán a 45° del borde superior de la ranura; 0 lo desactiva (mm)
chaflan_ranura = 1.5; // [0:0.5:3]
// Radio de las esquinas frontales y de la boca de la ranura; 0 las deja vivas (mm)
radio_esquinas = 4; // [0:0.5:10]
// Radio del filete interior entre placa y bandeja; 0 lo desactiva (mm)
radio_filete = 3; // [0:0.5:6]

/* [Calidad] */
// Resolución de las superficies curvas (segmentos por circunferencia)
$fn = 64; // [24:8:128]

/* [Hidden] */
// Constantes de diseño (data-model.md, Entidad 2)
longitud_labio = 6;                          // longitud en Y del labio de retención
holgura_cuerpo_min = longitud_labio + 2;     // holgura mínima cuerpo-placa y cuerpo-labio
margen_cuerpo_carril = 8;                    // apoyo mínimo del cuerpo sobre los carriles (total)
holgura_cuerpo_cartela = 2;                  // holgura mínima entre el cuerpo y las cartelas
altura_cartela_min_util = 10;                // altura útil mínima de cartela bajo los tornillos
espesor_min_pared = 1.2;                     // 3 líneas de extrusión de 0,4 mm (FR-012)
espesor_min_bajo_avellanado = 1.5;           // placa mínima bajo la cabeza del tornillo
rebaje_cabeza = 0.3;                         // la cabeza queda por debajo de la superficie
eps = 0.01;                                  // solape para evitar caras coplanarias

// Valores derivados
diametro_orificio = diametro_tornillo + holgura_tornillo;
diametro_cabeza = 2 * diametro_tornillo;
profundidad_avellanado = (diametro_cabeza - diametro_orificio) / 2 + rebaje_cabeza;
ancho_carril = (ancho - ancho_ranura) / 2;
radio_ranura = ancho_ranura / 2;
centro_ranura_y = espesor + (profundidad - espesor) / 2;
fondo_ranura_y = centro_ranura_y - radio_ranura;
tornillo_z = altura_placa - diametro_cabeza;
tornillo_x = [diametro_cabeza, ancho - diametro_cabeza];
altura_cartela = tornillo_z - diametro_cabeza;
fin_cartela_y = profundidad - longitud_labio - 2;
// Los dos redondeos de la punta de cada carril (exterior y boca) no pueden solaparse
radio_esquinas_util = min(radio_esquinas, ancho_carril / 2 - eps);

// Parámetros públicos: [nombre, valor, [mínimo, máximo], unidad] (regla V-01)
parametros_publicos = [
    ["ancho", ancho, [50, 150], " mm"],
    ["profundidad", profundidad, [60, 160], " mm"],
    ["diametro_tornillo", diametro_tornillo, [3, 8], " mm"],
    ["ancho_ranura", ancho_ranura, [30, 60], " mm"],
    ["diametro_cuerpo_taladro", diametro_cuerpo_taladro, [40, 90], " mm"],
    ["espesor", espesor, [4, 10], " mm"],
    ["altura_placa", altura_placa, [50, 120], " mm"],
    ["espesor_cartela", espesor_cartela, [3, 10], " mm"],
    ["holgura_tornillo", holgura_tornillo, [0.2, 1.0], " mm"],
    ["altura_labio", altura_labio, [0, 4.5], " mm"],
    ["chaflan_ranura", chaflan_ranura, [0, 3], " mm"],
    ["radio_esquinas", radio_esquinas, [0, 10], " mm"],
    ["radio_filete", radio_filete, [0, 6], " mm"],
    ["$fn", $fn, [24, 128], " segmentos"]
];

function en_rango(valor, rango) = is_num(valor) && valor >= rango[0] && valor <= rango[1];

// Suma de los elementos de un vector
function suma(v, i = 0) = i >= len(v) ? 0 : v[i] + suma(v, i + 1);

// Área con signo de un perfil 2D (positiva si los vértices van en sentido antihorario)
function area_perfil(p) =
    0.5 * suma([for (i = [0:len(p) - 1])
        p[i][0] * p[(i + 1) % len(p)][1] - p[(i + 1) % len(p)][0] * p[i][1]]);

// --- VALIDACIÓN DE PARÁMETROS ---
// Reglas V-01 a V-10 de data-model.md, en orden. Cada mensaje empieza por el parámetro
// principal implicado (contracts/interfaz_generador.md §2.2).

// V-01: cada parámetro es numérico y está dentro de su rango
for (p = parametros_publicos)
    assert(en_rango(p[1], p[2]),
        str(p[0], "=", p[1], ": fuera de rango [", p[2][0], ", ", p[2][1], "]", p[3]));

// V-02: material suficiente a cada lado de la ranura
assert(ancho_carril >= 2 * espesor,
    str("ancho_ranura=", ancho_ranura, ": deja carriles de ", ancho_carril,
        " mm; con espesor=", espesor, " se necesitan al menos ", 2 * espesor,
        " mm (reduzca ancho_ranura o aumente ancho)"));

// V-03: margen de la cabeza del tornillo a los bordes laterales
assert(ancho >= 4 * diametro_cabeza,
    str("diametro_tornillo=", diametro_tornillo, ": la cabeza de ", diametro_cabeza,
        " mm necesita ancho >= ", 4 * diametro_cabeza, " mm y ancho=", ancho,
        " (reduzca diametro_tornillo o aumente ancho)"));

// V-04: el avellanado no atraviesa la placa
assert(espesor - profundidad_avellanado >= espesor_min_bajo_avellanado,
    str("diametro_tornillo=", diametro_tornillo, ": el avellanado de ", profundidad_avellanado,
        " mm deja ", espesor - profundidad_avellanado, " mm de placa; se necesitan al menos ",
        espesor_min_bajo_avellanado, " mm (aumente espesor o reduzca diametro_tornillo)"));

// V-05: la placa deja cartela útil por debajo de los tornillos
assert(altura_cartela - espesor >= 2 * radio_filete + altura_cartela_min_util,
    str("altura_placa=", altura_placa, ": deja cartelas de ", altura_cartela - espesor,
        " mm bajo los tornillos; se necesitan al menos ", 2 * radio_filete + altura_cartela_min_util,
        " mm (aumente altura_placa o reduzca diametro_tornillo)"));

// V-06: holgura del cuerpo del taladro con la placa y con el labio
assert(profundidad >= espesor + diametro_cuerpo_taladro + 2 * holgura_cuerpo_min,
    str("profundidad=", profundidad, ": con diametro_cuerpo_taladro=", diametro_cuerpo_taladro,
        " se necesitan al menos ", espesor + diametro_cuerpo_taladro + 2 * holgura_cuerpo_min,
        " mm (aumente profundidad o reduzca diametro_cuerpo_taladro)"));

// V-07: el cuerpo apoya sobre los carriles y no cae por la ranura
assert(diametro_cuerpo_taladro >= ancho_ranura + margen_cuerpo_carril,
    str("diametro_cuerpo_taladro=", diametro_cuerpo_taladro, ": cabría por la ranura de ",
        ancho_ranura, " mm; debe ser al menos ", ancho_ranura + margen_cuerpo_carril,
        " mm (revise la medida o reduzca ancho_ranura)"));

// V-08: el cuerpo no choca con las cartelas
assert(diametro_cuerpo_taladro <= ancho - 2 * espesor_cartela - holgura_cuerpo_cartela,
    str("diametro_cuerpo_taladro=", diametro_cuerpo_taladro, ": choca con las cartelas; con ancho=",
        ancho, " y espesor_cartela=", espesor_cartela, " el máximo es ",
        ancho - 2 * espesor_cartela - holgura_cuerpo_cartela,
        " mm (aumente ancho o reduzca espesor_cartela)"));

// V-09 (defensiva): material entre el fondo de la ranura y la placa
assert(fondo_ranura_y - espesor >= espesor,
    str("profundidad=", profundidad, ": el fondo de la ranura queda a ", fondo_ranura_y - espesor,
        " mm de la placa; se necesitan al menos ", espesor, " mm (aumente profundidad)"));

// V-10 (defensiva): la cartela no invade el chaflán de la ranura
assert(espesor_cartela <= ancho_carril - chaflan_ranura,
    str("espesor_cartela=", espesor_cartela, ": invade el chaflán de la ranura; el máximo es ",
        ancho_carril - chaflan_ranura, " mm (reduzca espesor_cartela o chaflan_ranura)"));

// --- MÓDULOS PRINCIPALES Y ENSAMBLAJE ---
ensamblaje_principal();

// Pieza completa: cuerpos sólidos menos vaciados (FR-001)
module ensamblaje_principal() {
    difference() {
        union() {
            placa_trasera();
            bandeja();
            cartelas();
            filete_interior();
            labios_retencion();
        }
        vaciado_ranura();
        vaciado_tornillos();
    }
}

// Placa vertical que apoya en la pared (FR-001)
module placa_trasera() {
    cube([ancho, espesor, altura_placa]);
}

// Prisma recto de perfil convexo (Y, Z) extruido a lo largo de X entre x0 y x0 + longitud.
// Se genera como polyhedron (y no con linear_extrude) para que el CSG exportado se importe
// correctamente en FreeCAD 1.1 (research.md R10)
module prisma_yz(perfil, x0, longitud) {
    n = len(perfil);
    p = area_perfil(perfil) >= 0 ? perfil : [for (i = [n - 1:-1:0]) perfil[i]];
    polyhedron(
        points = concat([for (q = p) [x0, q[0], q[1]]],
                        [for (q = p) [x0 + longitud, q[0], q[1]]]),
        faces = concat([[for (i = [0:n - 1]) i]],
                       [[for (i = [n - 1:-1:0]) n + i]],
                       [for (i = [0:n - 1]) [i, n + i, n + (i + 1) % n, (i + 1) % n]]));
}

// Contorno en planta de la bandeja con las esquinas frontales redondeadas, como sólido
// entre z0 y z0 + altura (FR-003)
module cuerpo_contorno(z0, altura) {
    translate([0, 0, z0]) {
        if (radio_esquinas_util > 0) {
            cube([ancho, profundidad - radio_esquinas_util, altura]);
            translate([radio_esquinas_util, 0, 0])
                cube([ancho - 2 * radio_esquinas_util, profundidad, altura]);
            for (x = [radio_esquinas_util, ancho - radio_esquinas_util])
                translate([x, profundidad - radio_esquinas_util, 0])
                    cylinder(r = radio_esquinas_util, h = altura);
        } else {
            cube([ancho, profundidad, altura]);
        }
    }
}

// Volumen vertical con el contorno de la bandeja; recorta lo que no debe sobresalir de ella
module volumen_contorno() {
    cuerpo_contorno(-1, altura_placa + 2);
}

// Bandeja horizontal en voladizo (FR-001)
module bandeja() {
    cuerpo_contorno(0, espesor);
}

// Dos cartelas laterales en los bordes de la pieza (FR-001, R1). Perfil (Y, Z): triángulo
// apoyado en la bandeja y en la placa
module cartelas() {
    perfil_cartela = [
        [espesor - eps, espesor - eps],
        [fin_cartela_y, espesor - eps],
        [espesor - eps, altura_cartela]
    ];
    intersection() {
        union() {
            for (x = [0, ancho - espesor_cartela])
                prisma_yz(perfil_cartela, x, espesor_cartela);
        }
        volumen_contorno();
    }
}

// Filete cóncavo en la arista interior placa-bandeja (R1)
module filete_interior() {
    if (radio_filete > 0) {
        difference() {
            translate([0, espesor - eps, espesor - eps])
                cube([ancho, radio_filete + eps, radio_filete + eps]);
            translate([-1, espesor + radio_filete, espesor + radio_filete])
                rotate([0, 90, 0])
                    cylinder(r = radio_filete, h = ancho + 2);
        }
    }
}

// Labios de retención en el borde frontal de cada carril (R3). Perfil (Y, Z): cara frontal
// vertical y cara trasera a 45° hacia el taladro
module labios_retencion() {
    if (altura_labio > 0) {
        perfil_labio = [
            [profundidad - longitud_labio, espesor - eps],
            [profundidad, espesor - eps],
            [profundidad, espesor + altura_labio],
            [profundidad - longitud_labio + altura_labio, espesor + altura_labio]
        ];
        intersection() {
            union() {
                for (x = [0, ancho - ancho_carril])
                    prisma_yz(perfil_labio, x, ancho_carril);
            }
            volumen_contorno();
        }
    }
}

// Ranura en U pasante, con chaflán superior y boca redondeada (FR-002, FR-003)
module vaciado_ranura() {
    // U: fondo semicircular más tramo recto abierto al frente; atraviesa toda la altura
    translate([ancho / 2, centro_ranura_y, -1]) {
        cylinder(r = radio_ranura, h = altura_placa + 2);
        translate([-radio_ranura, 0, 0])
            cube([ancho_ranura, profundidad - centro_ranura_y + 1, altura_placa + 2]);
    }
    if (chaflan_ranura > 0) chaflan_ranura_superior();
    if (radio_esquinas_util > 0) {
        redondeo_boca_ranura(ancho / 2 - radio_ranura, -1);
        redondeo_boca_ranura(ancho / 2 + radio_ranura, 1);
    }
}

// Chaflán a 45° en el borde superior de la ranura (FR-003). Por encima de la bandeja el
// vaciado continúa en vertical con el ancho ampliado, para que los labios no queden en
// voladizo sobre el chaflán (FR-011)
module chaflan_ranura_superior() {
    radio_chaflan = radio_ranura + chaflan_ranura + eps;
    // Fondo semicircular: cono que se abre hacia arriba más cilindro vertical
    translate([ancho / 2, centro_ranura_y, espesor - chaflan_ranura]) {
        cylinder(h = chaflan_ranura + eps, r1 = radio_ranura, r2 = radio_chaflan);
        translate([0, 0, chaflan_ranura])
            cylinder(r = radio_chaflan, h = altura_placa + 1 - espesor);
    }
    // Tramo recto: prisma de perfil (X, Z) trapecio + rectángulo a lo largo de Y, desde el
    // centro de la ranura hasta pasado el frente. prisma_yz extruye en X; el giro de -90°
    // en Z lleva su eje Y local a X y su eje X local a -Y
    translate([ancho / 2, 0, 0])
        rotate([0, 0, -90])
            prisma_yz([
                [-radio_ranura, espesor - chaflan_ranura],
                [radio_ranura, espesor - chaflan_ranura],
                [radio_chaflan, espesor + eps],
                [radio_chaflan, altura_placa + 1],
                [-radio_chaflan, altura_placa + 1],
                [-radio_chaflan, espesor + eps]
            ], -(profundidad + 1), profundidad + 1 - centro_ranura_y);
}

// Redondeo vertical de una esquina de la boca de la ranura (FR-003)
// x_esquina: X del borde de la ranura; signo: -1 carril izquierdo, +1 carril derecho
module redondeo_boca_ranura(x_esquina, signo) {
    difference() {
        translate([signo < 0 ? x_esquina - radio_esquinas_util : x_esquina - eps,
                   profundidad - radio_esquinas_util, -1])
            cube([radio_esquinas_util + eps, radio_esquinas_util + 1, altura_placa + 2]);
        translate([x_esquina + signo * radio_esquinas_util, profundidad - radio_esquinas_util, -2])
            cylinder(r = radio_esquinas_util, h = altura_placa + 4);
    }
}

// Orificios pasantes con avellanado a 90° en la cara frontal de la placa (FR-004, FR-007, FR-009)
module vaciado_tornillos() {
    for (x = tornillo_x)
        translate([x, 0, tornillo_z])
            rotate([-90, 0, 0]) {    // eje del tornillo a lo largo de +Y
                translate([0, 0, -1])
                    cylinder(d = diametro_orificio, h = espesor + 2);
                translate([0, 0, espesor - profundidad_avellanado])
                    cylinder(h = profundidad_avellanado + 1,
                             d1 = diametro_orificio,
                             d2 = diametro_orificio + 2 * (profundidad_avellanado + 1));
            }
}
