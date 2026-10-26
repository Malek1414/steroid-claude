# Third-party notices

Steroid Claude's own code (installers, hooks, commands, the second-brain skill, vault template and brainbridge) is MIT, © Malek Hassan.

The components below are vendored unchanged except where noted. Each keeps its upstream licence, and a copy of that licence sits next to it.

| Component | Path | Upstream | Licence |
|---|---|---|---|
| 144 subagents | `plugins/steroid-agents/agents/` | [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) | MIT © 2025 VoltAgent (`plugins/steroid-agents/LICENSE-VoltAgent`) |
| semble-search agent | `plugins/steroid-agents/agents/semble-search.md` | [MinishLab/semble](https://github.com/MinishLab/semble) | MIT © 2026 Thomas van Dongen (`plugins/steroid-agents/LICENSE-semble`) |
| humanizer | `plugins/steroid-claude/skills/humanizer/` | [blader/humanizer](https://github.com/blader/humanizer) | MIT © 2025 Siqi Chen |
| peekaboo skill | `plugins/steroid-claude/skills/peekaboo/` | [steipete/Peekaboo](https://github.com/steipete/Peekaboo) | MIT © 2025 Peter Steinberger |
| reverse-engineer-anything | `plugins/steroid-claude/skills/reverse-engineer-anything/` | [rea-agents](https://www.npmjs.com/package/rea-agents) | MIT © 2026 morluto |
| tavily-* skills (8) | `plugins/steroid-claude/skills/tavily-*/` | [tavily-ai/skills](https://github.com/tavily-ai/skills) | MIT © 2026 Tavily |
| supabase, supabase-postgres-best-practices | `plugins/steroid-claude/skills/supabase*/` | [supabase/agent-skills](https://github.com/supabase/agent-skills) | MIT © 2026 Supabase |
| find-skills | `plugins/steroid-claude/skills/find-skills/` | [vercel-labs/skills](https://github.com/vercel-labs/skills) | MIT © 2026 Vercel, Inc. |
| study | `plugins/steroid-claude/skills/study/` | [flc1125/skills](https://github.com/flc1125/skills) | MIT © 2026 flc1125 |
| brainbridge dependency: chokidar | installed by `npm ci`, not vendored | [paulmillr/chokidar](https://github.com/paulmillr/chokidar) | MIT |

Changed from upstream: `social-edit` had malformed YAML frontmatter, which is fixed here.

## Installed, not redistributed

Setup installs these from their own sources. Their code is not in this repo:

- Plugins: claude-mem (Apache-2.0), superpowers, frontend-design, code-review, github, swift-lsp, rust-analyzer-lsp (Anthropic official marketplace), andrej-karpathy-skills, job-apply (MIT), nightcrawler (MIT), mozcode.
- MCP servers: semble (MIT), chrome-devtools-mcp, rea-agents (MIT), Peekaboo (MIT), blenderwright.
- Skill: llm-council from [am-will/codex-skills](https://github.com/am-will/codex-skills). It has no licence upstream, so it is fetched from source at setup rather than copied here.
