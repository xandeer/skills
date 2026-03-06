# Personal Skills Repo Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a source-of-truth skills repository compatible with skills.sh, including structure, validation, sync tooling, CI, and one sample skill.

**Architecture:** Store all canonical skill packages under `skills/`. Add shell scripts for validation and directory sync. Add docs for authoring rules. Enforce checks in GitHub Actions so local and CI behavior match.

**Tech Stack:** Bash, POSIX shell tools, GitHub Actions YAML, Markdown.

---

### Task 1: Create repository skeleton

**Files:**
- Create: `skills/.gitkeep`
- Create: `scripts/.gitkeep`
- Create: `docs/standards/.gitkeep`

**Step 1: Create directories**
Run: `mkdir -p skills scripts docs/standards`
Expected: directories exist

**Step 2: Add keep files**
Run: `touch skills/.gitkeep scripts/.gitkeep docs/standards/.gitkeep`
Expected: files created

### Task 2: Add authoring standards

**Files:**
- Create: `docs/standards/skill-authoring.md`

**Step 1: Write standards document**
Include:
- folder naming constraints
- SKILL.md frontmatter constraints
- recommended optional subdirs
- description quality guidance
- release/changelog guidance

**Step 2: Verify readability**
Run: `rg "^#|^##|^- " docs/standards/skill-authoring.md`
Expected: clear sectioned structure

### Task 3: Add validation script

**Files:**
- Create: `scripts/validate-skills.sh`

**Step 1: Write validator**
Checks:
- each `skills/*` directory name matches `^[a-z0-9-]+$`
- `SKILL.md` exists
- frontmatter exists
- `name` and `description` keys exist in frontmatter

**Step 2: Make executable**
Run: `chmod +x scripts/validate-skills.sh`
Expected: executable bit set

### Task 4: Add sync script

**Files:**
- Create: `scripts/sync-skills.sh`

**Step 1: Write sync script**
Behavior:
- require target directory arg
- create target if missing
- copy all skill directories under `skills/` to target
- print completion summary

**Step 2: Make executable**
Run: `chmod +x scripts/sync-skills.sh`
Expected: executable bit set

### Task 5: Add sample skill

**Files:**
- Create: `skills/weekly-review/SKILL.md`

**Step 1: Write minimal valid sample**
Include:
- valid frontmatter (`name`, `description`)
- concise instructions

**Step 2: Run validator (expected pass)**
Run: `scripts/validate-skills.sh`
Expected: `All skills validated successfully.`

### Task 6: Add CI workflow

**Files:**
- Create: `.github/workflows/validate-skills.yml`

**Step 1: Define workflow**
- trigger on push and pull_request
- checkout repo
- run `scripts/validate-skills.sh`

**Step 2: Verify YAML shape**
Run: `rg "^name:|^on:|validate-skills\.sh" .github/workflows/validate-skills.yml`
Expected: expected keys present

### Task 7: Add top-level usage guide

**Files:**
- Create: `README.md`

**Step 1: Document repository usage**
Include:
- repository purpose
- directory map
- local validate command
- local sync command
- skills.sh compatibility note

**Step 2: Smoke test all commands**
Run:
- `scripts/validate-skills.sh`
- `scripts/sync-skills.sh /tmp/personal-skills-sync`
Expected: both commands succeed

### Task 8: Final verification and handoff

**Files:**
- Modify: none required

**Step 1: Collect status**
Run: `git status --short`
Expected: only intended new files

**Step 2: Summarize deliverables**
Provide:
- created files
- validation output summary
- next actions (optional tag/release)
