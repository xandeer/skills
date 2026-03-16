# AI-Assisted Development System Evolution Design

**Date:** 2026-03-16
**Status:** Approved by user during brainstorming

## Goal
Define a lightweight mechanism that lets an AI-assisted development system evolve from real interaction patterns, automatically deciding what kind of reusable asset should be created without turning every one-off task into permanent process.

## Context
- The focus is specifically on the AI-assisted development workflow, not general team process.
- The primary problem is not output quality or speed, but that useful AI interaction patterns do not reliably become reusable system assets.
- The user wants the system to judge artifact type automatically from the interaction process itself.
- The preferred timing is hybrid:
  - capture signals during the task
  - make the artifact decision after the task

## Options Considered

### Option A: Post-task retrospective only
- Review the full interaction after each task and manually decide what to preserve.
- Pros:
  - low noise
  - low runtime complexity
- Cons:
  - misses live signals
  - relies too much on memory and manual discipline

### Option B: Real-time self-modifying system
- Update skills, scripts, rules, or templates as soon as patterns appear mid-task.
- Pros:
  - immediate adaptation
- Cons:
  - high noise
  - high risk of encoding one-off behavior as permanent process

### Option C: Hybrid signal capture plus post-task decision (Chosen)
- Capture structured evidence during the task, then decide artifact type once the task is complete.
- Pros:
  - evidence-driven
  - low impulsiveness
  - keeps human review and system growth separate
- Cons:
  - requires a signal model and a decision threshold

## Chosen Design
Adopt **Option C**.

## Design Details

### 1) Signal layer
During a task, the system records structured signals but does not immediately modify system assets.

Signals to capture:
- repeated corrections
- repeated commands or file operations
- repeated explanations of the same judgment standard
- recurring human-supplied constraints
- recurring errors caught manually instead of automatically
- unusually reusable prompts, analyses, or decision criteria

The signal layer should record evidence, not conclusions.

### 2) Decision layer
At task end, the system performs a single decision pass:
1. summarize the strongest 1-3 signals from the interaction
2. classify the best artifact type for those signals
3. recommend one smallest useful action

Possible actions:
- `create`
- `update`
- `ignore`

The system should prefer updating an existing asset over creating a new one when the same problem family is already covered.

### 3) Signal-to-artifact mapping
Use interaction pattern type to decide artifact class.

- repeated decision logic or repeated evaluative reasoning
  - create or update a `skill` or `playbook`
- repeated mechanical steps or command sequences
  - create or update a `script`, `command`, or `automation`
- repeated thinking or delivery structure
  - create or update a `plan template`, `document template`, or `ADR pattern`
- repeated defects discovered by humans
  - create or update a `test`, `lint rule`, or `CI check`
- repeated need for stable project-specific context
  - create or update project-local agent context or references

Decision heuristic:
- high repetition + high judgment = `skill`
- high repetition + high mechanicality = `script`
- high repetition + high structural similarity = `template`
- high repetition + high verifiability = `check`
- low repetition or low payoff = `ignore`

### 4) Anti-bloat rules
The system must default to conservatism.

Only create or update assets when at least one of the following is true:
- the same pattern appears across multiple tasks
- a single occurrence caused unusually high rework cost
- the constraint is clearly stable and long-lived

Hard guardrails:
- no repetition evidence -> do not codify
- no clear payoff -> do not codify
- existing asset can be extended -> do not create a new one

### 5) Operating loop
Daily operation follows a simple loop:

`interaction -> signal capture -> task-end classification -> artifact recommendation -> selective codification -> later reuse -> periodic cleanup`

The system must support deletion as well as addition.

Periodic review questions:
- which assets were reused?
- which assets are now obsolete?
- which assets should be promoted from documentation into scripts or checks?
- which assets add more complexity than value?

## Recommended Output Shape
After each task, the system should emit a short structured summary:

- `Detected pattern`
- `Recommended artifact`
- `Why`
- `Action`

Example:
- `Detected pattern`: repeated manual device UUID lookup
- `Recommended artifact`: script
- `Why`: high repetition, high mechanicality, low judgment cost
- `Action`: create `resolve-device.sh`

## Risks and Mitigations
- Risk: overfitting one-off events into permanent system rules
  - Mitigation: require repetition or unusually high single-task cost
- Risk: excessive system growth
  - Mitigation: prefer `update` over `create` and require cleanup reviews
- Risk: collecting too much raw interaction data
  - Mitigation: record signals, not full narrative logs, unless needed for auditability
- Risk: choosing the wrong artifact type
  - Mitigation: keep mapping rules explicit and review outcomes during periodic cleanup

## Acceptance Criteria
- The system distinguishes signal capture from codification.
- Artifact type is chosen from interaction evidence, not ad-hoc preference.
- The mechanism can recommend `skill`, `script`, `template`, `check`, or `ignore`.
- The mechanism includes hard anti-bloat thresholds.
- The mechanism includes periodic cleanup, not just accumulation.
