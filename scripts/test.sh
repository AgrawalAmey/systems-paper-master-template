#!/usr/bin/env bash
# ============================================================
# Multi-venue compilation test script
# Tests that the template compiles successfully for all
# supported conferences that have style files available.
# ============================================================

set -euo pipefail

# --- Configuration ---
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="$PROJECT_DIR/config.tex"

# Venues with style files available in styles/
ALL_VENUES=(mlsys neurips colm osdi sosp nsdi asplos eurosys socc vldb sigmod)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m' # No color

# --- Parse arguments ---
WARN_FLAG=false
SINGLE_VENUE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --warn)
            WARN_FLAG=true
            shift
            ;;
        --venue)
            SINGLE_VENUE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--warn] [--venue <name>]"
            echo ""
            echo "Options:"
            echo "  --warn          Fail on LaTeX warnings (not just errors)"
            echo "  --venue <name>  Test a single venue instead of all"
            echo ""
            echo "Supported venues: ${ALL_VENUES[*]}"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# --- Save original config ---
ORIGINAL_CONFIG="$(cat "$CONFIG_FILE")"

restore_config() {
    printf '%s\n' "$ORIGINAL_CONFIG" > "$CONFIG_FILE"
}
trap restore_config EXIT

# --- Determine venues to test ---
if [[ -n "$SINGLE_VENUE" ]]; then
    VENUES=("$SINGLE_VENUE")
else
    VENUES=("${ALL_VENUES[@]}")
fi

# --- Run tests ---
PASS=0
FAIL=0
WARN_COUNT=0
RESULTS=()

echo -e "${BOLD}Testing template compilation across venues...${NC}"
echo ""

for venue in "${VENUES[@]}"; do
    # Update config.tex with target venue (use perl to avoid BSD sed \t corruption)
    export VENUE="$venue"
    perl -pi -e 's/^\\def\\targetconference\{[^}]*\}/\\def\\targetconference{$ENV{VENUE}}/' "$CONFIG_FILE"

    printf "  %-12s " "$venue"

    # Clean and build (retry up to 3 times to handle transient TeX issues)
    BUILD_OK=false
    for attempt in 1 2 3; do
        if make -C "$PROJECT_DIR" clean all > /dev/null 2>&1; then
            BUILD_OK=true
            break
        fi
        sleep 1
    done

    if $BUILD_OK; then
        # Check for errors in log
        if grep -q "^!" "$PROJECT_DIR/main.log" 2>/dev/null; then
            echo -e "${RED}FAIL${NC} (errors in log)"
            RESULTS+=("$venue:FAIL")
            FAIL=$((FAIL + 1))
        elif $WARN_FLAG && grep -q "Warning" "$PROJECT_DIR/main.log" 2>/dev/null; then
            # Count warnings
            warns=$(grep -c "Warning" "$PROJECT_DIR/main.log" 2>/dev/null || true)
            echo -e "${YELLOW}WARN${NC} ($warns warnings)"
            RESULTS+=("$venue:WARN")
            WARN_COUNT=$((WARN_COUNT + 1))
            FAIL=$((FAIL + 1))
        else
            echo -e "${GREEN}PASS${NC}"
            RESULTS+=("$venue:PASS")
            PASS=$((PASS + 1))
        fi
    else
        echo -e "${RED}FAIL${NC} (build failed)"
        RESULTS+=("$venue:FAIL")
        FAIL=$((FAIL + 1))
    fi
done

# --- Summary ---
TOTAL=$((PASS + FAIL))
echo ""
echo -e "${BOLD}Results: $PASS/$TOTAL passed${NC}"

if [[ $WARN_COUNT -gt 0 ]]; then
    echo -e "  ${YELLOW}$WARN_COUNT venue(s) had warnings${NC}"
fi

if [[ $FAIL -gt 0 ]]; then
    echo -e "  ${RED}$((FAIL - WARN_COUNT)) venue(s) failed${NC}"
    exit 1
else
    echo -e "  ${GREEN}All venues compiled successfully${NC}"
    exit 0
fi
