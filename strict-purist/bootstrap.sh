#!/bin/sh
# MBSE Stacks — Bootstrap Script
# Ring 0: sh only, no external dependencies
#
# TRUE DOGFOODING: Each generator uses its own spec format
#
# Self-hosting hierarchy:
#   1. schemagen: specs/schemagen.schema → gen/schemagen/schemagen_types.h
#   2. lexgen:    gen/lexgen/lexgen_tokens.def → gen/lexgen/lexgen_self.h (X-macro)
#   3. smgen:     gen/smgen/smgen_tokens.def → gen/smgen/smgen_self.h (X-macro)
#   4. uigen:     gen/uigen/uigen_tokens.def → gen/uigen/uigen_self.h (X-macro)
#   5. defgen:    gen/defgen/defgen_macros.def → gen/defgen/defgen_self.h (X-macro)
#
# The X-macro self-hosting is compile-time: .def files are #included directly.
# No runtime code generation needed - the C preprocessor handles expansion.
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

echo "=== MBSE Stacks Bootstrap (TRUE DOGFOODING) ==="
echo "PROFILE: $PROFILE"
echo "CC: $CC"
echo ""

mkdir -p "$BUILD_DIR"

# ── Stage 0: Bootstrap Schemagen ────────────────────────────────────
# schemagen is special: needs runtime code gen, so we bootstrap first

echo "--- Stage 0: Bootstrap schemagen (hand-written bootstrap) ---"
$CC $CFLAGS -o "$BUILD_DIR/schemagen-bootstrap$EXE_EXT" \
    "$GEN_DIR/schemagen/schemagen_bootstrap.c"
echo "Built: schemagen-bootstrap"

# ── Stage 1: Self-Host Schemagen ────────────────────────────────────
# Use bootstrap to generate schemagen's own types from its spec

echo ""
echo "--- Stage 1: Schemagen self-hosts (generates own types) ---"
if [ -f "$SPEC_DIR/schemagen.schema" ]; then
    PROFILE="$PROFILE" "$BUILD_DIR/schemagen-bootstrap$EXE_EXT" \
        "$SPEC_DIR/schemagen.schema" \
        "$GEN_DIR/schemagen" \
        "SCHEMAGEN"
    echo "Self-hosted: schemagen_types.h generated from schemagen.schema"
else
    echo "Warning: $SPEC_DIR/schemagen.schema not found"
fi

# ── Stage 2: Compile Final Schemagen ────────────────────────────────

echo ""
echo "--- Stage 2: Compile final schemagen (uses self-hosted types) ---"
$CC $CFLAGS -I"$GEN_DIR/schemagen" \
    -o "$BUILD_DIR/schemagen$EXE_EXT" \
    "$GEN_DIR/schemagen/schemagen.c"
echo "Built: schemagen"

# ── Stage 3: Compile X-Macro Self-Hosted Generators ─────────────────
# These generators use compile-time X-macro self-hosting:
#   - lexgen:  lexgen_tokens.def → lexgen_self.h
#   - smgen:   smgen_tokens.def → smgen_self.h
#   - uigen:   uigen_tokens.def → uigen_self.h
#   - defgen:  defgen_macros.def → defgen_self.h
# The .def files are #included directly via X-macros - no separate generation step

echo ""
echo "--- Stage 3: Compile X-macro self-hosted generators ---"

for gen in lexgen smgen uigen defgen; do
    src="$GEN_DIR/$gen/$gen.c"
    if [ -f "$src" ]; then
        $CC $CFLAGS -I"$GEN_DIR/$gen" -o "$BUILD_DIR/$gen$EXE_EXT" "$src"
        echo "Built: $gen (X-macro self-hosted via ${gen}_self.h)"
    else
        echo "Skip: $src (not found)"
    fi
done

# ── Stage 4: Compile Remaining Generators ───────────────────────────
# bin2c doesn't need self-hosting (just embeds binary data)

echo ""
echo "--- Stage 4: Compile utility generators ---"

for gen in bin2c; do
    src="$GEN_DIR/$gen/$gen.c"
    if [ -f "$src" ]; then
        $CC $CFLAGS -o "$BUILD_DIR/$gen$EXE_EXT" "$src"
        echo "Built: $gen"
    else
        echo "Skip: $src (not found)"
    fi
done

# ── Verify Self-Hosting ─────────────────────────────────────────────

echo ""
echo "--- Verifying self-hosting ---"
echo "Checking .def files are properly included..."

verify_xmacro() {
    gen=$1
    def_file="$GEN_DIR/$gen/${gen}_*.def"
    if ls $def_file 1>/dev/null 2>&1; then
        count=$(ls $def_file | wc -l)
        echo "  $gen: $count .def file(s) (X-macro self-hosted)"
    fi
}

# Check schemagen (runtime self-hosting)
if [ -f "$GEN_DIR/schemagen/schemagen_types.h" ]; then
    echo "  schemagen: schemagen_types.h (runtime self-hosted)"
fi

# Check X-macro self-hosted generators
for gen in lexgen smgen uigen defgen; do
    verify_xmacro $gen
done

# ── Summary ─────────────────────────────────────────────────────────

echo ""
echo "=== Bootstrap Complete (TRUE DOGFOODING) ==="
echo ""
echo "Self-hosting hierarchy:"
echo "  schemagen → specs/schemagen.schema → gen/schemagen/schemagen_types.h"
echo "  lexgen    → gen/lexgen/lexgen_tokens.def (X-macro #include)"
echo "  smgen     → gen/smgen/smgen_tokens.def (X-macro #include)"
echo "  uigen     → gen/uigen/uigen_tokens.def (X-macro #include)"
echo "  defgen    → gen/defgen/defgen_macros.def (X-macro #include)"
echo ""
echo "Build directory: $BUILD_DIR"
ls -la "$BUILD_DIR"
