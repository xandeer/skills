# AI-Assisted Development System Evolution Scenarios

This document defines the verification scenarios for the `evolving-development-system` skill package.

## Scenario 1: Repeated decision logic becomes a skill

**Given**
- multiple tasks required the human to restate the same evaluative rule
- the rule is stable across projects

**Expected**
- the workflow recommends creating or updating a `skill`
- the reason points to repeated judgment, not repeated commands

## Scenario 2: Repeated commands become a script

**Given**
- multiple tasks repeated the same command sequence with minimal variation
- the work is mostly mechanical

**Expected**
- the workflow recommends creating or updating a `script` or automation
- the reason points to mechanical repetition

## Scenario 3: Repeated human-found defects become a check

**Given**
- the same category of mistake was discovered manually at review time more than once
- the failure is machine-detectable

**Expected**
- the workflow recommends creating or updating a `test`, `lint rule`, or `CI check`
- the reason points to verifiability and regression prevention

## Scenario 4: One-off friction is ignored

**Given**
- the issue happened once
- the recovery cost was low
- no stable rule or repeatable pattern is visible

**Expected**
- the workflow recommends `ignore`
- the reason points to low repetition or low payoff

## Scenario 5: Existing assets are extended before new ones are created

**Given**
- a similar skill, script, or template already exists
- the new pattern is part of the same problem family

**Expected**
- the workflow recommends `update`
- the workflow does not create a redundant new asset

## Scenario 6: Capture and codification stay separate

**Given**
- signals are detected during a task

**Expected**
- the workflow records signals during execution
- the workflow defers the codification decision until task end
- the workflow does not mutate the system immediately from one live signal
