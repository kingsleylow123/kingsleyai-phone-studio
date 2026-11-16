# KingsleyAI Phone Studio

Make Reels, TikToks and Shorts by texting Claude from your phone. Claude writes the video, renders
the MP4, and sends it back to you in the chat.

## What you need

- A Claude Pro or Max plan (Claude Code on the web is included).
- A GitHub account.
- The Claude app on your phone.

## Set up (one time, about 5 minutes)

1. **Copy this repo to your GitHub.** On this page tap **Use this template → Create a new repository**.
   Give it any name. Pick **Private** if your videos or footage are personal.
2. **Connect GitHub to Claude.** Go to claude.ai/code, sign in, and connect your GitHub account when asked.
   Allow it to see the repo you just made.
3. **Make a cloud environment.** In claude.ai/code, open the environment menu → **Add environment**.
   - Name: `video`
   - Network access: **Trusted** (the default). If you want Claude to transcribe your talking videos for
     captions, choose **Custom** and add `huggingface.co` on top of the trusted list.
   - Leave the rest as is and save.
4. **Test it.** In the Claude app on your phone: **Code** → pick your repo and the `video` environment →
   send: `Render the example reel and send it to me.`
   The first session takes a few extra minutes while it installs FFmpeg and Chromium.

## Make a video

Start a new Code session in your repo and send something like:

> Make a 10 s Reel: hook "Stop guessing your prices." then 3 punchy lines and a CTA "DM me PRICE".
> Black background, yellow accent, hit sound on each line. Export it and send it to me.

On your first video Claude asks 4 quick questions (your handle, colours, language, topic) and saves them
to `brand.md`, so every video after that matches.

**Editing your own footage:** upload the clip to Google Drive, set sharing to "Anyone with the link",
and paste the link: `Cut the pauses out of this, add captions and a follow card at the end: <link>`.

## Getting the video onto your phone

Claude sends the MP4 in the chat: tap it → Share → Save Video.
It is also pushed to the `exports/` folder: open the repo on GitHub → `exports` → tap the video → Download.

## What's inside

| Part | What it does |
|---|---|
| `CLAUDE.md` | The studio rules Claude follows on every video |
| `.claude/skills/` | Official HyperFrames skills: motion graphics, captions, sound, colour, transcription |
| `tools/render.js` | Turns a video project into an MP4 (Chromium + FFmpeg) |
| `tools/setup.sh` | Installs FFmpeg and Chromium automatically when a session starts |
| `kit/` | 23 sound effects, fonts, and the GSAP animation library |
| `projects/example-reel/` | A 6-second starter reel to copy |

## Credits

- [HyperFrames](https://github.com/heygen-com/hyperframes) by HeyGen: the video framework and skills.
- [GSAP](https://gsap.com): animation library (free standard licence).
- Sound effects from [Pixabay](https://pixabay.com/sound-effects/) under the Pixabay Content License.
- Fonts: Inter, JetBrains Mono, Newsreader (SIL Open Font License).
