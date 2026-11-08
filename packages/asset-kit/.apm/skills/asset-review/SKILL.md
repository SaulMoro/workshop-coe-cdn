---
name: asset-review
description: Review the pieces of an asset set before they go to the vault, deciding the type of each one and checking its model-facing text, its paths and its manifest. Use when creating, reviewing or proposing a skill, instruction, agent, hook or MCP server for an asset set.
---

# Asset review

Work on one asset set at a time. Propose changes, and apply them only after the person accepts them.

1. Read [asset-types.md](references/asset-types.md). For each piece of the set, state its type and the reason in one line. When a piece has the wrong type, say which one fits.
2. Check the vault boundary with the same reference. Name every path, page, folder, product or client that only exists in one repository, and propose how to remove it.
3. Run [scan-dated.sh](scripts/scan-dated.sh) with the set folder as argument. From the vault root: `bash asset-sets/asset-kit/skills/asset-review/scripts/scan-dated.sh asset-sets/<set>`. Classify each hit with [dated-catalog.md](references/dated-catalog.md): rewrite it, or keep it and say why.
4. Check the manifest and the README: the name equals the folder, a new set is PROPOSED, it names an owner, it depends on the closest set it builds on, and the README has its dependency line.
5. Report in the format of [review-format.md](references/review-format.md).
6. After the accepted changes, run `tools/verify.sh` from the vault root and fix every error. Warnings are for the person to decide.
