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
// Y puede definir, para el modo Funcionamiento del visor (simulación de las partes móviles; contrato:
// specs/007-simulacion-funcionamiento/contracts/ensamblaje.md), estas listas opcionales:
//   articulaciones   [nombre, etiqueta, elementos, punto, eje, rango, reposo, padre, velocidad,
//                     variable, pasos_por_grado]
//   motores          [nombre, etiqueta, elementos, punto, eje, articulación, relación, montado_en]
//   emisores         [nombre, etiqueta, punto, dirección, color, articulación, largo]
//   objetivos        [nombre, [un valor por articulación]]
//   deformables      [elemento, articulación, ángulos]
//   transparentes_simulacion   elementos que la simulación dibuja transparentes
// Y, para identificar las piezas en el visor (contrato: specs/008-identificacion-componentes/
// contracts/ensamblaje.md), esta lista opcional, con una entrada por elemento del catálogo:
//   nombres_elementos  [elemento, nombre, tipo ("impresa" o "comprada")]
// Y, para el modo Cableado del visor (cada cable de pin a pin; contrato:
// specs/011-vista-cableado/contracts/ensamblaje.md), estas listas opcionales:
//   cables                 [id, desde, hasta, función, grupo, hilos, diámetro, recorrido, extremos,
//                           largo_comprado, elemento]  (el elemento dibuja el tramo que se mueve, si hay)
//   grupos_cableado        [grupo, título]: orden de la lista del visor
//   conectores_cableado    [tipo, [ancho, alto, largo], color]: forma de cada extremo
//   obstaculos_cableado    [nombre, mín, máx, componente]: cajas que ningún cable atraviesa
//   pasos_tapa_cableado    [nombre, mín, máx]: aberturas por donde un cable sí cruza una pared
//   transparentes_cableado, ocultos_cableado   elementos transparentes u ocultos en ese modo
//   reserva_cable          largo que queda sin tensar en cada cable comprado
//   radio_curva_cableado   radio con que el visor redondea las esquinas de los recorridos
//   largo_elementos_cableado  [elemento, largo]: largo del tramo de cable que dibuja un elemento
// Se leen con is_undef (consultar una variable que no existe no avisa con --hardwarnings).
// Proporciones de la flecha respecto de su diámetro y resolución de sus cilindros:
//   punta de 2,5 diámetros de ancho y hasta 10/3 diámetros de largo; 16 lados.

// --- MÓDULOS PRINCIPALES ---
// Despacho del ensamblaje: un elemento suelto, los datos de los pasos, el conjunto o la vista de un paso
module armado() {
    comprobar_pasos();
    comprobar_simulacion();
    comprobar_nombres();
    comprobar_cables();
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
    echo(str("ARTICULACIONES;", simulacion_articulaciones()));
    echo(str("MOTORES;", simulacion_motores()));
    echo(str("EMISORES;", simulacion_emisores()));
    echo(str("OBJETIVOS;", simulacion_objetivos()));
    echo(str("DEFORMABLES;", simulacion_deformables()));
    echo(str("TRANSPARENTES;", simulacion_transparentes()));
    // El nombre va al final: echo no escapa las comillas y así el lector toma todo hasta la última
    for (x = nombres_declarados()) echo(str("NOMBRE;", x[0], ";", x[2], ";", x[1]));
    // Cables: los textos de desde y hasta van al final, como el nombre (no pueden tener ';')
    for (c = cableado_cables())
        echo(str("CABLE;", c[0], ";", [c[3], c[4], c[5], c[6], c[7], c[8],
                                       largo_cable(c), c[10]],
                 ";", c[1], ";", c[2]));
    echo(str("GRUPOS_CABLEADO;", cableado_grupos()));
    echo(str("CONECTORES_CABLEADO;", cableado_conectores()));
    echo(str("TRANSPARENTES_CABLEADO;", cableado_transparentes()));
    echo(str("OCULTOS_CABLEADO;", cableado_ocultos()));
    echo(str("RADIO_CURVA_CABLEADO;", cableado_radio()));
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

// Validación de las partes móviles (modo Funcionamiento del visor)
module comprobar_simulacion() {
    art = simulacion_articulaciones();
    mot = simulacion_motores();
    nombres_art = [for (a = art) a[0]];
    moviles = concat([for (a = art) for (e = a[2]) e], [for (m = mot) for (e = m[2]) e]);
    for (a = art) {
        assert(is_list(a) && len(a) == 11, str("articulaciones: ", a, " debe tener 11 campos"));
        assert(len([for (b = art) if (b[0] == a[0]) 0]) == 1, str("articulaciones: '", a[0], "' está repetida"));
        for (e = a[2]) assert(contiene(elementos, e), str("articulaciones: '", a[0], "' nombra el elemento desconocido '", e, "'"));
        assert(es_vector3(a[3]), str("articulaciones: el punto de '", a[0], "' no es [x, y, z]"));
        assert(es_vector3(a[4]) && norm(a[4]) > 0, str("articulaciones: '", a[0], "' tiene el eje nulo"));
        assert(is_undef(a[5]) || (is_list(a[5]) && len(a[5]) == 2 && a[5][0] < a[5][1]),
               str("articulaciones: '", a[0], "' tiene el rango invertido o mal formado"));
        assert(is_num(a[6]) && en_rango(a[6], a[5]), str("articulaciones: el reposo de '", a[0], "' está fuera del rango"));
        assert(a[7] == "" || contiene(nombres_art, a[7]), str("articulaciones: el padre de '", a[0], "' no existe"));
        assert(a[7] != a[0] && profundidad_articulacion(art, a[0], len(art)) >= 0,
               str("articulaciones: la cadena de padres de '", a[0], "' es circular"));
        assert(is_num(a[8]) && a[8] > 0, str("articulaciones: la velocidad de '", a[0], "' debe ser mayor que 0"));
        assert(is_string(a[9]), str("articulaciones: la variable de '", a[0], "' debe ser un texto (\"\" si no tiene)"));
        assert(is_undef(a[10]) || (is_num(a[10]) && a[10] > 0),
               str("articulaciones: pasos_por_grado de '", a[0], "' debe ser undef o mayor que 0"));
    }
    for (e = unicos(moviles)) assert(len([for (x = moviles) if (x == e) 0]) == 1,
        str("articulaciones y motores: el elemento '", e, "' está en dos articulaciones o motores"));
    for (m = mot) {
        assert(is_list(m) && len(m) == 8, str("motores: ", m, " debe tener 8 campos"));
        assert(len([for (b = mot) if (b[0] == m[0]) 0]) == 1 && !contiene(nombres_art, m[0]),
               str("motores: el nombre '", m[0], "' está repetido"));
        for (e = m[2]) assert(contiene(elementos, e), str("motores: '", m[0], "' nombra el elemento desconocido '", e, "'"));
        assert(es_vector3(m[3]), str("motores: el punto de '", m[0], "' no es [x, y, z]"));
        assert(es_vector3(m[4]) && norm(m[4]) > 0, str("motores: '", m[0], "' tiene el eje nulo"));
        assert(contiene(nombres_art, m[5]), str("motores: '", m[0], "' impulsa la articulación desconocida '", m[5], "'"));
        assert(is_num(m[6]) && m[6] != 0, str("motores: la relación de '", m[0], "' no puede ser 0"));
        assert(m[7] == "" || contiene(nombres_art, m[7]), str("motores: '", m[0], "' está montado en una articulación desconocida"));
    }
    for (x = simulacion_emisores()) {
        assert(is_list(x) && len(x) == 7, str("emisores: ", x, " debe tener 7 campos"));
        assert(es_vector3(x[2]), str("emisores: el punto de '", x[0], "' no es [x, y, z]"));
        assert(es_vector3(x[3]) && norm(x[3]) > 0, str("emisores: '", x[0], "' tiene la dirección nula"));
        assert(is_string(x[4]), str("emisores: el color de '", x[0], "' debe ser un nombre de color"));
        assert(x[5] == "" || contiene(nombres_art, x[5]), str("emisores: '", x[0], "' va en una articulación desconocida"));
        assert(is_num(x[6]) && x[6] > 0, str("emisores: el largo de '", x[0], "' debe ser mayor que 0"));
    }
    for (o = simulacion_objetivos()) {
        assert(is_list(o) && len(o) == 2 && is_list(o[1]) && len(o[1]) == len(art),
               str("objetivos: '", o[0], "' debe tener un valor por articulación (", len(art), ")"));
        for (i = [0:1:len(art) - 1]) assert(is_num(o[1][i]) && en_rango(o[1][i], art[i][5]),
            str("objetivos: el valor de '", art[i][0], "' en '", o[0], "' está fuera del rango"));
    }
    for (d = simulacion_deformables()) {
        a = [for (b = art) if (b[0] == d[1]) b];
        assert(is_list(d) && len(d) == 3, str("deformables: ", d, " debe tener 3 campos"));
        assert(contiene(elementos, d[0]), str("deformables: elemento desconocido '", d[0], "'"));
        assert(!contiene(moviles, d[0]), str("deformables: '", d[0], "' también está en una articulación o un motor"));
        assert(len(a) == 1 && a[0][9] != "", str("deformables: la articulación de '", d[0], "' no existe o no tiene variable"));
        for (g = d[2]) assert(is_num(g) && en_rango(g, a[0][5]), str("deformables: el ángulo ", g, " de '", d[0], "' está fuera del rango"));
    }
    for (e = simulacion_transparentes()) assert(contiene(elementos, e),
        str("transparentes_simulacion: elemento desconocido '", e, "'"));
}

// Validación de los nombres de los elementos (visor 3D): si hay lista, cubre el catálogo exacto
module comprobar_nombres() {
    lista = nombres_declarados();
    for (x = lista) {
        assert(is_list(x) && len(x) == 3, str("nombres_elementos: ", x, " debe ser [elemento, nombre, tipo]"));
        assert(contiene(elementos, x[0]), str("nombres_elementos: elemento desconocido '", x[0], "'"));
        assert(len([for (y = lista) if (y[0] == x[0]) 0]) == 1, str("nombres_elementos: '", x[0], "' está repetido"));
        assert(is_string(x[1]) && len(x[1]) > 0, str("nombres_elementos: el nombre de '", x[0], "' está vacío"));
        assert(x[2] == "impresa" || x[2] == "comprada",
               str("nombres_elementos: el tipo de '", x[0], "' debe ser \"impresa\" o \"comprada\""));
    }
    if (len(lista) > 0)
        for (e = elementos) assert(contiene([for (x = lista) x[0]], e),
                                   str("nombres_elementos: falta el nombre de '", e, "'"));
}

// Validación de los cables (modo Cableado del visor). La forma se valida siempre; los choques y el largo,
// solo al validar el conjunto o los datos (no al exportar cada elemento, para no repetirlos)
module comprobar_cables() {
    lista = cableado_cables();
    grupos = [for (g = cableado_grupos()) g[0]];
    tipos = [for (t = cableado_conectores()) t[0]];
    for (t = cableado_conectores())
        assert(is_list(t) && len(t) == 3 && es_vector3(t[1]) && is_string(t[2]),
               str("conectores_cableado: ", t, " debe ser [tipo, [ancho, alto, largo], color]"));
    for (c = lista) {
        assert(is_list(c) && len(c) == 11, str("cables: ", c, " debe tener 11 campos"));
        assert(is_string(c[0]) && len([for (d = lista) if (d[0] == c[0]) 0]) == 1 && !contiene(elementos, c[0]),
               str("cables: '", c[0], "' está repetido o es el nombre de un elemento"));
        for (texto = [c[1], c[2]])
            assert(is_string(texto) && len(texto) > 0 && len(search(";", texto)) == 0,
                   str("cables: el desde/hasta de '", c[0], "' está vacío o tiene ';'"));
        assert(c[3] == "+5V" || c[3] == "GND" || c[3] == "señal",
               str("cables: la función de '", c[0], "' debe ser \"+5V\", \"GND\" o \"señal\""));
        assert(contiene(grupos, c[4]), str("cables: '", c[0], "' usa el grupo desconocido '", c[4], "'"));
        assert(is_list(c[5]), str("cables: los hilos de '", c[0], "' deben ser una lista de colores"));
        assert(is_num(c[6]) && c[6] > 0, str("cables: el diámetro de '", c[0], "' debe ser mayor que 0"));
        assert(is_list(c[8]) && len(c[8]) == 2, str("cables: los extremos de '", c[0], "' deben ser [desde, hasta]"));
        for (x = c[8]) assert(contiene(tipos, x), str("cables: '", c[0], "' usa el conector desconocido '", x, "'"));
        assert(is_undef(c[10]) || contiene(elementos, c[10]),
               str("cables: '", c[0], "' usa el elemento desconocido '", c[10], "'"));
        assert(is_undef(c[7]) ? !is_undef(c[10]) : is_list(c[7]) && len(c[7]) >= 2 && len([for (p = c[7]) if (!es_vector3(p)) 0]) == 0,
               str("cables: '", c[0], "' necesita un recorrido de 2 o más puntos, un elemento o los dos"));
        assert(is_undef(c[9]) || (is_num(c[9]) && c[9] > 0),
               str("cables: el largo comprado de '", c[0], "' debe ser undef o mayor que 0"));
    }
    if (solo_elemento == "" && len(cableado_obstaculos()) > 0)
        for (c = lista) if (!is_undef(c[7])) {
            choque = choques_cable(c);
            assert(is_undef(choque), is_undef(choque) ? ""
                   : str("cables: '", c[0], "' atraviesa ", choque[0], " cerca de ", redondear_punto(choque[1])));
            falta = falta_largo(c);
            assert(falta <= 0, str("cables: '", c[0], "' mide ", round(largo_polilinea(c[7])), " mm y el cable comprado ",
                                   c[9], " mm (faltan ", ceil(falta), " mm)"));
        }
}

// --- FUNCIONES ---
// Listas de la simulación del diseño, o vacías si no las define
function simulacion_articulaciones() = is_undef(articulaciones) ? [] : articulaciones;
function simulacion_motores() = is_undef(motores) ? [] : motores;
function simulacion_emisores() = is_undef(emisores) ? [] : emisores;
function simulacion_objetivos() = is_undef(objetivos) ? [] : objetivos;
function simulacion_deformables() = is_undef(deformables) ? [] : deformables;
function simulacion_transparentes() = is_undef(transparentes_simulacion) ? [] : transparentes_simulacion;
// Nombres y tipos de los elementos del diseño, o vacía si no los define
function nombres_declarados() = is_undef(nombres_elementos) ? [] : nombres_elementos;
// Listas del modo Cableado, o vacías si el diseño no las define
function cableado_cables() = is_undef(cables) ? [] : cables;
function cableado_grupos() = is_undef(grupos_cableado) ? [] : grupos_cableado;
function cableado_conectores() = is_undef(conectores_cableado) ? [] : conectores_cableado;
function cableado_obstaculos() = is_undef(obstaculos_cableado) ? [] : obstaculos_cableado;
function cableado_pasos() = is_undef(pasos_tapa_cableado) ? [] : pasos_tapa_cableado;
function cableado_transparentes() = is_undef(transparentes_cableado) ? [] : transparentes_cableado;
function cableado_ocultos() = is_undef(ocultos_cableado) ? [] : ocultos_cableado;
function cableado_reserva() = is_undef(reserva_cable) ? 0 : reserva_cable;
function cableado_radio() = is_undef(radio_curva_cableado) ? 0 : radio_curva_cableado;
function largo_elemento_cableado(e) =
    let (x = is_undef(largo_elementos_cableado) || is_undef(e) ? [] : [for (l = largo_elementos_cableado) if (l[0] == e) l[1]])
    len(x) > 0 ? x[0] : 0;
// Largo de un cable: su recorrido más el tramo que dibuja su elemento, si tiene
function largo_cable(c) = (is_undef(c[7]) ? 0 : largo_polilinea(c[7])) + largo_elemento_cableado(c[10]);
function medidas_conector(tipo) = [for (t = cableado_conectores()) if (t[0] == tipo) t[1]][0];
function color_conector(tipo) = [for (t = cableado_conectores()) if (t[0] == tipo) t[2]][0];

// Largo de una polilínea y largo acumulado hasta cada punto
function largo_polilinea(p) = len(p) < 2 ? 0 : norm(p[1] - p[0]) + largo_polilinea([for (i = [1:len(p) - 1]) p[i]]);
function largos_acumulados(p) = [for (i = [0:len(p) - 1]) largo_polilinea([for (j = [0:i]) p[j]])];
function redondear_punto(p) = [for (v = p) round(v*10)/10];
function empieza_con(texto, prefijo) = len(prefijo) > 0 && len(texto) >= len(prefijo)
    && [for (i = [0:len(prefijo) - 1]) texto[i]] == [for (i = [0:len(prefijo) - 1]) prefijo[i]];
// Punto dentro de la caja [mín, máx] agrandada en r (estricto: tocar no es chocar)
function en_caja(p, mn, mx, r) = p[0] > mn[0] - r && p[0] < mx[0] + r && p[1] > mn[1] - r && p[1] < mx[1] + r
    && p[2] > mn[2] - r && p[2] < mx[2] + r;
function cajas_solapan(a0, a1, b0, b1) = a0[0] < b1[0] && a1[0] > b0[0] && a0[1] < b1[1] && a1[1] > b0[1]
    && a0[2] < b1[2] && a1[2] > b0[2];
function en_paso_tapa(p) = len([for (x = cableado_pasos()) if (en_caja(p, x[1], x[2], 0)) 0]) > 0;
// Tramo de cada extremo que puede tocar su propio componente: el conector, la curva y un diámetro
function largo_exento(tipo, d) = medidas_conector(tipo)[2] + cableado_radio() + d;
// Primer choque de un cable con los obstáculos ([nombre, punto]) o undef. Cada tramo se muestrea cada
// diámetro/2 y solo contra los obstáculos cuya caja toca la del tramo; las muestras dentro de un paso de
// la tapa no chocan; las de cada extremo no chocan con el componente donde nace el cable.
function choques_cable(c) =
    let (pts = c[7], d = c[6], r = d/2, total = largo_polilinea(pts), acum = largos_acumulados(pts),
         exento0 = largo_exento(c[8][0], d), exento1 = largo_exento(c[8][1], d),
         choques = [for (i = [0:len(pts) - 2])
             let (a = pts[i], b = pts[i + 1], largo = norm(b - a), n = max(1, ceil(largo/r)),
                  lo = [for (k = [0:2]) min(a[k], b[k]) - r], hi = [for (k = [0:2]) max(a[k], b[k]) + r],
                  cerca = [for (o = cableado_obstaculos()) if (cajas_solapan(lo, hi, o[1], o[2])) o])
             if (len(cerca) > 0) for (k = [0:n])
                 let (p = a + (b - a)*k/n, s = acum[i] + largo*k/n)
                 if (!en_paso_tapa(p)) for (o = cerca)
                     if (en_caja(p, o[1], o[2], r)
                         && !(o[3] != "" && ((s <= exento0 && empieza_con(c[1], o[3]))
                                             || (s >= total - exento1 && empieza_con(c[2], o[3])))))
                         [o[0], p]])
    len(choques) == 0 ? undef : choques[0];
// Cuánto le falta al cable comprado para cubrir el recorrido y la reserva (≤ 0: alcanza)
function falta_largo(c) = is_undef(c[9]) || is_undef(c[7]) ? 0 : largo_polilinea(c[7]) + cableado_reserva() - c[9];
function en_rango(v, rango) = is_undef(rango) || (v >= rango[0] && v <= rango[1]);
// Cantidad de padres de una articulación hasta la raíz, o −1 si la cadena no termina (circular)
function profundidad_articulacion(art, nombre, restantes) =
    let (a = [for (b = art) if (b[0] == nombre) b])
    len(a) == 0 || a[0][7] == "" ? 0
    : restantes <= 0 ? -1
    : let (p = profundidad_articulacion(art, a[0][7], restantes - 1)) p < 0 ? -1 : p + 1;

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
// Cables con recorrido (solo para revisarlos en OpenSCAD; el visor los dibuja con los mismos datos): un
// tubo por hilo, los hilos uno al lado del otro, y un conector en cada extremo, alineado con su tramo
module cables_modelados() {
    for (c = cableado_cables()) if (!is_undef(c[7])) {
        pts = c[7];
        n = len(c[5]);
        for (h = [0:n - 1], i = [0:len(pts) - 2]) {
            v = pts[i + 1] - pts[i];
            lado = norm(cross(v, [0, 0, 1])) > 0 ? cross(v, [0, 0, 1])/norm(cross(v, [0, 0, 1])) : [1, 0, 0];
            desp = (h - (n - 1)/2)*c[6]*lado;
            color(c[5][h]) hull() for (p = [pts[i], pts[i + 1]]) translate(p + desp) sphere(d = c[6], $fn = 12);
        }
        for (e = [[pts[0], pts[1] - pts[0], c[8][0]], [pts[len(pts) - 1], pts[len(pts) - 2] - pts[len(pts) - 1], c[8][1]]]) {
            medidas = medidas_conector(e[2]);
            if (medidas[2] > 0) color(color_conector(e[2])) conector_cableado(e[0], e[1], medidas);
        }
    }
}

// Caja de un conector: base en el punto p, eje hacia "hacia", sección ancho × alto
module conector_cableado(p, hacia, medidas) {
    largo = norm(hacia);
    translate(p) rotate([0, acos(hacia[2]/largo), atan2(hacia[1], hacia[0])])
        translate([-medidas[0]/2, -medidas[1]/2, 0]) cube(medidas);
}

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
