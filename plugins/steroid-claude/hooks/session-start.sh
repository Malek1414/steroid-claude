#!/usr/bin/env bash
# SessionStart: until setup has run once, tell Claude to suggest it. Silent after.
[ -f "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/steroid-claude/setup-done" ] && exit 0
echo "The Steroid Claude plugin is installed, but its setup has not run yet. Companion plugins (claude-mem, superpowers…) and MCP servers are not installed. At a natural moment, suggest the user run /steroid-claude:setup once."
exit 0
