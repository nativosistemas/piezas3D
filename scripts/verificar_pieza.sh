#!/bin/bash
# Ciclo de verificación de la fase 1 para una pieza de src/.
#
#   scripts/verificar_pieza.sh src/<pieza>.scad                 validación estricta + caja envolvente
#   scripts/verificar_pieza.sh --rapido src/<pieza>.scad        solo validación estricta sin render (< 1 s)
#   scripts/verificar_pieza.sh --capturas DIR src/<pieza>.scad  además, 5 capturas PNG en DIR
#
# Termina con 1 si hay cualquier WARNING o ERROR, si la pieza no apoya en Z = 0 o si no entra en la
# cama de src/perfil_impresora.scad. Las capturas necesitan el display de WSLg: fuera del sandbox.
set -u
cd "$(dirname "$0")/.." || exit 1

openscad=.tools/bin/openscad
banderas=(--hardwarnings --check-parameters=true --check-parameter-ranges=true)
modo=completo
dir_capturas=""

while [ $# -gt 1 ]; do
    case "$1" in
        --rapido) modo=rapido; shift ;;
        --capturas) dir_capturas="$2"; shift 2 ;;
        *) echo "Opción desconocida: $1" >&2; exit 2 ;;
    esac
done
pieza="${1:-}"
if [ ! -f "$pieza" ] || [[ "$pieza" != *.scad ]]; then
    echo "Uso: $0 [--rapido] [--capturas DIR] src/<pieza>.scad" >&2
    exit 2
fi
nombre=$(basename "$pieza" .scad)
tmp="${TMPDIR:-/tmp}/verificar"
mkdir -p "$tmp"
fallo=0

# --- 1. Validación estricta ---
if [ "$modo" = rapido ]; then
    salida="$tmp/$nombre.csg"
else
    salida="$tmp/$nombre.stl"
fi
log=$("$openscad" "${banderas[@]}" -o "$salida" "$pieza" 2>&1)
rc=$?
avisos=$(grep -E "WARNING|ERROR" <<< "$log")
if [ $rc -ne 0 ] || [ -n "$avisos" ]; then
    echo "✗ Validación estricta: $pieza"
    echo "${avisos:-$log}"
    exit 1
fi
echo "✓ Validación estricta"
[ "$modo" = rapido ] && exit 0

# --- 2. Caja envolvente ---
read -r dx dy dz zmin < <(awk '/vertex/{for(i=2;i<=4;i++){v=$i+0; if(!(i in mn)||v<mn[i])mn[i]=v; if(!(i in mx)||v>mx[i])mx[i]=v}}
    END{printf "%.2f %.2f %.2f %.2f\n",mx[2]-mn[2],mx[3]-mn[3],mx[4]-mn[4],mn[4]}' "$salida")
echo "  Caja envolvente: X $dx  Y $dy  Z $dz mm"

if [[ "$nombre" == *_ensamblaje ]]; then
    echo "  (ensamblaje: no se exporta, se omiten los controles de cama y apoyo)"
else
    if awk -v z="$zmin" 'BEGIN{exit !(z < -0.01 || z > 0.01)}'; then
        echo "✗ La pieza no apoya en Z = 0 (Z mínima = $zmin mm): está flotando o mal orientada"
        fallo=1
    else
        echo "✓ Apoya en Z = 0"
    fi
    perfil=src/perfil_impresora.scad
    cama=$(sed -n 's/^cama *= *\[\([0-9., ]*\)\].*/\1/p' "$perfil" | tr -d ' ')
    margen=$(sed -n 's/^margen_cama *= *\([0-9.]*\).*/\1/p' "$perfil")
    IFS=, read -r cx cy cz <<< "$cama"
    # Entra si cabe en X-Y en alguna de las dos rotaciones de 90°
    if awk -v dx="$dx" -v dy="$dy" -v dz="$dz" -v cx="$cx" -v cy="$cy" -v cz="$cz" -v m="$margen" \
        'BEGIN{ux=cx-2*m; uy=cy-2*m; ok=((dx<=ux&&dy<=uy)||(dx<=uy&&dy<=ux))&&dz<=cz; exit !ok}'; then
        echo "✓ Entra en la cama ${cx}×${cy}×${cz} mm con ${margen} mm de margen"
    else
        echo "✗ No entra en la cama ${cx}×${cy}×${cz} mm con ${margen} mm de margen por lado"
        fallo=1
    fi
fi

# --- 3. Capturas PNG ---
if [ -n "$dir_capturas" ]; then
    mkdir -p "$dir_capturas"
    comun=(--imgsize=800,600 --autocenter --viewall --colorscheme=Tomorrow)
    vistas=(
        "1-isometrica|"
        "2-frente|--projection=o --camera=0,0,0,90,0,0,0"
        "3-lateral|--projection=o --camera=0,0,0,90,0,90,0"
        "4-superior|--projection=o --camera=0,0,0,0,0,0,0"
        "5-inferior|--projection=o --camera=0,0,0,180,0,0,0"
    )
    for v in "${vistas[@]}"; do
        archivo="$dir_capturas/$nombre-${v%%|*}.png"
        # shellcheck disable=SC2086
        if "$openscad" -o "$archivo" "${comun[@]}" ${v#*|} "$pieza" > /dev/null 2>&1; then
            echo "  Captura: $archivo"
        else
            echo "✗ Falló la captura ${v%%|*}. Dentro del sandbox no hay display de WSLg: ejecutar fuera."
            fallo=1
            break
        fi
    done
fi

exit $fallo
