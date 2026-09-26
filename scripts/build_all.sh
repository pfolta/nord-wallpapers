#!/usr/bin/env bash

# build_all.sh - Render and assemble all wallpapers.
#
# USAGE:
#   scripts/build_all.sh "./build"

set -euo pipefail
shopt -s nullglob

if [[ $# != 1 || -z "$1" ]]; then
    printf "\033[31m✗ \033[1m%s\033[22m: %s\033[0m\n" "Usage" "scripts/build_all.sh <build-dir>" >&2
    exit 1
fi

build_dir="$1"
wallpapers_dir="./wallpapers"

for wallpaper_dir in "$wallpapers_dir"/*/; do
    wallpaper="$(basename "$wallpaper_dir")"
    scripts/build.sh "$wallpaper" "$build_dir"
done
