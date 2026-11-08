---
name: project-glossary
description: Keep the project glossary accurate as the domain language changes. Use when a task introduces, renames or retires a domain term, or when someone asks what a term means in this project.
---

# Project glossary

The glossary is `docs/GLOSSARY.md`, unless the project already keeps one somewhere else. Create it if there is none.

1. One entry per term, in alphabetical order: `**Term**: one-sentence definition. In code: where it appears.`
2. Use the word the code uses. When the code and the people use different words for the same thing, record both and say which one the code uses.
3. When a term is renamed, update its entry in the same change and keep the old word as `Formerly: …` until nobody uses it.
4. Leave out generic technical words such as component or endpoint. Only words whose meaning belongs to this project go in.
