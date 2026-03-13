# kk-install-device Cache Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a local device cache for `kk-install-device` so device lookup uses `~/.local/share/kk-install-device/devices.tsv` first and only refreshes from `xcrun devicectl list devices` on cache miss.

**Architecture:** Introduce one shell helper script under the skill package to resolve a user-supplied device name into the exact display name and UUID needed by the build/install workflow. The helper owns cache lookup, cache refresh, and error handling. Add a deterministic shell test script that stubs `xcrun`, then update `SKILL.md` to instruct agents to use the helper instead of listing devices directly.

**Tech Stack:** Bash, standard POSIX shell tools, Markdown.

---

### Task 1: Write the failing cache-hit test

**Files:**
- Create: `skills/kk-install-device/scripts/test-resolve-device.sh`

**Step 1: Write a cache-hit test case**
Add a test that:
- creates a temporary `HOME`
- seeds `~/.local/share/kk-install-device/devices.tsv` with one row
- places a stub `xcrun` earlier in `PATH` that fails if called
- runs `skills/kk-install-device/scripts/resolve-device.sh kio`
- expects stdout to equal `Kio iPhone\t04832C21-3945-5E10-89A0-F246713D1C8E`

**Step 2: Run the test to verify it fails**
Run: `bash skills/kk-install-device/scripts/test-resolve-device.sh`
Expected: FAIL because `skills/kk-install-device/scripts/resolve-device.sh` does not exist yet

### Task 2: Implement the minimal cache-hit resolver

**Files:**
- Create: `skills/kk-install-device/scripts/resolve-device.sh`
- Test: `skills/kk-install-device/scripts/test-resolve-device.sh`

**Step 1: Write the minimal implementation**
Implement:
- `set -euo pipefail`
- required device-name argument check
- lowercase normalization of the lookup key
- cache-file lookup in `~/.local/share/kk-install-device/devices.tsv`
- success output as `display_name<TAB>uuid`
- nonzero exit on cache miss

**Step 2: Run the test to verify it passes**
Run: `bash skills/kk-install-device/scripts/test-resolve-device.sh`
Expected: PASS for the cache-hit scenario

### Task 3: Write the failing cache-miss refresh test

**Files:**
- Modify: `skills/kk-install-device/scripts/test-resolve-device.sh`
- Test: `skills/kk-install-device/scripts/resolve-device.sh`

**Step 1: Add a cache-miss test case**
Extend the test script so it:
- starts with no cache file
- provides a stub `xcrun devicectl list devices` output containing at least one real-looking device name and UUID
- records invocations in a temp log
- runs `resolve-device.sh` with the cached-miss device name
- expects:
  - the resolver returns `display_name<TAB>uuid`
  - `devices.tsv` is created
  - `xcrun` was called exactly once

**Step 2: Run the test to verify it fails correctly**
Run: `bash skills/kk-install-device/scripts/test-resolve-device.sh`
Expected: FAIL because cache-miss refresh is not implemented yet

### Task 4: Implement refresh-on-miss behavior

**Files:**
- Modify: `skills/kk-install-device/scripts/resolve-device.sh`
- Test: `skills/kk-install-device/scripts/test-resolve-device.sh`

**Step 1: Extend the resolver**
Implement:
- cache parent directory creation on demand
- one refresh attempt on cache miss via `xcrun devicectl list devices`
- parsing of device display name and UUID into TSV rows
- temporary-file write followed by atomic replacement of `devices.tsv`
- second lookup against the refreshed cache

**Step 2: Run the test suite to verify it passes**
Run: `bash skills/kk-install-device/scripts/test-resolve-device.sh`
Expected: PASS for cache hit and cache miss scenarios

### Task 5: Write the failing refresh-failure and unresolved-device tests

**Files:**
- Modify: `skills/kk-install-device/scripts/test-resolve-device.sh`
- Test: `skills/kk-install-device/scripts/resolve-device.sh`

**Step 1: Add a refresh-failure test case**
Extend the test script so it:
- seeds an existing cache file with known content
- requests a device that is not in cache
- stubs `xcrun devicectl list devices` to exit nonzero
- expects:
  - resolver exits nonzero
  - stderr includes a clear refresh-failed message
  - original cache file content is unchanged

**Step 2: Add an unresolved-after-refresh test case**
Extend the test script so it:
- stubs a successful refresh output that does not include the requested device
- expects:
  - resolver exits nonzero
  - stderr says cache was refreshed but the device still was not found

**Step 3: Run the test suite to verify it fails correctly**
Run: `bash skills/kk-install-device/scripts/test-resolve-device.sh`
Expected: FAIL because refresh error handling and post-refresh miss messaging are not implemented yet

### Task 6: Implement refresh error handling

**Files:**
- Modify: `skills/kk-install-device/scripts/resolve-device.sh`
- Test: `skills/kk-install-device/scripts/test-resolve-device.sh`

**Step 1: Extend the resolver**
Implement:
- refresh command failure detection
- preservation of an existing cache on refresh failure
- clear stderr messages for:
  - refresh command failure
  - device not found after a successful refresh

**Step 2: Run the test suite to verify it passes**
Run: `bash skills/kk-install-device/scripts/test-resolve-device.sh`
Expected: PASS for cache hit, cache miss refresh, refresh failure, and unresolved-after-refresh scenarios

### Task 7: Update the skill instructions

**Files:**
- Modify: `skills/kk-install-device/SKILL.md`

**Step 1: Rewrite the workflow section**
Update the skill so it:
- tells the agent to resolve the device via `skills/kk-install-device/scripts/resolve-device.sh <device>`
- explains that the helper uses `~/.local/share/kk-install-device/devices.tsv`
- explains that cache refresh happens only on cache miss
- removes the hard-coded `Known Devices` table
- documents manual cache reset by deleting the TSV file

**Step 2: Verify the rendered structure**
Run: `rg -n "resolve-device|devices.tsv|Known Devices|cache" skills/kk-install-device/SKILL.md`
Expected:
- references to `resolve-device.sh` and `devices.tsv`
- no `Known Devices` section remains

### Task 8: Final verification and handoff

**Files:**
- Modify: none required

**Step 1: Run structural validation**
Run: `bash scripts/validate-skills.sh`
Expected: `All skills validated successfully.`

**Step 2: Run behavior verification**
Run: `bash skills/kk-install-device/scripts/test-resolve-device.sh`
Expected: all resolver tests pass

**Step 3: Check working tree**
Run: `git status --short`
Expected: only intended plan, skill, and helper-script changes

**Step 4: Commit implementation**
Run:
```bash
git add docs/plans/2026-03-13-kk-install-device-cache.md \
  skills/kk-install-device/SKILL.md \
  skills/kk-install-device/scripts/resolve-device.sh \
  skills/kk-install-device/scripts/test-resolve-device.sh
git commit -m "feat: cache kk install device lookups"
```
Expected: commit created with only the intended cache-related changes
