import { mkdir, writeFile } from 'node:fs/promises'
import { dirname, join } from 'node:path'
import { git, commitAll, push } from './git.js'

// Git refs and macOS filenames both dislike colons, so flatten the timestamp.
function stamp(now) {
  return now.toISOString().replace(/\.\d{3}Z$/, 'Z').replace(/:/g, '-')
}

// Called only when pullRebase reported a conflict. Preserves both sides:
// local commits survive on a branch, the remote wins on main, and a note
// explains where to find the other version.
//
// Nothing here resolves the conflict. That is a human decision, and guessing
// would be the one failure mode this whole design exists to prevent.
//
// The branch-then-reset order matters: simply aborting and retrying loops
// forever, because the same two commits re-conflict on every tick. Moving
// local work onto a branch leaves main clean relative to the remote, so the
// next tick is an ordinary sync.
export async function resolveConflict(cwd, conflicts, now) {
  const at = stamp(now)
  const branch = `conflict/${at}`

  await git(cwd, ['rebase', '--abort'])
  await git(cwd, ['branch', branch])          // pins the local commits
  await git(cwd, ['fetch', 'origin', 'main'])
  await git(cwd, ['reset', '--hard', 'origin/main'])

  const notePath = join('Inbox', `CONFLICT-${at}.md`)
  const body = [
    '---',
    `title: "Sync conflict ${at}"`,
    'category: general',
    'tags: ["brainbridge", "conflict"]',
    `created: ${now.toISOString()}`,
    '---',
    '',
    `# Sync conflict ${at}`,
    '',
    'Two devices edited the same note before syncing. Nothing was lost, and',
    'nothing was resolved automatically — you decide which version is right.',
    '',
    '## Conflicting files',
    '',
    ...conflicts.map(f => `- \`${f}\``),
    '',
    '## Where each version is',
    '',
    `- **This device's version** is on the branch \`${branch}\`.`,
    '- **The other device\'s version** is what you see in the vault now.',
    '',
    '## To compare them',
    '',
    '```bash',
    `cd "${cwd}"`,
    `git diff main ${branch}`,
    '```',
    '',
    'Once you have merged by hand, delete the branch with',
    `\`git branch -D ${branch}\` and this note.`,
    '',
  ].join('\n')

  const abs = join(cwd, notePath)
  await mkdir(dirname(abs), { recursive: true })
  await writeFile(abs, body, 'utf8')

  // The note is a brand-new file, so committing and pushing it cannot conflict.
  await commitAll(cwd, `chore: record sync conflict ${at}`)
  await push(cwd)

  return { branch, notePath }
}
