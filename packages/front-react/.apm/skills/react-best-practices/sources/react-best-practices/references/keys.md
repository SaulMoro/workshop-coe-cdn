# Keys

- Elements rendered from an array need a `key` that identifies the item, not its position: the record id, or another value that does not change when the array is sorted or filtered.
- The array index is only safe when the array never reorders, never filters and its items hold no state.
- Keys only need to be unique among siblings.
- Changing a component's `key` on purpose resets its state. Use it when a form or panel must start fresh for a different record.
