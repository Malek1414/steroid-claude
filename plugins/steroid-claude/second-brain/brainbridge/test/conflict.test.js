import test from 'node:test'
import assert from 'node:assert/strict'
import { readFile, writeFile } from 'node:fs/promises'
import { join } from 'node:path'
import { makeRemote, makeClone } from './helpers.js'
import { git, hasChanges, commitAll, pullRebase, push } from '../src/git.js'
import { resolveConflict } from '../src/conflict.js'

// Drives two clones into a genuine conflict and hands back the losing side.
async function conflicted() {
  const remote = await makeRemote()
  const a = await makeClone(remote)
  const b = await makeClone(remote)

  await writeFile(join(b, 'Ideas', 'note.md'), 'phone version\n', 'utf8')
  await commitAll(b, 'edit from phone')
  await push(b)

  await writeFile(join(a, 'Ideas', 'note.md'), 'mac version\n', 'utf8')
  await commitAll(a, 'edit from mac')

  const result = await pullRebase(a)
  assert.equal(result.ok, false)
  return { cwd: a, conflicts: result.conflicts }
}

const AT = new Date('2026-08-25T14:02:00Z')

test('local work is preserved on a conflict branch', async () => {
  const { cwd, conflicts } = await conflicted()
  const { branch } = await resolveConflict(cwd, conflicts, AT)

  const content = await git(cwd, ['show', `${branch}:Ideas/note.md`])
  assert.equal(content, 'mac version')
})

test('the remote version wins on main so syncing can resume', async () => {
  const { cwd, conflicts } = await conflicted()
  await resolveConflict(cwd, conflicts, AT)

  const onDisk = await readFile(join(cwd, 'Ideas', 'note.md'), 'utf8')
  assert.equal(onDisk, 'phone version\n')
})

test('a CONFLICT note is written naming the branch and the files', async () => {
  const { cwd, conflicts } = await conflicted()
  const { branch, notePath } = await resolveConflict(cwd, conflicts, AT)

  assert.equal(notePath, 'Inbox/CONFLICT-2026-08-25T14-02-00Z.md')
  const note = await readFile(join(cwd, notePath), 'utf8')
  assert.match(note, /Ideas\/note\.md/)
  assert.match(note, new RegExp(branch))
})

test('the tree is clean and rebase-free afterwards, so the next tick is a no-op', async () => {
  const { cwd, conflicts } = await conflicted()
  await resolveConflict(cwd, conflicts, AT)

  assert.equal(await hasChanges(cwd), false)
  // A second pull must now succeed rather than re-conflicting forever.
  assert.deepEqual(await pullRebase(cwd), { ok: true })
})
