# Personal Skills (Source of Truth)

This repository is the canonical source for personal skills content.
Use this repository to maintain local skill source content, and use `skills.sh` to distribute or install those skills into a runtime environment.

## Structure

- `skills/`: all skill packages (`<path-name>/SKILL.md`)
- `scripts/`: repository tooling (currently validation)
- `docs/standards/`: authoring and governance conventions
- `docs/plans/`: design and implementation planning documents

## Naming

- Skill folder paths use lowercase kebab-case, including namespace prefixes such as `kk-install-device`.
- `SKILL.md` frontmatter `name` may use a namespace prefix such as `kk:install-device`.
- When namespacing is needed, use `-` in the folder path and `:` in `name`.

## Local Usage

Validate all skills:

```bash
scripts/validate-skills.sh
```

## Compatibility

The repository uses standard skill package conventions (`SKILL.md` + optional `scripts/`, `references/`, `assets/`), which are compatible with `skills.sh` workflows.
