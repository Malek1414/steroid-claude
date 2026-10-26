#!/usr/bin/env bash
# Copies brainbridge to a stable folder (plugin updates replace the plugin's
# own copy), renders the launchd plist with this machine's paths and loads it.
#   ./install-launchd.sh [VAULT_PATH]     (default: ~/second-brain)
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="${BRAINBRIDGE_HOME:-$HOME/.local/share/brainbridge}"
VAULT="${1:-$HOME/second-brain}"
VAULT="$(cd "$VAULT" && pwd)"
NODE="$(command -v node)" || { echo "node not found" >&2; exit 1; }
[ -d "$VAULT/.git" ] || { echo "$VAULT is not a git repo yet: see README.md" >&2; exit 1; }
mkdir -p "$DIR"
(cd "$SRC" && tar cf - --exclude node_modules .) | (cd "$DIR" && tar xf -)
(cd "$DIR" && npm ci --silent)
PLIST="$HOME/Library/LaunchAgents/com.steroid-claude.brainbridge.plist"
mkdir -p "$(dirname "$PLIST")"
sed -e "s|{{NODE}}|$NODE|g" -e "s|{{DIR}}|$DIR|g" -e "s|{{HOME}}|$HOME|g" -e "s|{{VAULT}}|$VAULT|g" \
  "$DIR/com.steroid-claude.brainbridge.plist.template" > "$PLIST"
launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"
echo "brainbridge is syncing $VAULT (log: ~/Library/Logs/brainbridge.log)"
