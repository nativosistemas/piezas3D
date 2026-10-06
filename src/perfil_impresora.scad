// ==========================================
// Proyecto: piezas3D
// Componente: Perfil de impresora
// Descripción: Holguras y límites de la impresora real. Lo incluyen las piezas con encajes.
// ==========================================

// --- PARÁMETROS Y CONSTANTES ---

// Origen de los valores
perfil_medido = false;      // true solo después de imprimir y medir el peine de calibración
perfil_impresora = "";      // marca y modelo
perfil_material = "PETG";   // las holguras cambian con el material: PLA ≠ PETG ≠ ABS
perfil_boquilla = 0.4;      // [mm]
perfil_fecha = "";          // AAAA-MM-DD de la medición

// Holguras: mm que se suman al diámetro del agujero. Se miden como agujero_elegido − 6,00
holgura_presion = 0.15;     // entra con fuerza y queda fijo sin pegamento
holgura_justo = 0.25;       // entra a mano y sin juego (uso diario)
holgura_deslizante = 0.30;  // se mueve libre, sin juego apreciable
holgura_suelto = 0.40;      // cae solo, con juego visible

// Expansión horizontal por lado: (bloque_medido − 20,00) / 2.
// Positiva = la impresora "engorda" las piezas y los agujeros salen más chicos.
expansion_xy = 0.00;

// Límites de impresión
espesor_min_pared = 1.2;    // [mm]
espesor_min_piso = 0.8;     // [mm]
voladizo_max = 45;          // [°] respecto de la vertical
puente_max = 10;            // [mm]
cama = [220, 220, 250];     // [mm] X, Y, Z (specs 001 y 002)
margen_cama = 10;           // [mm] por lado

// --- VALIDACIONES ---
assert(holgura_presion < holgura_justo && holgura_justo < holgura_deslizante
       && holgura_deslizante < holgura_suelto,
       "las holguras deben crecer: presión < justo < deslizante < suelto");
assert(cama[0] > 2 * margen_cama && cama[1] > 2 * margen_cama,
       "el margen de la cama no deja superficie útil");

// --- FUNCIONES ---
function holgura(tipo = "justo") =
    tipo == "presion"    ? holgura_presion :
    tipo == "justo"      ? holgura_justo :
    tipo == "deslizante" ? holgura_deslizante :
    tipo == "suelto"     ? holgura_suelto :
    assert(false, str("tipo de holgura desconocido: ", tipo)) 0;

// Superficie útil de la cama (X, Y) descontando el margen
function cama_util() = [cama[0] - 2 * margen_cama, cama[1] - 2 * margen_cama];
