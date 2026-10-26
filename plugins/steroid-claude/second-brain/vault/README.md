# Second brain

Open this folder as a vault in [Obsidian](https://obsidian.md) (optional; it's plain Markdown). Claude Code reads and writes it through the `second-brain` skill.

| Folder | What goes in it |
|---|---|
| `Inbox/` | Anything not sorted yet. Claude files it later. |
| `Ideas/` | One note per idea: the pitch, why it matters, next step. |
| `Tasks/` | One note per task or project to-do list, with `- [ ]` checkboxes. |
| `Journal/` | One note per day: `YYYY-MM-DD.md`. |
| `Projects/` | One note per active project: goal, status, links, decisions. |
| `Reference/` | Things worth keeping: articles, snippets, how-tos. |
| `Plans/` | Longer plans: `YYYY-MM-DD - name.md`. |
| `Context/` | The **context system**: who you are, what you're working towards. Claude routes through `Context/INDEX.md`. |

## Getting started

Tell Claude: **"interview me to fill in my second brain"**. It asks one question at a time and writes the answers into the `Context/` notes.

After that, just talk to Claude normally. "Remember that…", "add this idea…", "what did I decide about…" all go through the vault.

## Sync across devices (optional)

Put the vault in a private Git repo and run `brainbridge` (in the plugin's `second-brain/brainbridge/` folder) to auto-commit, pull and push.

Never store passwords, card numbers or other secrets here.
