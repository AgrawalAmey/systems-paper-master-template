---
name: switch-venue
description: Switch target conference and verify compilation
user_invocable: true
---

Switch the target conference in config.tex and verify the paper compiles.

## Steps

1. Read `config.tex` to find the current `\def\targetconference{...}` line
2. Update it to the requested venue using perl (NEVER use sed — BSD sed corrupts LaTeX backslashes):
   ```bash
   export VENUE="<venue>"
   perl -pi -e 's/^\\def\\targetconference\{[^}]*\}/\\def\\targetconference{$ENV{VENUE}}/' config.tex
   ```
3. Run `make clean all` and check for errors
4. If compilation fails, read `main.log` to diagnose and fix the issue
5. Report success or any warnings

## Valid venues
mlsys, neurips, colm, osdi, nsdi, asplos, sosp, eurosys, socc, vldb, sigmod
