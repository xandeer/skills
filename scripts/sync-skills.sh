#!/usr/bin/env bash
set -euo pipefail

if [[ "${#}" -ne 1 ]]; then
  echo "Usage: $0 <target-skills-directory>" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="${ROOT_DIR}/skills"
TARGET_DIR="${1}"

if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo "ERROR: source skills directory not found: ${SOURCE_DIR}" >&2
  exit 1
fi

mkdir -p "${TARGET_DIR}"

count=0
while IFS= read -r -d '' skill_dir; do
  skill_name="$(basename "${skill_dir}")"
  rm -rf "${TARGET_DIR}/${skill_name}"
  cp -R "${skill_dir}" "${TARGET_DIR}/${skill_name}"
  ((count++))
done < <(find "${SOURCE_DIR}" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

echo "Synced ${count} skill(s) from '${SOURCE_DIR}' to '${TARGET_DIR}'."
