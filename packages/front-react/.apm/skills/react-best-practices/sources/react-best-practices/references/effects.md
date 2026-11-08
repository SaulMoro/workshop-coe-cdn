# Effects

An effect synchronises a component with something outside React: a subscription, a timer, a browser API. Most other uses have a better place.

- Responding to a user action belongs in the event handler, not in an effect that watches state.
- Server data is not loaded in an effect. Read it from a source that works with Suspense, such as a cached promise passed to `use()`.
- Every effect that subscribes, starts a timer or opens a connection returns a cleanup function.
- List every reactive value the effect reads in its dependency array. If that list causes extra runs, move the logic out of the effect instead of hiding the dependency.
