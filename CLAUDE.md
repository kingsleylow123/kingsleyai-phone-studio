# Reels studio (Claude Code in the cloud, driven from a phone)

This repository is a video studio. The owner prompts from the Claude app on a phone. Claude Code
builds each video as a HyperFrames project (HTML + GSAP), renders it to MP4, and pushes it so the
owner can save it from GitHub. Each cloud session starts on a fresh machine: anything not committed
and pushed is lost.

`tools/setup.sh` runs at session start (hook in `.claude/settings.json`) and installs FFmpeg and
Playwright Chromium if they are missing. If a render fails with "ffmpeg not found" or a Playwright
launch error, run `bash tools/setup.sh` and try again.

## First session: brand profile

If `brand.md` does not exist, before the first video ask the owner 4 short questions in one message:
name or handle for the end card, brand colours (or "pick for me"), language, and what the videos are
about. Save the answers to `brand.md`, commit it, and use it for every video after that.

## RENDER RULE: never run `npx hyperframes render` / `npm run render` with HyperFrames here

In the cloud container `hyperframes render` can take the whole session down (the container restarts
mid-render). Render with the backup renderer instead. It uses Playwright Chromium and FFmpeg, renders
the same index.html, and mixes the `<audio>` tags:

```bash
node tools/render.js projects/<name> exports/<name>.mp4                 # final
node tools/render.js projects/<name> exports/<name>-draft.mp4 --draft   # quick draft
node tools/render.js projects/<name> /tmp/x.mp4 --stills 1.5,4,8        # PNG stills only
node tools/render.js projects/<name> /tmp/x.mp4 --from 30 --to 40       # partial render
```

`npx hyperframes check` is safe and still required. This rule overrides any skill, template or
project instruction that says to run `hyperframes render`.

## Workflow for every video

1. `cd projects && npx --yes hyperframes@0.8.116 init <name> --non-interactive --resolution portrait`
   (or copy `projects/example-reel/` as a starting point).
2. Copy GSAP into the project: `mkdir -p projects/<name>/vendor && cp kit/vendor/gsap.min.js projects/<name>/vendor/`
   and load it with `<script src="vendor/gsap.min.js"></script>`. Never load GSAP or fonts from a CDN:
   the render browser may not reach CDNs. Paths must be project-relative (no `../`), so copy any kit
   sounds/fonts into the project folder (`sfx/`, `fonts/`).
3. Write `index.html`. Register the timeline with
   `window.__timelines = window.__timelines || {}; window.__timelines["main"] = tl;`
   Audio: `<audio id="..." src="sfx/x.wav" data-start="1.2" data-volume="0.6"></audio>`.
4. `cd projects/<name> && npx --yes hyperframes@0.8.116 check` and fix every error.
5. Render a draft, pull 3-4 stills and look at them before the final render. Fix clipped text or text
   in the unsafe zones.
6. Final render into `exports/<name>.mp4`, commit, push. Then send the MP4 to the owner with SendUserFile.

## Talking-head edits (footage from the owner)

- Footage usually comes as a Google Drive link (shared as "Anyone with the link"): download with
  `curl -L "https://drive.usercontent.google.com/download?id=<FILE_ID>&export=download&confirm=t" -o talking.mov`.
- Phone selfie footage is often mirrored: if text on clothing or signs reads backwards, flip it with `ffmpeg -vf hflip`.
- Tighten: `silencedetect=noise=-32dB:d=0.22`, keep speech +/-0.09 s, concat with 12 ms audio fades, `loudnorm=I=-14`.
- Transcribe the TIGHTENED audio (whisper drifts across long pauses):
  `npx hyperframes transcribe voice16.wav -m small.en --json`. If the model is missing, download it with curl:
  `curl -L -o ~/.cache/hyperframes/whisper/models/ggml-small.en.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin`
  (needs huggingface.co allowed in the environment's network settings).
- Put the face video in the composition as `<video id="face" muted data-start="0" data-duration="..">` plus a separate
  `<audio>` for the voice. `tools/render.js` seeks videos frame by frame.
- Keep raw footage in `projects/<name>/media/` (git-ignored). Commit only the build files and the export.
- A layout that works well: graphic panel on the top ~700 px, face below, a 2-3 word caption pill on the
  split line, follow card at the end.

## Sound design

- `kit/sfx/sx-*.wav`: 21 effects (Pixabay Content License, see `kit/sfx/CREDITS-pixabay.md`), peak-normalised
  to -1 dBFS, with pitched variants (`pop`, `pop-2..4` rise in pitch; `click-hi`; `whoosh-soft`). Copy into the project's `sfx/`.
- Keep every cue in ONE list: whoosh on each cut, pop on each element in (rising pitch for 1-2-3 sequences),
  typing/key-press under typed text, notification for messages, impact-bass on the hook and big reveals
  (start `impact-bass-2` 0.36 s early so its peak lands on the hit), sparkle on "done" moments.
- Mark the voice `<audio data-role="voice">`; `tools/render.js` ducks the SFX bus under it (2:1), trims each cue to
  its `data-duration` with a fade, and limits the master.

## Format defaults (Reels / TikTok / Shorts)

- 1080x1920, 30 fps, 6-15 s unless told otherwise. Keep exports under ~20 MB for mobile data.
- Safe zone for text: x 60-940, y 250-1440 (app buttons and captions cover the rest).
- Hook in the first 0.5 s. Hold key text at least 1.5 s so it can be read.
- Language, colours and handle come from `brand.md`.

## Reporting (the owner reads on a phone)

Keep reports short. Always name the export path and say whether it was pushed.

## Layout

- `kit/` shared assets: `vendor/gsap.min.js`, `sfx/` sounds, `fonts/` (Inter, JetBrains Mono, Newsreader; OFL).
- `projects/<name>/` one folder per video (renders/, snapshots/ and media/ are git-ignored).
- `exports/` finished MP4s, committed so they can be downloaded on the phone.
- `tools/render.js` the backup renderer; `tools/setup.sh` installs its dependencies.
- `.claude/skills/` official HyperFrames skills (`hyperframes`, `hyperframes-cli`, `hyperframes-registry`, `media-use`, ...).
