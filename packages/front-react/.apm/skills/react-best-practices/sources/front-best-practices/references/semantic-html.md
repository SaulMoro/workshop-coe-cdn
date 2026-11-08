# Semantic HTML

- A control that does something is a `<button>`. A control that goes somewhere is an `<a href>`. A `<div>` with a click handler is neither.
- One `<h1>` per page, and heading levels that do not skip (`h2` after `h1`, not `h4`).
- Use the landmarks the browser already knows: `<header>`, `<nav>`, `<main>`, `<footer>`.
- Tables are for tabular data, with `<th scope>` on the header cells. Do not use them for layout.
- Pick the element for its meaning, then style it. Do not pick it for its default look.
