# brainbridge

Keeps your second-brain vault in sync with a private Git remote, so the same notes show up on your laptop, desktop and phone (Obsidian + Obsidian Git or Working Copy).

- Commits 5 seconds after you stop typing, then `pull --rebase` and `push`.
- Pulls every 2 minutes, so edits from other devices land on their own.
- Never loses work: on a conflict, your local version goes to a `conflict/<timestamp>` branch and a note in the vault explains how to compare the two.
- macOS notifications for failures that need you (auth, conflicts). Everything else retries quietly.

## Setup

```bash
cd ~/second-brain                      # your vault
git init -b main && git add -A && git commit -m "first capture"
gh repo create my-second-brain --private --source . --push   # or any private remote

cd <this folder>                       # /steroid-claude:doctor prints where the plugin lives
npm ci
VAULT_PATH=~/second-brain npm start    # try it in the foreground first (Ctrl-C to stop)
```

## Run it in the background (macOS)

```bash
./install-launchd.sh ~/second-brain    # copies itself to ~/.local/share/brainbridge, renders the plist, loads it
tail -f ~/Library/Logs/brainbridge.log
```

To stop it: `launchctl unload ~/Library/LaunchAgents/com.steroid-claude.brainbridge.plist`.

On Linux, run `VAULT_PATH=... node index.js` from a systemd user service instead.

## Tests

`npm test`: 13 tests against throwaway bare repos, no network.
