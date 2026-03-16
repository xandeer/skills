# Signal-to-Artifact Mapping

Use this reference after the task, once the strongest signals have been summarized.

## Signal Classes

- repeated decision logic
- repeated commands or file operations
- repeated delivery or analysis structure
- repeated human-found defects
- repeated need for stable project context

## Artifact Classes

- `skill`
- `script`
- `template`
- `check`
- `project context`
- `ignore`

## Mapping Rules

### Repeated decision logic -> `skill`

Choose a `skill` when the same judgment standard or reasoning flow must be restated across tasks.

Good fit:
- prioritization rules
- debugging process
- review heuristics
- decision trees

### Repeated commands or file operations -> `script`

Choose a `script` when the work is mostly mechanical and repeated with small variation.

Good fit:
- repeated shell sequences
- repeated sync or install steps
- repeated file generation

### Repeated structure -> `template`

Choose a `template` when the same shape keeps reappearing but the content changes.

Good fit:
- implementation plans
- design docs
- post-task reviews
- release notes

### Repeated human-found defects -> `check`

Choose a `check` when humans keep catching the same issue and a machine can verify it.

Good fit:
- tests
- lint rules
- CI assertions
- validators

### Repeated stable project context -> `project context`

Choose project-local context when the AI needs the same durable background to work correctly.

Good fit:
- repository conventions
- deployment constraints
- naming rules
- architecture boundaries

### Weak signal or weak payoff -> `ignore`

Choose `ignore` when:
- the issue happened only once
- the cost was low
- the pattern is unstable
- no reusable asset would reduce future cost meaningfully

## Decision Heuristics

- high repetition + high judgment = `skill`
- high repetition + high mechanicality = `script`
- high repetition + high structural similarity = `template`
- high repetition + high verifiability = `check`
- high repetition + stable local background = `project context`
- low repetition or low payoff = `ignore`

## Create vs. Update

Prefer `update` when:
- an existing asset already covers the same problem family
- the new rule is a refinement, not a distinct workflow
- adding the new case keeps the system easier to search

Prefer `create` when:
- the pattern is materially different from existing assets
- forcing it into an old asset would make that asset harder to use

## Anti-Bloat Reminder

Do not codify just because something was annoying once. Reuse value must exceed the cost of carrying the asset.
