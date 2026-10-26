import chokidar from 'chokidar'

// Watches the vault and calls onSettled once per burst of activity.
//
// Debouncing matters for two reasons: saving a note in Obsidian produces
// several filesystem events, and a git pull rewrites many files at once. One
// commit per burst is what we want, not one per event.
export function watchVault(dir, onSettled, debounceMs = 5000) {
  let timer = null

  const watcher = chokidar.watch(dir, {
    ignored: /(^|[/\\])(\.git|\.DS_Store)([/\\]|$)/,
    ignoreInitial: true,   // the initial scan is not a change
    awaitWriteFinish: { stabilityThreshold: 200, pollInterval: 50 },
  })

  const bump = () => {
    if (timer) clearTimeout(timer)
    timer = setTimeout(() => { timer = null; onSettled() }, debounceMs)
  }

  watcher.on('add', bump).on('change', bump).on('unlink', bump)

  return {
    async close() {
      if (timer) clearTimeout(timer)
      await watcher.close()
    },
  }
}
