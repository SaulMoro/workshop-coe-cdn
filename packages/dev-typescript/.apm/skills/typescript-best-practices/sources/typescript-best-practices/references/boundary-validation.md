# Data from outside the program

A type annotation does not check anything at runtime. Data that comes from a network response, storage, a URL or a file is `unknown` until you check it.

- Check it once, where it enters, and return a typed value. The rest of the code trusts that type.
- Keep the check next to the type it produces, in the module that reads the data.
- If the project already uses a schema library, use it. If not, a small hand-written type guard is enough.
- When the data does not match, fail with a message that names the field and the value that arrived.
