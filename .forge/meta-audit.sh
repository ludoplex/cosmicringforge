#!/bin/sh
# ══════════════════════════════════════════════════════════════════════════════
# meta-audit.sh - Audit format coverage and find gaps
# ══════════════════════════════════════════════════════════════════════════════
#
# Compares declared formats in INTEROP_MATRIX.md against actual coverage.
# Identifies which generators are implemented vs planned.
#
# ══════════════════════════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

echo "══════════════════════════════════════════════════════════════════════════════"
echo " Format Coverage Audit"
echo "══════════════════════════════════════════════════════════════════════════════"
echo

# ── Ring 0 Generators ────────────────────────────────────────────────────────

echo "── Ring 0 Generators (In-Tree) ──────────────────────────────────────────────"
echo

printf "%-15s %-12s %-40s\n" "Format" "Generator" "Status"
printf "%-15s %-12s %-40s\n" "───────" "─────────" "──────"

check_generator() {
    format=$1
    gen=$2
    source="tools/${gen}.c"

    if [ -f "$source" ]; then
        if [ -x "build/$gen" ] 2>/dev/null; then
            status="✓ Implemented + Built"
        else
            status="✓ Implemented (run make)"
        fi
    else
        status="○ Planned"
    fi
    printf "%-15s %-12s %-40s\n" "$format" "$gen" "$status"
}

check_generator ".schema" "schemagen"
check_generator ".def" "defgen"
check_generator ".impl" "implgen"
check_generator ".sm" "smgen"
check_generator ".hsm" "hsmgen"
check_generator ".msm" "msmgen"
check_generator ".lex" "lexgen"
check_generator ".grammar" "lemon"
check_generator ".feature" "bddgen"
check_generator ".rules" "rulesgen"
check_generator ".api" "apigen"
check_generator ".ui" "uigen"
check_generator ".ggo" "gengetopt"
check_generator ".com" "comgen"
check_generator ".cfg" "cfggen"
check_generator ".tbl" "tblgen"

echo

# ── Ring 2 Tool Detection ────────────────────────────────────────────────────

echo "── Ring 2 Tools (External, Auto-Detected) ───────────────────────────────────"
echo

printf "%-20s %-15s %-30s\n" "Tool" "Command" "Status"
printf "%-20s %-15s %-30s\n" "────" "───────" "──────"

check_tool() {
    name=$1
    cmd=$2
    format=$3

    if command -v "$cmd" >/dev/null 2>&1; then
        status="✓ Available"
    else
        status="○ Not installed"
    fi
    printf "%-20s %-15s %-30s\n" "$name ($format)" "$cmd" "$status"
}

check_tool "StateSmith" "dotnet" ".drawio"
check_tool "protobuf-c" "protoc" ".proto"
check_tool "flatcc" "flatcc" ".fbs"
check_tool "OpenModelica" "omc" ".mo"
check_tool "DDS/Cyclone" "idlc" ".idl"
check_tool "MATLAB" "matlab" ".slx"
check_tool "Rhapsody" "rhapsodycl" ".emx"
check_tool "Qt" "qmake" ".qml"
check_tool "cosmocc" "cosmocc" "APE"

echo

# ── Spec Coverage ────────────────────────────────────────────────────────────

echo "── Spec File Coverage ───────────────────────────────────────────────────────"
echo

for layer in domain behavior interface parsing testing persistence serialization; do
    if [ -d "specs/$layer" ]; then
        count=$(find "specs/$layer" -type f 2>/dev/null | wc -l)
        printf "specs/%-15s %3d files\n" "$layer/" "$count"
    else
        printf "specs/%-15s (not created)\n" "$layer/"
    fi
done

echo

# ── Generated Output Coverage ────────────────────────────────────────────────

echo "── Generated Output Coverage ────────────────────────────────────────────────"
echo

for layer in domain behavior interface parsing testing imported; do
    if [ -d "gen/$layer" ]; then
        count=$(find "gen/$layer" -name "*.c" -o -name "*.h" 2>/dev/null | wc -l)
        printf "gen/%-15s %3d files\n" "$layer/" "$count"
    else
        printf "gen/%-15s (empty)\n" "$layer/"
    fi
done

echo

# ── Summary ──────────────────────────────────────────────────────────────────

echo "══════════════════════════════════════════════════════════════════════════════"
echo " Summary"
echo "══════════════════════════════════════════════════════════════════════════════"

implemented=$(find tools -name "*.c" -type f 2>/dev/null | wc -l)
specs=$(find specs -type f 2>/dev/null | wc -l)
generated=$(find gen -name "*.c" -o -name "*.h" 2>/dev/null | wc -l)

echo
echo "  Ring 0 generators:  $implemented implemented"
echo "  Spec files:         $specs"
echo "  Generated files:    $generated"
echo
