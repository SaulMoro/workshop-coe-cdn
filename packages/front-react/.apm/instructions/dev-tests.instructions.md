---
description: Test files in any language
applyTo: "**/*.{test,spec}.*"
---

- One behaviour per test. Name the test after the behaviour, not after the function it calls.
- Arrange, act and assert, in that order, separated by a blank line.
- No fixed waits such as `sleep` or `setTimeout`: wait for the condition the test needs.
- Load the react-best-practices skill when a test needs new helpers or fixtures.
