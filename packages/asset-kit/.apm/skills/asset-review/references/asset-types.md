# Asset types and the vault boundary

## Type

| Type | Choose it when |
|---|---|
| Skill | The default. Knowledge or a procedure the agent loads when a task needs it, even if it started life as a prompt or a command. |
| Instruction | A rule that has to be present whenever someone edits certain files, selected with `applyTo`. Keep it short and let it load a skill for the details. |
| Agent | A recurring role that works in its own context and returns a bounded result, such as a reviewer that only reports findings. |
| Hook | Code that has to run on a client event, for example when the agent stops, whatever the agent decides. |
| MCP server | Only when the task needs session state or credentials that a command-line tool or a script cannot provide. |

A piece with the wrong type usually works for a while. Say which type fits, and why, in one line.

## Place

- Same scope, same set. A different scope, a different set.
- What helps with any task goes in the base of the dependency line, not in every set.
- An asset only loads skills from its own dependency line.
- A set with a narrower scope than an existing set depends on it. If a piece fits the existing set as it is, say so: the owner of that set decides.

## The vault boundary

The vault serves many repositories. A piece that names one of them breaks in all the others.

- No clients, products, project names or people.
- No paths of a particular repository: no page such as `src/features/users/UsersPage.tsx` and no `.github/` folder. Those belong to the repository that has them.
- A hook or a script in the vault only names paths that the export creates (`.agents/skills/<skill>/…`, `.agents/hooks/…`) or paths it receives as arguments.
- To fix a hook that names a repository path, point it to `.agents/skills/<skill>/scripts/<script>` and let the script find what to check, for example the files that changed, or receive it as an argument. The other way out is to keep the hook in the repository it belongs to.

## Names

- Lower case with hyphens. A set is named after its layer first, then its specialisation: `front-ui-states`.
- A skill is named like its folder and an agent like its file. No name repeats anywhere in the vault.
