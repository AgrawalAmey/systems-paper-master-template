# latexmk configuration for systems-paper-master-template

# Add styles/ to search paths
ensure_path('TEXINPUTS', './styles//');
ensure_path('BSTINPUTS', './styles//');

# Use pdflatex by default
$pdf_mode = 1;
$pdflatex = 'pdflatex -interaction=nonstopmode -halt-on-error %O %S';

# Bibtex
$bibtex_use = 2;

# Clean extensions
@generated_exts = (@generated_exts, 'synctex.gz');
