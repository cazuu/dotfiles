#!/usr/bin/env python3
"""Claude Code <-> Slack ブリッジ。

- notify-slack.sh (Claude Code の Notification hook) から 127.0.0.1:8355 で
  JSON を受け取り、Slack チャンネルへ通知を投稿する
- 通知メッセージのボタン (許可/拒否) やスレッド返信を受け取り、
  `tmux send-keys` で該当ペインの Claude Code へ入力を返す
- Slack とは Socket Mode で接続するため、ポート公開や ngrok は不要

必要な環境変数 (~/.config/claude-slack-bridge/env でも可):
    SLACK_BOT_TOKEN   xoxb- で始まる Bot User OAuth Token
    SLACK_APP_TOKEN   xapp- で始まる App-Level Token (connections:write)
    SLACK_CHANNEL_ID  通知先チャンネル ID (例: C0123456789)
"""

import json
import logging
import os
import subprocess
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

from slack_bolt import App
from slack_bolt.adapter.socket_mode import SocketModeHandler

CONFIG_DIR = Path.home() / ".config" / "claude-slack-bridge"
ENV_FILE = CONFIG_DIR / "env"
STATE_FILE = CONFIG_DIR / "state.json"
LISTEN_PORT = int(os.environ.get("CLAUDE_BRIDGE_PORT", "8355"))
STATE_MAX_ENTRIES = 200

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("claude-slack-bridge")


def load_env_file() -> None:
    if not ENV_FILE.exists():
        return
    for line in ENV_FILE.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        os.environ.setdefault(key.strip(), value.strip().strip('"'))


load_env_file()

BOT_TOKEN = os.environ["SLACK_BOT_TOKEN"]
APP_TOKEN = os.environ["SLACK_APP_TOKEN"]
CHANNEL = os.environ["SLACK_CHANNEL_ID"]

app = App(token=BOT_TOKEN)

# thread_ts -> {"pane": str, "kind": "permission" | "idle" | "stop"}
threads: dict[str, dict] = {}
lock = threading.Lock()


def load_state() -> None:
    if STATE_FILE.exists():
        try:
            threads.update(json.loads(STATE_FILE.read_text()))
        except (json.JSONDecodeError, OSError):
            pass


def save_state() -> None:
    entries = dict(sorted(threads.items())[-STATE_MAX_ENTRIES:])
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(json.dumps(entries))


def tmux(*args: str) -> subprocess.CompletedProcess:
    return subprocess.run(["tmux", *args], capture_output=True, text=True)


def pane_exists(pane: str) -> bool:
    return bool(pane) and tmux("display-message", "-p", "-t", pane, "ok").returncode == 0


def pane_label(pane: str) -> str:
    result = tmux(
        "display-message", "-p", "-t", pane,
        "#{session_name}:#{window_index}.#{pane_index}",
    )
    return result.stdout.strip() if result.returncode == 0 else pane


def send_key(pane: str, key: str) -> None:
    tmux("send-keys", "-t", pane, key)


def send_text(pane: str, text: str) -> None:
    tmux("send-keys", "-t", pane, "-l", "--", text)
    time.sleep(0.2)
    send_key(pane, "Enter")


def classify(payload: dict) -> str:
    if payload.get("hook_event_name") == "Stop":
        return "stop"
    message = (payload.get("message") or "").lower()
    return "permission" if "permission" in message else "idle"


def post_notification(payload: dict) -> None:
    pane = payload.get("pane") or ""
    kind = classify(payload)
    label = pane_label(pane) if pane else "(tmux外)"
    cwd = payload.get("cwd") or ""

    if kind == "stop":
        headline = f":white_check_mark: *応答が完了しました* `{label}`"
    elif kind == "permission":
        headline = f":closed_lock_with_key: *承認待ち* `{label}`"
    else:
        headline = f":hourglass_flowing_sand: *入力待ち* `{label}`"

    lines = [headline]
    if cwd:
        lines.append(f":file_folder: `{cwd}`")
    if payload.get("message"):
        lines.append(f"> {payload['message']}")
    text = "\n".join(lines)

    blocks = [{"type": "section", "text": {"type": "mrkdwn", "text": text}}]
    if pane and kind == "permission":
        blocks.append({
            "type": "actions",
            "elements": [
                {
                    "type": "button",
                    "action_id": "approve",
                    "text": {"type": "plain_text", "text": "✅ 許可"},
                    "style": "primary",
                    "value": pane,
                },
                {
                    "type": "button",
                    "action_id": "deny",
                    "text": {"type": "plain_text", "text": "⛔ 拒否 (Esc)"},
                    "style": "danger",
                    "value": pane,
                },
            ],
        })
    if pane and kind != "stop":
        blocks.append({
            "type": "context",
            "elements": [{
                "type": "mrkdwn",
                "text": "このスレッドに返信すると、そのまま Claude Code への入力として送信されます",
            }],
        })

    response = app.client.chat_postMessage(channel=CHANNEL, text=text, blocks=blocks)
    if pane and kind != "stop":
        with lock:
            threads[response["ts"]] = {"pane": pane, "kind": kind}
            save_state()


class NotifyHandler(BaseHTTPRequestHandler):
    def do_POST(self):  # noqa: N802
        if self.path != "/notify":
            self.send_response(404)
            self.end_headers()
            return
        length = int(self.headers.get("Content-Length", 0))
        try:
            payload = json.loads(self.rfile.read(length))
            post_notification(payload)
            self.send_response(204)
        except Exception:
            log.exception("failed to handle notification")
            self.send_response(500)
        self.end_headers()

    def log_message(self, fmt, *args):
        log.debug(fmt, *args)


def resolve_action(body: dict) -> tuple[str, str, str]:
    pane = body["actions"][0]["value"]
    channel = body["container"]["channel_id"]
    ts = body["container"]["message_ts"]
    return pane, channel, ts


def finalize_message(channel: str, ts: str, suffix: str) -> None:
    """ボタンを取り除き、結果を末尾に追記してメッセージを更新する。"""
    original = app.client.conversations_history(
        channel=channel, latest=ts, inclusive=True, limit=1
    )["messages"][0]
    blocks = [b for b in original.get("blocks", []) if b.get("type") == "section"]
    blocks.append({
        "type": "context",
        "elements": [{"type": "mrkdwn", "text": suffix}],
    })
    app.client.chat_update(channel=channel, ts=ts, text=suffix, blocks=blocks)


@app.action("approve")
def on_approve(ack, body):
    ack()
    pane, channel, ts = resolve_action(body)
    if not pane_exists(pane):
        finalize_message(channel, ts, ":warning: ペインが見つかりませんでした")
        return
    send_key(pane, "1")
    finalize_message(channel, ts, ":white_check_mark: 許可しました")


@app.action("deny")
def on_deny(ack, body):
    ack()
    pane, channel, ts = resolve_action(body)
    if not pane_exists(pane):
        finalize_message(channel, ts, ":warning: ペインが見つかりませんでした")
        return
    send_key(pane, "Escape")
    with lock:
        if ts in threads:
            threads[ts]["kind"] = "idle"
            save_state()
    finalize_message(
        channel, ts,
        ":no_entry: 拒否しました (Esc 送信)。スレッド返信で指示を送れます",
    )


@app.event("message")
def on_message(event):
    if event.get("bot_id") or event.get("subtype"):
        return
    thread_ts = event.get("thread_ts")
    if not thread_ts:
        return
    with lock:
        info = threads.get(thread_ts)
    if not info or not info.get("pane"):
        return

    pane = info["pane"]
    text = (event.get("text") or "").strip()
    if not text:
        return
    if not pane_exists(pane):
        app.client.chat_postMessage(
            channel=event["channel"], thread_ts=thread_ts,
            text=":warning: ペインが見つかりませんでした",
        )
        return

    # 承認ダイアログが開いたままだと文字入力が届かないので先に閉じる
    if info["kind"] == "permission":
        send_key(pane, "Escape")
        time.sleep(0.3)
        with lock:
            threads[thread_ts]["kind"] = "idle"
            save_state()

    send_text(pane, text)
    app.client.reactions_add(
        channel=event["channel"], name="white_check_mark", timestamp=event["ts"]
    )


def main() -> None:
    load_state()
    server = ThreadingHTTPServer(("127.0.0.1", LISTEN_PORT), NotifyHandler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    log.info("notification endpoint: http://127.0.0.1:%d/notify", LISTEN_PORT)
    SocketModeHandler(app, APP_TOKEN).start()


if __name__ == "__main__":
    main()
