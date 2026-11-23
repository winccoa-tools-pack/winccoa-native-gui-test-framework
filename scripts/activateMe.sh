#!/usr/bin/env bash
# Registers Splash as a WinCC OA sub-project. Optional: set WINCCOA_VERSION (e.g. 3.22).
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
splash_path="$(cd -- "${script_dir}/../src/Splash" && pwd)"

if [[ ! -d "${splash_path}/scripts" ]]; then
  printf 'activateMe: Splash project not found: %s\n' "${splash_path}" >&2
  exit 1
fi

version_args=()
if [[ -n "${WINCCOA_VERSION:-}" ]]; then
  version_args=(--wincc-oa-version "${WINCCOA_VERSION}")
fi

npx --yes @winccoa-tools-pack/npm-winccoa-register-project \
  --project-path "${splash_path}" --runnable false ${version_args[@]+"${version_args[@]}"}
