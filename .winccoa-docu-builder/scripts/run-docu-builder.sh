#!/usr/bin/env bash
# Local / CI helper: prepare theme+overrides, then run winccoa-docu-builder.
#
# Usage:
#   ./run-docu-builder.sh              # prepare + build
#   ./run-docu-builder.sh prepare      # merge only
#   ./run-docu-builder.sh build        # prepare + build (default)
#   ./run-docu-builder.sh register     # prepare + register only
#
# Env (common):
#   REPO_ROOT, WORKER_PATH, THEME_*, PROJECT_DOCU_PATHS, SKIP_THEME_FETCH
#   WINCCOA_VERSION   default 3.21
#   COMPANY_NAME      default winccoa-tools-pack
#   PACKAGE_VERSION   default 0.2.1 (npm install when CLI missing)
#   PACKAGE_SPEC      full npm install spec override
#   SKIP_PREPARE=1    skip theme fetch/merge (CLI still merges --project-docu)
#   DOCU_ARGS         extra args appended to the CLI
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd "${SCRIPT_DIR}/../.." && pwd)}"
WORKER_PATH="${WORKER_PATH:-src/Squirt}"
WINCCOA_VERSION="${WINCCOA_VERSION:-3.21}"
COMPANY_NAME="${COMPANY_NAME:-winccoa-tools-pack}"
PACKAGE_VERSION="${PACKAGE_VERSION:-0.2.1}"
PACKAGE_SPEC="${PACKAGE_SPEC:-@winccoa-tools-pack/npm-winccoa-docu-builder@${PACKAGE_VERSION}}"
THEME_PATH="${THEME_PATH:-.docu-builder-theme}"
SKIP_PREPARE="${SKIP_PREPARE:-0}"

cmd="${1:-build}"
if [ "$#" -gt 0 ]; then
  shift
fi

cd "${REPO_ROOT}"
mkdir -p "${REPO_ROOT}/.artifacts"

prepare() {
  if [ "${SKIP_PREPARE}" = "1" ]; then
    echo "SKIP_PREPARE=1 - not running prepare-project-docu.sh"
    return 0
  fi
  "${SCRIPT_DIR}/prepare-project-docu.sh"
}

resolve_cli() {
  # Prints ONLY invocation tokens to stdout, NUL-separated.
  # Human messages go to stderr so command substitution stays clean.
  local pkg_root cli_js bin_shim

  if command -v winccoa-docu-builder >/dev/null 2>&1; then
    printf '%s\0' "$(command -v winccoa-docu-builder)"
    return 0
  fi

  pkg_root="${REPO_ROOT}/node_modules/@winccoa-tools-pack/npm-winccoa-docu-builder"
  cli_js="${pkg_root}/dist/cjs/cli.js"
  bin_shim="${REPO_ROOT}/node_modules/.bin/winccoa-docu-builder"

  if [ ! -f "${cli_js}" ]; then
    echo "Installing ${PACKAGE_SPEC} into ${REPO_ROOT} (local helper bootstrap)..." >&2
    npm install --no-save --prefix "${REPO_ROOT}" "${PACKAGE_SPEC}" >&2
  fi

  if [ -f "${cli_js}" ] && command -v node >/dev/null 2>&1; then
    # Prefer node + entry script: reliable under Git Bash/MSYS on Windows
    # where .bin shims may lack +x or need cmd.exe.
    printf '%s\0' "node" "${cli_js}"
    return 0
  fi

  if [ -f "${bin_shim}" ]; then
    printf '%s\0' "${bin_shim}"
    return 0
  fi
  if [ -f "${bin_shim}.cmd" ]; then
    printf '%s\0' "${bin_shim}.cmd"
    return 0
  fi

  echo "error: winccoa-docu-builder CLI not found after install" >&2
  echo "expected: ${cli_js}" >&2
  return 127
}

project_docu_args() {
  local paths=()
  if [ -n "${PROJECT_DOCU_PATHS:-}" ]; then
    while IFS= read -r line || [ -n "${line}" ]; do
      line="$(echo "${line}" | xargs)"
      [ -z "${line}" ] && continue
      paths+=("${line}")
    done < <(printf '%s\n' "${PROJECT_DOCU_PATHS}" | tr ',;' '\n')
  else
    paths+=("${THEME_PATH}" ".winccoa-docu-builder")
  fi
  local out=()
  for p in "${paths[@]}"; do
    out+=(--project-docu "${p}")
  done
  printf '%s\n' "${out[@]}"
}

run_cli() {
  local subcmd="$1"
  shift || true
  local -a cli_cmd=()
  local -a docu_flags=()
  mapfile -d '' -t cli_cmd < <(resolve_cli)
  mapfile -t docu_flags < <(project_docu_args)

  local -a args=(
    "${subcmd}"
    "${WORKER_PATH}"
    -v "${WINCCOA_VERSION}"
  )
  if [ "${subcmd}" = "build" ]; then
    args+=(-c "${COMPANY_NAME}")
  fi
  args+=("${docu_flags[@]}")
  if [ -n "${DOCU_ARGS:-}" ]; then
    # shellcheck disable=SC2206
    extra=( ${DOCU_ARGS} )
    args+=("${extra[@]}")
  fi
  args+=("$@")

  echo "Running: ${cli_cmd[*]} ${args[*]}"
  "${cli_cmd[@]}" "${args[@]}"
}

# Fallback for older published packages that leave OA temp absolute paths in
# WARN_LOGFILE. Newer npm-winccoa-docu-builder already rewrites this in-process.
normalize_warn_logfile() {
  local log_path="${REPO_ROOT}/${WORKER_PATH}/log/doxygen_warn_logfile.txt"
  local worker_rel tmp
  [ -f "${log_path}" ] || return 0
  worker_rel="${WORKER_PATH#./}"
  worker_rel="${worker_rel%/}"
  tmp="$(mktemp)"
  # Strip any host prefix up to and including WinCC_OA_docuGenerator/, then
  # prefix the public worker-relative path. Also drop container workspace roots.
  sed -E \
    -e "s|([^:[:space:]]*/)?WinCC_OA_docuGenerator/|${worker_rel}/|g" \
    -e "s|^/workspace/||" \
    -e "s|^/github/workspace/||" \
    "${log_path}" > "${tmp}"
  if ! cmp -s "${log_path}" "${tmp}"; then
    mv -f "${tmp}" "${log_path}"
    echo "Normalized absolute paths in ${log_path}"
  else
    rm -f "${tmp}"
  fi
}

case "${cmd}" in
  prepare|merge)
    prepare
    ;;
  build)
    prepare
    run_cli build "$@"
    normalize_warn_logfile
    ;;
  register)
    prepare
    run_cli register "$@"
    ;;
  -h|--help|help)
    sed -n '1,40p' "$0"
    ;;
  *)
    echo "unknown command: ${cmd}" >&2
    echo "usage: $0 [prepare|build|register]" >&2
    exit 2
    ;;
esac
