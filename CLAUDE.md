# Systems Paper Master Template

Multi-conference LaTeX template. Switch target conference by editing ONE line in `config.tex`.

## Architecture

```
config.tex          <- Single source of truth: conference, title, authors, institutions
  |
main.tex            <- Orchestrator: loads config, sets document class, builds author blocks
  |
  +-- packages.tex  <- Common packages with compatibility guards
  +-- macros.tex    <- Shared macros, abbreviations, author comments
  +-- macros-project.tex <- (optional) Project-specific macros, auto-loaded
  +-- content/*.tex <- Section files (abstract, 1-intro through 6-conc, appendix)
```

## Build Commands

- `make` — Full build (pdflatex + bibtex + pdflatex x2)
- `make quick` — Single pdflatex pass (no bibliography)
- `make watch` — Continuous build with latexmk
- `make clean` — Remove all build artifacts
- `make test` — Run compilation tests across all venues
- `make samples` — Generate sample PDFs for all venues into `samples/`

## Key Files

| File | Role |
|------|------|
| `config.tex` | Conference target, paper metadata, authors, institutions, footnotes |
| `main.tex` | Document class selection, style loading, author block rendering |
| `packages.tex` | Common packages with compatibility guards for all venues |
| `macros.tex` | Abbreviations, references, formatting helpers, author comments |
| `references.bib` | Bibliography database |
| `styles/` | Conference `.cls`/`.sty`/`.bst` files (resolved via `TEXINPUTS`) |
| `example/` | Working example project (Medha paper) with config, content, figures, tables, bib, macros-project |
| `scripts/test.sh` | Multi-venue compilation test script |
| `scripts/generate-samples.sh` | Generate sample PDFs for all venues |

## Conference Families

**ACM** (`acmart` class): asplos, sosp, eurosys, socc, vldb, sigmod
**USENIX** (`article` + `usenix-2020-09`): osdi, nsdi
**ML** (`article` + conference style): mlsys, neurips, colm

## Config Macros (`config.tex`)

### Conference & Metadata

| Macro | Example | Purpose |
|-------|---------|---------|
| `\targetconference` | `{asplos}` | Active venue (uncomment exactly one) |
| `\papertitle` | `{My Paper Title}` | Full paper title |
| `\shorttitle` | `{Short Title}` | Running header title (MLSys) |
| `\paperkeywords` | `{kw1, kw2, kw3}` | Paper keywords |
| `\sysnameplain` | `{Medha}` | System name (plain text, used by `\sysname`) |
| `\shortauthorlist` | `{Agrawal et al.}` | Running header author list |

### Institutions (A through J)

| Macro | Example | Purpose |
|-------|---------|---------|
| `\instA` | `{Microsoft}` | Institution name |
| `\instAcity` | `{Redmond}` | City (used by ACM venues) |
| `\instAcountry` | `{USA}` | Country (required by ACM venues) |

### Authors (A through J)

| Macro | Example | Purpose |
|-------|---------|---------|
| `\authorAname` | `{Jane Doe}` | Display name |
| `\authorAinst` | `{B}` | Institution key (letter matching `\instX`) |
| `\authorAemail` | `{jane@example.com}` | Email (used by MLSys) |

### Author Footnotes

| Macro | Example | Purpose |
|-------|---------|---------|
| `\authorAmark` | `{*}` | Superscript symbol on author name |
| `\authorfnA` | `{$^*$Equal contribution.}` | Footnote text (up to 5: A-E) |

### Visibility Toggle

| Macro | Effect |
|-------|--------|
| `\publicversiontrue` | Hide all author comments and TODOs (camera-ready) |
| `\publicversionfalse` | Show colored inline comments (drafting) |

## Critical Compatibility Notes

- **`amssymb`**: Must `\let\Bbbk\relax` before loading to avoid conflict with acmart fonts
- **`algorithm`/`algpseudocode`**: Guard with `\@ifpackageloaded{algorithmic}` — mlsys2024.sty pre-loads algorithmic
- **`\algref`**: Use `\providecommand` not `\newcommand` — neurips_2025.sty defines it
- **MLSys title**: Requires `\twocolumn[\mlsystitle{...}...]` pattern, NOT standard `\maketitle`
- **ACM `\country{}`**: Required in `\affiliation` or compilation fails
- **ACM abstract**: Goes BEFORE `\maketitle`; all others go AFTER
- **Author marks**: `\textsuperscript{$...$}` wraps math symbols safely for ACM's `\MakeUppercase`
- **MLSys footnotes**: Uses `\printAffiliationsAndNotice{text}`; others use `\footnotetext`
- **Config file safety**: Never use BSD `sed` or `echo` with LaTeX content — use `perl -pi -e` and `printf '%s\n'`

## Style Files

The `Makefile` sets `TEXINPUTS=./styles//` so all `.cls`, `.sty`, and `.bst` files in `styles/` are found automatically. Do not move style files elsewhere.
