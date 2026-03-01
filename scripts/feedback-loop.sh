#!/bin/sh
# ══════════════════════════════════════════════════════════════════════════════
# feedback-loop.sh - Tight Development Loop with Live Reload
# ══════════════════════════════════════════════════════════════════════════════
#
# Ring 0→1→2 Composability with instant feedback:
#
#   Ring 0: Edit spec → regen → types/X-macros generated
#   Ring 1: makeheaders → auto-generate headers from .c
#   Ring 2: External tools (if available) → committed outputs
#   Live:   livereload patches running process → instant feedback
#
# Usage:
#   ./scripts/feedback-loop.sh          # Full loop with demo app
#   ./scripts/feedback-loop.sh --specs  # Watch specs only (no app)
#   ./scripts/feedback-loop.sh --help
#
# ══════════════════════════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

usage() {
    cat << EOF
${CYAN}Feedback Loop - Ring 0→1→2 Composability with Live Reload${NC}

Usage:
  $0              Full loop: regen + build + livereload
  $0 --specs      Watch specs only, regen on change
  $0 --app        Watch app sources, livereload on change
  $0 --help       Show this help

Workflow:
  ${GREEN}Ring 0:${NC} specs/*.schema → schemagen → gen/*_types.h
          specs/*.def → X-macros (direct #include)
          specs/*.sm → smgen → gen/*_sm.c

  ${YELLOW}Ring 1:${NC} src/*.c → makeheaders → auto-headers (optional)
          Build with sanitizers for runtime checks

  ${CYAN}Ring 2:${NC} model/*.drawio → StateSmith → gen/imported/*
          (outputs committed, builds work without Ring 2 tools)

  ${RED}Live:${NC}   livereload → patches running process instantly
          Edit src/*.c, save, see changes immediately!

Example:
  Terminal 1: make run
  Terminal 2: $0 --app
  Terminal 3: vim src/main.c  # Edit and save - instant feedback!
EOF
}

ensure_tools() {
    echo "${CYAN}Building Ring 0 tools...${NC}"
    make -C "$ROOT_DIR" tools >/dev/null 2>&1

    echo "${GREEN}Ring 0 tools ready:${NC}"
    ls -1 "$BUILD_DIR"/schemagen "$BUILD_DIR"/defgen "$BUILD_DIR"/smgen 2>/dev/null | while read f; do
        echo "  $(basename $f)"
    done

    # Ring 1 tools (optional)
    if [ -x "$BUILD_DIR/makeheaders" ]; then
        echo "${YELLOW}Ring 1 tools:${NC}"
        echo "  makeheaders"
    fi
}

regen_all() {
    echo "${CYAN}Regenerating from specs...${NC}"
    make -C "$ROOT_DIR" regen 2>&1 | grep -E "^\[|→" | head -20
}

build_all() {
    echo "${CYAN}Building...${NC}"
    make -C "$ROOT_DIR" all e9studio 2>&1 | tail -5
}

watch_specs() {
    echo "${CYAN}Watching specs/ for changes...${NC}"
    echo "Edit .schema, .def, .sm files - will auto-regen"
    echo ""

    LAST_HASH=""
    while true; do
        HASH=$(find "$ROOT_DIR/specs" -type f \( -name "*.schema" -o -name "*.def" -o -name "*.sm" \) -exec md5sum {} \; 2>/dev/null | md5sum)

        if [ "$HASH" != "$LAST_HASH" ] && [ -n "$LAST_HASH" ]; then
            echo ""
            echo "${GREEN}Specs changed - regenerating...${NC}"
            regen_all
            build_all
            echo "${GREEN}Done. Waiting for changes...${NC}"
        fi

        LAST_HASH="$HASH"
        sleep 1
    done
}

watch_app() {
    echo "${CYAN}Attaching livereload to running app...${NC}"

    # Find running app
    PID=$(pgrep -f "$BUILD_DIR/app" | head -1)

    if [ -z "$PID" ]; then
        echo "${RED}No app running. Start with: make run${NC}"
        echo ""
        echo "Starting app in background..."
        "$BUILD_DIR/app" &
        sleep 1
        PID=$!
        echo "App started (PID: $PID)"
    fi

    echo "${GREEN}Livereload attached to PID $PID${NC}"
    echo "Edit src/*.c and save - changes appear instantly!"
    echo ""

    "$BUILD_DIR/livereload" "$PID" "$ROOT_DIR/src/main.c"
}

full_loop() {
    echo "═══════════════════════════════════════════════════════════════════════"
    echo "${CYAN}cosmo-bde — Feedback Loop${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    echo ""

    ensure_tools
    echo ""

    regen_all
    echo ""

    build_all
    echo ""

    echo "${GREEN}Ready for live development!${NC}"
    echo ""
    echo "Options:"
    echo "  1. ${CYAN}make run${NC}                    Start app"
    echo "  2. ${CYAN}./scripts/feedback-loop.sh --app${NC}  Attach livereload"
    echo "  3. Edit src/*.c              Changes appear instantly"
    echo ""
    echo "Or watch specs:"
    echo "  ${CYAN}./scripts/feedback-loop.sh --specs${NC}"
}

# ── Main ────────────────────────────────────────────────────────────────────

cd "$ROOT_DIR"

case "${1:-}" in
    --help|-h)
        usage
        exit 0
        ;;
    --specs)
        ensure_tools
        watch_specs
        ;;
    --app)
        watch_app
        ;;
    *)
        full_loop
        ;;
esac
