## Steroid Claude

### Code search: semble first

When the `semble` MCP server is connected, it gives you two tools:
- `mcp__semble__search`: search the codebase with a natural-language or code query.
- `mcp__semble__find_related`: find code similar to a given file and line.

Call `mcp__semble__search` before Grep, Glob or Read when exploring a codebase. Use Grep/Glob/Read for exact path lookups, exhaustive literal matches, or when a returned chunk lacks context. Pass `--content docs` for documentation and prose, `--content config` for config files, `--content all` for everything. Subagents without MCP access can use the CLI: `uvx --from "semble[mcp]" semble search "query" ./repo`.

### Memory

claude-mem records past sessions. When asked "did we already do X?" or "how did we solve Y last time?", search memory (mem-search skill) before re-deriving anything.

### Process

superpowers is installed: brainstorm before building something new, write a plan before multi-step work, debug systematically, and verify before you say something is done.
