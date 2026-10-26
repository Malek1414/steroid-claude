import { commitAll, pullRebase, push } from './src/git.js'
import { resolveConflict } from './src/conflict.js'
import { watchVault } from './src/watcher.js'
import { log, notify } from './src/log.js'
import { homedir } from 'node:os'
import { join } from 'node:path'

const VAULT = process.env.VAULT_PATH || join(homedir(), 'second-brain')
const DEBOUNCE_MS = 5_000
const PULL_INTERVAL_MS = 120_000

// One sync at a time. The watcher and the timer both call sync(), and two
// concurrent git processes in one repo corrupt the index.
let running = false
let queued = false

async function sync(reason) {
  if (running) { queued = true; return }
  running = true
  try {
    const committed = await commitAll(VAULT, `capture: ${reason}`)
    if (committed) await log(`committed (${reason})`)

    const result = await pullRebase(VAULT)
    if (!result.ok) {
      const { branch, notePath } = await resolveConflict(VAULT, result.conflicts, new Date())
      await log(`CONFLICT on ${result.conflicts.join(', ')} — local work saved to ${branch}`)
      await notify('Vault sync conflict', `Your version is on ${branch}. See ${notePath}.`)
      return
    }

    // Push whatever is ahead of origin — our own commit, or commits the
    // rebase replayed on top of the remote.
    await push(VAULT)
  } catch (err) {
    const message = err?.stderr?.toString().trim() || err?.message || String(err)
    await log(`sync failed (${reason}): ${message}`)
    if (/Authentication|could not read Username|Permission denied/i.test(message)) {
      await notify('Vault sync: auth failed', 'brainbridge cannot reach GitHub. Check your credentials.')
    }
    // Everything else — network down, GitHub unreachable — is transient.
    // Commits stay local and the next tick retries. Nothing is lost.
  } finally {
    running = false
    if (queued) { queued = false; sync('queued') }
  }
}

const watcher = watchVault(VAULT, () => sync('vault changed'), DEBOUNCE_MS)
const timer = setInterval(() => sync('scheduled pull'), PULL_INTERVAL_MS)

// Waking from sleep looks like a long gap between timer ticks, so the regular
// interval covers it with no special handling.
await log(`brainbridge watching ${VAULT}`)
await sync('startup')

for (const signal of ['SIGINT', 'SIGTERM']) {
  process.on(signal, async () => {
    clearInterval(timer)
    await watcher.close()
    await log('brainbridge stopped')
    process.exit(0)
  })
}
