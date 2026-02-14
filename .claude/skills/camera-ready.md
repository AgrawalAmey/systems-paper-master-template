---
name: camera-ready
description: Prepare for camera-ready (hide comments, find TODOs)
user_invocable: true
---

Prepare the paper for camera-ready submission.

## Steps

1. Set `\publicversiontrue` in `config.tex` (hides all author comments and TODOs)
2. Search for remaining issues:
   - Grep for `\todo{` in all content files — these should be resolved
   - Grep for `TODO`, `FIXME`, `XXX`, `HACK` in comments
   - Grep for `\authorA{`, `\authorB{`, etc. — verify they're hidden
3. Check for placeholder text:
   - "TBD", "TODO", "PLACEHOLDER", "Lorem ipsum"
   - Empty sections or subsections
4. Verify compilation with `make clean all`
5. Check `main.log` for any remaining warnings
6. Report all findings that need manual attention before submission
