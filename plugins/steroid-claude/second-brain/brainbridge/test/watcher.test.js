import test from 'node:test'
import assert from 'node:assert/strict'
import { mkdtemp, mkdir, writeFile } from 'node:fs/promises'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { watchVault } from '../src/watcher.js'

const sleep = ms => new Promise(r => setTimeout(r, ms))

test('a burst of writes collapses into a single callback', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'bb-watch-'))
  await mkdir(join(dir, 'Ideas'), { recursive: true })

  let calls = 0
  const w = watchVault(dir, () => { calls += 1 }, 100)
  await sleep(300) // let chokidar finish its initial scan

  for (const n of [1, 2, 3, 4, 5]) {
    await writeFile(join(dir, 'Ideas', `n${n}.md`), 'x\n', 'utf8')
  }
  await sleep(600)

  assert.equal(calls, 1)
  await w.close()
})

test('changes inside .git never trigger the callback', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'bb-watch-'))
  await mkdir(join(dir, '.git', 'refs'), { recursive: true })

  let calls = 0
  const w = watchVault(dir, () => { calls += 1 }, 100)
  await sleep(300)

  // Simulates brainbridge's own commit churning .git. If this fired, the
  // daemon would trigger itself in a loop.
  await writeFile(join(dir, '.git', 'refs', 'heads-main'), 'abc123\n', 'utf8')
  await sleep(600)

  assert.equal(calls, 0)
  await w.close()
})
