#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════════
# verify.sh — Verify generated code matches committed code
# ═══════════════════════════════════════════════════════════════════════════
#
# Usage: ./scripts/verify.sh [PROFILE]
#   PROFILE: portable (default), commercial
#
# This script regenerates all code and verifies no drift exists.
# Used in CI/CD and pre-commit hooks.
#
# Exit codes:
#   0 - No drift, all generated code matches
#   1 - Drift detected
#   2 - Generation failed
# ═══════════════════════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROFILE="${1:-portable}"

echo "═══════════════════════════════════════════════════════════════════════"
echo " Drift Verification (Profile: $PROFILE)"
echo "═══════════════════════════════════════════════════════════════════════"

# Run regeneration
"$SCRIPT_DIR/regen-all.sh" "$PROFILE"

echo
echo "── Checking for drift ─────────────────────────────────────────────────"

# Check gen/ directory (exclude timestamp files from semantic drift check)
if git diff --quiet -- gen/ ':(exclude)gen/**/GENERATOR_VERSION' ':(exclude)gen/*/GENERATOR_VERSION' ':(exclude)gen/REGEN_TIMESTAMP' 2>/dev/null; then
    echo "[OK]    gen/ is clean (semantic check)"
else
    echo "[FAIL]  Drift detected in gen/"
    git diff --stat -- gen/ ':(exclude)gen/**/GENERATOR_VERSION' ':(exclude)gen/*/GENERATOR_VERSION' ':(exclude)gen/REGEN_TIMESTAMP'
    echo
    echo "Ring 2 outputs MUST be committed. Run:"
    echo "  git add gen/"
    echo "  git commit -m 'regen: update generated code'"
    exit 1
fi

# Check Ring 2 imports specifically
if [ -d gen/imported ]; then
    if git diff --quiet gen/imported/ 2>/dev/null; then
        echo "[OK]    gen/imported/ is clean"
    else
        echo "[FAIL]  Ring 2 imports have drift"
        echo "These MUST be committed (Ring 2 tools may not be available at build time)"
        exit 1
    fi
fi

# Check generator version stamps
STAMP_DRIFT=0
for stamp in gen/**/GENERATOR_VERSION gen/*/GENERATOR_VERSION; do
    [ -f "$stamp" ] || continue
    if ! git diff --quiet "$stamp" 2>/dev/null; then
        echo "[WARN]  Generator version changed: $stamp"
        STAMP_DRIFT=1
    fi
done

if [ "$STAMP_DRIFT" = "1" ]; then
    echo "[INFO]  Generator versions changed - review before committing"
fi

echo
echo "═══════════════════════════════════════════════════════════════════════"
echo " Verification passed"
echo "═══════════════════════════════════════════════════════════════════════"
