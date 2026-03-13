# kk-install-device Cache Design

**Date:** 2026-03-13
**Status:** Approved by user during brainstorming

## Goal
Stop `kk-install-device` from listing connected devices on every invocation by maintaining a single local cache of device names and UUIDs, and only refreshing that cache when the requested device is not already cached.

## Context
- The current skill in `skills/kk-install-device/SKILL.md` instructs the agent to run `xcrun devicectl list devices` every time it needs a device UUID.
- The user wants the device list to be maintained locally instead.
- The cache must be machine-local, not committed into this repository.
- The cache location must not depend on a specific agent runtime such as Codex or Claude Code.
- Refresh policy is explicit: only refresh when the requested device name is not found in the local cache.

## Options Considered

### Option A: Single local cache in a cross-agent user directory (Chosen)
- Store a single cache file at `~/.local/share/kk-install-device/devices.tsv`.
- Read that file first and refresh it only on cache miss.
- Pros:
  - one source of truth per machine
  - no repository-local mutable state
  - works across Codex and Claude Code
  - easy to inspect and debug with standard shell tools
- Cons:
  - requires a small helper script to manage parsing and refresh behavior

### Option B: Agent-specific cache directories
- Keep a separate cache in each runtime's private storage.
- Pros:
  - straightforward if a runtime already exposes a stable state directory
- Cons:
  - duplicates state
  - breaks the user's requirement to maintain one local device list
  - couples the skill to runtime-specific conventions

### Option C: Keep `Known Devices` inside `SKILL.md`
- Manually maintain the UUID map in documentation.
- Pros:
  - no helper script required
- Cons:
  - manual drift is guaranteed
  - local device state does not belong in the shared repository
  - fails the requirement to update only when needed

## Chosen Design
Adopt **Option A**.

## Design Details

### 1) Cache location and format
- Cache file path: `~/.local/share/kk-install-device/devices.tsv`
- Parent directory is created on demand.
- File format is tab-separated text with one device per line:
  - column 1: normalized lookup name
  - column 2: original display name from `devicectl`
  - column 3: device UUID
- Example row:

```text
kio	Kio’s iPhone	04832C21-3945-5E10-89A0-F246713D1C8E
```

- Normalized lookup name is lowercase to support case-insensitive matching with simple shell tools.
- `display_name` is preserved so the build step can continue using the exact device name.

### 2) Lookup and refresh flow
1. Normalize the user-supplied device name to lowercase.
2. Look up that normalized name in the first column of `devices.tsv`.
3. If found, use the cached `display_name` and `uuid` directly.
4. If not found, run `xcrun devicectl list devices` once.
5. Parse the command output into TSV rows and overwrite the cache.
6. Retry the lookup against the freshly written cache.
7. If the device is still not found, fail with a clear message saying the cache was refreshed but no matching connected device was detected.

### 3) Build, install, and launch behavior
- Keep the existing build/install flow.
- Use cached `display_name` for:

```bash
xcodebuild -destination 'platform=iOS,name=<display_name>'
```

- Use cached `uuid` for install and optional launch:

```bash
xcrun devicectl device install app --device <uuid> <app-path>
xcrun devicectl device process launch --device <uuid> <bundle-id>
```

### 4) Failure handling
- Missing cache file is normal and should not be treated as an error.
- Refresh failures must not destroy a previously good cache.
  - Write refreshed content to a temporary file first.
  - Replace the main cache only after parse/write succeeds.
- If `xcrun devicectl list devices` fails, report refresh failure clearly and preserve the existing cache.
- Parsing should only depend on device name and UUID fields, ignoring extra columns so the skill is less brittle to `devicectl` formatting changes.

### 5) Skill documentation changes
- Remove the hard-coded `Known Devices` table from `skills/kk-install-device/SKILL.md`.
- Replace it with:
  - cache file location
  - cache-miss refresh rule
  - manual reset note (`rm ~/.local/share/kk-install-device/devices.tsv` if the user wants to force a rebuild)
- Prefer referencing helper scripts from the skill rather than embedding large command snippets inline.

## Testing and Verification
- Keep repository structural validation:

```bash
bash scripts/validate-skills.sh
```

- Add behavior verification for the helper script:
  - cache hit path does not invoke `devicectl`
  - cache miss path refreshes once and resolves the device
  - refresh failure preserves an existing cache
  - unresolved device after refresh returns a clear failure

- Use shell-based tests with stubbed `xcrun` output so behavior is deterministic and does not require an attached device.

## Risks and Mitigations
- Risk: `devicectl` output format changes.
  - Mitigation: isolate parsing in one helper script and test against representative sample output.
- Risk: stale cache points to renamed or disconnected devices.
  - Mitigation: refresh automatically on cache miss and document manual cache deletion.
- Risk: clobbering a good cache on transient refresh failure.
  - Mitigation: write to a temporary file and replace atomically on success only.

## Acceptance Criteria
- `kk-install-device` no longer instructs the agent to list devices on every run.
- The skill resolves known devices from `~/.local/share/kk-install-device/devices.tsv`.
- A cache miss refreshes the cache once and retries the lookup.
- A refresh failure preserves the previous cache.
- The repository contains deterministic verification coverage for cache hit, cache miss, and refresh error behavior.
