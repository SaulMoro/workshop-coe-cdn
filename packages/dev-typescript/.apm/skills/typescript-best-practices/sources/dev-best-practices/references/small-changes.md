# Small changes

- One purpose per change. A refactor and a behaviour change go in separate commits, so each one can be reviewed and reverted alone.
- Before you change behaviour, make sure a test covers it. If none does, add one first and watch it pass.
- Prefer the change that touches the fewest files. If a change needs many files, look for a first step that prepares the ground without changing behaviour.
- Leave the code you touch a little clearer, but do not reformat files you are not otherwise changing.
- When you stop halfway, the code still builds and the tests still pass.
