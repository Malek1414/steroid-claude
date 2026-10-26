import { appendFile, mkdir } from 'node:fs/promises'
import { homedir } from 'node:os'
import { dirname, join } from 'node:path'
import { execFile } from 'node:child_process'
import { promisify } from 'node:util'

const exec = promisify(execFile)
const LOG = join(homedir(), 'Library', 'Logs', 'brainbridge.log')

export async function log(message) {
  const line = `${new Date().toISOString()}  ${message}\n`
  process.stdout.write(line)
  try {
    await mkdir(dirname(LOG), { recursive: true })
    await appendFile(LOG, line, 'utf8')
  } catch {
    // A logging failure must never take the daemon down.
  }
}

// Surfaces a macOS notification. Used only for failures that need a human,
// because a silent sync failure is indistinguishable from a working one.
export async function notify(title, message) {
  const script = `display notification ${JSON.stringify(message)} with title ${JSON.stringify(title)}`
  try {
    await exec('osascript', ['-e', script])
  } catch {
    // Notification failure is not worth escalating.
  }
}
