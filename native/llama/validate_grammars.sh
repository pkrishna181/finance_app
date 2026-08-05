#!/usr/bin/env bash
# Parse-check every repo GBNF through llama.cpp (desktop grammar_validate binary).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
VALIDATOR="${ROOT}/build/desktop/grammar_validate"
GBNF_DIR="${ROOT}/../../app/lib/llm/gbnf"

if [[ ! -x "${VALIDATOR}" ]]; then
  echo "grammar_validate not built — run ./build_desktop.sh first" >&2
  exit 2
fi

if [[ ! -d "${GBNF_DIR}" ]]; then
  echo "GBNF dir missing: ${GBNF_DIR}" >&2
  exit 2
fi

shopt -s nullglob
files=("${GBNF_DIR}"/*.gbnf)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "No .gbnf files under ${GBNF_DIR}" >&2
  exit 2
fi

failed=0
for gbnf in "${files[@]}"; do
  if ! "${VALIDATOR}" "${gbnf}"; then
    failed=1
  fi
done

exit "${failed}"
