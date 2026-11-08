# Form libraries

React 19 actions cover most forms: a few fields, one submit, validation per field.

Consider a library when the form has many fields that depend on each other, dynamic lists of fields, or several steps that keep their state. Before you add one:

- Check whether the project already uses one, and use that.
- Prefer one that works with uncontrolled inputs and native validation.
- Keep validation rules in one place that both the library and the action can use.
