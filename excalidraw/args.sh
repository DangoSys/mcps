if [[ ! -s "${d}api-key" ]]; then
  echo "Skipping Excalidraw MCP: no API key in ${d}api-key" >&2
  continue
fi
args=(--header "Authorization: Bearer $(<"${d}api-key")")
