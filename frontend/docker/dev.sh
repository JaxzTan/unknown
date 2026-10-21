#!/bin/sh
# Runs `flutter run` for web and presses "r" (hot reload) whenever lib/ changes.
# `docker compose watch` syncs edits into lib/, this script picks them up.
set -e

FIFO=/tmp/flutter_stdin
STAMP=/tmp/last_reload
rm -f "$FIFO" && mkfifo "$FIFO"
exec 3<>"$FIFO" # keep the pipe open so flutter never sees EOF

flutter run -d web-server \
  --web-hostname 0.0.0.0 --web-port 8080 \
  --dart-define=API_URL="${API_URL:-http://localhost:3000}" <"$FIFO" &
PID=$!

touch "$STAMP"
while kill -0 "$PID" 2>/dev/null; do
  sleep 1
  if [ -n "$(find lib -newer "$STAMP" -type f 2>/dev/null | head -n 1)" ]; then
    touch "$STAMP"
    echo "[dev.sh] change detected, hot reloading"
    printf 'r' >&3
  fi
done
