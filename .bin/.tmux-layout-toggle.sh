#!/usr/bin/env bash
# Toggle between multi-window (laptop) and split-pane (desktop) layouts.
#   - 複数ウィンドウがあれば → カレントウィンドウへ全部 join-pane してペイン分割
#   - 1ウィンドウ複数ペインなら → 各ペインを別ウィンドウへ break-pane
set -euo pipefail

current_window=$(tmux display-message -p '#{window_id}')
window_count=$(tmux display-message -p '#{session_windows}')
pane_count=$(tmux display-message -p '#{window_panes}')

if [ "$window_count" -gt 1 ]; then
    for w in $(tmux list-windows -F '#{window_id}' | grep -v "^${current_window}$"); do
        tmux join-pane -h -s "$w"
    done
    tmux select-layout -t "$current_window" even-horizontal
    tmux display-message "merged into 1 window"
elif [ "$pane_count" -gt 1 ]; then
    for p in $(tmux list-panes -t "$current_window" -F '#{pane_id}' | tail -n +2); do
        tmux break-pane -d -s "$p"
    done
    tmux display-message "split into separate windows"
else
    tmux display-message "nothing to toggle"
fi
