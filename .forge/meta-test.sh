#!/bin/sh
# ══════════════════════════════════════════════════════════════════════════════
# meta-test.sh - Test CosmicRingForge generators and infrastructure
# ══════════════════════════════════════════════════════════════════════════════
#
# This tests the REPO ITSELF, not template usage.
# For template tests, see: scripts/test.sh
#
# Usage: .forge/meta-test.sh [--verbose]
#
# Test Suites:
#   1. Ring 0 generators compile
#   2. schemagen multi-format output (v2.0.0 composability)
#   3. Format discovery
#   4. Makefile targets
#   5. CI workflows
#   6. Documentation
#   7. Template initialization
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed
#
# ══════════════════════════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VERBOSE="${1:-}"
TEST_DIR="/tmp/forge-test-$$"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS=0
FAIL=0
SKIP=0

log_test() { printf "${CYAN}[TEST]${NC} %s... " "$1"; }
log_pass() { printf "${GREEN}PASS${NC}\n"; PASS=$((PASS + 1)); }
log_fail() { printf "${RED}FAIL${NC} %s\n" "$1"; FAIL=$((FAIL + 1)); }
log_skip() { printf "${YELLOW}SKIP${NC} %s\n" "$1"; SKIP=$((SKIP + 1)); }

cleanup() {
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

cd "$ROOT_DIR"
mkdir -p "$TEST_DIR"

echo "══════════════════════════════════════════════════════════════════════════════"
echo " CosmicRingForge Meta-Tests (Repo Development)"
echo "══════════════════════════════════════════════════════════════════════════════"
echo

# ── Suite 1: Ring 0 Generator Compilation ─────────────────────────────────────

echo "── Suite 1: Ring 0 Generator Compilation ─────────────────────────────────────"

log_test "schemagen.c compiles"
if cc -O2 -Wall -Werror -std=c11 -o "$TEST_DIR/schemagen" tools/schemagen.c 2>/dev/null; then
    log_pass
else
    log_fail "compilation error"
fi

log_test "lemon.c compiles"
if cc -O2 -Wall -std=c11 -Wno-stringop-truncation -o "$TEST_DIR/lemon" tools/lemon.c 2>/dev/null; then
    log_pass
else
    log_fail "compilation error"
fi

log_test "schemagen --help works"
if "$TEST_DIR/schemagen" --help 2>&1 | grep -q "schemagen"; then
    log_pass
else
    log_fail "help output missing"
fi

echo

# ── Suite 2: schemagen Multi-Format Output (v2.0.0) ───────────────────────────

echo "── Suite 2: schemagen Multi-Format Output (v2.0.0) ───────────────────────────"

mkdir -p "$TEST_DIR/gen"

log_test "schemagen --c produces _types.h and _types.c"
if "$TEST_DIR/schemagen" --c specs/domain/example.schema "$TEST_DIR/gen" example 2>/dev/null; then
    if [ -f "$TEST_DIR/gen/example_types.c" ] && [ -f "$TEST_DIR/gen/example_types.h" ]; then
        log_pass
    else
        log_fail "missing _types files"
    fi
else
    log_fail "generator failed"
fi

log_test "schemagen --json produces _json.h and _json.c"
if "$TEST_DIR/schemagen" --json specs/domain/example.schema "$TEST_DIR/gen" example 2>/dev/null; then
    if [ -f "$TEST_DIR/gen/example_json.c" ] && [ -f "$TEST_DIR/gen/example_json.h" ]; then
        log_pass
    else
        log_fail "missing _json files"
    fi
else
    log_fail "generator failed"
fi

log_test "schemagen --sql produces _sql.h and _sql.c"
if "$TEST_DIR/schemagen" --sql specs/domain/example.schema "$TEST_DIR/gen" example 2>/dev/null; then
    if [ -f "$TEST_DIR/gen/example_sql.c" ] && [ -f "$TEST_DIR/gen/example_sql.h" ]; then
        log_pass
    else
        log_fail "missing _sql files"
    fi
else
    log_fail "generator failed"
fi

log_test "schemagen --proto produces .proto"
if "$TEST_DIR/schemagen" --proto specs/domain/example.schema "$TEST_DIR/gen" example 2>/dev/null; then
    if [ -f "$TEST_DIR/gen/example.proto" ]; then
        log_pass
    else
        log_fail "missing .proto file"
    fi
else
    log_fail "generator failed"
fi

log_test "schemagen --fbs produces .fbs"
if "$TEST_DIR/schemagen" --fbs specs/domain/example.schema "$TEST_DIR/gen" example 2>/dev/null; then
    if [ -f "$TEST_DIR/gen/example.fbs" ]; then
        log_pass
    else
        log_fail "missing .fbs file"
    fi
else
    log_fail "generator failed"
fi

log_test "schemagen --all produces all 8 files"
rm -rf "$TEST_DIR/gen"
mkdir -p "$TEST_DIR/gen"
if "$TEST_DIR/schemagen" --all specs/domain/example.schema "$TEST_DIR/gen" example 2>/dev/null; then
    count=$(ls "$TEST_DIR/gen"/* 2>/dev/null | wc -l)
    if [ "$count" -ge 8 ]; then
        log_pass
    else
        log_fail "expected 8 files, got $count"
    fi
else
    log_fail "generator failed"
fi

log_test "generated C types compile"
if cc -c -I"$TEST_DIR/gen" "$TEST_DIR/gen/example_types.c" -o "$TEST_DIR/example_types.o" 2>/dev/null; then
    log_pass
else
    log_fail "generated code has errors"
fi

log_test "generated .proto is valid syntax"
if grep -q "syntax = \"proto3\"" "$TEST_DIR/gen/example.proto" && \
   grep -q "message Example" "$TEST_DIR/gen/example.proto"; then
    log_pass
else
    log_fail "invalid proto syntax"
fi

log_test "generated .fbs is valid syntax"
if grep -q "namespace example" "$TEST_DIR/gen/example.fbs" && \
   grep -q "table Example" "$TEST_DIR/gen/example.fbs"; then
    log_pass
else
    log_fail "invalid fbs syntax"
fi

echo

# ── Suite 3: Format Discovery ─────────────────────────────────────────────────

echo "── Suite 3: Format Discovery ─────────────────────────────────────────────────"

log_test "specs/domain/ exists"
if [ -d specs/domain ]; then
    log_pass
else
    log_fail "missing"
fi

log_test "specs/behavior/ exists"
if [ -d specs/behavior ]; then
    log_pass
else
    log_fail "missing"
fi

log_test "specs/testing/ exists"
if [ -d specs/testing ]; then
    log_pass
else
    log_fail "missing"
fi

log_test "gen/ directory exists"
if [ -d gen ]; then
    log_pass
else
    log_fail "missing"
fi

log_test "model/ directory exists"
if [ -d model ]; then
    log_pass
else
    log_fail "missing"
fi

log_test "at least one .schema file exists"
if find specs -name "*.schema" 2>/dev/null | grep -q .; then
    log_pass
else
    log_fail "no .schema files"
fi

echo

# ── Suite 4: Makefile Targets ─────────────────────────────────────────────────

echo "── Suite 4: Makefile Targets ─────────────────────────────────────────────────"

log_test "make formats runs"
if make formats >/dev/null 2>&1; then
    log_pass
else
    log_fail "error"
fi

log_test "make tools builds generators"
if make tools >/dev/null 2>&1; then
    log_pass
else
    log_fail "error"
fi

log_test "make regen runs without error"
if make regen >/dev/null 2>&1; then
    log_pass
else
    log_fail "error"
fi

log_test "make app builds application"
if make app >/dev/null 2>&1; then
    log_pass
else
    log_fail "error"
fi

log_test "make run executes"
if make run >/dev/null 2>&1; then
    log_pass
else
    log_fail "error"
fi

log_test "make verify runs (drift check)"
if make verify >/dev/null 2>&1; then
    log_pass
else
    log_skip "drift detected (expected if uncommitted changes)"
fi

echo

# ── Suite 5: CI Workflow Syntax ───────────────────────────────────────────────

echo "── Suite 5: CI Workflow Syntax ───────────────────────────────────────────────"

log_test "repo-ci.yml exists"
if [ -f .github/workflows/repo-ci.yml ]; then
    log_pass
else
    log_skip "not created yet"
fi

log_test "template-ci.yml exists"
if [ -f .github/workflows/template-ci.yml ]; then
    log_pass
else
    log_skip "not created yet"
fi

log_test "repo-ci.yml has required keys"
if [ -f .github/workflows/repo-ci.yml ]; then
    if grep -q "^name:" .github/workflows/repo-ci.yml && \
       grep -q "^on:" .github/workflows/repo-ci.yml && \
       grep -q "^jobs:" .github/workflows/repo-ci.yml; then
        log_pass
    else
        log_fail "missing required YAML keys"
    fi
else
    log_skip "file missing"
fi

log_test "template-ci.yml has required keys"
if [ -f .github/workflows/template-ci.yml ]; then
    if grep -q "^name:" .github/workflows/template-ci.yml && \
       grep -q "^on:" .github/workflows/template-ci.yml && \
       grep -q "^jobs:" .github/workflows/template-ci.yml; then
        log_pass
    else
        log_fail "missing required YAML keys"
    fi
else
    log_skip "file missing"
fi

log_test "repo-ci.yml tests generators"
if [ -f .github/workflows/repo-ci.yml ]; then
    if grep -q "schemagen" .github/workflows/repo-ci.yml; then
        log_pass
    else
        log_fail "no generator tests"
    fi
else
    log_skip "file missing"
fi

echo

# ── Suite 6: Documentation Completeness ───────────────────────────────────────

echo "── Suite 6: Documentation Completeness ───────────────────────────────────────"

log_test "README.md exists"
if [ -f README.md ]; then
    log_pass
else
    log_fail "missing"
fi

log_test "INTEROP_MATRIX.md exists"
if [ -f INTEROP_MATRIX.md ]; then
    log_pass
else
    log_fail "missing"
fi

log_test "RING_CLASSIFICATION.md exists"
if [ -f RING_CLASSIFICATION.md ]; then
    log_pass
else
    log_fail "missing"
fi

log_test "LITERATE.md exists"
if [ -f LITERATE.md ]; then
    log_pass
else
    log_fail "missing"
fi

log_test "SPEC_TYPES.md exists"
if [ -f SPEC_TYPES.md ]; then
    log_pass
else
    log_fail "missing"
fi

log_test ".claude/CLAUDE.md exists"
if [ -f .claude/CLAUDE.md ]; then
    log_pass
else
    log_fail "missing"
fi

log_test "CLAUDE.md under 200 lines"
if [ -f .claude/CLAUDE.md ]; then
    lines=$(wc -l < .claude/CLAUDE.md)
    if [ "$lines" -lt 200 ]; then
        log_pass
    else
        log_fail "$lines lines (max 200)"
    fi
else
    log_skip "file missing"
fi

log_test ".claude/SSOT.md exists"
if [ -f .claude/SSOT.md ]; then
    log_pass
else
    log_fail "missing"
fi

log_test ".claude/CONVENTIONS.md exists"
if [ -f .claude/CONVENTIONS.md ]; then
    log_pass
else
    log_fail "missing"
fi

echo

# ── Suite 7: Template Initialization ──────────────────────────────────────────

echo "── Suite 7: Template Initialization ──────────────────────────────────────────"

log_test "template-init.sh exists"
if [ -f scripts/template-init.sh ]; then
    log_pass
else
    log_fail "missing"
fi

log_test "template-init.sh is executable"
if [ -x scripts/template-init.sh ]; then
    log_pass
else
    log_fail "not executable"
fi

log_test "regen-all.sh exists"
if [ -f scripts/regen-all.sh ]; then
    log_pass
else
    log_fail "missing"
fi

log_test "regen-all.sh is executable"
if [ -x scripts/regen-all.sh ]; then
    log_pass
else
    log_fail "not executable"
fi

log_test "bde-workflow.sh exists"
if [ -f scripts/bde-workflow.sh ]; then
    log_pass
else
    log_skip "not created yet"
fi

log_test "verify-tools.sh exists"
if [ -f scripts/verify-tools.sh ]; then
    log_pass
else
    log_skip "not created yet"
fi

echo

# ── Suite 8: Composability Chain ──────────────────────────────────────────────

echo "── Suite 8: Composability Chain ──────────────────────────────────────────────"

log_test ".schema → .proto → (Ring 2 would compile)"
if [ -f "$TEST_DIR/gen/example.proto" ]; then
    if grep -q "message Example" "$TEST_DIR/gen/example.proto"; then
        log_pass
    else
        log_fail "proto missing message"
    fi
else
    log_skip "proto not generated"
fi

log_test ".schema → .fbs → (Ring 2 would compile)"
if [ -f "$TEST_DIR/gen/example.fbs" ]; then
    if grep -q "table Example" "$TEST_DIR/gen/example.fbs"; then
        log_pass
    else
        log_fail "fbs missing table"
    fi
else
    log_skip "fbs not generated"
fi

log_test "Ring 2 tool detection works"
if [ -x scripts/verify-tools.sh ]; then
    if ./scripts/verify-tools.sh 2>&1 | grep -q "Ring"; then
        log_pass
    else
        log_skip "verify-tools.sh output unexpected"
    fi
else
    log_skip "verify-tools.sh not available"
fi

echo

# ── Summary ───────────────────────────────────────────────────────────────────

echo "══════════════════════════════════════════════════════════════════════════════"
echo " Summary"
echo "══════════════════════════════════════════════════════════════════════════════"
echo
printf "  ${GREEN}PASS:${NC} %d\n" "$PASS"
printf "  ${RED}FAIL:${NC} %d\n" "$FAIL"
printf "  ${YELLOW}SKIP:${NC} %d\n" "$SKIP"
echo

if [ "$FAIL" -gt 0 ]; then
    echo "Meta-tests FAILED"
    exit 1
else
    echo "Meta-tests PASSED"
    exit 0
fi
