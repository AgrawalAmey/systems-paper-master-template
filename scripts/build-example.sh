#!/usr/bin/env bash
# ============================================================
# Build the example project (Medha paper).
# Assembles a complete build tree in a temp directory using
# the template infrastructure + example/ content, then copies
# the resulting PDF back to the project root.
# ============================================================

set -euo pipefail

# --- Configuration ---
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
EXAMPLE_DIR="$PROJECT_DIR/example"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m'

# --- Check example directory exists ---
if [[ ! -d "$EXAMPLE_DIR" ]]; then
    echo -e "${RED}Error: example/ directory not found${NC}"
    exit 1
fi

# --- Create temp build directory ---
BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_DIR"' EXIT

echo -e "${BOLD}Building example project in $BUILD_DIR ...${NC}"

# --- Copy template infrastructure ---
cp "$PROJECT_DIR"/main.tex "$BUILD_DIR/"
cp "$PROJECT_DIR"/packages.tex "$BUILD_DIR/"
cp "$PROJECT_DIR"/macros.tex "$BUILD_DIR/"
cp "$PROJECT_DIR"/Makefile "$BUILD_DIR/"
ln -s "$PROJECT_DIR/styles" "$BUILD_DIR/styles"

# --- Copy example content ---
cp "$EXAMPLE_DIR/config.tex" "$BUILD_DIR/"
cp "$EXAMPLE_DIR/references.bib" "$BUILD_DIR/"
cp "$EXAMPLE_DIR/macros-project.tex" "$BUILD_DIR/"
cp -R "$EXAMPLE_DIR/content" "$BUILD_DIR/content"
cp -R "$EXAMPLE_DIR/figures" "$BUILD_DIR/figures"
cp -R "$EXAMPLE_DIR/tables" "$BUILD_DIR/tables"

# --- Build ---
echo ""
make -C "$BUILD_DIR" all

# --- Copy PDF back ---
cp "$BUILD_DIR/main.pdf" "$PROJECT_DIR/main.pdf"

echo ""
echo -e "${GREEN}${BOLD}Example project built successfully: main.pdf${NC}"
