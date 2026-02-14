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
- `make example` — Build with example/ content (auto-restores generic template)

## Key Files

| File | Role |
|------|------|
| `config.tex` | Conference target, paper metadata, authors, institutions, footnotes |
| `main.tex` | Document class selection, style loading, author block rendering |
| `packages.tex` | Common packages with compatibility guards for all venues |
| `macros.tex` | Abbreviations, references, formatting helpers, author comments |
| `references.bib` | Bibliography database |
| `styles/` | Conference `.cls`/`.sty`/`.bst` files (resolved via `TEXINPUTS`) |
| `example/` | Working example project with config, content, figures, tables, bib, macros-project |
| `scripts/test.sh` | Multi-venue compilation test script |
| `scripts/generate-samples.sh` | Generate sample PDFs for all venues |
| `scripts/build-example.sh` | Build with example/ content (auto-restores generic template) |

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

### Institutions (A through Z)

| Macro | Example | Purpose |
|-------|---------|---------|
| `\instA` | `{Microsoft}` | Institution name |
| `\instAcity` | `{Redmond}` | City (used by ACM venues) |
| `\instAcountry` | `{USA}` | Country (required by ACM venues) |

### Authors (A through Z)

| Macro | Example | Purpose |
|-------|---------|---------|
| `\authorAname` | `{Jane Doe}` | Display name |
| `\authorAinst` | `{B}` | Institution key (letter matching `\instX`) |
| `\authorAemail` | `{jane@example.com}` | Email (used by MLSys) |

### ACM Camera-Ready Metadata

Only used for ACM venues in camera-ready mode. Commented out by default; uncomment after acceptance.

| Macro | Example | Purpose |
|-------|---------|---------|
| `\papercopyright` | `{rightsretained}` | Copyright type (acmart xkeyval option) |
| `\paperdoi` | `{10.1145/xxxxxxx.xxxxxxx}` | Paper DOI |
| `\paperisbn` | `{978-x-xxxx-xxxx-x}` | Proceedings ISBN |
| `\confyear` | `{2026}` | Conference year |
| `\confname` | `{Full Conference Name}` | Full conference name |
| `\confshort` | `{ASPLOS'26}` | Short conference name |
| `\confdate` | `{March 2026}` | Conference dates |
| `\conflocation` | `{City, Country}` | Conference location |

### Author Footnotes

| Macro | Example | Purpose |
|-------|---------|---------|
| `\authorAmark` | `{*}` | Superscript symbol on author name |
| `\authorfnA` | `{$^*$Equal contribution.}` | Footnote text (up to 26: A-Z) |

### Visibility Toggle

| Macro | Effect |
|-------|--------|
| `\publicversiontrue` | Hide all author comments and TODOs (camera-ready) |
| `\publicversionfalse` | Show colored inline comments (drafting) |

### Camera-Ready Toggle

| Macro | Effect |
|-------|--------|
| `\camerareadytrue` | Final/accepted mode: no anonymization, no line numbers, no review banners |
| `\camerareadyfalse` | Review/submission mode: anonymous where supported, review formatting |

Per-family behavior:

| Family | Camera-ready (`true`) | Review (`false`) |
|--------|----------------------|-------------------|
| ACM | `\documentclass[...]{acmart}` | `\documentclass[...,review,anonymous]{acmart}` |
| MLSys | `\usepackage[accepted]{mlsys2024}` | `\usepackage{mlsys2024}` (shows "Under review") |
| NeurIPS | `\usepackage[final]{neurips_2025}` | `\usepackage{neurips_2025}` (anonymous + line numbers) |
| COLM | `\usepackage[final]{colm2025_conference}` | `\usepackage[submission]{colm2025_conference}` |
| USENIX | Shows authors | Hides author block (USENIX style has no built-in anonymization) |

`\publicversion` and `\cameraready` are independent — you can use camera-ready layout with comments visible during final proofing.

## Critical Compatibility Notes

- **`amssymb`**: Must `\let\Bbbk\relax` before loading to avoid conflict with acmart fonts
- **`algorithm`/`algpseudocode`**: Guard with `\@ifpackageloaded{algorithmic}` — mlsys2024.sty pre-loads algorithmic
- **`\algref`**: Use `\providecommand` not `\newcommand` — neurips_2025.sty defines it
- **MLSys title**: Requires `\twocolumn[\mlsystitle{...}...]` pattern, NOT standard `\maketitle`
- **ACM `\country{}`**: Required in `\affiliation` or compilation fails
- **ACM abstract**: Goes BEFORE `\maketitle`; all others go AFTER
- **Author marks**: `\textsuperscript{$...$}` wraps math symbols safely for ACM's `\MakeUppercase`
- **MLSys footnotes**: Uses `\printAffiliationsAndNotice{text}`; others use `\footnotetext`
- **Camera-ready toggle**: `\cameraready` controls documentclass options (ACM) and style package options (ML). Independent of `\publicversion`
- **Config file safety**: Never use BSD `sed` or `echo` with LaTeX content — use `perl -pi -e` and `printf '%s\n'`

## Style Files

The `Makefile` sets `TEXINPUTS=./styles//` so all `.cls`, `.sty`, and `.bst` files in `styles/` are found automatically. Do not move style files elsewhere.
