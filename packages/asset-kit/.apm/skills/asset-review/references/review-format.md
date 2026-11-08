# Review report

Write the report in the language of the person who asked, with these sections in this order.

1. **Set**: name, status, owner and dependencies, in one line.
2. **Pieces**: one line per piece: `path · type · keep, or change to <type> · reason`.
3. **Vault boundary**: one line per finding: `path:line · what only exists in one repository · proposed change`.
4. **Dated patterns**: one line per scanner hit: `path:line · id · rewrite or keep · reason`.
5. **Manifest and README**: what is missing or wrong, with the exact text to add.
6. **Proposed changes**: a numbered list. Nothing is applied until the person accepts it.

Write "nothing to report" in a section without findings, so the person knows it was checked.
