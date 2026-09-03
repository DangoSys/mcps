#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
cd "$root"

if ! command -v npx >/dev/null; then
  echo "ERROR: npx not found" >&2
  exit 1
fi

add_mcp=(npx --yes add-mcp@2.3.0)

register() {
  local name="$1"
  local cmd="$2"
  "${add_mcp[@]}" --name "$name" -a cursor -a codex -y "$cmd"
}

register buckyball-dev ./scripts/claude/run_mcp_server.sh
register waveform-mcp ./thirdparty/waveform-mcp/target/release/waveform-mcp
