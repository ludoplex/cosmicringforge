#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════════
# regen-all.sh - Regenerate all generated code from specs
# ═══════════════════════════════════════════════════════════════════════════
#
# This script orchestrates ALL generators across ALL rings.
# Run before commit to ensure gen/ is up to date.
#
# Usage: ./scripts/regen-all.sh [--verify]
#   --verify: Also run git diff --exit-code after regeneration
#
# ═══════════════════════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VERIFY=0

if [ "$1" = "--verify" ]; then
    VERIFY=1
fi

cd "$ROOT_DIR"

echo "═══════════════════════════════════════════════════════════════════════"
echo " MBSE Stacks - Regenerate All"
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

# ── Ring 2 Generators ──────────────────────────────────────────────────────

echo
echo "── Ring 2: External toolchain generators ───────────────────────────────"

# StateSmith (.NET)
if command -v StateSmith.Cli >/dev/null 2>&1 || command -v dotnet >/dev/null 2>&1; then
    echo "[StateSmith] Processing *.drawio state machines..."
    find . -name "*.drawio" -path "*/specs/*" | while read -r spec; do
        dir="$(dirname "$spec")"
        gen_dir="$dir/../gen/statesmith"
        mkdir -p "$gen_dir"
        echo "  $spec → $gen_dir/"
        # StateSmith.Cli run "$spec" 2>/dev/null || echo "  (skipped)"
        echo "  (StateSmith invocation placeholder)"
    done
else
    echo "[StateSmith] .NET not available, skipping"
fi

# protobuf-c
if command -v protoc >/dev/null 2>&1 && command -v protoc-gen-c >/dev/null 2>&1; then
    echo "[protobuf-c] Processing *.proto files..."
    find . -name "*.proto" -not -path "./vendor/*" | while read -r spec; do
        dir="$(dirname "$spec")"
        gen_dir="$dir/../gen/proto"
        mkdir -p "$gen_dir"
        echo "  $spec → $gen_dir/"
        protoc --c_out="$gen_dir" "$spec" 2>/dev/null || echo "  (skipped)"
    done
else
    echo "[protobuf-c] Not available, skipping"
fi

# EEZ Studio
if command -v eez-studio-build >/dev/null 2>&1; then
    echo "[EEZ Studio] Processing *.eez-project files..."
    find . -name "*.eez-project" | while read -r spec; do
        dir="$(dirname "$spec")"
        gen_dir="$dir/../gen/eez"
        mkdir -p "$gen_dir"
        echo "  $spec → $gen_dir/"
        # eez-studio-build "$spec" -o "$gen_dir" 2>/dev/null || echo "  (skipped)"
        echo "  (EEZ invocation placeholder)"
    done
else
    echo "[EEZ Studio] Not available, skipping"
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
