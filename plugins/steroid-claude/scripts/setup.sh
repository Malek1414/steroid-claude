#!/usr/bin/env bash
# Steroid Claude setup. Installs the companion plugins, MCP servers, upstream
# skills and extras that make up the stack, and records what it added in
# $CLAUDE_DIR/steroid-claude/state so uninstall.sh can reverse exactly that.
#
# Written for bash 3.2 (macOS default): no associative arrays, no mapfile.
#
#   setup.sh [--yes] [--dry-run] [--check] [--minimal] [--no-agents]
#            [--with lsp,peekaboo,blender|all] [--second-brain [PATH]]
#            [--settings] [--no-claude-md] [--star | --no-star]

set -uo pipefail   # no -e: one failed step must not abort the rest

# Some marketplaces point at GitHub over SSH. Clone those over HTTPS so people
# without a GitHub SSH key can still install them (public repos need no auth).
if [ -z "${GIT_CONFIG_COUNT:-}" ]; then
  export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0="url.https://github.com/.insteadOf" GIT_CONFIG_VALUE_0="git@github.com:"
fi

REPO="Malek1414/steroid-claude"
VERSION="1.0.0"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
STATE_DIR="$CLAUDE_DIR/steroid-claude"
STATE_FILE="$STATE_DIR/state"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

YES=0 DRY=0 CHECK=0 MINIMAL=0 AGENTS=1 SETTINGS=0 CLAUDE_MD=1
STAR="ask" BRAIN="" WITH=","

usage() { sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

while [ $# -gt 0 ]; do
  case "$1" in
    -y|--yes) YES=1 ;;
    --dry-run) DRY=1 ;;
    --check|--doctor) CHECK=1 ;;
    --minimal) MINIMAL=1 ;;
    --no-agents) AGENTS=0 ;;
    --with) shift; WITH="$WITH${1:-},"; ;;
    --with=*) WITH="$WITH${1#--with=}," ;;
    --second-brain)
      if [ $# -gt 1 ] && [ "${2#-}" = "$2" ]; then BRAIN="$2"; shift; else BRAIN="$HOME/second-brain"; fi ;;
    --second-brain=*) BRAIN="${1#--second-brain=}" ;;
    --settings) SETTINGS=1 ;;
    --no-claude-md) CLAUDE_MD=0 ;;
    --star) STAR="yes" ;;
    --no-star) STAR="no" ;;
    -h|--help) usage 0 ;;
    *) echo "Unknown option: $1" >&2; usage 1 ;;
  esac
  shift
done
case "$WITH" in *,all,*) WITH=",lsp,peekaboo,blender," ;; esac
wants() { case "$WITH" in *",$1,"*) return 0 ;; *) return 1 ;; esac; }

# ── output ───────────────────────────────────────────────────────────────────
if [ -t 1 ]; then B=$'\033[1m' G=$'\033[32m' Y=$'\033[33m' R=$'\033[31m' D=$'\033[2m' N=$'\033[0m'
else B="" G="" Y="" R="" D="" N=""; fi
step() { printf '\n%s▸ %s%s\n' "$B" "$1" "$N"; }
ok()   { printf '  %s✓%s %s\n' "$G" "$N" "$1"; }
skip() { printf '  %s•%s %s\n' "$D" "$N" "$1"; }
warn() { printf '  %s!%s %s\n' "$Y" "$N" "$1"; }
fail() { printf '  %s✗%s %s\n' "$R" "$N" "$1"; FAILED=$((FAILED + 1)); }
FAILED=0

have() { command -v "$1" >/dev/null 2>&1; }
ERR_FILE="$(mktemp)"; trap 'rm -f "$ERR_FILE"' EXIT
run() {
  if [ "$DRY" = 1 ]; then printf '  %s[dry-run]%s %s\n' "$D" "$N" "$*"; return 0; fi
  "$@" </dev/null >/dev/null 2>"$ERR_FILE"
}
last_error() { tail -n 3 "$ERR_FILE" 2>/dev/null | tr '\n' ' '; }
record() {
  [ "$DRY" = 1 ] && return 0
  grep -qxF "$1" "$STATE_FILE" 2>/dev/null || printf '%s\n' "$1" >> "$STATE_FILE"
}
tty_ok() { [ "$YES" = 0 ] && { : </dev/tty; } 2>/dev/null; }
ask() { # ask "question" default(y|n) → 0 for yes
  local prompt="[y/N]" ans; [ "$2" = y ] && prompt="[Y/n]"
  printf '%s %s ' "$1" "$prompt" >/dev/tty; read -r ans </dev/tty || ans=""
  [ -z "$ans" ] && ans="$2"
  case "$ans" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

[ "$DRY" = 0 ] && { mkdir -p "$STATE_DIR"; touch "$STATE_FILE"; }
state_get() { sed -n "s/^$1 //p" "$STATE_FILE" 2>/dev/null | tail -1; }

# ── manifest ─────────────────────────────────────────────────────────────────
marketplace_repo() {
  case "$1" in
    claude-plugins-official) echo "anthropics/claude-plugins-official" ;;
    thedotmack) echo "thedotmack/claude-mem" ;;
    karpathy-skills) echo "forrestchang/andrej-karpathy-skills" ;;
    neonwatty-plugins) echo "neonwatty/job-apply-plugin" ;;
    nightcrawler) echo "Malek1414/nightcrawler" ;;
    mozcode) echo "Malek1414/MOZCODE" ;;
    steroid-claude) echo "$REPO" ;;
  esac
}

PLUGINS="steroid-claude@steroid-claude
superpowers@claude-plugins-official
frontend-design@claude-plugins-official
code-review@claude-plugins-official
github@claude-plugins-official
claude-mem@thedotmack
andrej-karpathy-skills@karpathy-skills"
[ "$AGENTS" = 1 ] && [ "$MINIMAL" = 0 ] && PLUGINS="$PLUGINS
steroid-agents@steroid-claude"
[ "$MINIMAL" = 0 ] && PLUGINS="$PLUGINS
nightcrawler@nightcrawler
mozcode@mozcode
job-apply@neonwatty-plugins"
wants lsp && PLUGINS="$PLUGINS
swift-lsp@claude-plugins-official
rust-analyzer-lsp@claude-plugins-official"

# name|runtime it needs|command...   (the runtime is checked before adding)
MCP_SERVERS="semble|uvx|uvx --from semble[mcp] semble
chrome-devtools|npx|npx -y chrome-devtools-mcp@latest"
[ "$MINIMAL" = 0 ] && MCP_SERVERS="$MCP_SERVERS
rea|npx|npx -y rea-agents mcp"
wants peekaboo && MCP_SERVERS="$MCP_SERVERS
peekaboo|peekaboo|peekaboo mcp"
wants blender && MCP_SERVERS="$MCP_SERVERS
blenderwright|uvx|uvx blenderwright"

# name|repo|path in repo   (skills with no upstream licence: fetched, not vendored)
UPSTREAM_SKILLS="llm-council|am-will/codex-skills|skills/llm-council"

# ── preflight ────────────────────────────────────────────────────────────────
printf '%sSteroid Claude %s%s  %s(%s)%s\n' "$B" "$VERSION" "$N" "$D" "$CLAUDE_DIR" "$N"
[ "$DRY" = 1 ] && warn "dry run: nothing will change"

step "Prerequisites"
if have claude; then ok "claude $(claude --version 2>/dev/null | head -1)"
else
  fail "Claude Code CLI not found. Install it first: curl -fsSL https://claude.ai/install.sh | bash"
  exit 1
fi
have git && ok "git" || warn "git missing: upstream skills will be skipped"
have npx && ok "node / npx" || warn "npx missing: chrome-devtools and rea MCP servers will be skipped (install Node.js)"
have uvx && ok "uv / uvx" || warn "uvx missing: semble MCP will be skipped (install uv: curl -LsSf https://astral.sh/uv/install.sh | sh)"
have python3 && ok "python3" || warn "python3 missing: --settings will be skipped"
have gh && ok "gh" || skip "gh not installed (only needed to star the repo)"

PLUGIN_LIST="$(claude plugin list --json </dev/null 2>/dev/null || echo '[]')"
MARKET_LIST="$(claude plugin marketplace list --json </dev/null 2>/dev/null || echo '[]')"
plugin_installed() { grep -Eq "\"id\": *\"$1\"" <<<"$PLUGIN_LIST"; }
marketplace_known() { grep -Eq "\"name\": *\"$1\"" <<<"$MARKET_LIST"; }
mcp_configured() { claude mcp get "$1" </dev/null >/dev/null 2>&1; }

# ── doctor ───────────────────────────────────────────────────────────────────
if [ "$CHECK" = 1 ]; then
  step "Plugins"
  while IFS= read -r id; do
    plugin_installed "$id" && ok "$id" || warn "$id (missing)"
  done <<<"$PLUGINS"
  step "MCP servers"
  while IFS='|' read -r name _ _; do
    mcp_configured "$name" && ok "$name" || warn "$name (missing)"
  done <<<"$MCP_SERVERS"
  step "Skills"
  while IFS='|' read -r name _ _; do
    [ -f "$CLAUDE_DIR/skills/$name/SKILL.md" ] && ok "$name" || warn "$name (missing)"
  done <<<"$UPSTREAM_SKILLS"
  step "Extras"
  grep -q 'steroid-claude:start' "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null && ok "CLAUDE.md block" || warn "CLAUDE.md block (missing)"
  b="$(state_get brain)"
  [ -n "$b" ] && ok "second brain at $b" || skip "second brain not set up (--second-brain)"
  [ -f "$STATE_DIR/setup-done" ] && ok "setup has run" || warn "setup has not run yet"
  exit 0
fi

# ── marketplaces + plugins ───────────────────────────────────────────────────
step "Plugins"
for mk in $(printf '%s\n' "$PLUGINS" | sed 's/.*@//' | sort -u); do
  marketplace_known "$mk" && continue
  repo="$(marketplace_repo "$mk")"
  if run claude plugin marketplace add "$repo"; then ok "marketplace $mk ($repo)"; record "marketplace $mk"
  else fail "marketplace $mk: $(last_error)"; fi
done
while IFS= read -r id; do
  if plugin_installed "$id"; then skip "$id (already installed)"; continue; fi
  if run claude plugin install "$id" --scope user -y; then ok "$id"; record "plugin $id"
  else fail "$id: $(last_error)"; fi
done <<<"$PLUGINS"

# ── MCP servers ──────────────────────────────────────────────────────────────
step "MCP servers"
if wants peekaboo && ! have peekaboo; then
  if [ "$(uname)" != Darwin ]; then warn "peekaboo is macOS only, skipping"
  elif have brew; then run brew install steipete/tap/peekaboo && ok "installed peekaboo CLI" || warn "brew install peekaboo failed"
  else warn "peekaboo needs Homebrew: brew install steipete/tap/peekaboo"; fi
fi
while IFS='|' read -r name runtime cmd; do
  if mcp_configured "$name"; then skip "$name (already configured)"; continue; fi
  if [ "$DRY" = 0 ] && ! have "$runtime"; then warn "$name skipped: needs $runtime"; continue; fi
  set -f   # cmd is a trusted, space-separated argv; semble[mcp] must not glob
  # shellcheck disable=SC2086
  if run claude mcp add --scope user "$name" -- $cmd; then ok "$name"; record "mcp $name"
  else fail "$name: $(last_error)"; fi
  set +f
done <<<"$MCP_SERVERS"
wants blender && warn "blenderwright also needs its Blender add-on: see https://pypi.org/project/blenderwright/"

# ── upstream skills ──────────────────────────────────────────────────────────
step "Skills"
ok "18 skills ship inside the steroid-claude plugin"
while IFS='|' read -r name repo path; do
  dest="$CLAUDE_DIR/skills/$name"
  if [ -e "$dest" ]; then skip "$name (already present)"; continue; fi
  if ! have git; then warn "$name skipped: needs git"; continue; fi
  if [ "$DRY" = 1 ]; then run git clone "https://github.com/$repo" "($path → $dest)"; continue; fi
  tmp="$(mktemp -d)"
  if git clone -q --depth 1 --filter=blob:none --sparse "https://github.com/$repo" "$tmp/r" </dev/null 2>"$ERR_FILE" \
     && git -C "$tmp/r" sparse-checkout set "$path" 2>>"$ERR_FILE" \
     && [ -f "$tmp/r/$path/SKILL.md" ]; then
    mkdir -p "$CLAUDE_DIR/skills" && cp -R "$tmp/r/$path" "$dest" && ok "$name (from $repo)" && record "skill $name"
  else fail "$name: $(last_error)"; fi
  rm -rf "$tmp"
done <<<"$UPSTREAM_SKILLS"

# ── second brain ─────────────────────────────────────────────────────────────
if [ -z "$BRAIN" ] && tty_ok && [ -z "$(state_get brain)" ]; then
  ask "Set up a second-brain vault (Obsidian-ready notes Claude keeps up to date) at ~/second-brain?" n && BRAIN="$HOME/second-brain"
fi
if [ -n "$BRAIN" ]; then
  step "Second brain"
  case "$BRAIN" in "~"/*) BRAIN="$HOME/${BRAIN#\~/}" ;; esac
  if [ "$DRY" = 1 ]; then run cp -Rn "$PLUGIN_ROOT/second-brain/vault/." "$BRAIN"
  else
    mkdir -p "$BRAIN" && cp -Rn "$PLUGIN_ROOT/second-brain/vault/." "$BRAIN/" 2>/dev/null
    [ -f "$BRAIN/Context/INDEX.md" ] && ok "vault ready at $BRAIN (existing files left untouched)" || fail "could not copy the vault template"
    sed -i.bak '/^brain /d' "$STATE_FILE" && rm -f "$STATE_FILE.bak"; record "brain $BRAIN"
  fi
  skip "optional git sync daemon: $PLUGIN_ROOT/second-brain/brainbridge/README.md"
fi
BRAIN_PATH="$(state_get brain)"
[ -z "$BRAIN_PATH" ] && [ "$DRY" = 1 ] && BRAIN_PATH="$BRAIN"

# ── CLAUDE.md block ──────────────────────────────────────────────────────────
if [ "$CLAUDE_MD" = 1 ]; then
  step "CLAUDE.md"
  md="$CLAUDE_DIR/CLAUDE.md"
  block="$(cat "$PLUGIN_ROOT/templates/CLAUDE.block.md")"
  if [ -n "$BRAIN_PATH" ]; then
    block="$block

$(sed "s|{{VAULT}}|$(printf '%s' "$BRAIN_PATH" | sed 's/[&|\\]/\\&/g')|g" "$PLUGIN_ROOT/templates/CLAUDE.brain.md")"
  fi
  block="<!-- steroid-claude:start -->
$block
<!-- steroid-claude:end -->"
  if [ "$DRY" = 1 ]; then run "write block to $md"
  else
    touch "$md"
    # drop any previous block and trailing blank lines, then append the new one
    awk '/<!-- steroid-claude:start -->/{s=1; next} /<!-- steroid-claude:end -->/{s=0; next} s{next}
         /^[[:space:]]*$/{blank++; next} {while (blank > 0) {print ""; blank--} print}' "$md" > "$md.tmp"
    { cat "$md.tmp"; if [ -s "$md.tmp" ]; then echo; fi; printf '%s\n' "$block"; } > "$md"
    rm -f "$md.tmp"
    ok "block written to $md (between steroid-claude markers)"; record "claude-md"
  fi
fi

# ── settings ─────────────────────────────────────────────────────────────────
if [ "$SETTINGS" = 1 ]; then
  step "Settings"
  if ! have python3; then warn "skipped: needs python3"
  elif [ "$DRY" = 1 ]; then run "merge $PLUGIN_ROOT/templates/settings.recommended.json into $CLAUDE_DIR/settings.json"
  else
    python3 - "$CLAUDE_DIR/settings.json" "$PLUGIN_ROOT/templates/settings.recommended.json" "$STATE_FILE" <<'PY'
import json, os, sys
target, rec, state = sys.argv[1:4]
cur = json.load(open(target)) if os.path.exists(target) and os.path.getsize(target) else {}
added = []
for k, v in json.load(open(rec)).items():
    if k.startswith("_"):
        continue
    if k not in cur:
        cur[k] = v
        added.append(k)
    else:
        print(f"  • {k} (you already have one, left as is)")
json.dump(cur, open(target, "w"), indent=2)
open(target, "a").write("\n")
with open(state, "a") as f:
    for k in added:
        f.write(f"settings {k}\n")
        print(f"  ✓ {k}")
PY
  fi
fi

# ── install count + star ─────────────────────────────────────────────────────
step "Finishing"
if [ "$DRY" = 0 ]; then
  touch "$STATE_DIR/setup-done"
  if [ ! -f "$STATE_DIR/counted" ] && [ -z "${STEROID_NO_COUNT:-}" ]; then
    # One download of a tiny release asset. GitHub counts it; that number is
    # the installs badge in the README. Nothing about you is sent.
    curl -fsSL --max-time 10 -o /dev/null \
      "https://github.com/$REPO/releases/latest/download/steroid-claude.version" 2>/dev/null \
      && touch "$STATE_DIR/counted" && ok "counted as an install (STEROID_NO_COUNT=1 opts out)"
  fi
fi

star() {
  if [ "$DRY" = 1 ]; then run gh api -X PUT "/user/starred/$REPO"; return; fi
  if have gh && gh auth status >/dev/null 2>&1 && gh api -X PUT "/user/starred/$REPO" --silent 2>/dev/null; then
    ok "starred $REPO. Thank you!"
  else
    skip "star it here: https://github.com/$REPO"
  fi
}
case "$STAR" in
  yes) star ;;
  no) ;;
  ask)
    if tty_ok; then ask "  ⭐ Star $REPO on GitHub so Malek knows you're using it?" y && star
    else skip "like it? star it: https://github.com/$REPO"; fi ;;
esac

printf '\n'
if [ "$FAILED" -gt 0 ]; then warn "$FAILED step(s) failed: see above. Re-run any time; finished steps are skipped."
else ok "${B}Done.${N} Restart Claude Code (or run /reload-plugins) to load everything."; fi
printf '  %sNext:%s set GITHUB_PERSONAL_ACCESS_TOKEN for the github plugin; run /steroid-claude:doctor to check the install.\n' "$D" "$N"
[ "$FAILED" -eq 0 ]
