# Steroid Claude

[![Installs](https://img.shields.io/github/downloads/Malek1414/steroid-claude/total?label=installs&color=brightgreen)](https://github.com/Malek1414/steroid-claude/releases)
[![Stars](https://img.shields.io/github/stars/Malek1414/steroid-claude?style=flat&color=yellow)](https://github.com/Malek1414/steroid-claude/stargazers)
[![CI](https://github.com/Malek1414/steroid-claude/actions/workflows/ci.yml/badge.svg)](https://github.com/Malek1414/steroid-claude/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

My whole Claude Code setup in one install: plugins, skills, 145 subagents, hooks, MCP servers, persistent memory (claude-mem), the superpowers workflow, and a second brain that Claude keeps up to date.

## Install

**Inside Claude Code** (type these three lines one at a time):

```
/plugin marketplace add Malek1414/steroid-claude
/plugin install steroid-claude@steroid-claude
/steroid-claude:setup
```

The setup command asks which extras you want, installs everything, and tells you what it skipped and why.

**Or from your terminal:**

```bash
curl -fsSL https://raw.githubusercontent.com/Malek1414/steroid-claude/main/install.sh | bash
```

Then restart Claude Code. Re-running either one is safe: anything already installed is skipped.

### Options

Pass these to `/steroid-claude:setup`, or after `| bash -s --` in the terminal:

| Flag | What it does |
|---|---|
| `--second-brain [path]` | Create the second-brain vault (default `~/second-brain`) |
| `--settings` | Add recommended settings: effort level and gym-themed spinner verbs. Never overwrites a setting you already have. |
| `--with lsp` | Swift and Rust language-server plugins |
| `--with peekaboo` | Peekaboo MCP (macOS screen and app automation; installs the CLI with Homebrew) |
| `--with blender` | Blenderwright MCP (drive Blender from Claude) |
| `--with all` | All of the above `--with` groups |
| `--minimal` | Core only: no subagents, nightcrawler, mozcode, job-apply or rea |
| `--no-agents` | Skip the 145 subagents (they add about 8k tokens to every session) |
| `--no-claude-md` | Don't add the Steroid Claude block to `~/.claude/CLAUDE.md` |
| `--dry-run` | Show what would happen without changing anything |
| `--check` | Show what is installed and what is missing (same as `/steroid-claude:doctor`) |

Example: `curl -fsSL https://raw.githubusercontent.com/Malek1414/steroid-claude/main/install.sh | bash -s -- --second-brain --with all`

## What you get

### Plugins

| Plugin | What it adds |
|---|---|
| [claude-mem](https://github.com/thedotmack/claude-mem) | Persistent memory across sessions: Claude remembers what you built, fixed and decided, and can search it |
| [superpowers](https://github.com/obra/superpowers) | Brainstorm → plan → build → verify workflow, TDD, systematic debugging, parallel subagents |
| [frontend-design](https://github.com/anthropics/claude-plugins-official) | Distinctive UI design instead of template defaults |
| [code-review](https://github.com/anthropics/claude-plugins-official) | PR and diff review |
| [github](https://github.com/anthropics/claude-plugins-official) | GitHub MCP: issues, PRs, code search, releases (set `GITHUB_PERSONAL_ACCESS_TOKEN`) |
| [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) | Guidelines that cut the usual LLM coding mistakes: overbuilding, scope creep, unverified claims |
| [nightcrawler](https://github.com/Malek1414/nightcrawler) | Web research with parallel researcher waves and a citation check on every source |
| [mozcode](https://github.com/Malek1414/MOZCODE) | Symbol-level code reads and edits that cut input tokens, plus a savings dashboard |
| [job-apply](https://github.com/neonwatty/job-apply-plugin) | Fills job applications (LinkedIn Easy Apply, Greenhouse, Ashby, Lever, Workday) from your resume |
| **steroid-agents** (this repo) | 145 specialist subagents (see below) |
| swift-lsp, rust-analyzer-lsp | Language servers, with `--with lsp` |

### Skills (bundled in the steroid-claude plugin)

| Skill | Use it for |
|---|---|
| `second-brain` | Capture notes, ideas, tasks and journal entries; answer questions about you from your own context; onboarding interview |
| `humanizer` | Strip AI-writing tells from text |
| `social-research` → `social-edit` | Research how a creator edits their videos, then apply that style to your footage with ffmpeg + whisper |
| `reverse-engineer-anything` | Reverse engineer binaries, Electron/JS apps, APKs, firmware and web apps with REA |
| `peekaboo` | macOS screenshots and background UI automation |
| `tavily-search`, `-extract`, `-crawl`, `-map`, `-research`, `-dynamic-search`, `-cli`, `-best-practices` | Web search, scraping, crawling and cited research through the Tavily CLI |
| `supabase`, `supabase-postgres-best-practices` | Supabase (auth, RLS, edge functions, migrations) and Postgres tuning |
| `study` | Staged learning plans with practice and review loops |
| `find-skills` | Find and install more skills |
| `llm-council` | Several CLI agents (Codex, Claude, Gemini…) plan independently, then one plan is judged and merged. Fetched from [am-will/codex-skills](https://github.com/am-will/codex-skills) at setup. |

### Subagents (steroid-agents)

145 specialists that Claude can hand work to, from [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents), plus `semble-search`. They cover languages (python-pro, typescript-pro, rust-engineer, golang-pro, swift-expert…), frameworks (nextjs-developer, django-developer, rails-expert, flutter-expert…), infra (kubernetes-specialist, terraform-engineer, sre-engineer, docker-expert…), data and AI (data-scientist, llm-architect, mlops-engineer, prompt-engineer…), security (penetration-tester, security-auditor, compliance-auditor…), product and business (product-manager, market-researcher, project-idea-validator…), and orchestration (multi-agent-coordinator, workflow-orchestrator…).

<details><summary>All 145</summary>

accessibility-tester · ad-security-reviewer · agent-installer · agent-organizer · ai-engineer · ai-writing-auditor · angular-architect · api-designer · api-documenter · architect-reviewer · azure-infra-engineer · backend-developer · blockchain-developer · build-engineer · business-analyst · chaos-engineer · cli-developer · cloud-architect · code-reviewer · codebase-orchestrator · competitive-analyst · compliance-auditor · content-marketer · context-manager · cpp-pro · csharp-developer · customer-success-manager · data-analyst · data-engineer · data-researcher · data-scientist · database-administrator · database-optimizer · debugger · dependency-manager · deployment-engineer · design-bridge · devops-engineer · devops-incident-responder · django-developer · docker-expert · documentation-engineer · dotnet-core-expert · dotnet-framework-4.8-expert · dx-optimizer · electron-pro · elixir-expert · embedded-systems · error-coordinator · error-detective · expo-react-native-expert · fastapi-developer · fintech-engineer · flutter-expert · frontend-developer · fullstack-developer · game-developer · git-workflow-manager · golang-pro · graphql-architect · healthcare-admin · incident-responder · iot-engineer · it-ops-orchestrator · java-architect · javascript-pro · knowledge-synthesizer · kotlin-specialist · kubernetes-specialist · laravel-specialist · legacy-modernizer · legal-advisor · license-engineer · llm-architect · m365-admin · machine-learning-engineer · market-researcher · mcp-developer · microservices-architect · ml-engineer · mlops-engineer · mobile-app-developer · mobile-developer · multi-agent-coordinator · network-engineer · nextjs-developer · nlp-engineer · node-specialist · payment-integration · penetration-tester · performance-engineer · performance-monitor · php-pro · platform-engineer · postgres-pro · powershell-5.1-expert · powershell-7-expert · powershell-module-architect · powershell-security-hardening · powershell-ui-architect · product-manager · project-idea-validator · project-manager · prompt-engineer · python-pro · qa-expert · quant-analyst · rails-expert · react-specialist · readme-generator · refactoring-specialist · reinforcement-learning-engineer · research-analyst · risk-manager · rust-engineer · sales-engineer · scientific-literature-researcher · scrum-master · search-specialist · security-auditor · security-engineer · semble-search · seo-specialist · slack-expert · spring-boot-engineer · sql-pro · sre-engineer · swift-expert · symfony-specialist · task-distributor · technical-writer · terraform-engineer · terragrunt-expert · test-automator · tooling-engineer · trend-analyst · typescript-pro · ui-designer · ui-ux-tester · ux-researcher · vue-expert · websocket-engineer · windows-infra-admin · wordpress-master · workflow-orchestrator

</details>

### MCP servers

| Server | What it does | Needs |
|---|---|---|
| [semble](https://github.com/MinishLab/semble) | Fast semantic code search: Claude finds code by intent instead of grepping | `uv` |
| [chrome-devtools](https://github.com/ChromeDevTools/chrome-devtools-mcp) | Drive and debug Chrome: navigate, click, screenshot, console, network, Lighthouse | Node.js |
| [rea](https://www.npmjs.com/package/rea-agents) | Reverse-engineering toolkit (200+ tools) | Node.js |
| [peekaboo](https://github.com/steipete/Peekaboo) | macOS screen capture and UI automation, with `--with peekaboo` | macOS, Homebrew |
| [blenderwright](https://pypi.org/project/blenderwright/) | Model, light and render in Blender, with `--with blender` | `uv`, Blender + its add-on |

The GitHub MCP comes with the github plugin.

If a runtime is missing, setup skips that server and prints the one-line fix: [uv](https://docs.astral.sh/uv/) (`curl -LsSf https://astral.sh/uv/install.sh | sh`) or [Node.js](https://nodejs.org).

### Hooks

- **claude-mem**: records each session and injects relevant past context at startup.
- **superpowers**: loads the skills-first workflow at session start.
- **mozcode**: points Claude at symbol-level tools for code files.
- **steroid-claude**: reminds Claude to suggest `/steroid-claude:setup` until it has run once, then stays silent.

### Second brain

`--second-brain` creates a plain-Markdown vault that opens in Obsidian:

```
second-brain/
├── Inbox/ Ideas/ Tasks/ Journal/ Projects/ Reference/ Plans/
└── Context/
    ├── INDEX.md            ← routing table: which note answers which question
    ├── UPDATE_PROTOCOL.md  ← update in place, date-stamp, one source of truth, keep links whole
    ├── about-me.md, career, goals, projects, learning, health, finances, people
```

Claude reads `Context/INDEX.md` before answering anything about you, opens only the notes it needs, and updates them when something changes. Say **"interview me to fill in my second brain"** to get started. To sync the vault across devices through a private Git repo, use [brainbridge](plugins/steroid-claude/second-brain/brainbridge/README.md), a small daemon that commits, pulls and pushes and never loses work on conflicts.

### CLAUDE.md

Setup adds a short block (between `<!-- steroid-claude:start -->` markers) to `~/.claude/CLAUDE.md`. It tells Claude to search code with semble first, check memory before re-deriving past work, follow the superpowers process, and use your second brain. Your own content in that file is never touched.

## Commands

| Command | |
|---|---|
| `/steroid-claude:setup` | Install or repair the stack |
| `/steroid-claude:doctor` | What's installed, what's missing, how to fix it |
| `/steroid-claude:uninstall` | Remove what setup added |

## Install counter and stars

**How installs are counted.** The first time setup runs on a machine, it downloads one small file (`steroid-claude.version`) from this repo's latest release. GitHub counts release downloads, and the **installs** badge above shows that number. Nothing about you or your machine is sent. To opt out, set `STEROID_NO_COUNT=1`.

**Stars.** At the end, setup asks whether you want to star the repo. It only stars on a yes, using your own `gh` login. GitHub doesn't allow automatic starring, and an honest count means more anyway.

## Uninstall

```
/steroid-claude:uninstall
```

or `bash ~/.claude/plugins/cache/steroid-claude/steroid-claude/*/scripts/uninstall.sh`. It removes only what setup recorded as added by it: plugins, MCP servers, skills, settings keys and the CLAUDE.md block. Anything you had before is left alone, and so is your second-brain vault. Add `--keep-plugins` to keep the companion plugins.

## Not included

These are in my own setup, but they need personal credentials or are private:

- **Slack MCP** ([@c3-oss/slack-mcp-server](https://www.npmjs.com/package/@c3-oss/slack-mcp-server)): needs your Slack session tokens.
- **Beeper, Gmail and CRM bridges**: local or private servers.
- **Tavily account**: the Tavily skills need the `tavily-cli`. Search and extract work without a key (capped); crawl, map and research need `tvly login`.

## Credits

Built on the work of [thedotmack/claude-mem](https://github.com/thedotmack/claude-mem), [obra/superpowers](https://github.com/obra/superpowers), [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents), [blader/humanizer](https://github.com/blader/humanizer), [tavily-ai/skills](https://github.com/tavily-ai/skills), [supabase/agent-skills](https://github.com/supabase/agent-skills), [steipete/Peekaboo](https://github.com/steipete/Peekaboo), [MinishLab/semble](https://github.com/MinishLab/semble), [vercel-labs/skills](https://github.com/vercel-labs/skills), [flc1125/skills](https://github.com/flc1125/skills), REA and Anthropic's official plugins. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

MIT © Malek Hassan
