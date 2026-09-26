#!/usr/bin/env bash

# package.sh - Package built wallpapers for distribution.
#
# USAGE:
#   scripts/package.sh "./build"

set -euo pipefail
shopt -s nullglob

if [[ $# != 1 || -z "$1" ]]; then
    printf "\033[31m✗ \033[1m%s\033[22m: %s\033[0m\n" "Usage" "scripts/package.sh <build-dir>" >&2
    exit 1
fi

build_dir="$1"
out_dir="$build_dir/out"
dist_dir="$build_dir/dist"
dist_wallpaper_dir="$dist_dir/Nord"
dist_wallpaper_archive="$dist_dir/Nord.zip"
checksum_file="$dist_dir/SHA256SUMS"

printf "\033[34m•\033[0m \033[1m%s\033[0m\n" "Packaging wallpapers..."

heic_wallpapers=("$out_dir"/*/*.heic)

if (( ${#heic_wallpapers[@]} == 0 )); then
    printf "  \033[31m✗\033[0m \033[1m%s\033[0m\n" "No HEIC wallpapers found" >&2
    exit 1
fi

if mkdir -p "$dist_wallpaper_dir"; then
    printf "  \033[32m✓\033[0m %s: '%s'\n" "Ensure distribution directory exists" "$dist_wallpaper_dir"
else
    printf "  \033[31m✗ %s: '%s'\033[0m\n" "Failed to create distribution directory" "$dist_wallpaper_dir" >&2
    exit 1
fi

for heic_wallpaper in "${heic_wallpapers[@]}"; do
    if cp "$heic_wallpaper" "$dist_wallpaper_dir/"; then
        printf "  \033[32m✓\033[0m %s: '%s'\n" "Packaged wallpaper" "$(basename "$heic_wallpaper" .heic)"
    else
        printf "  \033[31m✗\033[0m %s: '%s'\n" "Failed to package wallpaper" "$(basename "$heic_wallpaper" .heic)" >&2
        exit 1
    fi
done

if ditto -c -k --keepParent "$dist_wallpaper_dir" "$dist_wallpaper_archive"; then
    printf "  \033[32m✓\033[0m %s: '%s'\n" "Created wallpaper archive" "$dist_wallpaper_archive"
else
    printf "  \033[31m✗ %s: '%s'\033[0m\n" "Failed to create wallpaper archive" "$dist_wallpaper_archive" >&2
    exit 1
fi

if ( cd "$dist_dir" && shasum -a 256 "$(basename "$dist_wallpaper_archive")" > "$(basename "$checksum_file")" ); then
    printf "  \033[32m✓\033[0m %s: '%s'\n" "Generated checksums" "$checksum_file"
else
    printf "  \033[31m✗ %s: '%s'\033[0m\n" "Failed to generate checksums" "$checksum_file" >&2
    exit 1
fi
