# Repository Guidelines

## Project Structure & Module Organization
This repository is the source of truth for personal skills content.
Use this repository to maintain local skill source content, and use `skills.sh` to distribute or install those skills into a runtime environment.

- `skills/`: skill packages, one folder per skill (example: `skills/weekly-review/`).
- `skills/<skill-name>/SKILL.md`: required entry file for each skill.
- `scripts/`: maintenance tooling (`validate-skills.sh`, `sync-skills.sh`).
- `docs/standards/`: authoring conventions (see `skill-authoring.md`).
- `docs/plans/`: design and implementation plans.
- `.github/workflows/`: CI checks (currently skill validation).

Use lowercase kebab-case for skill folders: `my-skill-name`.

## Build, Test, and Development Commands
No build step is required. Use these commands during development:

- `bash scripts/validate-skills.sh`: validates skill folder names and required `SKILL.md` frontmatter keys.
- `bash scripts/sync-skills.sh /tmp/personal-skills-sync`: mirrors `skills/` to a target runtime directory.
- `find skills -maxdepth 2 -type f`: quick inspection of skill files.

Run validation before every commit.

## Coding Style & Naming Conventions
- Prefer ASCII content unless a file already requires Unicode.
- Use clear, short Markdown sections and actionable wording.
- In `SKILL.md`, frontmatter must include only:
  - `name: <skill-name>`
  - `description: <trigger-focused description>`
- Keep descriptions focused on **when to use** the skill.
- Shell scripts should use `bash`, `set -euo pipefail`, and explicit error messages.

## Testing Guidelines
Primary test gate is structural validation:

1. Run `bash scripts/validate-skills.sh`.
2. Smoke test sync with `bash scripts/sync-skills.sh <target-dir>`.
3. Confirm copied skill exists at `<target-dir>/<skill-name>/SKILL.md`.

When adding scripts, include at least one runnable example in docs or comments.

## Commit & Pull Request Guidelines
This repo currently has no commit history; use this convention going forward:

- Commit format: `type: short summary` (examples: `feat: add planning skill`, `chore: tighten validator`).
- Keep commits scoped to one change set (skill content, tooling, or docs).
- PRs should include:
  - purpose and scope,
  - commands run and results,
  - impacted paths (for example, `skills/*`, `scripts/*`),
  - migration notes if behavior changes.
