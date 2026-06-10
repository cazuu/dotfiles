# Claude Code ↔ Slack ブリッジ

tmux 上で動かしている Claude Code が **承認待ち / 入力待ち** になったら Slack に通知し、
Slack 上のボタンやスレッド返信を `tmux send-keys` で Claude Code に返す仕組み。

```
Claude Code (tmux pane)
  │ Notification hook (承認待ち・60秒入力待ちで発火)
  ▼
notify-slack.sh ── HTTP ──▶ slack_bridge.py ── Socket Mode ──▶ Slack
                              │    ▲                            │
                              │    └── ボタン押下 / スレッド返信 ◀┘
                              ▼
                        tmux send-keys -t <pane>
```

- Slack とは **Socket Mode** で接続するため、ポート公開や ngrok は不要
- 通知には tmux のペイン ID (`$TMUX_PANE`) を含めるので、複数ペインで
  Claude Code を並行起動していても正しいペインに応答が返る

## Slack でできること

| 操作 | 動作 |
|---|---|
| ✅ 許可 ボタン | 該当ペインに `1` を送信(ダイアログの Yes) |
| ⛔ 拒否 ボタン | `Esc` を送信してダイアログを閉じる |
| スレッドに返信 | 返信テキスト + Enter をそのまま入力として送信(承認ダイアログが開いていれば先に Esc で閉じる) |

## セットアップ

### 1. Slack アプリを作成

1. https://api.slack.com/apps → **Create New App** → **From a manifest**
2. `slack-app-manifest.json` の内容を貼り付けて作成
3. **Basic Information → App-Level Tokens** で `connections:write` スコープの
   トークンを生成 → `xapp-...` を控える
4. **Install App** でワークスペースにインストール → `xoxb-...` を控える
5. 通知用チャンネルを作り、アプリを `/invite` してチャンネル ID を控える

### 2. ブリッジをインストール

```sh
cd ~/dotfiles/claude
./setup.sh            # 手動起動派
./setup.sh --launchd  # Mac mini で常駐させるならこちら
```

`~/.config/claude-slack-bridge/env` にトークンを記入:

```
SLACK_BOT_TOKEN=xoxb-...
SLACK_APP_TOKEN=xapp-...
SLACK_CHANNEL_ID=C0XXXXXXXXX
```

手動起動の場合は `mise run claude:bridge`(別 tmux ペインで動かすと楽)。

### 3. Claude Code に hook を設定

`~/.claude/settings.json` に `settings.example.json` の内容をマージ:

```json
{
  "hooks": {
    "Notification": [
      { "hooks": [{ "type": "command", "command": "$HOME/dotfiles/claude/notify-slack.sh" }] }
    ]
  }
}
```

Notification hook は以下のタイミングで発火する:

- ツール実行の承認待ちになったとき
- プロンプトが 60 秒以上アイドルのとき

応答完了ごとに通知が欲しければ `Stop` hook にも同じコマンドを追加する
(ターンが終わるたびに通知が来るので好みで)。

## 注意点

- ブリッジの HTTP エンドポイントは `127.0.0.1:8355` のみで listen する
  (ポートは `CLAUDE_BRIDGE_PORT` で変更可)
- 「許可」は *その1回のみ許可*(選択肢 1)を送る。「常に許可」は選択肢の並びが
  ダイアログによって異なり誤爆しうるため、あえてボタンにしていない
- Slack からの「許可」は、画面を見ずにツール実行を承認することになる。
  通知メッセージの内容をよく確認してから押すこと
- hook は `jq` と `curl` を使用(どちらも Brewfile に含まれる)
