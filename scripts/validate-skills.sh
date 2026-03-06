#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="${ROOT_DIR}/skills"

if [[ ! -d "${SKILLS_DIR}" ]]; then
  echo "ERROR: skills directory not found: ${SKILLS_DIR}" >&2
  exit 1
fi

error_count=0

while IFS= read -r -d '' skill_dir; do
  skill_name="$(basename "${skill_dir}")"
  skill_md="${skill_dir}/SKILL.md"

  if [[ ! "${skill_name}" =~ ^[a-z0-9-]+$ ]]; then
    echo "ERROR: invalid skill directory name '${skill_name}'"
    ((error_count++))
  fi

  if [[ ! -f "${skill_md}" ]]; then
    echo "ERROR: missing SKILL.md in '${skill_name}'"
    ((error_count++))
    continue
  fi

  if ! head -n 1 "${skill_md}" | grep -q '^---$'; then
    echo "ERROR: missing frontmatter start in '${skill_name}/SKILL.md'"
    ((error_count++))
    continue
  fi

  if ! awk 'NR>1 && /^---$/ { print NR; exit }' "${skill_md}" | grep -q '^[0-9]\+$'; then
    echo "ERROR: missing frontmatter end in '${skill_name}/SKILL.md'"
    ((error_count++))
    continue
  fi

  fm_end_line="$(awk 'NR>1 && /^---$/ { print NR; exit }' "${skill_md}")"
  frontmatter="$(sed -n "2,$((fm_end_line-1))p" "${skill_md}")"

  if ! grep -q '^name:[[:space:]]*' <<< "${frontmatter}"; then
    echo "ERROR: missing 'name' in '${skill_name}/SKILL.md' frontmatter"
    ((error_count++))
  fi

  if ! grep -q '^description:[[:space:]]*' <<< "${frontmatter}"; then
    echo "ERROR: missing 'description' in '${skill_name}/SKILL.md' frontmatter"
    ((error_count++))
  fi
done < <(find "${SKILLS_DIR}" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

if [[ "${error_count}" -gt 0 ]]; then
  echo "Validation failed with ${error_count} error(s)."
  exit 1
fi

echo "All skills validated successfully."
