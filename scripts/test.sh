#!/usr/bin/env bash
# RepoTest App Review sample — no npm install required.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/test-lib.sh
source "$ROOT/scripts/test-lib.sh"

if [[ "${1:-}" == "--seed" ]]; then
  run_seed
  exit 0
fi

if [[ -z "${REPOTEST_TEST_NONINTERACTIVE:-${MTR_TEST_NONINTERACTIVE:-${FISKAL_TEST_NONINTERACTIVE:-}}}" ]]; then
  echo "RepoTest Demo: run this repo from the RepoTest app (File → Open Project…)."
  echo "Or export REPOTEST_TEST_NONINTERACTIVE=1 and set REPOTEST_TEST_* variables (see README.md)."
  exit 0
fi

run_suite
