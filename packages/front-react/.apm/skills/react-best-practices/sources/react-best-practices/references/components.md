# Components

- A component does one job. When its JSX needs a comment to explain a section, that section is probably its own component.
- Pass data down as props and events up as callbacks named `on<Event>`.
- Prefer composition (`children` or a render prop) to a growing list of boolean props.
- Keep components pure: the same props and state produce the same JSX. Side effects go in event handlers or, as a last resort, in an effect.
- Custom hooks hold reusable logic, not markup. Name them `use<Thing>` and return the smallest useful API.
- Declare components at the top level of a module, never inside another component, or React remounts them on every render.
