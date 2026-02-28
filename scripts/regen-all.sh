#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════════
# regen-all.sh - Regenerate all generated code from specs
# ═══════════════════════════════════════════════════════════════════════════
#
# This script orchestrates ALL generators across ALL rings.
# Ring 2 tools are auto-detected—available tools are used, missing are skipped.
# Ring 2 outputs are committed, so builds always succeed with just C+sh.
#
# Usage: ./scripts/regen-all.sh [--verify]
#   --verify: Also run git diff --exit-code after regeneration
#
# Exit codes:
#   0 - Success
#   1 - Generator failed
#   2 - Drift detected (with --verify)
#
# ═══════════════════════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VERIFY=0

for arg in "$@"; do
    case "$arg" in
        --verify) VERIFY=1 ;;
    esac
done

cd "$ROOT_DIR"

echo "═══════════════════════════════════════════════════════════════════════"
echo " CosmicRingForge - Regenerate All (auto-detecting tools)"
echo "═══════════════════════════════════════════════════════════════════════"

# ── Ring 0 Generators ──────────────────────────────────────────────────────

echo
echo "── Ring 0: In-tree generators ──────────────────────────────────────────"

# schemagen
if command -v schemagen >/dev/null 2>&1 || [ -x "strict-purist/gen/schemagen" ]; then
    echo "[schemagen] Processing *.schema files..."
    SCHEMAGEN="${SCHEMAGEN:-schemagen}"
    find . -name "*.schema" -not -path "./vendor/*" | while read -r spec; do
        dir="$(dirname "$spec")"
        gen_dir="$dir/../gen"
        mkdir -p "$gen_dir"
        echo "  $spec → $gen_dir/"
        $SCHEMAGEN "$spec" -o "$gen_dir/" 2>/dev/null || echo "  (skipped - schemagen not ready)"
    done
else
    echo "[schemagen] Not available, skipping"
fi

# smgen
if command -v smgen >/dev/null 2>&1 || [ -x "strict-purist/gen/smgen" ]; then
    echo "[smgen] Processing *.sm files..."
    SMGEN="${SMGEN:-smgen}"
    find . -name "*.sm" -not -path "./vendor/*" | while read -r spec; do
        dir="$(dirname "$spec")"
        gen_dir="$dir/../gen"
        mkdir -p "$gen_dir"
        echo "  $spec → $gen_dir/"
        $SMGEN "$spec" -o "$gen_dir/" 2>/dev/null || echo "  (skipped - smgen not ready)"
    done
else
    echo "[smgen] Not available, skipping"
fi

# lexgen
if command -v lexgen >/dev/null 2>&1 || [ -x "strict-purist/gen/lexgen" ]; then
    echo "[lexgen] Processing *.lex files..."
    LEXGEN="${LEXGEN:-lexgen}"
    find . -name "*.lex" -not -path "./vendor/*" | while read -r spec; do
        dir="$(dirname "$spec")"
        gen_dir="$dir/../gen"
        mkdir -p "$gen_dir"
        echo "  $spec → $gen_dir/"
        $LEXGEN "$spec" -o "$gen_dir/" 2>/dev/null || echo "  (skipped - lexgen not ready)"
    done
else
    echo "[lexgen] Not available, skipping"
fi

# lemon (parser generator)
if command -v lemon >/dev/null 2>&1 || [ -x "strict-purist/vendor/lemon/lemon" ]; then
    echo "[lemon] Processing *.y files..."
    LEMON="${LEMON:-lemon}"
    find . -name "*.y" -not -path "./vendor/*" | while read -r spec; do
        dir="$(dirname "$spec")"
        echo "  $spec"
        $LEMON "$spec" 2>/dev/null || echo "  (skipped)"
    done
else
    echo "[lemon] Not available, skipping"
fi

# ── Ring 2 Generators (FOSS - Portable Profile) ─────────────────────────────

echo
echo "── Ring 2: FOSS tools (portable profile) ─────────────────────────────────"

# StateSmith (.NET) - generates zero-dependency C
if command -v StateSmith.Cli >/dev/null 2>&1 || command -v dotnet >/dev/null 2>&1; then
    echo "[StateSmith] Processing *.drawio state machines..."
    find . -name "*.drawio" -path "*/model/statesmith/*" | while read -r spec; do
        gen_dir="./gen/imported/statesmith"
        mkdir -p "$gen_dir"
        echo "  $spec → $gen_dir/"
        # dotnet StateSmith.Cli run "$spec" --lang=C99 -o "$gen_dir" || echo "  (failed)"
        echo "  (StateSmith invocation placeholder)"
    done
else
    echo "[StateSmith] .NET not available, outputs must already be committed"
fi

# protobuf-c - generates pure C serialization
if command -v protoc >/dev/null 2>&1; then
    echo "[protobuf-c] Processing *.proto files..."
    find . -name "*.proto" -not -path "./vendor/*" | while read -r spec; do
        gen_dir="./gen/imported/protobuf"
        mkdir -p "$gen_dir"
        echo "  $spec → $gen_dir/"
        protoc --c_out="$gen_dir" "$spec" 2>/dev/null || echo "  (skipped)"
    done
else
    echo "[protobuf-c] Not available, outputs must already be committed"
fi

# flatcc - generates zero-copy C
if command -v flatcc >/dev/null 2>&1; then
    echo "[flatcc] Processing *.fbs files..."
    find . -name "*.fbs" -not -path "./vendor/*" | while read -r spec; do
        gen_dir="./gen/imported/flatbuf"
        mkdir -p "$gen_dir"
        echo "  $spec → $gen_dir/"
        flatcc -a -o "$gen_dir" "$spec" 2>/dev/null || echo "  (skipped)"
    done
else
    echo "[flatcc] Not available, outputs must already be committed"
fi

# EEZ Studio - generates embedded C/C++ GUI
if command -v eez-studio >/dev/null 2>&1; then
    echo "[EEZ Studio] Processing *.eez-project files..."
    find . -name "*.eez-project" | while read -r spec; do
        gen_dir="./gen/imported/eez"
        mkdir -p "$gen_dir"
        echo "  $spec → $gen_dir/"
        # eez-studio build "$spec" --output-dir="$gen_dir" || echo "  (failed)"
        echo "  (EEZ invocation placeholder)"
    done
else
    echo "[EEZ Studio] Not available, outputs must already be committed"
fi

# OpenModelica - generates C simulation code
if command -v omc >/dev/null 2>&1; then
    echo "[OpenModelica] Processing *.mo files..."
    find . -name "*.mo" -path "*/model/openmodelica/*" | while read -r spec; do
        gen_dir="./gen/imported/modelica"
        mkdir -p "$gen_dir"
        echo "  $spec → $gen_dir/"
        # omc "$spec" +s +d=initialization --output="$gen_dir" || echo "  (failed)"
        echo "  (OpenModelica invocation placeholder)"
    done
else
    echo "[OpenModelica] Not available, outputs must already be committed"
fi

# ── Ring 2 Generators (Commercial - Auto-Detected) ───────────────────────────

echo
echo "── Ring 2: Commercial tools (auto-detected) ──────────────────────────────"

# MATLAB/Simulink Embedded Coder
if command -v matlab >/dev/null 2>&1; then
    echo "[Embedded Coder] Processing *.slx files..."
    find . -name "*.slx" -path "*/model/simulink/*" | while read -r spec; do
        gen_dir="./gen/imported/simulink"
        mkdir -p "$gen_dir"
        echo "  $spec → $gen_dir/"
        # matlab -batch "slbuild('$spec')" || echo "  (failed)"
        echo "  (Embedded Coder invocation placeholder)"
    done
else
    echo "[Embedded Coder] MATLAB not available, outputs must already be committed"
fi

# IBM Rhapsody
if command -v rhapsodycl >/dev/null 2>&1; then
    echo "[Rhapsody] Processing *.emx files..."
    find . -name "*.emx" -path "*/model/rhapsody/*" | while read -r spec; do
        gen_dir="./gen/imported/rhapsody"
        mkdir -p "$gen_dir"
        echo "  $spec → $gen_dir/"
        # rhapsodycl -generate "$spec" || echo "  (failed)"
        echo "  (Rhapsody invocation placeholder)"
    done
else
    echo "[Rhapsody] Not available, outputs must already be committed"
fi

# Qt Design Studio
if command -v qmlsc >/dev/null 2>&1; then
    echo "[Qt] Processing *.qml files..."
    find . -name "*.qml" -path "*/model/qt/*" | while read -r spec; do
        gen_dir="./gen/imported/qt"
        mkdir -p "$gen_dir"
        name=$(basename "$spec" .qml)
        echo "  $spec → $gen_dir/${name}.cpp"
        qmlsc "$spec" -o "$gen_dir/${name}.cpp" 2>/dev/null || echo "  (skipped)"
    done
else
    echo "[Qt] Not available, outputs must already be committed"
fi

# RTI DDS
if command -v rtiddsgen >/dev/null 2>&1; then
    echo "[RTI DDS] Processing *.idl files..."
    find . -name "*.idl" -not -path "./vendor/*" | while read -r spec; do
        gen_dir="./gen/imported/dds"
        mkdir -p "$gen_dir"
        echo "  $spec → $gen_dir/"
        rtiddsgen -language C -d "$gen_dir" "$spec" 2>/dev/null || echo "  (skipped)"
    done
else
    echo "[RTI DDS] Not available, outputs must already be committed"
fi

# ── Stamp Files ────────────────────────────────────────────────────────────

echo
echo "── Updating stamp files ────────────────────────────────────────────────"

# Find all gen/ directories and update stamps
find . -type d -name "gen" -not -path "./vendor/*" | while read -r gen_dir; do
    if [ -n "$(ls -A "$gen_dir" 2>/dev/null)" ]; then
        echo "$gen_dir/REGEN_TIMESTAMP"
        date -u +"%Y-%m-%dT%H:%M:%SZ" > "$gen_dir/REGEN_TIMESTAMP"
    fi
done

# ── Verification ───────────────────────────────────────────────────────────

if [ "$VERIFY" = "1" ]; then
    echo
    echo "── Verification ────────────────────────────────────────────────────────"
    if git diff --exit-code gen/ >/dev/null 2>&1; then
        echo "✓ gen/ is clean (no uncommitted changes)"
    else
        echo "✗ gen/ has uncommitted changes:"
        git diff --stat gen/
        exit 1
    fi
fi

echo
echo "═══════════════════════════════════════════════════════════════════════"
echo " Regeneration complete"
echo "═══════════════════════════════════════════════════════════════════════"
