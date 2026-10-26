---
description: Check which parts of the Steroid Claude stack are installed and what is missing
allowed-tools: Bash
---

Run:

```bash
SETUP="${CLAUDE_PLUGIN_ROOT}/scripts/setup.sh"; [ -f "$SETUP" ] || SETUP="$(ls ~/.claude/plugins/cache/steroid-claude/steroid-claude/*/scripts/setup.sh | tail -1)"
bash "$SETUP" --check; echo "plugin root: $(dirname "$(dirname "$SETUP")")"
```

Summarise the result: what is healthy, what is missing, and the single command that fixes each missing piece (usually `/steroid-claude:setup`, or installing `uv` / Node.js for skipped MCP servers). Keep it short.
