#!/bin/bash
# Genera una captura por paso de armado a partir de src/<diseño>_ensamblaje.scad (fase 4).
#
#   scripts/capturas_armado.sh puntero_laser
#
# El ensamblaje debe tener el parámetro paso_armado: con -1 lista los pasos ("PASO;n;elementos")
# y con n > 0 dibuja la vista explotada del paso n. Escribe docs/img/<diseño>_paso_NN.png, que
# scripts/generar_web.py coloca junto a cada paso. Los pasos sin elementos no tienen captura.
# Necesita el display de WSLg: ejecutar fuera del sandbox.
set -u
cd "$(dirname "$0")/.." || exit 1

diseno="${1:-}"
ensamblaje="src/${diseno}_ensamblaje.scad"
if [ -z "$diseno" ] || [ ! -f "$ensamblaje" ]; then
    echo "Uso: $0 <diseño>   (necesita $ensamblaje)" >&2
    exit 2
fi
openscad=.tools/bin/openscad
tmp="${TMPDIR:-/tmp}/capturas_armado"
mkdir -p "$tmp" docs/img

"$openscad" -D paso_armado=-1 -o "$tmp/pasos.echo" "$ensamblaje" > /dev/null 2>&1
pasos=$(sed -n 's/^ECHO: "PASO;\([0-9]*\);\([0-9]*\)"$/\1;\2/p' "$tmp/pasos.echo")
if [ -z "$pasos" ]; then
    echo "✗ $ensamblaje no lista sus pasos (¿falta el parámetro paso_armado?)" >&2
    exit 1
fi

fallo=0
for linea in $pasos; do
    n=${linea%;*}
    elementos=${linea#*;}
    archivo=$(printf "docs/img/%s_paso_%02d.png" "$diseno" "$n")
    if [ "$elementos" -eq 0 ]; then
        rm -f "$archivo"
        echo "  Paso $n: sin piezas nuevas, sin captura"
        continue
    fi
    if "$openscad" -D paso_armado="$n" -o "$archivo" --imgsize=1000,750 --autocenter --viewall \
        --colorscheme=Tomorrow "$ensamblaje" > /dev/null 2>&1 && [ -s "$archivo" ]; then
        echo "✓ Paso $n: $archivo"
    else
        echo "✗ Paso $n: falló la captura (dentro del sandbox no hay display de WSLg)"
        fallo=1
    fi
done
exit $fallo
