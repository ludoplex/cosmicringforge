#!/bin/sh
# MBSE Stacks — Bootstrap Script
# Ring 0: sh only, no external dependencies
#
# This script bootstraps the generator toolchain:
# 1. Compiles schemagen-bootstrap (hand-written Stage 0)
# 2. Uses it to generate schemagen's own types (dogfooding)
# 3. Compiles remaining generators
#
# Usage: ./bootstrap.sh [PROFILE]
#   PROFILE=portable  Use native cc (default)
#   PROFILE=ape       Use cosmocc for Actually Portable Executable

set -e

PROFILE="${1:-portable}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/../build/$PROFILE"
GEN_DIR="$SCRIPT_DIR/gen"
SPEC_DIR="$SCRIPT_DIR/specs"

# ── Toolchain Selection ─────────────────────────────────────────────

if [ "$PROFILE" = "ape" ]; then
    CC="${CC:-cosmocc}"
    CFLAGS="-mcosmo -O2 -Wall -Werror -std=c11 -Wno-stringop-truncation"
    EXE_EXT=".com"
else
    CC="${CC:-cc}"
    CFLAGS="-O2 -Wall -Werror -std=c11 -D_POSIX_C_SOURCE=200809L -Wno-stringop-truncation"
    EXE_EXT=""
fi

echo "=== MBSE Stacks Bootstrap ==="
echo "PROFILE: $PROFILE"
echo "CC: $CC"
echo ""

mkdir -p "$BUILD_DIR"

# ── Stage 0: Bootstrap Schemagen ────────────────────────────────────

echo "--- Stage 0: Compiling schemagen-bootstrap ---"
$CC $CFLAGS -o "$BUILD_DIR/schemagen-bootstrap$EXE_EXT" \
    "$GEN_DIR/schemagen/schemagen_bootstrap.c"
echo "Built: $BUILD_DIR/schemagen-bootstrap$EXE_EXT"

# ── Stage 1: Self-Host (Dogfooding) ─────────────────────────────────

echo ""
echo "--- Stage 1: Generating schemagen's own types ---"
if [ -f "$SPEC_DIR/schemagen.schema" ]; then
    PROFILE="$PROFILE" "$BUILD_DIR/schemagen-bootstrap$EXE_EXT" \
        "$SPEC_DIR/schemagen.schema" \
        "$GEN_DIR/schemagen" \
        "SCHEMAGEN"
    echo "Self-hosted: schemagen types generated from spec"
else
    echo "Warning: $SPEC_DIR/schemagen.schema not found, skipping self-host"
fi

# ── Stage 2: Compile Final Schemagen ────────────────────────────────

echo ""
echo "--- Stage 2: Compiling schemagen (final) ---"
$CC $CFLAGS -I"$GEN_DIR/schemagen" \
    -o "$BUILD_DIR/schemagen$EXE_EXT" \
    "$GEN_DIR/schemagen/schemagen.c"
echo "Built: $BUILD_DIR/schemagen$EXE_EXT"

# ── Stage 3: Remaining Generators ───────────────────────────────────

echo ""
echo "--- Stage 3: Compiling remaining generators ---"

for gen in lexgen bin2c smgen uigen; do
    src="$GEN_DIR/$gen/$gen.c"
    if [ -f "$src" ]; then
        $CC $CFLAGS -o "$BUILD_DIR/$gen$EXE_EXT" "$src"
        echo "Built: $BUILD_DIR/$gen$EXE_EXT"
    else
        echo "Skip: $src (not found)"
    fi
done

# ── Summary ─────────────────────────────────────────────────────────

echo ""
echo "=== Bootstrap Complete ==="
echo "Build directory: $BUILD_DIR"
ls -la "$BUILD_DIR"
