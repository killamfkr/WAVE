#!/usr/bin/env bash
# Builds the screenshot web app and captures README PNGs via headless Chrome.
set -euo pipefail
cd "$(dirname "$0")/.."

ROOT="$PWD"
WEB_DIR="$ROOT/build/readme_web"
PORT=8765
export WAVE_SCREENSHOT_PORT="$PORT"

echo "Building screenshot web app..."
flutter build web \
  -t lib/tool/readme_screenshots_app.dart \
  --output "$WEB_DIR" \
  --no-tree-shake-icons

SESSION_NAME="readme-web-server"
if tmux -f /exec-daemon/tmux.portal.conf has-session -t "=$SESSION_NAME" 2>/dev/null; then
  tmux -f /exec-daemon/tmux.portal.conf kill-session -t "$SESSION_NAME"
fi
tmux -f /exec-daemon/tmux.portal.conf new-session -d -s "$SESSION_NAME" -c "$WEB_DIR" -- \
  python3 -m http.server "$PORT"

cleanup() {
  tmux -f /exec-daemon/tmux.portal.conf kill-session -t "$SESSION_NAME" 2>/dev/null || true
}
trap cleanup EXIT

sleep 2

echo "Capturing PNGs with Puppeteer..."
(cd tool && npm install --silent)
node tool/capture_readme_screenshots.mjs

for file in homescreenshot.png djscreenshot.png settingsscreenshot.png playingscreenshot.png; do
  size="$(wc -c < "$ROOT/$file")"
  if [[ "$size" -lt 20000 ]]; then
    echo "ERROR: $file is too small (${size} bytes)" >&2
    exit 1
  fi
  echo "Verified $file (${size} bytes)"
done

echo "Done."
