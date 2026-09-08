#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
PROJECT_NAME="egps-sanky-venn"
OUTPUT_DIR="$SCRIPT_DIR/out/production/$PROJECT_NAME"
BASE_CLASSES=""
SHELL_CLASSES=""
while (($#)); do
    case "$1" in
        --base-classes|--shell-classes)
            [[ $# -ge 2 && -d "$2" ]] || { echo "$1 requires a class directory" >&2; exit 2; }
            classes="$(cd "$2" && pwd)"
            if [[ "$1" == --base-classes ]]; then BASE_CLASSES="$classes"; else SHELL_CLASSES="$classes"; fi
            shift 2
            ;;
        *) echo "Usage: bash compile.sh [--base-classes DIR --shell-classes DIR]" >&2; exit 2 ;;
    esac
done
if [[ -n "$BASE_CLASSES" && -z "$SHELL_CLASSES" || -z "$BASE_CLASSES" && -n "$SHELL_CLASSES" ]]; then
    echo "Specify both --base-classes and --shell-classes" >&2
    exit 2
fi
JAVAC="${JAVA_HOME:+$JAVA_HOME/bin/}javac"
[[ "$("$JAVAC" -version 2>&1)" == 'javac 25'* ]] || { echo "JDK 25 is required; set JAVA_HOME or PATH" >&2; exit 2; }
CP_ENTRIES=()
if [[ -n "$BASE_CLASSES" ]]; then CP_ENTRIES+=("$BASE_CLASSES" "$SHELL_CLASSES"); fi
shopt -s nullglob
for jar in "$SCRIPT_DIR"/dependency-egps/*.jar; do
    if [[ -n "$BASE_CLASSES" ]]; then
        case "${jar##*/}" in egps-base*.jar|egps-shell*.jar) continue ;; esac
    fi
    CP_ENTRIES+=("$jar")
done
[[ ${#CP_ENTRIES[@]} -gt 0 ]] || { echo "No dependencies in dependency-egps/" >&2; exit 2; }
CP="$(IFS=:; echo "${CP_ENTRIES[*]}")"
mkdir -p "$SCRIPT_DIR/out/production"
STAGE_DIR="$(mktemp -d "$SCRIPT_DIR/out/build-${PROJECT_NAME}.XXXXXX")"
mkdir -p "$STAGE_DIR/classes"
# javac argument files need quoted paths, including on checkouts containing spaces.
while IFS= read -r -d '' source; do
    source="${source//\\/\\\\}"
    source="${source//\"/\\\"}"
    printf '"%s"\n' "$source"
done < <(find src -path 'src/test' -prune -o -type f -name '*.java' -print0) > "$STAGE_DIR/sources.list"
printf '\n- Build %s: staged sources/classes in `%s`; failed builds leave existing output unchanged.\n' "$(date '+%Y-%m-%d %H:%M:%S')" "${STAGE_DIR#"$SCRIPT_DIR/"}" >> AGENTS.md
"$JAVAC" -encoding UTF-8 -d "$STAGE_DIR/classes" -cp "$CP" "@$STAGE_DIR/sources.list"
while IFS= read -r -d '' resource; do
    target="$STAGE_DIR/classes/${resource#src/}"
    mkdir -p "$(dirname "$target")"
    cp "$resource" "$target"
done < <(find src -path 'src/test' -prune -o -type f ! -name '*.java' -print0)
if [[ -e "$OUTPUT_DIR" ]]; then
    BACKUP_DIR="$STAGE_DIR/backup_${PROJECT_NAME}"
    printf -- '- Move `%s` to `%s` before installing successfully compiled classes.\n' "${OUTPUT_DIR#"$SCRIPT_DIR/"}" "${BACKUP_DIR#"$SCRIPT_DIR/"}" >> AGENTS.md
    mv "$OUTPUT_DIR" "$BACKUP_DIR"
fi
printf -- '- Move `%s/classes` to `%s` (includes non-Java resources).\n' "${STAGE_DIR#"$SCRIPT_DIR/"}" "${OUTPUT_DIR#"$SCRIPT_DIR/"}" >> AGENTS.md
mv "$STAGE_DIR/classes" "$OUTPUT_DIR"
printf 'Compiled %s into %s\n' "$PROJECT_NAME" "$OUTPUT_DIR"
