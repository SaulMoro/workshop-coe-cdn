# How code reports failures

- Fail where the problem is detected, with a message that says what was expected and what arrived.
- Do not swallow a failure. If you catch it, either handle it completely or rethrow it with more context.
- Keep one way of reporting failures per layer. Mixing thrown errors, `null` returns and status flags in the same module makes callers guess.
- Expected outcomes (not found, invalid input) are values the caller can check. Unexpected ones (a bug, a broken invariant) are thrown.
- Never put secrets, tokens or personal data in a failure message or a log line.
