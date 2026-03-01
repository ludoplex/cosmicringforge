#!/bin/sh
# ══════════════════════════════════════════════════════════════════════════════
# livereload.sh - Hot-patch running processes in real-time
# ══════════════════════════════════════════════════════════════════════════════
#
# Part of cosmo-bde (uses e9studio)
#
# Usage:
#   ./scripts/livereload.sh <app_name> [source_file]
#   ./scripts/livereload.sh --demo
#   ./scripts/livereload.sh --help
#
# No sudo needed for processes you own (uses process_vm_writev on Linux)
#
# ══════════════════════════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
LIVERELOAD="$BUILD_DIR/livereload"

# Colors (if terminal supports them)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi

usage() {
    cat << EOF
${CYAN}Live Reload - Hot-patch running processes${NC}

Usage:
  $0 <app_name> [source_file]    Attach to running process
  $0 --pid <PID> [source_file]   Attach by PID
  $0 --demo                      Run demo (builds target, attaches)
  $0 --help                      Show this help

Examples:
  $0 app src/main.c       Attach to 'app', watch src/main.c
  $0 --pid 12345          Attach to PID 12345
  $0 --demo               Full demo with sample app

How it works:
  1. Watches source file for changes (stat-based polling)
  2. Recompiles changed functions
  3. Diffs old/new object files (via Binaryen)
  4. Patches running process memory (via process_vm_writev)
  5. Flushes instruction cache

${YELLOW}No sudo needed for processes you own!${NC}
EOF
}

ensure_built() {
    if [ ! -x "$LIVERELOAD" ]; then
        echo "${YELLOW}Building livereload tool...${NC}"
        cd "$PROJECT_ROOT"
        make tools regen e9studio
    fi
}

demo() {
    echo "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo "${CYAN}  Live Reload Demo${NC}"
    echo "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""

    ensure_built

    # Build demo target
    echo "${GREEN}1. Building application...${NC}"
    make app

    # Start app in background
    echo ""
    echo "${GREEN}2. Starting application in background...${NC}"
    "$BUILD_DIR/app" &
    APP_PID=$!
    sleep 0.5

    echo "   PID: $APP_PID"
    echo ""
    echo "${GREEN}3. Attaching live reload...${NC}"
    echo "   Edit src/main.c and save to see hot-patching!"
    echo ""
    echo "${YELLOW}Press Ctrl+C to stop${NC}"
    echo ""

    # Attach livereload
    "$LIVERELOAD" "$APP_PID" "$PROJECT_ROOT/src/main.c"

    # Cleanup
    kill "$APP_PID" 2>/dev/null || true
}

attach_by_name() {
    local app_name="$1"
    local source_file="${2:-}"

    ensure_built

    # Find PID
    local pid=$(pgrep -f "$app_name" | head -1)
    if [ -z "$pid" ]; then
        echo "${RED}Error: No process found matching '$app_name'${NC}" >&2
        echo "Start your application first, then run this script." >&2
        exit 1
    fi

    echo "${GREEN}Attaching to '$app_name' (PID: $pid)${NC}"

    if [ -n "$source_file" ]; then
        "$LIVERELOAD" "$pid" "$source_file"
    else
        "$LIVERELOAD" "$pid"
    fi
}

attach_by_pid() {
    local pid="$1"
    local source_file="${2:-}"

    ensure_built

    # Verify PID exists
    if ! kill -0 "$pid" 2>/dev/null; then
        echo "${RED}Error: Process $pid not found${NC}" >&2
        exit 1
    fi

    echo "${GREEN}Attaching to PID: $pid${NC}"

    if [ -n "$source_file" ]; then
        "$LIVERELOAD" "$pid" "$source_file"
    else
        "$LIVERELOAD" "$pid"
    fi
}

# ── Main ────────────────────────────────────────────────────────────────────

case "${1:-}" in
    --help|-h)
        usage
        exit 0
        ;;
    --demo)
        demo
        ;;
    --pid)
        if [ -z "${2:-}" ]; then
            echo "${RED}Error: --pid requires a PID argument${NC}" >&2
            exit 1
        fi
        attach_by_pid "$2" "${3:-}"
        ;;
    "")
        usage
        exit 1
        ;;
    *)
        attach_by_name "$1" "${2:-}"
        ;;
esac
