# Strict types

- The project compiles with `strict: true`. Do not turn options off to make an error go away.
- Use `unknown` for values you have not checked yet, and narrow them with `typeof`, `in` or a type guard.
- Let TypeScript infer local variables. Annotate exported functions, so their contract is visible where they are declared.
- Prefer `type` aliases for data shapes and keep them next to the code that owns them.
- A non-null assertion (`value!`) needs a comment that says why the value is always present. Usually a check is clearer.
- Use `satisfies` to check an object against a type without widening it.
