---
name: social-edit
description: >
  Apply a creator-style edit spec (produced by /social-research) to the user's
  own videos. Only use when the user explicitly invokes /social-edit or asks
  to "edit my videos like <creator>" / "apply the edit spec". Takes a folder
  or list of video files plus an EDIT_SPEC.md, then transcribes, cuts silences,
  burns in styled word-synced captions, applies punch-in zooms and audio
  normalization with ffmpeg + whisper, and outputs finished vertical videos to
  an edited/ folder without touching the originals.
---

# Social Edit

Execute an `EDIT_SPEC.md` from `/social-research` on real footage. The spec is
the contract for STYLING — follow it exactly; don't invent style choices that
aren't in it. There are two pipelines:

- **Transcript mode** (default when the footage has continuous speech/VO):
  the workflow below — transcribe, cut silences, subtitle, render.
- **Story mode** (when the footage is raw action clips — sports, training,
  b-roll — or the user asks for a highlight/narrative edit): the "Story mode"
  section at the end. Story mode decides WHAT to show and in what order;
  the spec still decides how it looks.

## Input

- **Videos:** a folder or explicit file list from the user's arguments. If
  none given, look for video files (`.mov`, `.mp4`) in the current directory
  and confirm the selection with the user before processing (this is the one
  acceptable question — processing is slow and irreversible in time).
- **Spec:** `--spec <path>`, or if omitted, the most recently modified
  `social-specs/*/EDIT_SPEC.md` under the current directory. State which spec
  you picked. If no spec exists anywhere, tell the user to run
  `/social-research @handle` first and stop.

## Setup (run once per session)

```bash
which ffmpeg ffprobe   # required; if missing: brew install ffmpeg
```

Transcription: prefer `mlx-whisper` (fast on Apple Silicon), fall back to
`openai-whisper`. Both run fine via uvx without a permanent install:

```bash
uvx --from mlx-whisper mlx_whisper --help >/dev/null 2>&1 \
  || uvx --from openai-whisper whisper --help >/dev/null 2>&1
```

Use `--word_timestamps True` (openai-whisper) / word-level output
(mlx-whisper `--word-timestamps`) — word timing is required for karaoke
captions.

## Workflow

Process videos **one at a time**, completing and verifying each before the
next. For long videos or many files, run encodes in background Bash and
report progress.

### 1. Inventory

`ffprobe` every input: resolution, fps, duration, rotation metadata, audio
channels. Note anything that conflicts with the spec's target output (e.g.
horizontal footage for a 9:16 spec — center-crop unless the spec says
otherwise, and flag it in the report).

### 2. Transcribe

Extract audio (`ffmpeg -i in.mov -ar 16000 -ac 1 audio.wav`) and transcribe
with word timestamps to JSON. Keep the JSON in the working dir — it drives
both cutting and captions.

### 3. Cut plan (silence + filler removal, if spec says so)

Derive keep-segments from the word timestamps: any gap between consecutive
words longer than the spec's threshold gets trimmed to the spec's padding.
If the spec removes filler words, drop segments whose only content is
um/uh/like (standalone). Build one ffmpeg filter to apply all cuts in a
single pass:

```javascript

select='between(t,a1,b1)+between(t,a2,b2)+...',setpts=N/FRAME_RATE/TB
aselect='...',asetpts=N/SR/TB
```

(For many segments, generate the filter script to a file and use
`-filter_complex_script`.) After cutting, **re-map the word timestamps** into
the new timeline — captions must sync to the cut video, not the original.

### 4. Captions

Generate an **ASS subtitle file** implementing the spec exactly:

- Word-by-word mode: one dialogue event per word (or karaoke `\k` tags per
  phrase with the current word highlighted via inline color override
  `{\c&HBBGGRR&}` — note ASS uses BGR hex).
- Style block from the spec: font, size (convert % of frame height to pt via
  PlayResY), colors, `Outline`, `Shadow`, `Alignment=2`, `MarginV` from the
  spec's y-position.
- Pop-in animation: `{\t(0,80,\fscx100\fscy100)}` from a starting
  `\fscx N\fscy N` per the spec's scale rule.
- Hook treatment: apply the spec's first-N-seconds overrides as a second
  ASS style.
- Font availability: check `fc-list | grep -i "<font>"`; if the exact font
  isn't installed, use the spec's stated fallback or the closest system font
  and record the substitution in the report.

### 5. Zooms

Implement punch-ins per the spec's trigger rule (e.g. alternate 100%/120%
between cut segments, or zoom on emphasis words) using per-segment
`crop` + `scale`, applied in the same filter graph as the cuts. If the spec's
zoom rule can't be expressed in ffmpeg cleanly, do the simple version
(alternating segments) and flag the difference.

### 6. Final render

One encode combining: cuts → zoom → scale/crop to target aspect →
`subtitles=captions.ass` → audio `loudnorm` to the spec's LUFS target →
`libx264 -crf 18 -preset medium`, `aac 192k`, target fps. Output to
`edited/<original-name>_<handle>.mp4`. **Never overwrite or modify
originals.** Intermediate files go in the scratchpad directory.

### 7. Verify + report

For each output: `ffprobe` it, and extract 3 frames (hook, middle, end) with
`ffmpeg -ss ... -frames:v 1` and **Read them** to visually confirm captions
render correctly (position, color, not clipped). Fix and re-render if wrong —
don't ship a video you haven't looked at.

Final message must include:

- Table of outputs (file, duration before → after, size).
- Which spec was applied and any deviations/substitutions made.
- The spec's "not automatable" items as a manual to-do list for the user.

## Story mode (creative editorial intelligence)

For raw action footage (dunks, workouts, runs) with no continuous voiceover.
The job: watch the clips like an editor, then build a narrative cut. Never
assemble blind — every editorial decision must trace to something you SAW in
a frame or HEARD in the audio energy.

### 1. Watch everything first

- Scene-split long recordings into candidate clips (ffmpeg
  `select='gt(scene,0.3)'` timestamps, or split on recording boundaries).
- For each clip, extract frames at 3–6 points including the motion peak
  (find it via audio RMS spikes — rim hits, ball bounces, impacts — with
  `astats`/`ebur128` per window, or frame-difference peaks) and **Read the
  frames**. Classify into `clips.json`:
  - action + outcome: e.g. dunk MADE / MISSED / rim-out / unclear
  - camera angle (baseline, under-rim, side, far, POV) and framing quality
  - energy/mood (golden hour, night, indoor), defects (blur, obstruction)
  - the money-moment timestamp (ball leaves hand → rim contact)
- Outcome calls must be verified on the frames around rim contact. If you
  can't tell made vs missed from the frames, mark `unclear` and exclude it
  from outcome-dependent slots — never guess a climax clip.

### 2. Pick a narrative structure

Choose based on the user's brief, or default by inventory:

- **CLIMAX** (default when there are 3+ misses and ≥1 clean make): attempts
  and misses stacked with rising tempo — each clip shorter than the last
  (e.g. 2.5s → 1.8s → 1.2s → 0.8s) — never showing a successful outcome;
  then a beat of stillness (spec's black-frame word or a 0.5s hold); then
  the best make lands as the climax, held ≥1.5s, followed by one afterglow
  clip (reaction, walk-off).
- **HIGHLIGHTS** (when makes dominate): only successful reps, strongest
  first, alternating camera angles so no two consecutive clips share one.
- **MULTI-ANGLE DRAMA**: the same successful attempt from 2+ angles
  back-to-back — full speed from angle A, then slow-motion replay from
  angle B. With 60fps sources do slow-mo as clean 50% (`setpts=2*PTS`,
  output 30fps); never interpolate 30fps sources beyond 75%.

### 3. Cut decision rules

- Cut IN just before motion starts (\~0.3s pre-action), cut OUT on the action
  peak or its immediate follow-through — not after the energy dies.
- Never reveal the outcome of the climax before the climax (no makes in the
  buildup of a CLIMAX edit, including in the background).
- The money shot gets the longest hold and, if available, the best angle;
  buildup clips get the weaker angles.
- Vary angles between consecutive clips whenever inventory allows.
- Write the final sequence as an EDL (`edl.json`: source file, in/out,
  speed, slot role) before rendering, and include it in the report so the
  user can tweak slots and re-render cheaply.

### 4. Render and verify

- Render per the EDIT\_SPEC styling (canvas mode, text systems, loudnorm).
  Display text/headline content comes from the user's brief or the narrative
  (e.g. attempt count as the amber number).
- Verification is editorial here, not just technical: extract one frame per
  EDL slot from the final render, Read them in order, and confirm the story
  reads correctly (no spoiled climax, angles alternate, slow-mo where
  intended). Fix and re-render if the narrative is broken.
- Report which structure was chosen and why, the clip inventory summary
  (n clips, makes/misses/unclear), and which `unclear` clips were left out.

Story mode is slow by design — visually reviewing dozens of clips takes many
tool calls. Tell the user the clip count and rough expectation before
starting the watch pass, then proceed without further questions.

## Rules

- The spec is authoritative for styling; your taste is not. Deviate only when
  technically forced, and always report the deviation. In Story mode your
  editorial judgment IS the product, but it must follow the structure rules
  above and stay traceable to observed frames.
- Disk space: check `df -h` before batch-processing; warn if outputs may not
  fit.
- If a step fails on one video, finish the others and report the failure —
  don't abort the whole batch.
