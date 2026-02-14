---
name: fix-compile
description: Iteratively fix compilation errors and warnings
user_invocable: true
---

Fix LaTeX compilation errors and warnings iteratively.

## Steps

1. Run `make clean all 2>&1` and capture the output
2. Check `main.log` for errors (`grep "^!" main.log`) and warnings (`grep "Warning" main.log`)
3. For each error/warning:
   - Read the referenced file and line number
   - Identify the root cause (missing package, undefined command, bad syntax, etc.)
   - Apply the fix
4. Rebuild and check again
5. Repeat until clean compilation (no `^!` errors in main.log)

## Common fixes
- Missing `\country{}` in ACM venues → add to `\affiliation` block
- `\Bbbk` conflict → already handled in packages.tex with `\let\Bbbk\relax`
- `algorithmic` conflict with MLSys → already handled with `\@ifpackageloaded` guard
- Undefined references → check label names match `\ref` calls
- Missing bibliography entries → check `references.bib`
