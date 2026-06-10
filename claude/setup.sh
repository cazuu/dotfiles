#!/usr/bin/env bash
# Claude Code <-> Slack ブリッジのセットアップ。
#   ./setup.sh            venv 作成 + 依存インストール + 設定ファイル雛形作成
#   ./setup.sh --launchd  上記に加えて launchd で常駐させる
set -euo pipefail

DATA_DIR="$HOME/.local/share/claude-slack-bridge"
VENV="$DATA_DIR/venv"
CONF_DIR="$HOME/.config/claude-slack-bridge"
BRIDGE="$HOME/dotfiles/claude/slack_bridge.py"
PLIST="$HOME/Library/LaunchAgents/com.cazuu.claude-slack-bridge.plist"

echo "==> venv を作成して slack-bolt をインストール"
mkdir -p "$DATA_DIR"
python3 -m venv "$VENV"
"$VENV/bin/pip" -q install --upgrade pip slack-bolt

echo "==> 設定ファイルを準備: $CONF_DIR/env"
mkdir -p "$CONF_DIR"
if [ ! -f "$CONF_DIR/env" ]; then
    cat > "$CONF_DIR/env" <<'EOF'
# Slack アプリの認証情報 (claude/README.md 参照)
SLACK_BOT_TOKEN=xoxb-...
SLACK_APP_TOKEN=xapp-...
SLACK_CHANNEL_ID=C0XXXXXXXXX
EOF
    chmod 600 "$CONF_DIR/env"
    echo "    -> トークンを記入してください"
else
    echo "    -> 既存の env をそのまま使用"
fi

if [ "${1:-}" = "--launchd" ]; then
    echo "==> launchd エージェントを登録: $PLIST"
    mkdir -p "$(dirname "$PLIST")"
    cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.cazuu.claude-slack-bridge</string>
    <key>ProgramArguments</key>
    <array>
        <string>$VENV/bin/python</string>
        <string>$BRIDGE</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$DATA_DIR/bridge.log</string>
    <key>StandardErrorPath</key>
    <string>$DATA_DIR/bridge.log</string>
</dict>
</plist>
EOF
    launchctl unload "$PLIST" 2>/dev/null || true
    launchctl load "$PLIST"
    echo "    -> ログ: $DATA_DIR/bridge.log"
else
    echo "==> 手動起動する場合: mise run claude:bridge (または tmux ペインで)"
    echo "    $VENV/bin/python $BRIDGE"
fi

echo "==> 仕上げに ~/.claude/settings.json へ hooks を追加してください"
echo "    (claude/settings.example.json 参照)"
