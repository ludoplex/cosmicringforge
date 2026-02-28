#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════════
# verify-tools.sh - Verify all tools are available and working
# ═══════════════════════════════════════════════════════════════════════════
#
# Checks each ring's tools and reports status.
# Use this to verify a system is ready for mbse-stacks development.
#
# Exit codes:
#   0 - All Ring 0 tools present (minimum viable)
#   1 - Missing Ring 0 tools (cannot build)
#
# ═══════════════════════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi

RING0_OK=1
RING1_OK=1
RING2_OK=1

check() {
    local name="$1"
    local cmd="$2"
    local ring="$3"

    if command -v "$cmd" >/dev/null 2>&1; then
        printf "  ${GREEN}✓${NC} %-20s %s\n" "$name" "$(command -v "$cmd")"
        return 0
    elif [ -x "$ROOT_DIR/$cmd" ]; then
        printf "  ${GREEN}✓${NC} %-20s %s\n" "$name" "$ROOT_DIR/$cmd"
        return 0
    else
        printf "  ${RED}✗${NC} %-20s (not found)\n" "$name"
        return 1
    fi
}

check_lib() {
    local name="$1"
    local path="$2"

    if [ -d "$ROOT_DIR/$path" ]; then
        printf "  ${GREEN}✓${NC} %-20s %s\n" "$name" "$path"
        return 0
    else
        printf "  ${YELLOW}○${NC} %-20s (not vendored)\n" "$name"
        return 1
    fi
}

echo "═══════════════════════════════════════════════════════════════════════"
echo " MBSE Stacks - Tool Verification"
echo "═══════════════════════════════════════════════════════════════════════"

# ── Ring 0: Bootstrap ──────────────────────────────────────────────────────

echo
printf "${CYAN}Ring 0: Bootstrap (C + sh + make)${NC}\n"
echo "─────────────────────────────────────────────────────────────────────────"

echo "System tools:"
check "C Compiler" "cc" 0 || check "C Compiler" "gcc" 0 || check "C Compiler" "clang" 0 || RING0_OK=0
check "Make" "make" 0 || RING0_OK=0
check "Shell" "sh" 0 || RING0_OK=0

echo
echo "In-tree generators:"
check "schemagen" "strict-purist/gen/schemagen" 0 || echo "    (will be built)"
check "smgen" "strict-purist/gen/smgen" 0 || echo "    (will be built)"
check "lexgen" "strict-purist/gen/lexgen" 0 || echo "    (will be built)"
check "bin2c" "strict-purist/vendor/bin2c/bin2c" 0 || echo "    (will be built)"

echo
echo "Vendored libraries:"
check_lib "SQLite" "strict-purist/vendor/sqlite"
check_lib "Lemon" "strict-purist/vendor/lemon"
check_lib "Nuklear" "strict-purist/vendor/nuklear"
check_lib "yyjson" "strict-purist/vendor/yyjson"
check_lib "CivetWeb" "strict-purist/vendor/civetweb"
check_lib "CLIPS" "strict-purist/vendor/clips"
check_lib "Cosmopolitan" "strict-purist/vendor/cosmopolitan"
check_lib "e9patch" "strict-purist/vendor/e9patch"
check_lib "kilo" "strict-purist/vendor/kilo"

echo
echo "APE toolchain:"
check "cosmocc" "cosmocc" 0 || echo "    (APE builds unavailable)"

# ── Ring 1: Velocity ───────────────────────────────────────────────────────

echo
printf "${CYAN}Ring 1: Velocity Tools (optional)${NC}\n"
echo "─────────────────────────────────────────────────────────────────────────"

check "gengetopt" "gengetopt" 1 || RING1_OK=0
check "makeheaders" "makeheaders" 1 || true
check "cppcheck" "cppcheck" 1 || RING1_OK=0
check "valgrind" "valgrind" 1 || true

echo
echo "Compiler sanitizers:"
if cc -fsanitize=address -x c -c /dev/null -o /dev/null 2>/dev/null; then
    printf "  ${GREEN}✓${NC} AddressSanitizer\n"
else
    printf "  ${YELLOW}○${NC} AddressSanitizer (not supported)\n"
fi
if cc -fsanitize=undefined -x c -c /dev/null -o /dev/null 2>/dev/null; then
    printf "  ${GREEN}✓${NC} UBSan\n"
else
    printf "  ${YELLOW}○${NC} UBSan (not supported)\n"
fi

# ── Ring 2: Authoring ──────────────────────────────────────────────────────

echo
printf "${CYAN}Ring 2: Authoring Appliances${NC}\n"
echo "─────────────────────────────────────────────────────────────────────────"

echo "State machine generators:"
check "StateSmith" "StateSmith.Cli" 2 || true
check ".NET SDK" "dotnet" 2 || RING2_OK=0

echo
echo "Schema generators:"
check "protoc" "protoc" 2 || true
check "protoc-gen-c" "protoc-gen-c" 2 || true

echo
echo "UI/Visual tools:"
check "EEZ Studio" "eez-studio" 2 || true
check "Node.js" "node" 2 || true

echo
echo "Modeling/Simulation:"
check "OpenModelica" "omc" 2 || true

echo
echo "WASM tools:"
check "Binaryen" "wasm-opt" 2 || true
check_lib "ludoplex-binaryen" "upstream/ludoplex-binaryen"
check_lib "WAMR" "upstream/e9studio/src/e9patch/vendor/wamr"

echo
echo "Vendored Ring-2 tools:"
check_lib "StateSmith" "foss-visual/vendor/StateSmith"
check_lib "protobuf-c" "foss-visual/vendor/protobuf-c"
check_lib "EEZ Studio" "foss-visual/vendor/eez-studio"
check_lib "LVGL" "foss-visual/vendor/lvgl"
check_lib "OpenModelica" "foss-visual/vendor/openmodelica"

# ── Upstream Components ────────────────────────────────────────────────────

echo
printf "${CYAN}Upstream Components${NC}\n"
echo "─────────────────────────────────────────────────────────────────────────"

check_lib "e9studio" "upstream/e9studio"
check_lib "cosmo-sokol" "upstream/cosmo-sokol"
check_lib "cosmo-bsd" "upstream/cosmo-bsd"
check_lib "cosmogfx" "upstream/cosmogfx"
check_lib "tedit-cosmo" "upstream/tedit-cosmo"
check_lib "cosmo-include" "upstream/cosmo-include"
check_lib "cosmo-cross-sdk" "upstream/cosmo-cross-sdk"
check_lib "cosmo-disasm" "upstream/cosmo-disasm"
check_lib "cosmo-gcc-plugin" "upstream/cosmo-gcc-plugin"
check_lib "awesome-cosmo" "upstream/awesome-cosmo"
check_lib "ludoplex-binaryen" "upstream/ludoplex-binaryen"
check_lib "ludoplex-cosmo-bsd" "upstream/ludoplex-cosmo-bsd"

# ── Summary ────────────────────────────────────────────────────────────────

echo
echo "═══════════════════════════════════════════════════════════════════════"
echo " Summary"
echo "═══════════════════════════════════════════════════════════════════════"

if [ "$RING0_OK" = "1" ]; then
    printf "${GREEN}Ring 0: READY${NC} - Bootstrap build possible\n"
else
    printf "${RED}Ring 0: MISSING${NC} - Cannot build without C compiler, make, sh\n"
fi

if [ "$RING1_OK" = "1" ]; then
    printf "${GREEN}Ring 1: AVAILABLE${NC} - Enhanced development experience\n"
else
    printf "${YELLOW}Ring 1: PARTIAL${NC} - Some velocity tools missing (optional)\n"
fi

if [ "$RING2_OK" = "1" ]; then
    printf "${GREEN}Ring 2: AVAILABLE${NC} - Full authoring capability\n"
else
    printf "${YELLOW}Ring 2: PARTIAL${NC} - Some authoring tools missing\n"
    echo "  Note: Ring 2 tool outputs are committed; tools only needed for regeneration"
fi

echo
if [ "$RING0_OK" = "1" ]; then
    echo "System is ready for mbse-stacks development."
    exit 0
else
    echo "Install missing Ring 0 tools before proceeding."
    exit 1
fi
