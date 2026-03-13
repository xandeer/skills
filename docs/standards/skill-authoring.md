# Skill Authoring Standard

## Purpose

Define conventions for creating and maintaining skills in this repository.

## Folder and File Rules

- Skill folders live under `skills/`.
- Skill folder names must match `^[a-z0-9-]+$`.
- Use kebab-case for folder paths, including namespace prefixes such as `kk-install-device`.
- Every skill folder must include `SKILL.md`.
- Optional subdirectories:
  - `scripts/`
  - `references/`
  - `assets/`
  - `agents/`

## `SKILL.md` Frontmatter Rules

- Frontmatter must exist at the top of `SKILL.md`.
- Required keys:
  - `name`
  - `description`
- `name` may use a namespace prefix such as `kk:install-device`.
- When namespacing is needed, use `-` in the folder path and `:` in `name`:
  - folder path: `skills/kk-install-device/`
  - frontmatter: `name: kk:install-device`
- `name` does not need to match the folder name exactly.
- `description` must describe trigger conditions ("when to use"), not implementation internals.

## Content Guidance

- Keep core workflow concise.
- Move heavy reference content into `references/`.
- Prefer reusable deterministic operations in `scripts/`.
- Avoid duplicating large content between `SKILL.md` and `references/`.

## Quality Gate

- Run `scripts/validate-skills.sh` before commit.
- Keep repository-level changes documented in commit history and release tags.

## Versioning Guidance

- Use tags/releases for stable snapshots.
- Highlight breaking trigger or behavior changes in release notes.
