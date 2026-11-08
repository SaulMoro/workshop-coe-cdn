# Unions instead of flags

Two booleans that cannot both be true are one state in disguise. Model it as a union.

```ts
// Before: four combinations, two of them impossible
type Upload = { isDone: boolean; isFailed: boolean; reason?: string }

// After: only the states that exist
type Upload =
  | { state: 'pending' }
  | { state: 'done' }
  | { state: 'failed'; reason: string }
```

- Switch on the discriminant (`state`) and let the compiler check that every case is handled: end the `switch` with a `never` check.
- Data that only exists in one state (`reason`) lives in that branch, so it cannot be read by mistake in another.
