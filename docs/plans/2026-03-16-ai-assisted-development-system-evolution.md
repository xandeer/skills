# AI-Assisted Development System Evolution Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a reusable skill package that helps an AI-assisted development workflow capture recurring interaction signals and decide whether to codify them as a skill, script, template, check, or ignore.

**Architecture:** Implement this as a new skill in the personal skills repository, with one concise `SKILL.md`, one reference document for the signal-to-artifact mapping, and one reusable post-task review template. Use document-first TDD: write verification scenarios that show the gap before adding the skill content, then add the minimum documentation required to make the workflow reusable and unambiguous.

**Tech Stack:** Markdown, repository skill conventions, Bash validation script.

---

### Task 1: Write the failing verification scenarios

**Files:**
- Create: `docs/plans/2026-03-16-ai-assisted-development-system-evolution-scenarios.md`

**Step 1: Write scenario-based checks**
Document at least these scenarios:
- repeated decision logic should map to a skill
- repeated commands should map to a script
- repeated human-found bugs should map to a check
- one-off friction should map to ignore
- existing asset should be updated instead of creating a duplicate

**Step 2: Verify the gap exists**
Run: `rg -n "evolving-development-system|signal-to-artifact|post-task-review" skills docs`
Expected: no existing skill package or reference covers this workflow completely

### Task 2: Add the minimal skill package

**Files:**
- Create: `skills/evolving-development-system/SKILL.md`
- Test: `docs/plans/2026-03-16-ai-assisted-development-system-evolution-scenarios.md`

**Step 1: Write the minimal skill**
Include:
- trigger-focused frontmatter
- brief overview
- signal-capture vs. codification split
- task-end decision pass
- anti-bloat rules

**Step 2: Verify repository structure**
Run: `bash scripts/validate-skills.sh`
Expected: `All skills validated successfully.`

### Task 3: Add the mapping reference

**Files:**
- Create: `skills/evolving-development-system/references/signal-to-artifact-mapping.md`
- Modify: `skills/evolving-development-system/SKILL.md`

**Step 1: Write the mapping reference**
Document:
- signal classes
- artifact classes
- mapping heuristics
- when to choose `ignore`
- when to prefer `update` over `create`

**Step 2: Link it from the skill**
Update `SKILL.md` so the main body stays concise and points to the reference for details.

**Step 3: Verify discoverability**
Run: `rg -n "signal|artifact|ignore|update|create" skills/evolving-development-system`
Expected: the core terminology appears in the skill and reference files

### Task 4: Add the post-task review template

**Files:**
- Create: `skills/evolving-development-system/assets/post-task-review-template.md`
- Modify: `skills/evolving-development-system/SKILL.md`

**Step 1: Write the template**
Include fixed headings for:
- `Detected pattern`
- `Recommended artifact`
- `Why`
- `Action`

**Step 2: Reference the template from the skill**
Document when to use the template and how it fits into the task-end decision pass.

**Step 3: Verify the template is reusable**
Run: `sed -n '1,200p' skills/evolving-development-system/assets/post-task-review-template.md`
Expected: concise template with stable headings and no project-specific content

### Task 5: Refine the skill against the scenarios

**Files:**
- Modify: `skills/evolving-development-system/SKILL.md`
- Modify: `skills/evolving-development-system/references/signal-to-artifact-mapping.md`
- Test: `docs/plans/2026-03-16-ai-assisted-development-system-evolution-scenarios.md`

**Step 1: Compare skill content to the scenarios**
Check each scenario and confirm the skill gives a deterministic next action.

**Step 2: Tighten loopholes**
Ensure the skill:
- does not recommend codifying one-off issues
- separates signal capture from system mutation
- includes cleanup/deletion, not only accumulation

**Step 3: Re-run validation**
Run: `bash scripts/validate-skills.sh`
Expected: `All skills validated successfully.`

### Task 6: Final verification and handoff

**Files:**
- Modify: none required

**Step 1: Verify intended files**
Run: `git status --short`
Expected: only the new skill package, scenario doc, and plan/design docs are present

**Step 2: Summarize the delivered system**
Confirm the implementation includes:
- one discoverable skill
- one mapping reference
- one reusable post-task review template
- explicit anti-bloat rules

**Step 3: Commit implementation**
Run:
```bash
git add docs/plans/2026-03-16-ai-assisted-development-system-evolution-scenarios.md \
  skills/evolving-development-system/SKILL.md \
  skills/evolving-development-system/references/signal-to-artifact-mapping.md \
  skills/evolving-development-system/assets/post-task-review-template.md
git commit -m "feat: add development system evolution skill"
```
Expected: commit created with only the new skill-related files
