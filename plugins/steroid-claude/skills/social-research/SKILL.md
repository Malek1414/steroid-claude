---
name: social-research
description: >
  Deep-research a social media creator's content style from their handle.
  Only use when the user explicitly invokes /social-research (or clearly asks
  to "research this creator/handle"), passing a handle like @creatorname or a
  profile URL. Analyzes in depth how the creator films and — most importantly —
  edits their videos: caption style and sequencing, caption-to-speech sync,
  cut cadence, hooks, pacing, sound design, plus filming equipment and setup.
  Produces a research report, a summary, an implementation guide tailored to
  the user's situation, and a machine-ready EDIT_SPEC.md that the /social-edit
  skill consumes to replicate the style on the user's own videos.
---

# Social Research

Reverse-engineer how a creator produces their short-form videos, then hand off
an actionable edit spec to `/social-edit`.

**Priority order:** editing style is the core deliverable. Filming setup and
equipment matter, but are secondary. Never pad the equipment section with
guesses — if the gear can't be identified, say so and move on.

## Input

The user provides a handle (e.g. `@hormozi`) or a profile URL. Default platform
is **Instagram**; if the handle is ambiguous or the user names another platform
(TikTok, YouTube Shorts), follow that instead. If no handle was provided at
all, ask for one — that's the only blocking question this skill should ask.

## Workflow

### Phase 1 — Watch the actual content (browser)

Use the Claude-in-Chrome browser tools (load them via ToolSearch in ONE call:
`select:mcp__claude-in-chrome__tabs_context_mcp,mcp__claude-in-chrome__navigate,mcp__claude-in-chrome__computer,mcp__claude-in-chrome__read_page,mcp__claude-in-chrome__tabs_create_mcp,mcp__claude-in-chrome__get_page_text`).

1. Call `tabs_context_mcp` first, then open the profile in a **new tab**:
   `https://www.instagram.com/<handle>/reels/`.
2. If Instagram blocks viewing (login wall), tell the user to log in in that
   tab, or fall back to Phase 2 web research plus any mirrors of the content
   (YouTube channel, TikTok) that are publicly viewable.
3. Review the profile: follower count, posting frequency, dominant formats
   (talking head, POV, b-roll voiceover, vlog, tutorial).
4. Open **at least 5 recent videos** one by one. For each, take screenshots at
   several timestamps (hook, mid, end) and record observations against the
   Analysis Checklist below. Screenshots are the ground truth for caption
   styling — read font, color, placement, and animation off them directly.

### Phase 2 — Research the production (web)

Use WebSearch/WebFetch for what can't be seen on screen:

- `"<creator name>" camera setup / gear / how he films`
- `"<creator name>" editor OR "who edits" OR CapCut OR Premiere`
- Interviews, podcast appearances, "how I make my videos" content,
  gear-breakdown videos by third parties, Reddit/Twitter threads.
- The creator's other platforms (YouTube often shows the setup in-frame).

Label every claim from this phase as **observed**, **reported** (someone said
it), or **inferred** (educated guess from visual evidence). Never present an
inference as fact.

### Phase 3 — Analysis Checklist

Work through every item. This is the heart of the skill — be exhaustive here.

**Editing (most important):**
- Caption style: font (or closest match), size, weight, case, color(s),
  stroke/shadow, background box, screen position, safe margins.
- Caption sequencing: word-by-word pop-in, phrase chunks, or full lines? How
  many words on screen at once? Does the current word get highlighted
  (color change, scale bump)? Do emphasis words get a different color/emoji?
- Caption-to-speech sync: are captions locked exactly to the spoken word
  (karaoke-style timing) or loosely phrase-timed? Any deliberate lead/lag?
- Cut cadence: average seconds between cuts; jump cuts on every breath vs.
  longer takes; are silences/filler words removed?
- Punch-ins/zooms: digital zoom on emphasis? How much (~110%? ~130%)? Snap or
  eased? On which beats?
- B-roll and overlays: stock footage, memes, screenshots, product shots — how
  often, how long, how triggered by the script?
- Sound design: background music (genre, volume relative to voice), SFX
  (whooshes, pops, dings) and what triggers them, silence used for emphasis.
- Hook construction: first 1–3 seconds — what's on screen, what's said, is
  there a visual pattern-interrupt, is the hook text different from the rest
  of the captions?
- Transitions, color grade/LUT feel, aspect ratio and framing (headroom,
  rule-of-thirds, distance from lens), end-of-video CTA pattern.
- Likely editing tool (CapCut template look? Premiere/AE motion graphics?)
  and whether the style is replicable with automated tools vs. needs manual
  motion-graphics work.

**Filming setup (secondary):**
- Camera (phone vs. mirrorless — judge from depth of field, sharpness),
  lens feel (wide vs. tight), stabilization.
- Microphone: lav visible? Shotgun? Podcast mic in frame? How is voice EQ'd —
  and note how the creator positions/addresses the mic while talking.
- Lighting: key light direction, softness, background lighting, time of day.
- Location/backdrop and how it's dressed.

**Content/captions (the written kind):**
- Post caption structure (hook line, body, CTA, hashtags), where the caption
  text likely comes from (script excerpt, AI, ghostwriter patterns),
  on-screen title cards vs. spoken content.

### Phase 4 — Deliverables

Write everything to `social-specs/<handle>/` **in the current working
directory** (create it). Four files:

1. **`RESEARCH.md`** — the full deep-research dump: per-video observations,
   every checklist item, sources for reported claims, screenshots referenced
   by timestamp.
2. **`SUMMARY.md`** — one page. The creator's formula in plain language: the
   5–10 things that actually make their videos look/feel the way they do,
   ranked by impact.
3. **`IMPLEMENTATION.md`** — tailored to the user's situation (they film
   fitness content on an iPhone; check the current project folder for actual
   footage to reference). Concretely: what to change in filming, what setup
   (if any) to buy to reach this quality bar — cheapest option first — and
   what the editing workflow should be. Honest about which parts of the style
   are automatable and which need manual editing.
4. **`EDIT_SPEC.md`** — the handoff artifact for `/social-edit` and for
   `vidbridge style import`. It opens with a **machine values** block, then the
   prose sections.

   The block is the contract: prose is for a human, the block is what tooling
   reads, and a spec without one imports almost nothing. Write `null` for
   anything you did not observe — never a plausible guess. A `null` becomes a
   documented default downstream; an invented number becomes a silent lie.
   Everything the block cannot express — what triggers a cutaway, how the hook
   is built, sound design, the manual-work list — goes in the prose below it.

   ````markdown
   # Edit Spec: <handle> style
   Source: social-research on <date>

   ## Machine values

   ```yaml
   captions_enabled: true      # false if the creator burns no captions at all
   caption_font: Montserrat    # family only, no weight
   caption_style: ExtraBold    # weight/style
   caption_size_pct: 4.5       # % of FRAME HEIGHT
   caption_y_pct: 62           # % from the TOP of the frame
   words_per_line: 3
   fill: "#FFFFFF"
   highlight: "#FFE600"        # current-word colour, null if no karaoke
   outline: "#000000"
   outline_px: 6
   pop_in_ms: 120              # null if captions do not animate
   pop_overshoot_pct: 8        # 100->108 => 8; 0 for a plain fade/appear
   loudness_lufs: -14
   zoom_pct: 112               # 100 if the creator never punches in
   look: neutral
   broll:                      # null if they use no cutaways
     interval_s: 4.5
     duration_s: 2.0
     motion: kenburns_in
   ```

   ## Target output
   - Aspect ratio, resolution, fps, max duration

   ## Cuts
   - Silence removal threshold and padding (e.g. cut gaps > 0.4s, keep 0.1s pad)
   - Filler-word removal: yes/no

   ## Captions
   - Timing mode: word-by-word | phrase (N words)
   - Case: UPPER | Sentence
   - Anything the machine block cannot carry: emphasis-word rules, per-language
     font fallbacks, position changes between modes

   ## Zooms
   - Trigger for the punch-in (every sentence start / emphasis words), snap or eased

   ## B-roll and overlays
   - What triggers a cutaway, and what it cuts to

   ## Audio
   - Music yes/no + volume ratio, SFX rules, silence used for emphasis

   ## Hook treatment
   - Special treatment for the first N seconds

   ## Not automatable (flag for manual work)
   - <list anything requiring After Effects / manual b-roll>
   ````

   Fill in real values from the research. Where you could not determine a
   value, put `null` in the block and say so in the prose — do not invent one.

### Phase 5 — Library index (multi-creator matching)

After writing the four files, create or update `social-specs/LIBRARY.md` —
the cross-creator index that `/social-edit` uses to auto-pick a spec when
several exist. One section per creator, overwriting that creator's previous
entry if re-run:

```markdown
## @<handle> (researched <date>)
- Content type: <niche — e.g. ecom/business, fitness, comedy>
- Formats: <e.g. letterbox talking head; VO documentary; full-vertical POV>
- Best fit for footage that is: <e.g. VO-driven story arcs; raw action
  clips; single-take speech>
- Poor fit for: <e.g. no-speech montages; multi-angle sports>
- Signature markers: <3–5 bullets max — text systems, pacing, canvas>
- Spec: social-specs/<handle>/EDIT_SPEC.md
```

Be blunt in "Best fit / Poor fit" — this is what the matcher weighs, so an
honest "poor fit for X" is worth more than praise.

### Phase 6 — Handoff

End your final message with: the summary highlights, the path to
`social-specs/<handle>/`, how this creator compares to others already in
LIBRARY.md (if any), and the exact next command:
`/social-edit <path-to-video-folder> --spec social-specs/<handle>/EDIT_SPEC.md`
(note the `--spec` flag is optional once LIBRARY.md has 2+ creators —
/social-edit will match automatically).

## Rules

- Watch real videos before writing anything. No generic "creators like this
  usually…" filler — every claim in RESEARCH.md ties to an observed video,
  a cited source, or is explicitly marked as inference.
- If browser access fails entirely after 2–3 attempts, say so and deliver a
  reduced report from web research only, clearly labeled as such.
- Don't ask the user questions mid-research; make judgment calls and note them.
