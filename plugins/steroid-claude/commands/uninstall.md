---
description: Remove what Steroid Claude installed (your own plugins, MCP servers and notes are left alone)
argument-hint: "[--keep-plugins]"
allowed-tools: Bash, AskUserQuestion
---

1. Show the user what will be removed:

```bash
U="${CLAUDE_PLUGIN_ROOT}/scripts/uninstall.sh"; [ -f "$U" ] || U="$(ls ~/.claude/plugins/cache/steroid-claude/steroid-claude/*/scripts/uninstall.sh | tail -1)"
bash "$U" --dry-run $ARGUMENTS
```

2. Ask with AskUserQuestion: "Remove these?" Options: "Remove everything listed", "Keep the companion plugins (superpowers, claude-mem…)" → add `--keep-plugins`, "Cancel".

3. Unless they cancelled, run `bash "$U" --yes <flags>` and report the result. The second-brain vault is never deleted. Say where it is.
