# Context

- Context is for values many components at different depths need, such as the theme, the current user or the locale. For two levels of props, pass the props.
- Export a custom hook (`useTheme`) instead of the context object, and make it fail with a clear message when the provider is missing.
- Keep the value stable: memoise objects and callbacks passed to a provider, or every consumer renders again on each parent render.
- Split a context when some consumers read only part of it and the parts change at different rates.
