# Personal Skills (Source of Truth)

This repository is the canonical source for personal skills content that can be distributed with `skills.sh`.

## Structure

- `skills/`: all skill packages (`<skill-name>/SKILL.md`)
- `scripts/`: repository tooling (validation and sync)
- `docs/standards/`: authoring and governance conventions
- `docs/plans/`: design and implementation planning documents

## Local Usage

Validate all skills:

```bash
scripts/validate-skills.sh
```

Sync skills to a local runtime directory:

```bash
scripts/sync-skills.sh /path/to/target/skills
```

Example:

```bash
scripts/sync-skills.sh /tmp/personal-skills-sync
```

## Compatibility

The repository uses standard skill package conventions (`SKILL.md` + optional `scripts/`, `references/`, `assets/`), which are compatible with `skills.sh` workflows.
