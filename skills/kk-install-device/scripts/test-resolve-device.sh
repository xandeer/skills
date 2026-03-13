#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
RESOLVER="$ROOT_DIR/skills/kk-install-device/scripts/resolve-device.sh"
EXPECTED_UUID="04832C21-3945-5E10-89A0-F246713D1C8E"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_eq() {
  local expected="$1"
  local actual="$2"
  local message="$3"

  if [[ "$expected" != "$actual" ]]; then
    fail "$message: expected [$expected] got [$actual]"
  fi
}

assert_file_has_line() {
  local file_path="$1"
  local expected_line="$2"
  local message="$3"

  if ! grep -Fqx "$expected_line" "$file_path"; then
    fail "$message: missing [$expected_line] in [$file_path]"
  fi
}

assert_contains() {
  local needle="$1"
  local haystack="$2"
  local message="$3"

  if [[ "$haystack" != *"$needle"* ]]; then
    fail "$message: expected [$haystack] to contain [$needle]"
  fi
}

run_cache_hit_test() {
  local temp_home bin_dir stdout_file stderr_file call_log
  temp_home="$(mktemp -d)"
  bin_dir="$temp_home/bin"
  stdout_file="$temp_home/stdout"
  stderr_file="$temp_home/stderr"
  call_log="$temp_home/xcrun.log"

  mkdir -p "$bin_dir" "$temp_home/.local/share/kk-install-device"
  cat >"$bin_dir/xcrun" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "unexpected xcrun invocation" >>"$XCRUN_CALL_LOG"
exit 99
EOF
  chmod +x "$bin_dir/xcrun"

  printf 'kio iphone\tKio iPhone\t%s\n' "$EXPECTED_UUID" >"$temp_home/.local/share/kk-install-device/devices.tsv"

  if ! HOME="$temp_home" PATH="$bin_dir:$PATH" XCRUN_CALL_LOG="$call_log" \
    bash "$RESOLVER" kio >"$stdout_file" 2>"$stderr_file"; then
    fail "cache-hit resolver invocation should succeed"
  fi

  assert_eq "$(printf 'Kio iPhone\t%s' "$EXPECTED_UUID")" "$(cat "$stdout_file")" \
    "cache-hit output mismatch"

  if [[ -f "$call_log" ]]; then
    fail "cache-hit path should not call xcrun"
  fi
}

run_cache_miss_refresh_test() {
  local temp_home bin_dir stdout_file stderr_file call_log cache_file
  temp_home="$(mktemp -d)"
  bin_dir="$temp_home/bin"
  stdout_file="$temp_home/stdout"
  stderr_file="$temp_home/stderr"
  call_log="$temp_home/xcrun.log"
  cache_file="$temp_home/.local/share/kk-install-device/devices.tsv"

  mkdir -p "$bin_dir"
  cat >"$bin_dir/xcrun" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "$*" >>"$XCRUN_CALL_LOG"
if [[ "${1-}" == "devicectl" && "${2-}" == "list" && "${3-}" == "devices" ]]; then
  cat <<'OUT'
Name                Identifier                            State
Kio iPhone          04832C21-3945-5E10-89A0-F246713D1C8E  connected
QA iPad             11111111-2222-3333-4444-555555555555  connected
OUT
  exit 0
fi
echo "unexpected xcrun arguments: $*" >&2
exit 98
EOF
  chmod +x "$bin_dir/xcrun"

  if ! HOME="$temp_home" PATH="$bin_dir:$PATH" XCRUN_CALL_LOG="$call_log" \
    bash "$RESOLVER" "qa" >"$stdout_file" 2>"$stderr_file"; then
    fail "cache-miss resolver invocation should succeed after refresh"
  fi

  assert_eq "QA iPad	11111111-2222-3333-4444-555555555555" "$(cat "$stdout_file")" \
    "cache-miss output mismatch"
  assert_eq "devicectl list devices" "$(cat "$call_log")" \
    "cache-miss should refresh devices exactly once"
  assert_file_has_line "$cache_file" "qa ipad	QA iPad	11111111-2222-3333-4444-555555555555" \
    "cache-miss should write refreshed device to cache"
}

run_refresh_failure_test() {
  local temp_home bin_dir stdout_file stderr_file call_log cache_file original_cache
  temp_home="$(mktemp -d)"
  bin_dir="$temp_home/bin"
  stdout_file="$temp_home/stdout"
  stderr_file="$temp_home/stderr"
  call_log="$temp_home/xcrun.log"
  cache_file="$temp_home/.local/share/kk-install-device/devices.tsv"
  original_cache="$(printf 'kio\tKio iPhone\t%s\n' "$EXPECTED_UUID")"

  mkdir -p "$bin_dir" "$(dirname "$cache_file")"
  cat >"$bin_dir/xcrun" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "$*" >>"$XCRUN_CALL_LOG"
echo "CoreDevice unavailable" >&2
exit 7
EOF
  chmod +x "$bin_dir/xcrun"
  printf '%s' "$original_cache" >"$cache_file"

  if HOME="$temp_home" PATH="$bin_dir:$PATH" XCRUN_CALL_LOG="$call_log" \
    bash "$RESOLVER" "qa" >"$stdout_file" 2>"$stderr_file"; then
    fail "refresh failure should make resolver exit nonzero"
  fi

  assert_eq "devicectl list devices" "$(cat "$call_log")" \
    "refresh failure should attempt exactly one refresh"
  assert_contains "failed to refresh device cache" "$(cat "$stderr_file")" \
    "refresh failure should explain the refresh error"
  assert_eq "$original_cache" "$(cat "$cache_file")" \
    "refresh failure should preserve existing cache"
}

run_unresolved_after_refresh_test() {
  local temp_home bin_dir stdout_file stderr_file call_log cache_file
  temp_home="$(mktemp -d)"
  bin_dir="$temp_home/bin"
  stdout_file="$temp_home/stdout"
  stderr_file="$temp_home/stderr"
  call_log="$temp_home/xcrun.log"
  cache_file="$temp_home/.local/share/kk-install-device/devices.tsv"

  mkdir -p "$bin_dir"
  cat >"$bin_dir/xcrun" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "$*" >>"$XCRUN_CALL_LOG"
if [[ "${1-}" == "devicectl" && "${2-}" == "list" && "${3-}" == "devices" ]]; then
  cat <<'OUT'
Name                Identifier                            State
Kio iPhone          04832C21-3945-5E10-89A0-F246713D1C8E  connected
OUT
  exit 0
fi
echo "unexpected xcrun arguments: $*" >&2
exit 98
EOF
  chmod +x "$bin_dir/xcrun"

  if HOME="$temp_home" PATH="$bin_dir:$PATH" XCRUN_CALL_LOG="$call_log" \
    bash "$RESOLVER" "qa" >"$stdout_file" 2>"$stderr_file"; then
    fail "resolver should fail when refreshed cache still lacks the device"
  fi

  assert_eq "devicectl list devices" "$(cat "$call_log")" \
    "unresolved device should perform exactly one refresh"
  assert_contains "not found after refreshing local cache" "$(cat "$stderr_file")" \
    "unresolved device should explain that refresh already happened"
  assert_file_has_line "$cache_file" "kio iphone	Kio iPhone	$EXPECTED_UUID" \
    "unresolved device should still persist the refreshed cache"
}

run_cache_hit_test
run_cache_miss_refresh_test
run_refresh_failure_test
run_unresolved_after_refresh_test
echo "PASS: resolve-device cache hit, refresh, and error scenarios"
