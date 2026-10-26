#!/usr/bin/env bash
# Steroid Claude: one-line installer.
#
#   curl -fsSL https://raw.githubusercontent.com/Malek1414/steroid-claude/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/Malek1414/steroid-claude/main/install.sh | bash -s -- --second-brain --with all
#
# Adds this repo as a Claude Code plugin marketplace, installs the
# steroid-claude plugin, then runs its setup.sh with your arguments.

set -uo pipefail

# Wrapped in main() so a half-downloaded script never runs half its steps.
main() {
  # Some marketplaces point at GitHub over SSH. Clone those over HTTPS so people
  # without a GitHub SSH key can still install them (public repos need no auth).
  if [ -z "${GIT_CONFIG_COUNT:-}" ]; then
    export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0="url.https://github.com/.insteadOf" GIT_CONFIG_VALUE_0="git@github.com:"
  fi
  local REPO="Malek1414/steroid-claude"
  local CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

  if ! command -v claude >/dev/null 2>&1; then
    echo "Claude Code is not installed. Install it first:" >&2
    echo "  curl -fsSL https://claude.ai/install.sh | bash" >&2
    return 1
  fi

  if ! claude plugin marketplace list --json </dev/null 2>/dev/null | grep -Eq '"name": *"steroid-claude"'; then
    echo "▸ Adding the steroid-claude marketplace"
    claude plugin marketplace add "$REPO" </dev/null || return 1
  fi
  if ! claude plugin list --json </dev/null 2>/dev/null | grep -Eq '"id": *"steroid-claude@steroid-claude"'; then
    echo "▸ Installing the steroid-claude plugin"
    claude plugin install steroid-claude@steroid-claude --scope user -y </dev/null || return 1
  fi

  local root
  root="$(claude plugin list --json </dev/null 2>/dev/null | awk '
    /"id": *"steroid-claude@steroid-claude"/ { found = 1 }
    found && /"installPath"/ { sub(/.*"installPath": *"/, ""); sub(/".*/, ""); print; exit }')"
  [ -f "$root/scripts/setup.sh" ] || root="$(ls -d "$CLAUDE_DIR"/plugins/cache/steroid-claude/steroid-claude/*/ 2>/dev/null | tail -1)"
  root="${root%/}"
  if [ ! -f "$root/scripts/setup.sh" ]; then
    echo "Installed the plugin but could not find its setup.sh. Run /steroid-claude:setup inside Claude Code." >&2
    return 1
  fi

  bash "$root/scripts/setup.sh" "$@"
}

main "$@"
