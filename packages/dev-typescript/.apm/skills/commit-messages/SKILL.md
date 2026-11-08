---
name: commit-messages
description: Write commit messages with the Conventional Commits format and a body that explains the reason. Use when committing changes or when asked to write or review a commit message.
---

# Commit messages

1. Subject: `<type>(<scope>): <summary>`, at most 72 characters, imperative mood, no full stop.
   - Types: `feat`, `fix`, `refactor`, `test`, `docs`, `build`, `ci`, `chore`.
   - The scope is the module or feature folder the change touches. Leave it out if the change is cross-cutting.
2. Leave one blank line, then a body that says why the change was needed and anything the diff does not show. Wrap it at 72 characters.
3. A breaking change adds `!` after the type and a `BREAKING CHANGE:` paragraph that says what callers have to do.
4. Do not list the files that changed: the diff already does.
