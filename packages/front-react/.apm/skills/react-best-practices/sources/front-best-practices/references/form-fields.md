# Form fields

- Every field has a visible `<label>` tied to it with `for` and `id`, or by wrapping the field. A placeholder is not a label.
- Use the input type that matches the data (`email`, `tel`, `number`, `date`), so the browser offers the right keyboard and checks.
- Add `autocomplete` with the standard token (`name`, `email`, `postal-code`) to fields about the person.
- Group related radio buttons or checkboxes in a `<fieldset>` with a `<legend>`.
- Mark a required field with `required` and say so in the label text, not only with colour or an asterisk.
