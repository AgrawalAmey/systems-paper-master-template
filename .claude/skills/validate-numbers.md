---
name: validate-numbers
description: Cross-check numbers in text against figures/tables
user_invocable: true
---

Cross-check quantitative claims in the text against data in figures and tables.

## Steps

1. Read all content files in `content/*.tex`
2. Extract all quantitative claims: numbers with units, percentages, speedups (e.g., "2.3$\times$", "15\%", "30ms")
3. For each claim, identify the source:
   - Which figure or table is it referencing? (look for nearby `\figref`, `\tabref`)
   - Read the corresponding figure `.tex` file or table data
4. Cross-check:
   - Does the number in the text match the data in the figure/table?
   - Are comparison baselines consistent?
   - Are units consistent (ms vs s, MB vs GB)?
5. Report any mismatches or claims that cannot be verified
