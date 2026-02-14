# ============================================================
# Makefile for systems-paper-master-template
# ============================================================

MAIN    = main
TEX     = pdflatex
BIB     = bibtex
FLAGS   = -interaction=nonstopmode -halt-on-error

# Add styles/ to TeX search paths
export TEXINPUTS := ./styles//:${TEXINPUTS}
export BSTINPUTS := ./styles//:${BSTINPUTS}

.PHONY: all clean watch quick test samples

# Full build: pdflatex -> bibtex -> pdflatex x2
all: $(MAIN).pdf

$(MAIN).pdf: $(MAIN).tex config.tex packages.tex macros.tex content/*.tex references.bib
	$(TEX) $(FLAGS) $(MAIN)
	-$(BIB) $(MAIN)
	$(TEX) $(FLAGS) $(MAIN)
	$(TEX) $(FLAGS) $(MAIN)

# Quick build: single pdflatex pass (no bibliography update)
quick:
	$(TEX) $(FLAGS) $(MAIN)

# Continuous build with latexmk (watches for changes)
watch:
	latexmk -pdf -pvc $(MAIN)

# Test compilation across all venues
test:
	./scripts/test.sh

# Generate sample PDFs for all venues (uses example/ content)
samples:
	./scripts/generate-samples.sh --example

# Clean build artifacts
clean:
	rm -f $(MAIN).{aux,bbl,blg,log,out,pdf,synctex.gz,fdb_latexmk,fls,toc,lof,lot,loa}
	rm -f content/*.aux
