# Naming

- A name says what the thing is or does in the domain, not how it is built: `pendingOrders`, not `filteredArray`.
- Booleans read as a question: `isOpen`, `hasItems`, `canRetry`.
- Functions that return something are named after the result (`totalPrice`). Functions that change something start with a verb (`saveDraft`).
- Keep one word per concept across the codebase. If one file says `customer` and another says `client` for the same thing, pick one and rename the other.
- Abbreviations only when the domain already uses them (`id`, `url`, `vat`).
- A file is named after its main export, with the casing the project already uses.
