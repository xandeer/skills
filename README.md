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

## Manage With `skills.sh`

Use `skills.sh` from the target project root when you want a skill installed only for that project. Project scope is the default. Add `-g` only when you want a global install instead.

Example: install `kk-install-device` from this GitHub repository into one project for Claude Code and Codex:

```bash
cd /path/to/your-project

npx skills add https://github.com/xandeer/skills \
  --skill kk-install-device \
  -a claude-code \
  -a codex
```

`skills.sh` also accepts GitHub shorthand such as `xandeer/skills`.

Recommended workflow:

- Run the command from the project root you want to target.
- Prefer `Symlink` when `skills.sh` asks for an installation method.
- Repeat the install in each project that should receive the skill.
- Keep this repository as the single source of truth and avoid manually editing the installed project copies.

Project installs will be created in agent-specific project directories such as `.claude/skills/` and `.agents/skills/`.

## Update Project Installs

Run update commands from the same project root where the skill was installed:

```bash
cd /path/to/your-project

npx skills list
npx skills check
npx skills update
```

If `npx skills list` does not show the skill for that project, `skills.sh` is not managing that install, so `npx skills update` will not update it. In that case:

1. Remove the manually copied or stale project-local skill directory.
2. Reinstall it from the project root with `npx skills add ...`.
3. Verify it appears in `npx skills list` before relying on `check` or `update`.

## Compatibility

The repository uses standard skill package conventions (`SKILL.md` + optional `scripts/`, `references/`, `assets/`), which are compatible with `skills.sh` workflows.
