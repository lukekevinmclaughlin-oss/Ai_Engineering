#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PART_ONE="$ROOT/scripts/content/curriculum_part_01_10.json"
PART_TWO="$ROOT/scripts/content/curriculum_part_11_20.json"
PART_THREE="$ROOT/scripts/content/curriculum_part_21_30.json"
PART_FOUR="$ROOT/scripts/content/curriculum_part_31_40.json"
OUTPUT="$ROOT/Ai_Engineering/Resources/curriculum.json"
TEMP="$(mktemp)"
trap 'rm -f "$TEMP"' EXIT

jq -s '
  {
    courses: (
      [.[].courses[]]
      | map(.isFeatured = (.id == "llm-application-architecture"))
    )
  }
' "$PART_ONE" "$PART_TWO" "$PART_THREE" "$PART_FOUR" > "$TEMP"

jq -e '
  (.courses | length) == 40 and
  ([.courses[].modules[]] | length) == 80 and
  ([.courses[].modules[].lessons[]] | length) == 400 and
  ([.courses[] | select(.isFeatured)] | length) == 1 and
  ([.courses[].id] | unique | length) == 40 and
  ([.courses[].modules[].id] | unique | length) == 80 and
  ([.courses[].modules[].lessons[].id] | unique | length) == 400 and
  all(.courses[]; (.modules | length) == 2) and
  all(.courses[].modules[]; (.lessons | length) == 5) and
  ([.courses[].modules[].lessons[] | select(.kind == "code")] | length) == 140 and
  ([.courses[].modules[].lessons[] | select(.kind == "quiz")] | length) == 100 and
  ([.courses[].modules[].lessons[] | select(.kind == "architecture")] | length) == 80 and
  ([.courses[].modules[].lessons[] | select(.kind == "concept")] | length) == 80
' "$TEMP" >/dev/null

mv "$TEMP" "$OUTPUT"
trap - EXIT
echo "Merged 40 courses, 80 modules, and 400 lessons into $OUTPUT"
echo "Lesson kinds: 140 code, 100 quiz, 80 architecture, 80 concept"
