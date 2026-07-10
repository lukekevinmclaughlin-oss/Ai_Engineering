#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REQUIRED_DIRECTORIES=(
  "$ROOT_DIR/Ai_Engineering"
  "$ROOT_DIR/Ai_Engineering/Resources"
  "$ROOT_DIR/Ai_EngineeringTests"
)

missing_directories=()
for directory in "${REQUIRED_DIRECTORIES[@]}"; do
  if [[ ! -d "$directory" ]]; then
    missing_directories+=("${directory#"$ROOT_DIR/"}")
  fi
done

if (( ${#missing_directories[@]} > 0 )); then
  printf 'Cannot generate the Xcode project. Missing source directories:\n' >&2
  printf '  - %s\n' "${missing_directories[@]}" >&2
  exit 1
fi

if ! command -v xcodegen >/dev/null 2>&1; then
  printf 'XcodeGen is required. Install it with: brew install xcodegen\n' >&2
  exit 1
fi

xcodegen generate \
  --spec "$ROOT_DIR/project.yml" \
  --project "$ROOT_DIR" \
  --project-root "$ROOT_DIR"
