import test from 'node:test'
import assert from 'node:assert/strict'
import { writeFile } from 'node:fs/promises'
import { join } from 'node:path'
import { makeRemote, makeClone } from './helpers.js'
import { hasChanges, commitAll, pullRebase, push } from '../src/git.js'

test('hasChanges is false on a clean tree', async () => {
  const clone = await makeClone(await makeRemote())
  assert.equal(await hasChanges(clone), false)
})

test('hasChanges is true after writing a new note', async () => {
  const clone = await makeClone(await makeRemote())
  await writeFile(join(clone, 'Ideas', 'fresh.md'), 'hello\n', 'utf8')
  assert.equal(await hasChanges(clone), true)
})

test('commitAll returns false when there is nothing to commit', async () => {
  const clone = await makeClone(await makeRemote())
  assert.equal(await commitAll(clone, 'no-op'), false)
})

test('commitAll commits a new note and returns true', async () => {
  const clone = await makeClone(await makeRemote())
  await writeFile(join(clone, 'Ideas', 'fresh.md'), 'hello\n', 'utf8')
  assert.equal(await commitAll(clone, 'capture: fresh'), true)
  assert.equal(await hasChanges(clone), false)
})

test('a new file on the remote arrives via pullRebase without conflict', async () => {
  const remote = await makeRemote()
  const a = await makeClone(remote)
  const b = await makeClone(remote)

  await writeFile(join(b, 'Ideas', 'from-phone.md'), 'phone\n', 'utf8')
  await commitAll(b, 'capture: from phone')
  await push(b)

  const result = await pullRebase(a)
  assert.deepEqual(result, { ok: true })
  assert.equal(await hasChanges(a), false)
})

test('pullRebase reports the conflicting path instead of throwing', async () => {
  const remote = await makeRemote()
  const a = await makeClone(remote)
  const b = await makeClone(remote)

  // Both sides edit the same existing note — the only way to conflict, since
  // captures are append-only. This is the grader-vs-phone scenario.
  await writeFile(join(b, 'Ideas', 'note.md'), 'phone version\n', 'utf8')
  await commitAll(b, 'edit from phone')
  await push(b)

  await writeFile(join(a, 'Ideas', 'note.md'), 'mac version\n', 'utf8')
  await commitAll(a, 'edit from mac')

  const result = await pullRebase(a)
  assert.equal(result.ok, false)
  assert.deepEqual(result.conflicts, ['Ideas/note.md'])
})

// Regression: pullRebase treated *any* pull failure as a conflict. A dirty
// tree (another process writing to the vault mid-sync) has no unmerged paths,
// so the conflict path then called `rebase --abort` on a repo with no rebase
// in progress and died with a confusing "fatal: no rebase in progress".
// A non-conflict failure must throw so the next tick simply retries.
test('a pull that fails without conflicts throws rather than reporting one', async () => {
  const remote = await makeRemote()
  const a = await makeClone(remote)
  const b = await makeClone(remote)

  await writeFile(join(b, 'Ideas', 'note.md'), 'remote change\n', 'utf8')
  await commitAll(b, 'remote edit')
  await push(b)

  // Uncommitted local edit to the same file: git refuses to rebase, but
  // nothing is ever in an unmerged state.
  await writeFile(join(a, 'Ideas', 'note.md'), 'dirty local edit\n', 'utf8')

  await assert.rejects(() => pullRebase(a))
})
