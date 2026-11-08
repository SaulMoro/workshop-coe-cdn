# Dated patterns

Text that made up for the limits of older models. Current models follow plain instructions, and these patterns make them rigid, overcautious or noisy. The scanner only flags candidates: each hit needs a decision.

## pressure-caps

Words in capitals that push the model: `ALWAYS`, `NEVER`, `MUST`, `IMPORTANT`, `CRITICAL`.

- Example: `ALWAYS use the shared banner. NEVER show a raw error.`
- Rewrite: state the rule in normal case and give the reason. `Show errors with the shared banner, so every page explains them the same way.`

## step-by-step

Reasoning fillers such as `think step by step`, `think carefully` or `take a deep breath`.

- Rewrite: delete the sentence. If the order matters, write the steps as a numbered list.

## identity-stub

An identity line that adds nothing, such as `You are an expert React developer.`

- Rewrite: delete it, or replace it with the context the agent really needs: what it works on and what it returns.

## When to keep one

Keep it when it states a real requirement: a security limit, a format a machine reads, a legal constraint. Keep the rule, drop the capitals, add the reason, and say in the review why it stays.
