#!/usr/bin/env bash
# ============================================================
# Generate sample PDFs for all (or one) supported venues.
# Compiles the template for each venue and copies the output
# PDF to samples/<mode>/<venue>.pdf.
#
# With --example, overlays example/ content (Medha paper) into
# the root before building, then restores generic content.
#
# With --mode, controls which formatting mode(s) to generate:
#   camera-ready  = final/accepted (no anonymization)
#   review        = submission (anonymous where supported)
#   both          = generate both (default)
# ============================================================

set -euo pipefail

# --- Configuration ---
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="$PROJECT_DIR/config.tex"
SAMPLES_DIR="$PROJECT_DIR/samples"
EXAMPLE_DIR="$PROJECT_DIR/example"

# Venues with style files available in styles/
ALL_VENUES=(mlsys neurips colm osdi sosp nsdi asplos eurosys socc vldb sigmod)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

# --- Parse arguments ---
SINGLE_VENUE=""
USE_EXAMPLE=false
MODE="both"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --example)
            USE_EXAMPLE=true
            shift
            ;;
        --venue)
            SINGLE_VENUE="$2"
            shift 2
            ;;
        --mode)
            MODE="$2"
            if [[ "$MODE" != "camera-ready" && "$MODE" != "review" && "$MODE" != "both" ]]; then
                echo "Error: --mode must be 'camera-ready', 'review', or 'both'"
                exit 1
            fi
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--example] [--venue <name>] [--mode camera-ready|review|both]"
            echo ""
            echo "Options:"
            echo "  --example       Use example/ content (Medha paper) for samples"
            echo "  --venue <name>  Generate sample for a single venue"
            echo "  --mode <mode>   Generate camera-ready, review, or both (default: both)"
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

# --- Save original root content to a temp dir for restoration ---
BACKUP_DIR="$(mktemp -d)"

cp "$CONFIG_FILE" "$BACKUP_DIR/config.tex"
cp "$PROJECT_DIR/references.bib" "$BACKUP_DIR/references.bib"
mkdir -p "$BACKUP_DIR/content"
cp "$PROJECT_DIR"/content/*.tex "$BACKUP_DIR/content/"

# Track whether macros-project.tex existed before
if [[ -f "$PROJECT_DIR/macros-project.tex" ]]; then
    cp "$PROJECT_DIR/macros-project.tex" "$BACKUP_DIR/macros-project.tex"
fi

restore_root() {
    # Restore backed-up files
    cp "$BACKUP_DIR/config.tex" "$CONFIG_FILE"
    cp "$BACKUP_DIR/references.bib" "$PROJECT_DIR/references.bib"
    cp "$BACKUP_DIR"/content/*.tex "$PROJECT_DIR/content/"
    # Restore or remove macros-project.tex
    if [[ -f "$BACKUP_DIR/macros-project.tex" ]]; then
        cp "$BACKUP_DIR/macros-project.tex" "$PROJECT_DIR/macros-project.tex"
    else
        rm -f "$PROJECT_DIR/macros-project.tex"
    fi
    # Restore figures and tables to their original state (empty with .gitkeep)
    if $USE_EXAMPLE; then
        find "$PROJECT_DIR/figures/" -mindepth 1 ! -name '.gitkeep' -exec rm -rf {} + 2>/dev/null || true
        find "$PROJECT_DIR/tables/" -mindepth 1 ! -name '.gitkeep' -exec rm -rf {} + 2>/dev/null || true
    fi
    # Clean up temp dir
    rm -rf "$BACKUP_DIR"
}
trap restore_root EXIT

# --- Overlay example content if requested ---
if $USE_EXAMPLE; then
    if [[ ! -d "$EXAMPLE_DIR" ]]; then
        echo -e "${RED}Error: example/ directory not found${NC}"
        exit 1
    fi
    echo -e "${BOLD}Using example/ content for samples...${NC}"
    cp "$EXAMPLE_DIR/config.tex" "$CONFIG_FILE"
    cp "$EXAMPLE_DIR/references.bib" "$PROJECT_DIR/references.bib"
    cp "$EXAMPLE_DIR"/content/*.tex "$PROJECT_DIR/content/"
    cp "$EXAMPLE_DIR/macros-project.tex" "$PROJECT_DIR/macros-project.tex"
    rsync -a "$EXAMPLE_DIR/figures/" "$PROJECT_DIR/figures/"
    rsync -a "$EXAMPLE_DIR/tables/" "$PROJECT_DIR/tables/"
fi

# --- Determine venues and modes ---
if [[ -n "$SINGLE_VENUE" ]]; then
    VENUES=("$SINGLE_VENUE")
else
    VENUES=("${ALL_VENUES[@]}")
fi

if [[ "$MODE" == "both" ]]; then
    MODES=("camera-ready" "review")
else
    MODES=("$MODE")
fi

# --- Create output directories ---
for mode in "${MODES[@]}"; do
    mkdir -p "$SAMPLES_DIR/$mode"
done

# --- Helper: set \cameraready in config.tex ---
set_camera_ready() {
    local val="$1"
    if [[ "$val" == "true" ]]; then
        perl -pi -e 's/^\\cameraready(true|false)/\\camerareadytrue/' "$CONFIG_FILE"
    else
        perl -pi -e 's/^\\cameraready(true|false)/\\camerareadyfalse/' "$CONFIG_FILE"
    fi
}

# --- Generate samples ---
PASS=0
FAIL=0
RESULTS=()

echo -e "${BOLD}Generating sample PDFs...${NC}"
echo ""

for mode in "${MODES[@]}"; do
    echo -e "${BOLD}Mode: $mode${NC}"

    if [[ "$mode" == "camera-ready" ]]; then
        set_camera_ready "true"
    else
        set_camera_ready "false"
    fi

    for venue in "${VENUES[@]}"; do
        # Update config.tex with target venue (use perl to avoid BSD sed corruption)
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
                RESULTS+=("$mode/$venue:FAIL")
                FAIL=$((FAIL + 1))
            else
                # Copy PDF to samples/<mode>/
                cp "$PROJECT_DIR/main.pdf" "$SAMPLES_DIR/$mode/$venue.pdf"
                echo -e "${GREEN}OK${NC} -> samples/$mode/$venue.pdf"
                RESULTS+=("$mode/$venue:OK")
                PASS=$((PASS + 1))
            fi
        else
            echo -e "${RED}FAIL${NC} (build failed)"
            RESULTS+=("$mode/$venue:FAIL")
            FAIL=$((FAIL + 1))
        fi
    done
    echo ""
done

# --- Summary ---
TOTAL=$((PASS + FAIL))
echo -e "${BOLD}Results: $PASS/$TOTAL generated${NC}"

if [[ $FAIL -gt 0 ]]; then
    echo -e "  ${RED}$FAIL venue(s) failed${NC}"
    exit 1
else
    echo -e "  ${GREEN}All sample PDFs generated successfully${NC}"
    exit 0
fi
