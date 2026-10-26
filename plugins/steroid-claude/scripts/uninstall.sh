#!/usr/bin/env bash
# Steroid Claude uninstall. Removes only what setup.sh recorded as added by it
# ($CLAUDE_DIR/steroid-claude/state), then the steroid-claude plugins and
# marketplace. Things you had before setup ran, and the second-brain vault,
# are never touched.
#
#   uninstall.sh [--yes] [--dry-run] [--keep-plugins]

set -uo pipefail

# Everything runs inside main(): bash reads scripts lazily, and this script
# deletes the plugin folder it lives in.
main() {
  local YES=0 DRY=0 KEEP=0
  while [ $# -gt 0 ]; do
    case "$1" in
      -y|--yes) YES=1 ;;
      --dry-run) DRY=1 ;;
      --keep-plugins) KEEP=1 ;;
      -h|--help) sed -n '2,7p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; return 0 ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
    shift
  done

  local CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  local STATE_DIR="$CLAUDE_DIR/steroid-claude"
  local STATE="$STATE_DIR/state"
  local STATE_COPY; STATE_COPY="$(mktemp)"
  [ -f "$STATE" ] && cp "$STATE" "$STATE_COPY"

  act() { # act "description" cmd...
    local what="$1"; shift
    if [ "$DRY" = 1 ]; then echo "  - $what"; return 0; fi
    if "$@" </dev/null >/dev/null 2>&1; then echo "  ✓ removed $what"; else echo "  • $what (already gone)"; fi
  }
  items() { sed -n "s/^$1 //p" "$STATE_COPY"; }

  if [ "$DRY" = 0 ] && [ "$YES" = 0 ]; then
    if { : </dev/tty; } 2>/dev/null; then
      printf 'Remove Steroid Claude and everything it installed%s? [y/N] ' "$([ "$KEEP" = 1 ] && echo ' (keeping companion plugins)')" >/dev/tty
      local ans; read -r ans </dev/tty || ans=""
      case "$ans" in y|Y|yes) ;; *) echo "Cancelled."; return 0 ;; esac
    else
      echo "Not a terminal: pass --yes to confirm, or --dry-run to preview." >&2; return 1
    fi
  fi

  [ "$DRY" = 1 ] && echo "Would remove:"

  # settings keys setup added
  local keys; keys="$(items settings | tr '\n' ' ')"
  if [ -n "$keys" ] && command -v python3 >/dev/null 2>&1; then
    if [ "$DRY" = 1 ]; then echo "  - settings: $keys"
    else
      python3 - "$CLAUDE_DIR/settings.json" $keys <<'PY'
import json, sys
path, keys = sys.argv[1], sys.argv[2:]
try:
    data = json.load(open(path))
except Exception:
    sys.exit(0)
for k in keys:
    if data.pop(k, None) is not None:
        print(f"  ✓ removed setting {k}")
json.dump(data, open(path, "w"), indent=2)
open(path, "a").write("\n")
PY
    fi
  fi

  # CLAUDE.md block
  local md="$CLAUDE_DIR/CLAUDE.md"
  if grep -q '<!-- steroid-claude:start -->' "$md" 2>/dev/null; then
    if [ "$DRY" = 1 ]; then echo "  - Steroid Claude block in $md"
    else
      awk '/<!-- steroid-claude:start -->/{s=1; next} /<!-- steroid-claude:end -->/{s=0; next} s{next}
           /^[[:space:]]*$/{blank++; next} {while (blank > 0) {print ""; blank--} print}' "$md" > "$md.tmp" && mv "$md.tmp" "$md"
      echo "  ✓ removed the Steroid Claude block from $md"
    fi
  fi

  local name id mk
  for name in $(items skill); do act "skill $name" rm -rf "$CLAUDE_DIR/skills/$name"; done
  for name in $(items mcp); do act "MCP server $name" claude mcp remove "$name" --scope user; done

  # plugins: steroid-agents always; companions unless --keep-plugins
  for id in $(items plugin); do
    case "$id" in
      steroid-claude@steroid-claude) ;;   # last, below
      steroid-agents@steroid-claude) act "plugin $id" claude plugin uninstall "$id" ;;
      *) [ "$KEEP" = 1 ] || act "plugin $id" claude plugin uninstall "$id" ;;
    esac
  done
  if [ "$KEEP" = 0 ]; then
    for mk in $(items marketplace); do
      case "$mk" in steroid-claude|claude-plugins-official) continue ;; esac   # ours goes last; never drop the official one
      act "marketplace $mk" claude plugin marketplace remove "$mk"
    done
  fi

  local brain; brain="$(items brain | tail -1)"

  # the plugin itself, then its marketplace and our state (keep the install-count marker)
  act "plugin steroid-claude@steroid-claude" claude plugin uninstall steroid-claude@steroid-claude
  act "marketplace steroid-claude" claude plugin marketplace remove steroid-claude
  if [ "$DRY" = 0 ]; then
    find "$STATE_DIR" -mindepth 1 -maxdepth 1 ! -name counted -exec rm -rf {} + 2>/dev/null
  fi
  rm -f "$STATE_COPY"

  [ -n "$brain" ] && echo "  • your second-brain vault stays where it is: $brain"
  [ "$DRY" = 0 ] && echo "Done. Restart Claude Code to finish."
  return 0
}

main "$@"
