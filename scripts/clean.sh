#!/usr/bin/env bash

# clean.sh - Remove all build artifacts.
#
# USAGE:
#   scripts/clean.sh "./build"

set -euo pipefail

if [[ $# != 1 || -z "$1" ]]; then
    printf "\033[31m✗ \033[1m%s\033[22m: %s\033[0m\n" "Usage" "scripts/clean.sh <build-dir>" >&2
    exit 1
fi

build_dir="$1"

printf "\033[34m•\033[0m \033[1m%s\033[0m\n" "Cleaning build directory..."

if rm -rf "$build_dir"; then
    printf "  \033[32m✓\033[0m %s: '%s'\n" "Build directory cleaned" "$build_dir"
else
    printf "  \033[31m✗ %s: '%s'\033[0m\n" "Failed to clean build directory" "$build_dir" >&2
    exit 1
fi
