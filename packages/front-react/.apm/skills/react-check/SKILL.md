---
name: react-check
description: Diagnose React components that render more than expected, lose state or behave inconsistently, starting with a read-only scan of the code. Use when a component re-renders unexpectedly, resets its state, or someone asks for a health check of React code.
---

# React check

Look in this order; stop when you find the cause.

1. Run [scan-components.sh](scripts/scan-components.sh) on the folder or files you are asked about, from the repository root. It only reads files and prints `file:line · problem`.
2. Keys: items keyed by array index lose their state when the list reorders or filters.
3. Component identity: a component declared inside another one is redefined on each render. React sees a different component every time and remounts it, losing its state.
4. Effects: an effect that fetches data, or that sets state the render already has, adds a render and can race.
5. Context: a provider value created on every render makes every consumer render again.

Report each cause with its file and line and the smallest change that removes it. Do not apply the change unless you are asked to.
