BUILD_DIR ?= ./build

.PHONY: default
default: deps clean build_all package

.PHONY: build
build:
	@scripts/build.sh "$(WALLPAPER)" "$(BUILD_DIR)"

.PHONY: build_all
build_all:
	@scripts/build_all.sh "$(BUILD_DIR)"

.PHONY: clean
clean:
	@scripts/clean.sh "$(BUILD_DIR)"

.PHONY: deps
deps:
	@scripts/deps.sh

.PHONY: help
help:
	@printf "\033[34m•\033[0m \033[1m%s\033[0m\n" "TARGETS"
	@printf "  \033[34m•\033[0m %-24s%s\n" "(no target)" "Default: Remove stale build artifacts, then build and package all wallpapers"
	@printf "  \033[34m•\033[0m %-24s%s\n" "deps"        "Verify all dependencies are available"
	@printf "  \033[34m•\033[0m %-24s%s\n" "clean"       "Remove all build artifacts"
	@printf "  \033[34m•\033[0m %-24s%s\n" "build"       "Render and assemble a single wallpaper"
	@printf "  \033[34m•\033[0m %-24s%s\n" "build_all"   "Render and assemble all wallpapers"
	@printf "  \033[34m•\033[0m %-24s%s\n" "package"     "Package built wallpapers for distribution"
	@printf "  \033[34m•\033[0m %-24s%s\n" "help"        "Show this help message"
	@printf "\n"
	@printf "\033[34m•\033[0m \033[1m%s\033[0m\n" "VARIABLES"
	@printf "  \033[34m•\033[0m %-24s%s\n" "BUILD_DIR" "Build directory (default: ./build)"
	@printf "  \033[34m•\033[0m %-24s%s\n" "WALLPAPER" "Wallpaper name (required by 'build')"
	@printf "\n"
	@printf "\033[34m•\033[0m \033[1m%s\033[0m\n" "EXAMPLES"
	@printf "  \033[34m•\033[0m %s\n" "make"
	@printf "  \033[34m•\033[0m %s\n" "make build WALLPAPER=\"Nord Mojave\""
	@printf "  \033[34m•\033[0m %s\n" "make build WALLPAPER=\"Nord Mojave\" BUILD_DIR=\"./tmp\""
	@printf "  \033[34m•\033[0m %s\n" "make build_all BUILD_DIR=\"./tmp\""

.PHONY: package
package:
	@scripts/package.sh "$(BUILD_DIR)"
