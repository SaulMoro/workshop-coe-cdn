---
description: TypeScript source files
applyTo: "**/*.{ts,tsx}"
---

- No `any`. Use `unknown` and narrow it.
- No non-null assertion (`!`) without a comment that says why the value is present.
- Load the react-best-practices skill when you add or change a type that other modules import.
