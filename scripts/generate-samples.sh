#!/usr/bin/env bash
# ============================================================
# Generate sample PDFs for all (or one) supported venues.
# Compiles the template for each venue and copies the output
# PDF to samples/<venue>.pdf.
#
# With --example, overlays example/ content (Medha paper) into
# the root before building, then restores generic content.
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
        -h|--help)
            echo "Usage: $0 [--example] [--venue <name>]"
            echo ""
            echo "Options:"
            echo "  --example       Use example/ content (Medha paper) for samples"
            echo "  --venue <name>  Generate sample for a single venue"
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

# --- Determine venues ---
if [[ -n "$SINGLE_VENUE" ]]; then
    VENUES=("$SINGLE_VENUE")
else
    VENUES=("${ALL_VENUES[@]}")
fi

# --- Create output directory ---
mkdir -p "$SAMPLES_DIR"

# --- Generate samples ---
PASS=0
FAIL=0
RESULTS=()

echo -e "${BOLD}Generating sample PDFs...${NC}"
echo ""

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
            RESULTS+=("$venue:FAIL")
            FAIL=$((FAIL + 1))
        else
            # Copy PDF to samples/
            cp "$PROJECT_DIR/main.pdf" "$SAMPLES_DIR/$venue.pdf"
            echo -e "${GREEN}OK${NC} -> samples/$venue.pdf"
            RESULTS+=("$venue:OK")
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
echo -e "${BOLD}Results: $PASS/$TOTAL generated${NC}"

if [[ $FAIL -gt 0 ]]; then
    echo -e "  ${RED}$FAIL venue(s) failed${NC}"
    exit 1
else
    echo -e "  ${GREEN}All sample PDFs generated successfully${NC}"
    exit 0
fi
