---
description: Install the full Steroid Claude stack (companion plugins, MCP servers, claude-mem, skills, second brain)
argument-hint: "[--minimal] [--with lsp,peekaboo,blender|all] [--second-brain [path]] [--settings]"
allowed-tools: Bash, AskUserQuestion
---

Set up Steroid Claude for the user. The installer is:

```bash
SETUP="${CLAUDE_PLUGIN_ROOT}/scripts/setup.sh"
```

If that path does not exist, use `SETUP="$(ls ~/.claude/plugins/cache/steroid-claude/steroid-claude/*/scripts/setup.sh | tail -1)"`.

1. Run `bash "$SETUP" --check` and summarise in two or three lines what is already installed and what is missing.

2. If the user passed arguments (`$ARGUMENTS`), use them as given and skip the extras question. Otherwise make **one** AskUserQuestion call with these two questions:
   - "Which extras do you want?" (multiSelect: true). Options:
     - "Second-brain vault": an Obsidian-ready notes vault at ~/second-brain that Claude keeps up to date → `--second-brain`
     - "Recommended settings": effort level and gym-themed spinner verbs; never overwrites a setting you already have → `--settings`
     - "Language servers": Swift and Rust LSP plugins → `--with lsp`
     - "Mac + Blender MCPs": Peekaboo (macOS screen automation) and Blenderwright → `--with peekaboo,blender`
   - "Star Malek1414/steroid-claude on GitHub so Malek can see you're using it?" Options: "Yes, star it" → `--star`, "No thanks" → `--no-star`.
   Never pass `--star` unless the user picked "Yes, star it".

3. Run `bash "$SETUP" --yes <flags>` with a 600000 ms timeout. Plugin installs take a while.

4. Report what was installed, anything skipped and why (missing `uvx`/`npx` and so on, with the one-line fix), and any failures with their error text. Finish with: restart Claude Code or run `/reload-plugins` to load everything.
