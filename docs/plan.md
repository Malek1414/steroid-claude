# Steroid Claude: build plan and implementation plan

Status: **APPROVED** (2026-10-26). The owner asked for both plans to be approved without a review round, so the build went ahead straight away.

## Goal

Bundle Malek's Claude Code setup into one public repo, `Malek1414/steroid-claude`, so anyone can install the whole thing with one command in Claude Code or the terminal. Count how many people install it.

## Build plan (what ships)

| Layer | What | How it installs |
|---|---|---|
| Core plugin `steroid-claude` | setup / doctor / uninstall commands, SessionStart hook, 18 skills (including second-brain) | Claude Code plugin from this repo's marketplace |
| Agents plugin `steroid-agents` | 145 specialist subagents | Claude Code plugin from this repo's marketplace |
| Companion plugins | claude-mem, superpowers, frontend-design, github, code-review, karpathy-skills, job-apply, nightcrawler, mozcode (+ swift / rust LSPs, opt-in) | `claude plugin install` from their own public marketplaces |
| MCP servers | semble, chrome-devtools, rea (+ peekaboo, blenderwright, opt-in) | `claude mcp add --scope user`, only when the runtime it needs is present |
| Upstream skills | llm-council (no licence upstream, so it is fetched, not vendored) | sparse git checkout into `~/.claude/skills` |
| Second brain | Obsidian vault template with the Context routing system, plus the `brainbridge` git-sync daemon | `--second-brain` copies the template; the daemon is documented and opt-in |
| CLAUDE.md block | semble-first code search guidance, second-brain pointer | marked block appended to `~/.claude/CLAUDE.md`, removed by uninstall |
| Settings | spinner verbs, effort level (opt-in, never overwrites a key you already have) | `--settings` |

### Left out on purpose

- Secrets and personal data: MCP tokens, chat session tokens, claude-mem's database, vault notes, job-application profile.
- Private or local-only MCP servers (personal mail, university, CRM and messaging bridges).
- Client-specific and personal skills (client recruiting and agency playbooks, a voice model trained on private messages, project-specific helpers).
- Plugins whose repos are private or exist only locally.
- Anthropic's claude.ai-synced skills (docx / pdf / pptx / xlsx …): every claude.ai user already has them, and they are not ours to redistribute.

### Install counting and stars

- **Installs:** on a machine's first setup, the installer downloads one tiny file (`steroid-claude.version`) from the latest GitHub release. GitHub counts release downloads, and the README badge reads that number. Nothing about the user is sent. `STEROID_NO_COUNT=1` opts out.
- **Stars:** GitHub's Acceptable Use Policies forbid automated starring, so the installer *asks* ("Star the repo? [Y/n]") and stars via `gh` only on a yes. Inside Claude Code, the setup command asks with a question prompt first. Nothing is starred without a yes.

## Implementation plan

1. Repo skeleton: root marketplace (`.claude-plugin/marketplace.json`) with two plugins under `plugins/`.
2. Vendor the licensed skills and agents: copy, strip caches, keep upstream LICENSE files, write `THIRD_PARTY_NOTICES.md`.
3. Write `plugins/steroid-claude/scripts/setup.sh`: preflight, marketplaces, plugins, MCP servers, upstream skills, CLAUDE.md block, optional settings, optional second brain, install count, star prompt, state file. Flags: `--yes --dry-run --check --minimal --with <group> --second-brain [path] --settings --star/--no-star`.
4. Write `uninstall.sh`, which reverses only what setup recorded in `~/.claude/steroid-claude/state`.
5. Root `install.sh` bootstrap (`curl | bash`): adds the marketplace, installs the core plugin, runs its `setup.sh`.
6. Slash commands `/steroid-claude:setup`, `/steroid-claude:doctor`, `/steroid-claude:uninstall`; a SessionStart hook that suggests setup until it has run.
7. Second-brain template plus the generalised brainbridge daemon (no hard-coded paths).
8. README with an installs badge, a stars badge and an inventory; MIT licence; CI that runs `claude plugin validate`-equivalent JSON checks, `bash -n` and a dry run.
9. Verify: `claude plugin validate`, a dry run, a real run in a throwaway `CLAUDE_CONFIG_DIR`, install from GitHub in a throwaway config.
10. Publish: public repo, push `main`, create release `v1.0.0` with the counter asset.
