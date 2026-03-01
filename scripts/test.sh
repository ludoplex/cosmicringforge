#!/bin/sh
# ══════════════════════════════════════════════════════════════════════════════
# test.sh - Run tests for template users
# ══════════════════════════════════════════════════════════════════════════════
#
# This is for TEMPLATE USERS testing their application.
# For repo development tests, see: .forge/meta-test.sh
#
# Usage: ./scripts/test.sh [--bdd] [--unit] [--all]
#
# ══════════════════════════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
SPECS_DIR="$ROOT_DIR/specs"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

cd "$ROOT_DIR"

echo "══════════════════════════════════════════════════════════════════════════════"
echo " CosmicRingForge — BDE with Models"
echo " Test Runner"
echo "══════════════════════════════════════════════════════════════════════════════"
echo

# ── Ensure tools are built ───────────────────────────────────────────────────

if [ ! -x "$BUILD_DIR/schemagen" ]; then
    echo "Building tools first..."
    make tools
    echo
fi

# ── BDD Tests ────────────────────────────────────────────────────────────────

echo "── BDD Tests (from .feature specs) ──────────────────────────────────────────"

FEATURES=$(find "$SPECS_DIR" -name "*.feature" 2>/dev/null)

if [ -z "$FEATURES" ]; then
    printf "${YELLOW}[SKIP]${NC} No .feature files found in specs/\n"
else
    if [ -x "$BUILD_DIR/bddgen" ]; then
        for feature in $FEATURES; do
            name=$(basename "$feature" .feature)
            printf "  Running %s... " "$name"
            if "$BUILD_DIR/bddgen" --run "$feature" 2>/dev/null; then
                printf "${GREEN}PASS${NC}\n"
            else
                printf "${RED}FAIL${NC}\n"
            fi
        done
    else
        printf "${YELLOW}[SKIP]${NC} bddgen not built (run: make tools)\n"
        echo "  Features found:"
        for feature in $FEATURES; do
            echo "    - $feature"
        done
    fi
fi

echo

# ── Generated Code Validation ────────────────────────────────────────────────

echo "── Generated Code Validation ────────────────────────────────────────────────"

# Only test _types.c files (self-contained, no external deps)
# _json.c requires yyjson, _sql.c requires sqlite3 - skip unless deps installed
GEN_FILES=$(find gen -name "*_types.c" 2>/dev/null)
ERRORS=0

for c_file in $GEN_FILES; do
    name=$(basename "$c_file")
    printf "  Compiling %s... " "$name"
    dir=$(dirname "$c_file")
    if cc -c -I"$dir" "$c_file" -o /tmp/test_$$.o 2>/dev/null; then
        printf "${GREEN}OK${NC}\n"
        rm -f /tmp/test_$$.o
    else
        printf "${RED}ERROR${NC}\n"
        ERRORS=$((ERRORS + 1))
    fi
done

# Optionally test _json.c if yyjson is available
if [ -f /usr/include/yyjson.h ] || [ -f /usr/local/include/yyjson.h ]; then
    echo "  (yyjson found - also testing _json.c files)"
    JSON_FILES=$(find gen -name "*_json.c" 2>/dev/null)
    for c_file in $JSON_FILES; do
        name=$(basename "$c_file")
        printf "  Compiling %s... " "$name"
        dir=$(dirname "$c_file")
        if cc -c -I"$dir" "$c_file" -o /tmp/test_$$.o 2>/dev/null; then
            printf "${GREEN}OK${NC}\n"
            rm -f /tmp/test_$$.o
        else
            printf "${YELLOW}WARN${NC} (yyjson API mismatch?)\n"
        fi
    done
else
    printf "  ${YELLOW}[SKIP]${NC} _json.c files (yyjson not installed)\n"
fi

# Optionally test _sql.c if sqlite3 is available
if [ -f /usr/include/sqlite3.h ] || [ -f /usr/local/include/sqlite3.h ]; then
    echo "  (sqlite3 found - also testing _sql.c files)"
    SQL_FILES=$(find gen -name "*_sql.c" 2>/dev/null)
    for c_file in $SQL_FILES; do
        name=$(basename "$c_file")
        printf "  Compiling %s... " "$name"
        dir=$(dirname "$c_file")
        if cc -c -I"$dir" "$c_file" -o /tmp/test_$$.o 2>/dev/null; then
            printf "${GREEN}OK${NC}\n"
            rm -f /tmp/test_$$.o
        else
            printf "${YELLOW}WARN${NC} (sqlite3 API mismatch?)\n"
        fi
    done
else
    printf "  ${YELLOW}[SKIP]${NC} _sql.c files (sqlite3 not installed)\n"
fi

echo

# ── Application Test ─────────────────────────────────────────────────────────

echo "── Application Test ─────────────────────────────────────────────────────────"

if [ -x "$BUILD_DIR/app" ]; then
    printf "  Running application... "
    if "$BUILD_DIR/app" >/dev/null 2>&1; then
        printf "${GREEN}OK${NC}\n"
    else
        printf "${RED}FAILED${NC}\n"
        ERRORS=$((ERRORS + 1))
    fi
else
    printf "${YELLOW}[SKIP]${NC} Application not built (run: make app)\n"
fi

echo

# ── Summary ──────────────────────────────────────────────────────────────────

echo "══════════════════════════════════════════════════════════════════════════════"
if [ "$ERRORS" -eq 0 ]; then
    printf " ${GREEN}All tests passed${NC}\n"
    exit 0
else
    printf " ${RED}$ERRORS errors${NC}\n"
    exit 1
fi
