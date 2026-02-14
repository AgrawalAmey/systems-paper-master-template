---
name: orphans
description: Fix orphan/widow words by inserting ~ ties
user_invocable: true
---

Find and fix orphan words (single words on the last line of a paragraph) and widow lines by inserting `~` non-breaking space ties.

## Steps

1. Build the paper with `make` to generate the PDF
2. Read each content file in `content/*.tex`
3. Look for paragraphs where the last line likely has only 1-2 short words. Common patterns:
   - Short words at end of sentences after a long paragraph
   - Prepositions, articles, or conjunctions that could be tied to the previous word
4. Insert `~` between the second-to-last and last word to prevent the break:
   - `performance and` → `performance~and`
   - `the system` → `the~system`
5. Also fix standard non-breaking space conventions:
   - Before `\cite`: `work~\cite{...}`
   - Before `\ref`: `Figure~\ref{...}`, `Section~\ref{...}`
   - After abbreviations: `Fig.~`, `Eq.~`, `et~al.`
6. Rebuild and verify
