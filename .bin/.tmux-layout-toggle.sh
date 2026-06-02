#!/usr/bin/env bash
# Toggle between multi-window (laptop) and split-pane (desktop) layouts.
#   - 複数ウィンドウがあれば → カレントウィンドウへ全ペインを join-pane
#   - 1ウィンドウ複数ペインなら → アクティブ以外を別ウィンドウへ break-pane
set -euo pipefail

current_window=$(tmux display-message -p '#{window_id}')
current_pane=$(tmux display-message -p '#{pane_id}')
window_count=$(tmux display-message -p '#{session_windows}')
pane_count=$(tmux display-message -p '#{window_panes}')

if [ "$window_count" -gt 1 ]; then
    for p in $(tmux list-panes -s -F '#{window_id} #{pane_id}' \
               | awk -v cur="$current_window" '$1 != cur { print $2 }'); do
        tmux join-pane -h -s "$p" -t "$current_window"
    done
    tmux select-layout -t "$current_window" even-horizontal
    tmux display-message "merged into 1 window"
elif [ "$pane_count" -gt 1 ]; then
    for p in $(tmux list-panes -t "$current_window" -F '#{pane_id}' \
               | grep -v "^${current_pane}$"); do
        tmux break-pane -d -s "$p"
    done
    tmux display-message "split into separate windows"
else
    tmux display-message "nothing to toggle"
fi
