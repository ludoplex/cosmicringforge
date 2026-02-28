#!/bin/sh
# MBSE Stacks — Cosmopolitan Build System
# Integrates ludoplex/cosmo-cross-sdk with vendored BSD utilities
#
# Usage:
#   ./cosmo-build.sh setup    # Download and setup cosmocc toolchain
#   ./cosmo-build.sh build    # Build all Ring 0 tools as APE
#   ./cosmo-build.sh test     # Test the built binaries
#
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VENDOR_DIR="$SCRIPT_DIR/vendor"
BUILD_DIR="$SCRIPT_DIR/../build/ape"
COSMO_SDK="$VENDOR_DIR/cosmo-cross-sdk"
COSMO_INCLUDE="$VENDOR_DIR/cosmo-include"

# ── Setup ────────────────────────────────────────────────────────────

setup_cosmocc() {
    echo "=== Setting up Cosmopolitan toolchain ==="

    if [ ! -f "$VENDOR_DIR/cosmopolitan/cosmocc.zip" ]; then
        echo "Downloading cosmocc..."
        mkdir -p "$VENDOR_DIR/cosmopolitan"
        curl -sL "https://cosmo.zip/pub/cosmocc/cosmocc.zip" -o "$VENDOR_DIR/cosmopolitan/cosmocc.zip"
    fi

    if [ ! -d "$BUILD_DIR/cosmocc" ]; then
        echo "Extracting cosmocc..."
        mkdir -p "$BUILD_DIR/cosmocc"
        cd "$BUILD_DIR/cosmocc"
        unzip -q -o "$VENDOR_DIR/cosmopolitan/cosmocc.zip"
    fi

    export PATH="$BUILD_DIR/cosmocc/bin:$PATH"
    echo "cosmocc ready: $(which cosmocc)"
    cosmocc --version | head -1
}

# ── Build Tools ──────────────────────────────────────────────────────

build_lemon() {
    echo "--- Building Lemon parser generator ---"
    cosmocc -Os -o "$BUILD_DIR/lemon.com" "$VENDOR_DIR/lemon/lemon.c"
    echo "Built: $BUILD_DIR/lemon.com"
}

build_bin2c() {
    echo "--- Building bin2c ---"
    cosmocc -Os -o "$BUILD_DIR/bin2c.com" "$VENDOR_DIR/bin2c/bin2c_simple.c"
    echo "Built: $BUILD_DIR/bin2c.com"
}

build_generators() {
    echo "--- Building generators ---"

    # Bootstrap schemagen
    cosmocc -Os -o "$BUILD_DIR/schemagen-bootstrap.com" \
        "$SCRIPT_DIR/gen/schemagen/schemagen_bootstrap.c"

    # Generate schemagen's own types
    "$BUILD_DIR/schemagen-bootstrap.com" \
        "$SCRIPT_DIR/specs/schemagen.schema" \
        "$SCRIPT_DIR/gen/schemagen" \
        "SCHEMAGEN"

    # Build final schemagen
    cosmocc -Os -I"$SCRIPT_DIR/gen/schemagen" \
        -o "$BUILD_DIR/schemagen.com" \
        "$SCRIPT_DIR/gen/schemagen/schemagen.c"

    # Build other generators
    for gen in lexgen smgen defgen; do
        cosmocc -Os -I"$SCRIPT_DIR/gen/$gen" \
            -o "$BUILD_DIR/${gen}.com" \
            "$SCRIPT_DIR/gen/$gen/${gen}.c" 2>/dev/null || \
            echo "Warning: $gen build had warnings"
    done

    echo "Generators built:"
    ls "$BUILD_DIR"/*.com
}

build_kilo() {
    echo "--- Building kilo editor ---"
    # kilo needs some tweaks for cosmopolitan
    cosmocc -Os -DKILO_COSMO -o "$BUILD_DIR/kilo.com" \
        "$VENDOR_DIR/kilo/kilo.c" 2>/dev/null || \
        echo "kilo requires termios tweaks for cosmo"
}

# ── Main ─────────────────────────────────────────────────────────────

mkdir -p "$BUILD_DIR"

case "${1:-build}" in
    setup)
        setup_cosmocc
        ;;
    build)
        setup_cosmocc
        build_lemon
        build_bin2c
        build_generators
        build_kilo
        echo ""
        echo "=== APE Build Complete ==="
        ls -la "$BUILD_DIR"/*.com
        ;;
    test)
        echo "=== Testing APE binaries ==="
        "$BUILD_DIR/schemagen.com" "$SCRIPT_DIR/specs/schemagen.schema" /tmp/test SCHEMA
        "$BUILD_DIR/smgen.com" "$SCRIPT_DIR/specs/example.sm" /tmp/test EXAMPLE
        echo "Tests passed"
        ;;
    *)
        echo "Usage: $0 {setup|build|test}"
        exit 1
        ;;
esac
