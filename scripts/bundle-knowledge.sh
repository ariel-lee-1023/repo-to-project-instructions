#!/usr/bin/env bash
# Bundle a repository's markdown into a small number of knowledge files that fit
# a Gem / Project upload cap.
#
# Usage:
#   bundle-knowledge.sh <repo-url-or-local-path> [out-dir] [--max-files N] [--max-bytes N]
#                       [--include-ext "md,txt"] [--subpath PATH]
#
# Output: <out-dir>/bundle-01.md … bundle-NN.md, plus manifest.md.
# Each file inside a bundle is preceded by "===== FILE: <repo-relative-path> ====="
# so compiled instructions can cite repo paths regardless of which bundle holds them.

set -euo pipefail

SRC="${1:-}"
if [ -z "$SRC" ] || [ "$SRC" = "-h" ] || [ "$SRC" = "--help" ]; then
  sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
fi
shift

OUT="knowledge-bundle"
case "${1:-}" in --*|"") ;; *) OUT="$1"; shift ;; esac

MAX_FILES=8
MAX_BYTES=700000
EXTS="md,txt"
SUBPATH=""

while [ $# -gt 0 ]; do
  case "$1" in
    --max-files)   MAX_FILES="$2"; shift 2 ;;
    --max-bytes)   MAX_BYTES="$2"; shift 2 ;;
    --include-ext) EXTS="$2";      shift 2 ;;
    --subpath)     SUBPATH="${2#/}"; shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

CLONE_DIR=""
cleanup() { [ -n "$CLONE_DIR" ] && rm -rf "$CLONE_DIR"; }
trap cleanup EXIT

case "$SRC" in
  http://*|https://*|git@*)
    CLONE_DIR="$(mktemp -d)"
    echo "cloning $SRC …" >&2
    git clone --depth 1 --quiet "$SRC" "$CLONE_DIR"
    ROOT="$CLONE_DIR"
    ;;
  *)
    [ -d "$SRC" ] || { echo "not a directory: $SRC" >&2; exit 1; }
    ROOT="$SRC"
    ;;
esac

SHA="$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo "unknown")"
ORIGIN="$(git -C "$ROOT" remote get-url origin 2>/dev/null || echo "$SRC")"
SCAN="$ROOT${SUBPATH:+/$SUBPATH}"
[ -d "$SCAN" ] || { echo "subpath not found: $SUBPATH" >&2; exit 1; }

# --- collect ---------------------------------------------------------------
FIND_ARGS=()
IFS=',' read -r -a EXT_ARR <<< "$EXTS"
first=1
for e in "${EXT_ARR[@]}"; do
  e="$(echo "$e" | tr -d ' .')"
  if [ $first -eq 1 ]; then FIND_ARGS+=( -name "*.$e" ); first=0
  else FIND_ARGS+=( -o -name "*.$e" ); fi
done

LIST="$(mktemp)"
find "$SCAN" \
  \( -name .git -o -name node_modules -o -name dist -o -name build \
     -o -name .venv -o -name vendor -o -name .next -o -name target \) -prune -o \
  -type f \( "${FIND_ARGS[@]}" \) -print0 \
  | LC_ALL=C sort -z > "$LIST"

COUNT=0; TOTAL=0
while IFS= read -r -d '' f; do
  COUNT=$((COUNT + 1))
  TOTAL=$((TOTAL + $(wc -c < "$f")))
done < "$LIST"

[ "$COUNT" -gt 0 ] || { echo "no matching files under $SCAN" >&2; exit 1; }

# Grow the per-bundle budget rather than exceeding the file cap.
NEEDED=$(( (TOTAL / MAX_FILES) + 4096 ))
[ "$NEEDED" -gt "$MAX_BYTES" ] && MAX_BYTES="$NEEDED"

mkdir -p "$OUT"
rm -f "$OUT"/bundle-*.md "$OUT/manifest.md"

MANIFEST="$OUT/manifest.md"
{
  printf '# Knowledge bundle manifest\n\n'
  printf -- '- source: %s\n- commit: %s\n- built: %s\n- files: %s (%s bytes)\n\n' \
    "$ORIGIN" "$SHA" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$COUNT" "$TOTAL"
  printf '| bundle | repo path | bytes |\n|---|---|---|\n'
} > "$MANIFEST"

# --- pack ------------------------------------------------------------------
IDX=1
CUR="$(printf '%s/bundle-%02d.md' "$OUT" "$IDX")"
CUR_BYTES=0
: > "$CUR"
printf '# %s — bundle %02d (commit %s)\n' "$(basename "$ORIGIN" .git)" "$IDX" "$SHA" >> "$CUR"

while IFS= read -r -d '' f; do
  rel="${f#"$ROOT"/}"
  sz=$(wc -c < "$f")
  if [ "$CUR_BYTES" -gt 0 ] && [ $((CUR_BYTES + sz)) -gt "$MAX_BYTES" ]; then
    IDX=$((IDX + 1))
    CUR="$(printf '%s/bundle-%02d.md' "$OUT" "$IDX")"
    CUR_BYTES=0
    : > "$CUR"
    printf '# %s — bundle %02d (commit %s)\n' "$(basename "$ORIGIN" .git)" "$IDX" "$SHA" >> "$CUR"
  fi
  {
    printf '\n\n===== FILE: %s =====\n\n' "$rel"
    cat "$f"
  } >> "$CUR"
  CUR_BYTES=$((CUR_BYTES + sz + 40))
  printf '| %02d | `%s` | %s |\n' "$IDX" "$rel" "$sz" >> "$MANIFEST"
done < "$LIST"

rm -f "$LIST"

echo "wrote $IDX bundle(s) + manifest.md to $OUT/ (commit $SHA)" >&2
ls -la "$OUT" >&2
