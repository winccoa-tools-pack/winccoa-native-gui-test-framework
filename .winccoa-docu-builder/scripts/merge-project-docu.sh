#!/usr/bin/env bash
# Merge external projectDocu sources into the worker data/projectDocu tree.
# Rules match @winccoa-tools-pack/npm-winccoa-docu-builder:
#   - top-level files only
#   - advanced_doxygenConfig.txt is concatenated (later keys win)
#   - other files last-wins
#
# Usage:
#   merge-project-docu.sh [source_dir ...]
# Env:
#   REPO_ROOT   repository root (default: auto from script location)
#   WORKER_PATH worker project relative to REPO_ROOT (default: src/Squirt)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd "${SCRIPT_DIR}/../.." && pwd)}"
WORKER_PATH="${WORKER_PATH:-src/Squirt}"
ADVANCED_NAME="advanced_doxygenConfig.txt"

SKIP_NAMES="README.md LICENSE .gitignore .gitattributes .editorconfig .generated-by-docu-builder"
should_skip() {
  case " ${SKIP_NAMES} " in
    *" $1 "*) return 0 ;;
  esac
  return 1
}

TARGET_DIR="${REPO_ROOT}/${WORKER_PATH}/data/projectDocu"
mkdir -p "${TARGET_DIR}"

if [ "$#" -eq 0 ]; then
  echo "usage: $0 <source_dir> [source_dir ...]" >&2
  exit 2
fi

sources=()
for src in "$@"; do
  case "${src}" in
    /*) ;;
    *) src="${REPO_ROOT}/${src}" ;;
  esac
  if [ ! -d "${src}" ]; then
    echo "error: projectDocu source is missing or not a directory: ${src}" >&2
    exit 2
  fi
  sources+=("${src}")
done

advanced_tmp="$(mktemp)"
trap 'rm -f "${advanced_tmp}"' EXIT
: > "${advanced_tmp}"
have_advanced=0
written_list=()

for src in "${sources[@]}"; do
  echo "Merging projectDocu from: ${src}"
  shopt -s nullglob
  for from in "${src}"/*; do
    [ -f "${from}" ] || continue
    name="$(basename "${from}")"
    if should_skip "${name}"; then
      continue
    fi
    to="${TARGET_DIR}/${name}"

    if [ "${name}" = "${ADVANCED_NAME}" ]; then
      {
        printf '# --- projectDocu source: %s ---\n' "${src//\\//}"
        sed '1s/^\xEF\xBB\xBF//' "${from}"
        printf '\n'
      } >> "${advanced_tmp}"
      have_advanced=1
      written_list+=("${name}")
      continue
    fi

    cp -f "${from}" "${to}"
    written_list+=("${name}")
  done
  shopt -u nullglob
done

if [ "${have_advanced}" -eq 1 ]; then
  {
    echo "# Merged by .winccoa-docu-builder/scripts/merge-project-docu.sh"
    echo "# Sources applied top to bottom; later Doxygen keys override earlier ones."
    echo
    cat "${advanced_tmp}"
  } > "${TARGET_DIR}/${ADVANCED_NAME}"
fi

echo "Merged into: ${TARGET_DIR}"
if [ "${#written_list[@]}" -gt 0 ]; then
  printf '%s\n' "${written_list[@]}" | awk 'NF' | sort -u | sed 's/^/  - /'
fi