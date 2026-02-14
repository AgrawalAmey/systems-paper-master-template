---
name: check-refs
description: Find broken references, dead labels, unused citations
user_invocable: true
---

Audit all cross-references, labels, and citations for correctness.

## Steps

1. Build the paper with `make` to generate `main.log`
2. Check `main.log` for:
   - `LaTeX Warning: Reference .* undefined` — broken `\ref` calls
   - `LaTeX Warning: Citation .* undefined` — missing bib entries
   - `LaTeX Warning: Label .* multiply defined` — duplicate labels
3. Find dead labels (defined but never referenced):
   - Grep all `\label{...}` in `content/*.tex`
   - Grep all `\ref{...}`, `\sref{...}`, `\figref{...}`, `\tabref{...}`, `\algref{...}`, `\eqnref{...}`, `\cref{...}` calls
   - Report labels that are never referenced
4. Find unused bibliography entries:
   - Grep all `\cite{...}` and `\citep{...}` and `\citet{...}` calls, extract keys
   - Compare against entries in `references.bib`
   - Report bib entries that are never cited
5. Report all findings with file locations
