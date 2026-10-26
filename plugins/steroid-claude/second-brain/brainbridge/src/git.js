import { execFile } from 'node:child_process'
import { promisify } from 'node:util'

const exec = promisify(execFile)

// Thin wrapper over the git binary. Uses execFile (not exec) so arguments are
// passed as an array and never go through a shell — the vault path contains a
// space, and shell interpolation would split it.
export async function git(cwd, args) {
  const { stdout } = await exec('git', args, { cwd })
  return stdout.trim()
}

export async function hasChanges(cwd) {
  return (await git(cwd, ['status', '--porcelain'])).length > 0
}

// Returns false when the tree was already clean, so callers can skip the push.
export async function commitAll(cwd, message) {
  if (!(await hasChanges(cwd))) return false
  await git(cwd, ['add', '-A'])
  await git(cwd, ['commit', '-m', message])
  return true
}

// Never throws on a conflict — a conflict is an expected outcome that the
// caller must handle deliberately, not an exception to unwind through.
export async function pullRebase(cwd) {
  try {
    await git(cwd, ['pull', '--rebase', 'origin', 'main'])
    return { ok: true }
  } catch (err) {
    // Read the unmerged paths while the rebase is still in progress; aborting
    // first would discard this information.
    const out = await git(cwd, ['diff', '--name-only', '--diff-filter=U']).catch(() => '')
    const conflicts = out.split('\n').map(s => s.trim()).filter(Boolean)
    if (conflicts.length > 0) return { ok: false, conflicts }

    // A pull can fail without any conflict — most often because another
    // process wrote to the vault between our commit and this pull, leaving
    // the tree dirty. Treating that as a conflict sent it down the
    // branch-and-reset path, where `rebase --abort` then died with "no rebase
    // in progress". Leave no half-finished rebase behind and surface it as an
    // ordinary error so the next tick simply retries.
    await git(cwd, ['rebase', '--abort']).catch(() => {})
    throw err
  }
}

export async function push(cwd) {
  await git(cwd, ['push', 'origin', 'main'])
}
