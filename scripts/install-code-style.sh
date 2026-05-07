#!/usr/bin/env bash
# Install vdufloth code-style guidance into ~/.claude/CLAUDE.md.
# Idempotent: re-running replaces the previously-installed block in place.
#
# Run from a clone:
#   bash scripts/install-code-style.sh
#
# Run remotely (no clone needed):
#   curl -fsSL https://raw.githubusercontent.com/vdufloth/claude-plugins/main/scripts/install-code-style.sh | bash

set -euo pipefail

CLAUDE_MD="${HOME}/.claude/CLAUDE.md"
RULES_URL="${VDUFLOTH_CODE_STYLE_URL:-https://raw.githubusercontent.com/vdufloth/claude-plugins/main/plugins/vdufloth/skills/code-style/SKILL.md}"
BEGIN_MARKER="<!-- vdufloth/code-style: BEGIN -->"
END_MARKER="<!-- vdufloth/code-style: END -->"

# Prefer a local copy if invoked from a clone.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
LOCAL_RULES="${SCRIPT_DIR}/../plugins/vdufloth/skills/code-style/SKILL.md"

if [[ -f "$LOCAL_RULES" ]]; then
  RAW_RULES="$(cat "$LOCAL_RULES")"
else
  RAW_RULES="$(curl -fsSL "$RULES_URL")"
fi

# Strip YAML frontmatter (everything between the first two --- lines).
RULES_BODY="$(printf '%s\n' "$RAW_RULES" | awk '
  BEGIN { n = 0 }
  /^---$/ { n++; next }
  n >= 2 { print }
')"

if [[ -z "$RULES_BODY" ]]; then
  echo "error: fetched rules body is empty (URL: $RULES_URL)" >&2
  exit 1
fi

mkdir -p "$(dirname "$CLAUDE_MD")"
touch "$CLAUDE_MD"

# Remove any previously-installed block in place.
if grep -qF "$BEGIN_MARKER" "$CLAUDE_MD"; then
  awk -v b="$BEGIN_MARKER" -v e="$END_MARKER" '
    $0 == b { skip = 1; next }
    $0 == e { skip = 0; next }
    !skip
  ' "$CLAUDE_MD" > "${CLAUDE_MD}.tmp"
  mv "${CLAUDE_MD}.tmp" "$CLAUDE_MD"
fi

# Append a fresh block, separated by one blank line from prior content.
{
  printf '\n%s\n' "$BEGIN_MARKER"
  printf '%s\n' "$RULES_BODY"
  printf '%s\n' "$END_MARKER"
} >> "$CLAUDE_MD"

echo "Installed vdufloth/code-style block into ${CLAUDE_MD}"
echo "Re-run this script any time you want to refresh the rules."
