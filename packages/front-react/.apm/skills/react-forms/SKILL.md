---
name: react-forms
description: Build forms with React 19 actions, useActionState, labelled fields and validation messages per field. Use when creating or changing a form component.
---

# React forms

Load the react-best-practices skill for component structure. This skill covers what is specific to forms.

1. Submit through an action: `<form action={submit}>`, with `useActionState` holding the result of the last submission.
2. Read the values from the `FormData` the action receives. Keep a field controlled only when the UI reacts while the person types.
3. Validate in the action and return the messages per field. Show each message next to its field and tie it with `aria-describedby`. Details in [validation.md](references/validation.md).
4. Disable the submit button while the action runs, with `useFormStatus` or the pending flag of `useActionState`. More in [actions.md](references/actions.md).
5. Before adding a form library, read [libraries.md](references/libraries.md).
