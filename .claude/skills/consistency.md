---
name: consistency
description: Check terminology, capitalization, and style consistency
user_invocable: true
---

Check the paper for consistency in terminology, capitalization, hyphenation, and style.

## Steps

1. Read all content files in `content/*.tex`
2. Check for inconsistencies in:
   - **System name**: Is `\sysname` used consistently (not the plain text name)?
   - **Terminology**: Same concept referred to by different names (e.g., "KV cache" vs "key-value cache" vs "KV-cache")
   - **Capitalization**: Consistent capitalization of technical terms (e.g., "Transformer" vs "transformer")
   - **Hyphenation**: Consistent hyphenation (e.g., "end-to-end" vs "end to end", "long-context" vs "long context")
   - **Number formatting**: Consistent use of units, decimal places, and thousand separators
   - **Citation style**: Consistent use of `\cite` vs `\citep` vs `\citet`
   - **Reference macros**: Using `\sref`, `\figref`, `\tabref` consistently (not raw `\ref`)
   - **Abbreviations**: Using `\ie`, `\eg`, `\etal` macros (not typed out)
3. Report all inconsistencies with file locations and suggested fixes
