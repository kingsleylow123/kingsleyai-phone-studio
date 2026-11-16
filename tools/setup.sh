#!/usr/bin/env bash
# Makes sure the two things the renderer needs are present: FFmpeg and Playwright Chromium.
# Runs automatically at the start of every Claude Code session (see .claude/settings.json).
# Safe to run again: it skips anything already installed.
cd "$(dirname "$0")/.." || exit 0
log() { echo "[studio setup] $*"; }

if ! command -v ffmpeg >/dev/null 2>&1; then
  log "installing ffmpeg"
  if command -v apt-get >/dev/null 2>&1; then
    (sudo -n true 2>/dev/null && SUDO=sudo) ; $SUDO apt-get update -qq >/dev/null 2>&1; $SUDO apt-get install -y -qq ffmpeg >/dev/null 2>&1
  elif command -v brew >/dev/null 2>&1; then
    brew install ffmpeg >/dev/null 2>&1
  fi
  command -v ffmpeg >/dev/null 2>&1 && log "ffmpeg ready" || log "WARNING: could not install ffmpeg"
fi

can_launch() { node -e "require('playwright').chromium.launch().then(b=>b.close()).catch(()=>process.exit(1))" >/dev/null 2>&1; }
if ! can_launch; then
  [ -d node_modules/playwright ] || { log "installing playwright"; npm install --silent --no-audit --no-fund >/dev/null 2>&1; }
  if ! can_launch; then
    log "downloading Chromium for playwright"
    npx --yes playwright install --with-deps chromium >/dev/null 2>&1 || npx --yes playwright install chromium >/dev/null 2>&1
  fi
  can_launch && log "playwright ready" || log "WARNING: playwright Chromium will not start"
fi
exit 0
