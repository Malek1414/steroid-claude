import { mkdtemp, mkdir, writeFile } from 'node:fs/promises'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { execFile } from 'node:child_process'
import { promisify } from 'node:util'

const exec = promisify(execFile)

// A bare repo standing in for GitHub, seeded with one note so clones have a
// real `main` branch to track (cloning an empty bare repo yields no branch).
export async function makeRemote() {
  const remote = await mkdtemp(join(tmpdir(), 'bb-remote-'))
  await exec('git', ['init', '--bare', '-b', 'main'], { cwd: remote })

  const seed = await mkdtemp(join(tmpdir(), 'bb-seed-'))
  await exec('git', ['clone', remote, seed])
  await identify(seed)
  await mkdir(join(seed, 'Ideas'), { recursive: true })
  await writeFile(join(seed, 'Ideas', 'note.md'), 'original\n', 'utf8')
  await exec('git', ['add', '-A'], { cwd: seed })
  await exec('git', ['commit', '-m', 'seed'], { cwd: seed })
  await exec('git', ['push', '-u', 'origin', 'main'], { cwd: seed })

  return remote
}

export async function makeClone(remote) {
  const parent = await mkdtemp(join(tmpdir(), 'bb-clone-'))
  const dir = join(parent, 'vault')
  await exec('git', ['clone', remote, dir])
  await identify(dir)
  return dir
}

// Tests must not depend on the machine's global git identity.
async function identify(cwd) {
  await exec('git', ['config', 'user.name', 'Test Runner'], { cwd })
  await exec('git', ['config', 'user.email', 'test@example.invalid'], { cwd })
}
