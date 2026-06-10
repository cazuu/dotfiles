#!/usr/bin/env bash
# Claude Code の Notification/Stop hook から呼ばれ、
# stdin の JSON に tmux ペインIDを付与してローカルの Slack ブリッジへ転送する。
# ブリッジが起動していなくても Claude Code を止めないよう必ず 0 で終了する。
set -u

PORT="${CLAUDE_BRIDGE_PORT:-8355}"

input=$(cat)
pane="${TMUX_PANE:-}"

payload=$(printf '%s' "$input" | jq -c --arg pane "$pane" '. + {pane: $pane}' 2>/dev/null) || exit 0

curl -fsS -m 5 \
    -H 'Content-Type: application/json' \
    -d "$payload" \
    "http://127.0.0.1:${PORT}/notify" >/dev/null 2>&1

exit 0
