#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: resolve-device.sh <device-name>" >&2
  exit 1
fi

device_name="$1"
cache_file="${HOME}/.local/share/kk-install-device/devices.tsv"
normalized_name="$(printf '%s' "$device_name" | tr '[:upper:]' '[:lower:]')"

normalize_name() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

sanitize_display_name() {
  local display_name="$1"

  if [[ "$display_name" =~ ^(.+[^[:space:]])[[:space:]]{2,}[^[:space:]]+\.coredevice\.local$ ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
    return 0
  fi

  printf '%s\n' "$display_name"
}

lookup_cache() {
  local lookup_name="$1"
  local cached_name display_name device_uuid sanitized_display_name sanitized_cached_name
  local partial_match_count=0
  local partial_display_name=""
  local partial_device_uuid=""

  if [[ ! -f "$cache_file" ]]; then
    return 1
  fi

  while IFS=$'\t' read -r cached_name display_name device_uuid; do
    sanitized_display_name="$(sanitize_display_name "$display_name")"
    sanitized_cached_name="$(normalize_name "$sanitized_display_name")"

    if [[ "$cached_name" == "$lookup_name" || "$sanitized_cached_name" == "$lookup_name" ]]; then
      printf '%s\t%s\n' "$sanitized_display_name" "$device_uuid"
      return 0
    fi

    if [[ "$cached_name" == *"$lookup_name"* || "$sanitized_cached_name" == *"$lookup_name"* ]]; then
      partial_match_count=$((partial_match_count + 1))
      partial_display_name="$sanitized_display_name"
      partial_device_uuid="$device_uuid"
    fi
  done <"$cache_file"

  if (( partial_match_count == 1 )); then
    printf '%s\t%s\n' "$partial_display_name" "$partial_device_uuid"
    return 0
  fi

  if (( partial_match_count > 1 )); then
    echo "device '$device_name' matched multiple cached devices; use a more specific name" >&2
    return 2
  fi

  return 1
}

refresh_cache() {
  local cache_dir raw_output raw_stderr temp_cache line
  local display_name device_uuid normalized_display

  cache_dir="$(dirname "$cache_file")"
  mkdir -p "$cache_dir"

  raw_output="$(mktemp "$cache_dir/devices.raw.XXXXXX")"
  raw_stderr="$(mktemp "$cache_dir/devices.err.XXXXXX")"
  temp_cache="$(mktemp "$cache_dir/devices.tsv.XXXXXX")"

  if ! xcrun devicectl list devices >"$raw_output" 2>"$raw_stderr"; then
    echo "failed to refresh device cache from xcrun devicectl list devices" >&2
    if [[ -s "$raw_stderr" ]]; then
      cat "$raw_stderr" >&2
    fi
    rm -f "$raw_output" "$raw_stderr" "$temp_cache"
    return 1
  fi

  while IFS= read -r line; do
    if [[ "$line" =~ ^(.+[^[:space:]])[[:space:]]{2,}([^[:space:]]+)[[:space:]]{2,}([A-F0-9-]{36})([[:space:]].*)?$ ]]; then
      display_name="$(sanitize_display_name "${BASH_REMATCH[1]}")"
      device_uuid="${BASH_REMATCH[3]}"
      normalized_display="$(normalize_name "$display_name")"
      printf '%s\t%s\t%s\n' "$normalized_display" "$display_name" "$device_uuid" >>"$temp_cache"
    elif [[ "$line" =~ ^(.+[^[:space:]])[[:space:]]+([A-F0-9-]{36})([[:space:]].*)?$ ]]; then
      display_name="$(sanitize_display_name "${BASH_REMATCH[1]}")"
      device_uuid="${BASH_REMATCH[2]}"
      normalized_display="$(normalize_name "$display_name")"
      printf '%s\t%s\t%s\n' "$normalized_display" "$display_name" "$device_uuid" >>"$temp_cache"
    fi
  done <"$raw_output"

  mv "$temp_cache" "$cache_file"
  rm -f "$raw_output" "$raw_stderr"
}

if lookup_result="$(lookup_cache "$normalized_name")"; then
  printf '%s\n' "$lookup_result"
  exit 0
else
  lookup_status=$?
  if [[ $lookup_status -eq 2 ]]; then
    exit 1
  fi
fi

if ! refresh_cache; then
  exit 1
fi

if lookup_result="$(lookup_cache "$normalized_name")"; then
  printf '%s\n' "$lookup_result"
  exit 0
else
  lookup_status=$?
  if [[ $lookup_status -eq 2 ]]; then
    exit 1
  fi
fi

echo "device '$device_name' not found after refreshing local cache" >&2
exit 1
