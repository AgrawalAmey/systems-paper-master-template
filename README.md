# Systems Paper Master Template

A multi-conference LaTeX template for systems and ML research papers. Switch between 11 venues by editing a single line.

## Quick Start

```bash
# 1. Clone and enter the project
git clone git@github.com:AgrawalAmey/systems-paper-master-template.git && cd systems-paper-master-template

# 2. Set your target conference in config.tex
#    Change: \def\targetconference{neurips}

# 3. Build
make
```

## Supported Conferences

| Venue | Family | Style File | Status |
|-------|--------|-----------|--------|
| MLSys | ML | `mlsys2024.sty` | Ready |
| NeurIPS | ML | `neurips_2025.sty` | Ready |
| COLM | ML | `colm2025_conference.sty` | Ready |
| ICML | ML | — | Needs `.sty` |
| ICLR | ML | — | Needs `.sty` |
| OSDI | USENIX | `usenix-2020-09.sty` | Ready |
| NSDI | USENIX | `usenix-2020-09.sty` | Ready |
| ASPLOS | ACM | `acmart.cls` | Ready |
| SOSP | ACM | `acmart.cls` | Ready |
| EuroSys | ACM | `acmart.cls` | Ready |
| SoCC | ACM | `acmart.cls` | Ready |
| VLDB | ACM | `acmart.cls` | Ready |
| SIGMOD | ACM | `acmart.cls` | Ready |

## Switching Conferences

Edit the `\def\targetconference{...}` line in `config.tex`:

```latex
% In config.tex, change this line:
\def\targetconference{neurips}    % <- set your venue here
```

That's it. The template automatically selects the correct document class, style package, bibliography style, and author block format. Authors are rendered in a condensed format with superscript institution numbers:

```
Author1¹  Author2²  Author3¹  Author4²  Author5³
¹Institution1   ²Institution2   ³Institution3
```

## Project Structure

```
.
├── config.tex          # Conference, title, authors, institutions (edit this)
├── main.tex            # Document orchestrator (rarely edit)
├── packages.tex        # Common packages with compatibility guards
├── macros.tex          # Macros, abbreviations, author comments
├── references.bib      # Bibliography database
├── content/
│   ├── abstract.tex    # Abstract
│   ├── 1-intro.tex     # Introduction
│   ├── 2-background.tex
│   ├── 3-design.tex
│   ├── 4-eval.tex
│   ├── 5-related.tex
│   ├── 6-conc.tex      # Conclusion
│   └── appendix.tex
├── figures/            # Static figures (PDF, PNG)
├── figures-tex/        # TikZ/pgfplots source figures
├── tables/             # Table data (CSV)
├── algorithms/         # Algorithm pseudocode
├── styles/             # Conference .cls/.sty/.bst files
├── samples/            # Pre-built sample PDFs for each venue
├── example/            # Working example project (Medha paper)
├── scripts/
│   ├── test.sh         # Multi-venue compilation tests
│   └── generate-samples.sh  # Generate sample PDFs for all venues
└── Makefile
```

## Example Project

The `example/` directory contains a complete working paper (Medha, ASPLOS'26) that demonstrates the template with real content, figures, and references. Use it as a reference for how to structure your paper.

To build with the example content:
```bash
# Copy example files into root
cp example/config.tex config.tex
cp example/references.bib references.bib
cp example/macros-project.tex macros-project.tex
cp example/content/*.tex content/
rsync -a example/figures/ figures/
rsync -a example/tables/ tables/

# Build
make
```

The `make samples` command automatically uses the example content to generate sample PDFs for all venues.

### Project-Specific Macros

Create a `macros-project.tex` file in the root directory for paper-specific commands. It is automatically loaded by `main.tex` via `\InputIfFileExists`. See `example/macros-project.tex` for reference.

## Configuration

All configuration lives in `config.tex`. It has four sections:

### Conference Target
```latex
\def\targetconference{neurips}
```

### Paper Metadata
```latex
\def\papertitle{Your Paper Title Here}
\def\shorttitle{Short Title for Running Headers}
\def\paperkeywords{keyword1, keyword2}
\def\sysnameplain{SystemName}
```

### Authors and Institutions
```latex
% Institutions (A through J)
\def\instA{Georgia Institute of Technology}
\def\instAcity{Atlanta}
\def\instAcountry{USA}

% Authors (A through J, referencing institution keys)
\def\authorAname{First Author}
\def\authorAinst{A}
\def\authorAemail{first@example.com}
```

### Author Footnotes
```latex
% Marks on author names
\def\authorAmark{*}
\def\authorBmark{*,\dagger}

% Footnote text
\def\authorfnA{$^*$Equal contribution.}
\def\authorfnB{$^\dagger$Work done during internship.}
```

### Author Block Rendering

Authors render in a **condensed format** with superscript institution numbers (auto-generated from config):

| Macro | Purpose |
|-------|---------|
| `\condensedauthorlist` | All authors with superscript inst numbers, separated by `\enskip` |
| `\instlegend` | Numbered institution legend: `^1Name1  ^2Name2  ...` |
| `\authorwithnum{X}` | Single author with superscript: `Name^{num}` |
| `\getname{X}` | Author name with optional mark (no inst number) |
| `\authormark{X}` | Superscript mark only (e.g., `*`, `†`) |
| `\emitauthorfn` | Emit author footnotes as unnumbered footnote |
| `\renderauthorfn` | Collect all `\authorfnA`..`\authorfnE` into one block |

MLSys uses its own `\mlsysauthorlist` environment and is not condensed.

## Writing Content

### Section Files
Write your paper in the `content/` directory. Each section is a separate file that gets `\input` by `main.tex`.

### System Name

`\sysname` renders `\sysnameplain` (from config.tex) in small caps with automatic trailing space.

```latex
\sysname achieves 2$\times$ lower latency than the baseline.
% -> Medha achieves 2× lower latency than the baseline.
```

### Abbreviations

All abbreviations include `\xspace` so they handle trailing spaces and punctuation correctly.

```latex
We target tail latency, \ie the p99, for LLM serving.
Prior work~\cite{orca} uses first-come-first-served, \aka FCFS.
Several factors affect performance (\eg batch size, model size, \etc).
```

| Macro | Output |
|-------|--------|
| `\ie` | *i.e.,* |
| `\eg` | *e.g.,* |
| `\etal` | *et al.* |
| `\etc` | *etc.* |
| `\wrt` | w.r.t. |
| `\aka` | a.k.a. |
| `\cf` | cf. |

### Cross-References

Use `~` for non-breaking spaces before `\ref` to prevent line breaks between "Figure" and the number.

```latex
As shown in \figref{fig:overview}, \sysname has three components.
We describe each in \sref{sec:design} and evaluate in \sref{sec:eval}.
The results (\tabref{tab:main}) show that \sysname reduces latency
by 2.3$\times$ (see \eqnref{eq:speedup} and \algref{alg:schedule}).
```

| Macro | Output |
|-------|--------|
| `\sref{sec:x}` | §3 |
| `\figref{fig:x}` | Figure 3 |
| `\tabref{tab:x}` | Table 3 |
| `\algref{alg:x}` | Algorithm 3 |
| `\eqnref{eq:x}` | Eq. 3 |

### Formatting Helpers

```latex
% Bold inline headings for structured paragraphs
\heading{Key insight} Preemption allows shorter requests to avoid
head-of-line blocking behind long-context requests.

\vheading{Challenge} Migrating KV cache between GPUs is expensive.

% Bold-title captions for figures and tables
\begin{figure}
  \includegraphics{figures/overview.pdf}
  \mycaption{System overview}{\sysname intercepts requests at the
  proxy and routes them to the appropriate model instance.}
\end{figure}

% Wider row spacing in tables
\begin{table}
  \ra{1.2}
  \begin{tabular}{lcc} ...
```

| Macro | Purpose |
|-------|---------|
| `\heading{Title}` | Bold inline heading: **Title.** |
| `\vheading{Title}` | Bold inline heading with vertical space above |
| `\myparagraph{Title}` | Bold paragraph header |
| `\mycaption{Title}{Desc}` | Bold-title caption: **Title.** Desc |
| `\ra{1.2}` | Set `\arraystretch` for table row spacing |

### Math Operators

```latex
$\theta^* = \argmax_\theta \mathcal{L}(\theta)$
```

| Macro | Output |
|-------|--------|
| `\argmax` | arg max |
| `\argmin` | arg min |

### Table Symbols

```latex
\begin{tabular}{lccc}
  \toprule
  System & Preemption & Migration & SLO-aware \\
  \midrule
  vLLM       & \redcross   & \redcross   & \redcross \\
  \sysname   & \greencheck & \greencheck & \greencheck \\
  \bottomrule
\end{tabular}

% In results tables:
% 2.3\myx faster       ->  2.3× faster
% 15\% \greenup        ->  15% ↑
% 8\% \reddown         ->  8% ↓

% Rotated column headers for compact tables:
\rot{Throughput} & \rot{Latency} & \rot{SLO Rate}
```

| Macro | Output | Purpose |
|-------|--------|---------|
| `\greencheck` | Green ✓ | Feature present |
| `\redcross` | Red ✗ | Feature absent |
| `\myx` | × | Multiplication / dimensions |
| `\greenup` | Green ↑ | Improvement |
| `\reddown` | Red ↓ | Degradation |
| `\rot{text}` | Rotated 90° | Rotated column headers |

### Figure Part Labels

```latex
\figref{fig:results} shows end-to-end performance.
\figleft Throughput scales linearly up to 8 GPUs.
\figright Tail latency remains flat under 200ms.
```

| Macro | Output |
|-------|--------|
| `\figleft` | *(Left)* |
| `\figright` | *(Right)* |
| `\figtop` | *(Top)* |
| `\figbottom` | *(Bottom)* |

### Compact Lists

Use `\squishlist`/`\squishend` for tighter spacing than standard `itemize` (useful in space-constrained sections).

```latex
Our contributions are:
\squishlist
  \item A preemptive scheduling algorithm for long-context LLM inference.
  \item An efficient KV cache migration mechanism across GPUs.
  \item An end-to-end system evaluation on production workloads.
\squishend
```

### Callout Boxes

Highlight key insights or takeaways using `framed`-based boxes.

```latex
\begin{insightbox}
  \textbf{Insight:} Long-context requests occupy GPU memory for 10--100$\times$
  longer than short requests, causing head-of-line blocking.
\end{insightbox}

\begin{takeawaybox}
  \textbf{Takeaway:} Preemptive scheduling with KV cache migration reduces
  p99 latency by 2.3$\times$ compared to FCFS scheduling.
\end{takeawaybox}
```

### Circled Numbers

White-on-black circled numbers for labeling steps in architecture figures.

```latex
% In a TikZ figure:
\node at (1,2) {\circled{1} Client sends request};
\node at (3,2) {\circled{2} Scheduler assigns GPU};
\node at (5,2) {\circled{3} Model generates tokens};
```

### Author Comments

Colored inline comments for collaborative drafting. Hidden when `\publicversiontrue` is set in config.tex. Rename the display names in `macros.tex` to match your co-authors.

```latex
\sysname reduces tail latency by 2.3$\times$.
\authorA{Should we also report median latency?}
\todo{Add comparison with Orca and Sarathi.}

% Renders as:
% Medha reduces tail latency by 2.3×. [Alice: Should we also report
% median latency?] [TODO: Add comparison with Orca and Sarathi.]
```

| Macro | Color |
|-------|-------|
| `\authorA{text}` | teal |
| `\authorB{text}` | purple |
| `\authorC{text}` | orange |
| `\authorD{text}` | brown |
| `\authorE{text}` | olive |
| `\todo{text}` | red |

### Figures and Tables
- Place static figures (PDF, PNG) in `figures/`
- Place TikZ/pgfplots source in `figures-tex/`
- Place table data (CSV) in `tables/`
- Use `\mycaption{Bold Title}{Description}` for consistent captions
- Use `~` before `\ref` for non-breaking spaces: `Figure~\ref{fig:x}`

## Building

| Command | Description |
|---------|-------------|
| `make` | Full build: pdflatex → bibtex → pdflatex ×2 |
| `make quick` | Single pdflatex pass (skip bibliography) |
| `make watch` | Continuous build with latexmk (watches for changes) |
| `make clean` | Remove all build artifacts |
| `make test` | Test compilation across all venues |
| `make samples` | Generate sample PDFs in `samples/` for all venues |

### Troubleshooting

- **Missing style files**: Ensure `styles/` contains the required `.sty`/`.cls` files. The Makefile sets `TEXINPUTS=./styles//` automatically.
- **`\Bbbk` conflict**: Already handled in `packages.tex` with `\let\Bbbk\relax`.
- **`algorithmic` conflict**: Already handled with `\@ifpackageloaded` guard.
- **ACM compilation fails**: Ensure every `\affiliation` has a `\country{}` field in `config.tex`.
- **USENIX `\dagger` error**: Install the `zapfchan` package (`tlmgr install zapfchan`).

## Testing

Run compilation tests across all supported venues:

```bash
make test                            # Test all venues
./scripts/test.sh --venue neurips    # Test a single venue
./scripts/test.sh --warn             # Also fail on warnings
```

### Generating Samples

Generate sample PDFs for all venues (saved to `samples/`):

```bash
make samples                                  # All venues
./scripts/generate-samples.sh --venue neurips  # Single venue
```

## Packages (`packages.tex`)

Pre-loaded with compatibility guards for all venues:

- **Math**: amsmath, amssymb, amsfonts, mathtools
- **Figures**: graphicx, subcaption, tikz, pgfplots, pgfplotstable
- **Tables**: booktabs, multirow, array, makecell
- **Lists**: enumitem (with tight defaults)
- **Colors**: xcolor (dvipsnames, table)
- **Algorithms**: algorithm + algpseudocode (with mlsys shims)
- **Code**: listings (with default style)
- **Boxes**: framed (tcolorbox is incompatible with TinyTeX)
- **Refs**: hyperref, url, cleveref (loaded last)
- **Utilities**: xspace, ifthen, comment, microtype

## Compatibility Notes

The template handles several cross-venue compatibility challenges automatically:

- **`amssymb` + acmart**: The `\Bbbk` symbol conflicts with acmart's fonts. Resolved with `\let\Bbbk\relax` before loading.
- **`algorithm` + MLSys**: MLSys's style pre-loads `algorithmic`, which conflicts with `algpseudocode`. Resolved with `\@ifpackageloaded` guard.
- **`\algref` + NeurIPS**: NeurIPS's style defines `\algref`. Resolved with `\providecommand`.
- **ACM abstract placement**: ACM requires `\begin{abstract}...\end{abstract}` before `\maketitle`. All other venues place it after.
- **MLSys title pattern**: MLSys requires `\twocolumn[\mlsystitle{...}...]` instead of `\maketitle`.
- **Author marks in ACM**: ACM's `\MakeUppercase` breaks bare math mode. Resolved with `\textsuperscript{$...$}` wrapping.

