# Validation

- Use the browser checks first (`required`, `type`, `min`, `pattern`). They cost nothing and work before JavaScript loads.
- Repeat the checks in the action. The browser checks help the person; the action checks protect the data.
- Return one message per field, written as what to do: "Enter a date after today", not "Invalid date".
- Render the message in an element with an `id`, and point the field to it with `aria-describedby`. Set `aria-invalid` on the field while the message is shown.
- Keep the values the person typed when a submission fails.
