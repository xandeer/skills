# Personal Skills Repository Design

**Date:** 2026-03-06
**Status:** Approved by user intent (`source of truth` + `skills.sh` ecosystem)

## Goal
Build this repository as the single source of truth for personal skills, while staying compatible with `skills.sh` distribution/installation workflows across agent runtimes.

## Context
- User already uses `skills.sh` to manage skills elsewhere.
- This repo is currently an empty git repository.
- Requirement is broad coverage (`all`): generic process skills, stack-specific skills, and personal workflow skills.

## Options Considered

### Option A: Flat skill-only repo
- Structure: only `<skill-name>/SKILL.md` directories at root.
- Pros: minimal and direct.
- Cons: weak governance, no validation or sync automation.

### Option B: Structured source repo (Recommended)
- Structure:
  - `skills/` for all skill packages
  - `scripts/` for validation and sync helpers
  - `docs/` for governance and contribution rules
  - CI to run validation on every commit/PR
- Pros: scalable, auditable, supports versioning and automation.
- Cons: slightly more setup overhead.

### Option C: Generated repo only
- Treat source content elsewhere and generate this repo artifacts.
- Pros: can align with complex pipelines.
- Cons: overkill for personal management; harder local iteration.

## Chosen Design
Adopt **Option B**.

## Repository Architecture

### 1) Skills Layout
- `skills/<skill-name>/SKILL.md` is the compatibility baseline.
- Optional subdirs per skill: `scripts/`, `references/`, `assets/`, `agents/`.
- Naming rule: lowercase letters, digits, hyphens.

### 2) Governance
- `docs/standards/skill-authoring.md` defines:
  - required frontmatter fields (`name`, `description`)
  - naming rules
  - token budget guidance for SKILL body
  - change policy (semantic release notes)

### 3) Validation
- `scripts/validate-skills.sh` validates:
  - skill folder naming
  - `SKILL.md` existence
  - frontmatter presence and key checks
- CI runs validator on push/PR.

### 4) Distribution/Sync
- `scripts/sync-skills.sh` copies `skills/*` to a target directory
  (for local runtime folder mirrors).
- `skills.sh` remains the install/distribution interface; this repo provides canonical content.

### 5) Versioning
- Use git tags/releases for stable snapshots.
- Keep a repository-level changelog for trigger-condition and breaking changes.

## Testing and Verification
- Structural validation script must pass locally.
- CI runs the same script for deterministic checks.
- Include one sample skill to ensure scaffold works end-to-end.

## Risks and Mitigations
- Risk: drift between source and installed directories.
  - Mitigation: sync script + clear target path config.
- Risk: low-quality skill descriptions reduce discoverability.
  - Mitigation: authoring standard with trigger-focused description requirements.
- Risk: slow growth due to inconsistent contribution style.
  - Mitigation: template and checklist in docs.

## Acceptance Criteria
- Repo has a clear source-of-truth layout.
- At least one valid sample skill exists.
- Local validator and CI validator are both in place.
- Sync command can mirror skills to a specified target path.
