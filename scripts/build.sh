#!/usr/bin/env bash

# build.sh - Render and assemble a single wallpaper.
#
# USAGE:
#   scripts/build.sh "Nord Arctic Ocean Fractal" "./build"

set -euo pipefail

if [[ $# != 2 || -z "$1" || -z "$2" ]]; then
    printf "\033[31m✗ \033[1m%s\033[22m: %s\033[0m\n" "Usage" "scripts/build.sh <wallpaper> <build-dir>" >&2
    exit 1
fi

wallpaper="$1"
build_dir="$2"

wallpapers_dir="./wallpapers"
out_dir="$build_dir/out/$wallpaper"

printf "\033[34m•\033[0m \033[1m%s\033[0m\n" "Creating wallpaper '$wallpaper'..."

wallpaper_svg_light="$wallpapers_dir/$wallpaper/$wallpaper Light.svg"
if [[ -f "$wallpaper_svg_light" ]]; then
    printf "  \033[32m✓\033[0m %s: '%s'\n" "Found light SVG" "$wallpaper_svg_light"
else
    printf "  \033[31m✗ %s: '%s'\033[0m\n" "Light SVG not found" "$wallpaper_svg_light" >&2
    exit 1
fi

wallpaper_svg_dark="$wallpapers_dir/$wallpaper/$wallpaper Dark.svg"
if [[ -f "$wallpaper_svg_dark" ]]; then
    printf "  \033[32m✓\033[0m %s: '%s'\n" "Found dark SVG" "$wallpaper_svg_dark"
else
    printf "  \033[31m✗ %s: '%s'\033[0m\n" "Dark SVG not found" "$wallpaper_svg_dark" >&2
    exit 1
fi

if mkdir -p "$out_dir"; then
    printf "  \033[32m✓\033[0m %s: '%s'\n" "Ensure output directory exists" "$out_dir"
else
    printf "  \033[31m✗ %s: '%s'\033[0m\n" "Failed to create output directory" "$out_dir" >&2
    exit 1
fi

wallpaper_png_light="$out_dir/$(basename "$wallpaper_svg_light" ".svg").png"
if resvg "$wallpaper_svg_light" "$wallpaper_png_light"; then
    printf "  \033[32m✓\033[0m %s: '%s'\n" "Rendered light PNG" "$wallpaper_png_light"
else
    printf "  \033[31m✗ %s: '%s'\033[0m\n" "Failed to render light PNG" "$wallpaper_png_light" >&2
    exit 1
fi

wallpaper_png_dark="$out_dir/$(basename "$wallpaper_svg_dark" ".svg").png"
if resvg "$wallpaper_svg_dark" "$wallpaper_png_dark"; then
    printf "  \033[32m✓\033[0m %s: '%s'\n" "Rendered dark PNG" "$wallpaper_png_dark"
else
    printf "  \033[31m✗ %s: '%s'\033[0m\n" "Failed to render dark PNG" "$wallpaper_png_dark" >&2
    exit 1
fi

wallpaper_png_light_w=$(exiftool -s3 -ImageWidth "$wallpaper_png_light")
wallpaper_png_light_h=$(exiftool -s3 -ImageHeight "$wallpaper_png_light")
wallpaper_png_dark_w=$(exiftool -s3 -ImageWidth "$wallpaper_png_dark")
wallpaper_png_dark_h=$(exiftool -s3 -ImageHeight "$wallpaper_png_dark")

if (( wallpaper_png_light_w != wallpaper_png_dark_w )); then
    printf "  \033[31m✗ %s: %d != %d\033[0m\n" "Light and dark PNGs have different widths" "$wallpaper_png_light_w" "$wallpaper_png_dark_w" >&2
    exit 1
fi

if (( wallpaper_png_light_h != wallpaper_png_dark_h )); then
    printf "  \033[31m✗ %s: %d != %d\033[0m\n" "Light and dark PNGs have different heights" "$wallpaper_png_light_h" "$wallpaper_png_dark_h" >&2
    exit 1
fi

preview_svg="$out_dir/preview.svg"
{
    printf '<svg xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg" width="%s" height="%s" viewBox="0 0 %s %s">\n' "$wallpaper_png_light_w" "$wallpaper_png_light_h" "$wallpaper_png_light_w" "$wallpaper_png_light_h"
    printf '  <clipPath id="l"><rect x="0" y="0" width="%s" height="%s" /></clipPath>\n' "$(( wallpaper_png_light_w / 2 ))" "$wallpaper_png_light_h"
    printf '  <clipPath id="r"><rect x="%s" y="0" width="%s" height="%s" /></clipPath>\n' "$(( wallpaper_png_dark_w / 2 ))" "$(( wallpaper_png_dark_w - (wallpaper_png_dark_w / 2) ))" "$wallpaper_png_dark_h"
    printf '  <image href="%s" x="0" y="0" width="%s" height="%s" clip-path="url(#l)" />\n' "$(basename "$wallpaper_png_light")" "$wallpaper_png_light_w" "$wallpaper_png_light_h"
    printf '  <image href="%s" x="0" y="0" width="%s" height="%s" clip-path="url(#r)" />\n' "$(basename "$wallpaper_png_dark")" "$wallpaper_png_dark_w" "$wallpaper_png_dark_h"
    printf '</svg>\n'
} > "$preview_svg"
printf "  \033[32m✓\033[0m %s: '%s'\n" "Created SVG preview" "$preview_svg"

preview_png="$out_dir/preview.png"
if resvg "$preview_svg" "$preview_png"; then
    printf "  \033[32m✓\033[0m %s: '%s'\n" "Rendered preview PNG" "$preview_png"
else
    printf "  \033[31m✗ %s: '%s'\033[0m\n" "Failed to render preview PNG" "$preview_png" >&2
    exit 1
fi

wallpaper_heic="$out_dir/$wallpaper.heic"
if heif-enc -L --no-alpha "$preview_png" "$wallpaper_png_light" "$wallpaper_png_dark" -o "$wallpaper_heic"; then
    printf "  \033[32m✓\033[0m %s: '%s'\n" "Assembled composite HEIC" "$wallpaper_heic"
else
    printf "  \033[31m✗ %s: '%s'\033[0m\n" "Failed to assemble composite HEIC" "$wallpaper_heic" >&2
    exit 1
fi

# HEIC image indices:
#   0: Composite preview (left half light, right half dark)
#   1: Light wallpaper
#   2: Dark wallpaper
apr_payload='{"l":1,"d":2}'
printf "  \033[32m✓\033[0m %s: '%s'\n" "Created appearance payload" "$apr_payload"

apr_payload_enc=$(printf '%s\n' "$apr_payload" | plutil -convert binary1 - -o - | base64)
printf "  \033[32m✓\033[0m %s: '%s'\n" "Encoded appearance payload" "$apr_payload_enc"

wallpaper_xmp="$out_dir/apr.xmp"
{
    printf '<?xpacket begin="\357\273\277" id="W5M0MpCehiHzreSzNTczkc9d"?> '
    printf '<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="XMP Core 6.0.0"> '
    printf '<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"> '
    printf '<rdf:Description rdf:about="" xmlns:apple_desktop="http://ns.apple.com/namespace/1.0/" apple_desktop:apr="%s"/> ' "$apr_payload_enc"
    printf '</rdf:RDF> '
    printf '</x:xmpmeta> '
    printf '<?xpacket end="w"?>'
} > "$wallpaper_xmp"
printf "  \033[32m✓\033[0m %s: '%s'\n" "Created appearance XMP serialization" "$wallpaper_xmp"

if exiftool -overwrite_original -q "-XMP<=$wallpaper_xmp" "$wallpaper_heic"; then
    printf "  \033[32m✓\033[0m %s: '%s'\n" "Embedded appearance payload" "$wallpaper_heic"
else
    printf "  \033[31m✗ %s: '%s'\033[0m\n" "Failed to embed appearance payload" "$wallpaper_heic" >&2
    exit 1
fi
