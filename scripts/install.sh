#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
mcps="$(cd "$here/.." && pwd)"
root="$(cd "$here/../../.." && pwd)"
cd "$root"

add_mcp=(npx --loglevel=error --yes add-mcp@2.3.0)

register() {
  local name="$1"
  local cmd="$2"
  shift 2
  # The progress UI reads stdin even with -y; setup may inherit an unreadable fd.
  "${add_mcp[@]}" --name "$name" -a cursor -a codex -a claude-code -y "$cmd" "$@" < /dev/null
}

found=0
shopt -s nullglob
for d in "$mcps"/*/; do
  name="$(basename "$d")"
  if [[ "$name" == scripts ]]; then
    continue
  fi
  cmdfile="${d}cmd"
  if [[ ! -f "$cmdfile" ]]; then
    echo "ERROR: missing ${cmdfile}" >&2
    exit 1
  fi
  lines=()
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    if [[ -n "$line" ]]; then
      lines+=("$line")
    fi
  done < "$cmdfile"
  if [[ ${#lines[@]} -ne 1 ]]; then
    echo "ERROR: ${cmdfile} must contain exactly one command line" >&2
    exit 1
  fi
  args=()
  if [[ -f "${d}args.sh" ]]; then
    source "${d}args.sh"
  fi
  register "$name" "${lines[0]}" "${args[@]}"
  found=1
done

if [[ "$found" -eq 0 ]]; then
  echo "ERROR: no MCP entries under ${mcps}" >&2
  exit 1
fi
