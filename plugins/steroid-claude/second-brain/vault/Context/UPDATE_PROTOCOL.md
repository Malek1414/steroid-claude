---
updated: 2026-10-26
---
# Update Protocol

Rules every session follows to keep this vault current.

1. **Update in place.** When something new comes up (a number changes, a project ends, a goal appears, a fact is corrected), rewrite the relevant note. Don't append stray notes elsewhere.
2. **Stamp the date.** Update the `updated:` field in the note's frontmatter whenever you change it.
3. **Report the change.** Tell the owner in one line what changed and where.
4. **Single source of truth.** Never store the same fact in two notes. Keep it in the one note it belongs to and **cross-reference** with wiki links everywhere else.
5. **Keep the graph connected.** Every note links its related notes in a `## Related` section the moment it's created, and [[INDEX]] links to every note so the graph stays whole.
6. **Route through [[INDEX]].** When a question maps to a note that doesn't exist yet, create it (frontmatter + prose + `## Related`) and add it to [[INDEX]].
7. **No secrets.** Passwords, keys, card and ID numbers never go in the vault.
