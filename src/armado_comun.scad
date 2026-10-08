// ==========================================
// Proyecto: piezas3D – Biblioteca común
// Componente: Armado (vistas explotadas y datos del visor 3D)
// Descripción: Maquinaria común de los ensamblajes de diseños de varias piezas: la vista explotada de
//              cada paso de la guía, el contexto de cada paso según los subconjuntos, la salida de
//              datos para el visor 3D (scripts/generar_visor.py) y el despacho según paso_armado y
//              solo_elemento. El ensamblaje del diseño la incluye con include y define lo propio.
//              Contrato: specs/005-visor-armado-3d/contracts/ensamblaje.md.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---
// La biblioteca no tiene parámetros propios: no resta volúmenes (no usa eps) y no redeclara nada del
// diseño, porque con --hardwarnings una reasignación detiene la validación. El ensamblaje DEBE definir:
//   paso_armado, solo_elemento         modo (0 conjunto, n vista del paso n, -1 datos; o un elemento)
//   alfa_contexto, color_flecha        aspecto de lo ya armado y de las flechas
//   diametro_flecha                    grosor de las flechas (la punta sale de este valor)
//   pasos                              [elemento, desplazamiento, resaltar, origen?, giro?] por paso
//   elementos                          catálogo de elementos
//   color_elemento(e), elemento(e)     color y geometría de cada elemento en su posición final
//   anclas(e)                          puntos donde nacen las flechas (fuera de cualquier sólido)
//   grupo(e, n)                        subconjunto del elemento en el paso n ("conjunto" si no hay)
//   ensamblaje_principal()             conjunto completo
// Proporciones de la flecha respecto de su diámetro y resolución de sus cilindros:
//   punta de 2,5 diámetros de ancho y hasta 10/3 diámetros de largo; 16 lados.

// --- MÓDULOS PRINCIPALES ---
// Despacho del ensamblaje: un elemento suelto, los datos de los pasos, el conjunto o la vista de un paso
module armado() {
    comprobar_pasos();
    if (solo_elemento != "")
        elemento(solo_elemento);
    else if (paso_armado == -1)
        datos_armado();
    else if (paso_armado == 0)
        ensamblaje_principal();
    else
        vista_paso(paso_armado);
}

// Vista explotada del paso n: lo opaco y sus flechas primero (en la vista previa, una pieza
// transparente tapa lo que se dibuja después detrás de ella), después lo no resaltado y el contexto.
// El origen (cuarto campo) es el desplazamiento de la pieza que recibe al elemento: la flecha va de
// la pieza a ese punto. El giro (quinto campo) solo lo usa el visor 3D.
module vista_paso(n) {
    assert(n >= 1 && n <= len(pasos), str("paso_armado=", n, ": la guía tiene ", len(pasos), " pasos"));
    actual = pasos[n - 1];
    for (e = actual) if (e[2]) {
        color(color_elemento(e[0])) translate(e[1]) elemento(e[0]);
        origen = origen_entrada(e);
        if (norm(e[1] - origen) > 0)
            for (p = anclas(e[0])) color(color_flecha) flecha(p + origen + 0.85*(e[1] - origen),
                                                              p + origen + 0.2*(e[1] - origen));
    }
    for (e = actual) if (!e[2]) color(color_elemento(e[0]), alfa_contexto) translate(e[1]) elemento(e[0]);
    for (e = contexto_paso(n)) color(color_elemento(e), alfa_contexto) elemento(e);
}

// Datos para el visor 3D y para scripts/capturas_armado.sh (una línea de echo por dato)
module datos_armado() {
    for (n = [1:len(pasos)]) echo(str("PASO;", n, ";", len(pasos[n - 1])));
    echo(str("PASOS;", pasos));
    for (e = elementos) echo(str("COLOR;", e, ";", color_elemento(e)));
    for (n = [1:len(pasos)]) echo(str("CONTEXTO;", n, ";", contexto_paso(n)));
}

// Validación de la tabla de pasos
module comprobar_pasos() {
    for (n = [1:len(pasos)], e = pasos[n - 1]) {
        assert(is_list(e) && len(e) >= 3 && len(e) <= 5,
               str("pasos: la entrada ", e, " del paso ", n, " debe tener de 3 a 5 campos"));
        assert(contiene(elementos, e[0]), str("pasos: elemento desconocido '", e[0], "' en el paso ", n));
        assert(es_vector3(e[1]), str("pasos: el desplazamiento de '", e[0], "' (paso ", n, ") no es [x, y, z]"));
        assert(is_bool(e[2]), str("pasos: resaltar de '", e[0], "' (paso ", n, ") debe ser true o false"));
        assert(len(e) < 4 || is_undef(e[3]) || es_vector3(e[3]),
               str("pasos: el origen de '", e[0], "' (paso ", n, ") debe ser undef o [x, y, z]"));
        assert(len(e) < 5 || (is_list(e[4]) && len(e[4]) == 3 && es_vector3(e[4][0]) && es_vector3(e[4][1])
                              && norm(e[4][1]) > 0 && is_num(e[4][2])),
               str("pasos: el giro de '", e[0], "' (paso ", n, ") debe ser [punto, eje, grados]"));
    }
}

// --- FUNCIONES ---
// Elementos ya armados que se ven en el paso n: los de pasos anteriores que no están en el paso n y
// cuyo subconjunto coincide con el de algún elemento del paso n. En un paso sin elementos (cableado,
// puesta a punto), todo lo armado hasta ahí.
function contexto_paso(n) =
    let (actual = pasos[n - 1],
         nombres = [for (e = actual) e[0]],
         grupos = [for (e = actual) grupo(e[0], n)],
         previos = unicos([for (k = [0:1:n - 2]) for (e = pasos[k]) e[0]]))
    len(actual) == 0 ? previos
    : [for (e = previos) if (!contiene(nombres, e) && contiene(grupos, grupo(e, n))) e];

function origen_entrada(e) = len(e) > 3 && es_vector3(e[3]) ? e[3] : [0, 0, 0];
function es_vector3(v) = is_list(v) && len(v) == 3 && is_num(v[0]) && is_num(v[1]) && is_num(v[2]);
function contiene(lista, x) = len([for (e = lista) if (e == x) 0]) > 0;
function unicos(lista) = [for (i = [0:1:len(lista) - 1]) if (!contiene([for (j = [0:1:i - 1]) lista[j]], lista[i])) lista[i]];

// --- ELEMENTOS QUE SUMAN MATERIAL ---
// Flecha de la vista explotada, de "desde" a "hasta"
module flecha(desde, hasta) {
    v = hasta - desde;
    largo = norm(v);
    punta = min(10/3*diametro_flecha, largo/2);
    if (largo > 1)
        translate(desde) rotate([0, acos(v[2]/largo), atan2(v[1], v[0])]) {
            cylinder(d = diametro_flecha, h = largo - punta, $fn = 16);
            translate([0, 0, largo - punta]) cylinder(d1 = 2.5*diametro_flecha, d2 = 0, h = punta, $fn = 16);
        }
}
