#!/usr/bin/env bash
# Registers Squirt as a WinCC OA sub-project. Optional: set WINCCOA_VERSION (e.g. 3.22).
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
squirt_path="$(cd -- "${script_dir}/../src/Squirt" && pwd)"

if [[ ! -d "${squirt_path}/config" ]]; then
  printf 'activateMe: Squirt project not found: %s\n' "${squirt_path}" >&2
  exit 1
fi

version_args=()
if [[ -n "${WINCCOA_VERSION:-}" ]]; then
  version_args=(--wincc-oa-version "${WINCCOA_VERSION}")
fi

npx --yes @winccoa-tools-pack/npm-winccoa-register-project \
  --project-path "${squirt_path}" --runnable false ${version_args[@]+"${version_args[@]}"}
