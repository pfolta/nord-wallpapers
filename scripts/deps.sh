#!/usr/bin/env bash

# deps.sh - Verify all dependencies are available.
#
# USAGE:
#   scripts/deps.sh

set -euo pipefail

if [[ $# != 0 ]]; then
    printf "\033[31m✗ \033[1m%s\033[22m: %s\033[0m\n" "Usage" "scripts/deps.sh" >&2
    exit 1
fi

deps=(
    "base64"
    "exiftool"
    "heif-enc"
    "plutil"
    "resvg"
)

printf "\033[34m•\033[0m \033[1m%s\033[0m\n" "Checking platform..."
if [[ "$(uname -s)" == "Darwin" ]]; then
    printf "  \033[32m✓\033[0m %s\n" "Platform is macOS."
else
    printf "  \033[31m✗ %s\033[0m\n" "This script requires macOS." >&2
    exit 1
fi

# Set to 1 if any dependencies are missing.
missingDeps=0

printf "\033[34m•\033[0m \033[1m%s\033[0m\n" "Checking dependencies..."
for dep in "${deps[@]}"; do
    if cmd="$(command -v "$dep")"; then
        printf "  \033[32m✓\033[0m \033[1m%s\033[0m: Found at '%s'\n" "$dep" "$cmd"
    else
        missingDeps=1
        printf "  \033[31m✗ \033[1m%s\033[22m: %s\033[0m\n" "$dep" "Not found" >&2
    fi
done

if (( missingDeps )); then
    exit 1
fi
