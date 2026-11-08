# Form actions

```tsx
type SignupState = { errors: Partial<Record<'email', string>>; done: boolean }

async function signup(_previous: SignupState, data: FormData): Promise<SignupState> {
  const email = String(data.get('email') ?? '')
  if (!email.includes('@')) return { errors: { email: 'Enter a valid email address.' }, done: false }
  await saveSignup(email)
  return { errors: {}, done: true }
}

export function SignupForm() {
  const [state, action, pending] = useActionState(signup, { errors: {}, done: false })
  // …
}
```

- The action receives the previous state and the `FormData`, and returns the next state.
- `pending` is true while the action runs. Use it to disable the submit button.
- After a successful submission React resets uncontrolled fields. Show the result from `state`.
