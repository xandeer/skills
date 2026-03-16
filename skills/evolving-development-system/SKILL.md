---
name: evolving-development-system
description: Use when an AI-assisted development workflow shows repeated corrections, commands, explanations, or review failures and you need to decide whether to codify the pattern as a reusable system asset.
---

# Evolving Development System

Treat the development system as a product. Capture evidence during work, then decide after the task whether the pattern should become a reusable asset.

## Use This Workflow

- The same judgment rule had to be restated more than once
- The same commands or file operations kept repeating
- The same class of review bug was found manually again
- The same delivery structure had to be rebuilt from scratch
- Stable project context had to be re-explained for the AI to work correctly

## Core Rule

Split the workflow into two phases:

1. `signal capture` during the task
2. `codification decision` after the task

Do not mutate the system in the middle of the task just because one signal appeared.

## Signal Capture

During the task, record only structured evidence:

- repeated corrections
- repeated commands
- repeated explanations
- recurring human-supplied constraints
- recurring human-found errors
- unusually reusable prompts or decision criteria

Do not decide the artifact type yet.

## Task-End Decision

At the end of the task:

1. summarize the strongest 1-3 signals
2. choose one best artifact type
3. prefer `update` over `create`
4. choose `ignore` when repetition or payoff is weak

Use the mapping reference in [`references/signal-to-artifact-mapping.md`](references/signal-to-artifact-mapping.md).

## Anti-Bloat Rules

- No repetition evidence: do not codify
- No clear payoff: do not codify
- Existing asset can absorb the change: update it
- One-off friction with low cost: ignore it
- Review the system periodically and delete low-value assets

## Output

Use the post-task template in [`assets/post-task-review-template.md`](assets/post-task-review-template.md):

- `Detected pattern`
- `Recommended artifact`
- `Why`
- `Action`
