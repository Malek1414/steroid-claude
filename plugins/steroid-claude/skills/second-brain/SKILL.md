---
name: second-brain
description: Use when the user wants to capture something into their second brain or personal notes vault ("remember that…", "add this idea", "log this", "note to self", "journal"), asks a question their own context would answer ("what are my goals", "what did I decide about X", "what's the status of my projects"), wants to be interviewed to fill in their second brain, or wants to set the vault up. Reads and writes a plain-Markdown, Obsidian-ready vault with a Context/INDEX.md routing table.
---

# Second brain

A plain-Markdown vault (Obsidian-ready) that you read from and keep up to date for the user.

## 1. Find the vault

Check in this order and use the first one that exists:

1. A path the user gives you.
2. The `brain <path>` line in `${CLAUDE_CONFIG_DIR:-~/.claude}/steroid-claude/state`.
3. The "Second brain" section of `~/.claude/CLAUDE.md`.
4. `~/second-brain`.

If there is none, offer to create one. This command copies the template and leaves existing files untouched:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/setup.sh" --yes --no-star --second-brain ~/second-brain
```

If `${CLAUDE_PLUGIN_ROOT}` is not set, find the script with `ls ~/.claude/plugins/cache/steroid-claude/steroid-claude/*/scripts/setup.sh | tail -1`.

## 2. Answer questions about the user

1. Read `Context/INDEX.md`. It is a routing table.
2. Open only the note(s) it routes to. Never load the whole folder.
3. For things outside `Context/` (old ideas, journal entries, decisions), search the vault with Grep before you answer.
4. Answer from what the notes say, and name the note you used (`[[career]]`). If the notes don't cover it, say so. Don't guess.

## 3. Capture

File each capture where it belongs. Use a short kebab-case filename, frontmatter, and wiki links to related notes:

| Kind | Where | Shape |
|---|---|---|
| Unsorted / quick | `Inbox/` | one note per capture |
| Idea | `Ideas/<idea>.md` | pitch, why it matters, next step |
| Task | `Tasks/<area>.md` | `- [ ] task (due YYYY-MM-DD)` lines appended under a heading |
| Journal | `Journal/YYYY-MM-DD.md` | append under `## HH:MM` |
| Project update | `Projects/<project>.md` | update status/decisions in place |
| Link / snippet | `Reference/<topic>.md` | source URL + why it's worth keeping |
| Plan | `Plans/YYYY-MM-DD - <name>.md` | goal, steps, open questions |

```markdown
---
created: 2026-10-26
tags: [idea]
---
# Title

Body in the user's own words: keep their phrasing.

## Related
[[projects]] · [[goals]]
```

After capturing, say in one line where it went. When the user's facts change (new job, finished project, new goal), update the matching `Context/` note in place. Never add a second copy of a fact.

## 4. Keep Context current

Follow `Context/UPDATE_PROTOCOL.md` every time: update in place, bump `updated:`, keep a single source of truth, link every note from `INDEX.md` and from its `## Related` section, and report each change in one line.

## 5. Onboarding interview

When the `Context/` notes are still empty templates, or the user asks to be interviewed:

- Ask **one question at a time**, in this order: about-me → career → goals → projects → learning → health → finances → people. Let the user skip any area.
- After each answer, write it into the note as short prose in the user's words, then move on.
- End by showing which notes you filled and which are still empty.

## Rules

- Never write secrets (passwords, API keys, card, bank or ID numbers) into the vault, even when asked. Suggest a password manager instead.
- Don't delete notes. Move superseded content into a `## History` section at the bottom of the note.
- The vault is the user's data. Never send its contents to an external service unless the user asks for that specifically.
