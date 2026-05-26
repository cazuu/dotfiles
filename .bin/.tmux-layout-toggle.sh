#!/usr/bin/env bash
# Toggle between multi-window (laptop) and split-pane (desktop) layouts.
#   - 複数ウィンドウがあれば → カレントウィンドウへ全部 join-pane してペイン分割
#   - 1ウィンドウ複数ペインなら → 各ペインを別ウィンドウへ break-pane
set -euo pipefail

session=$(tmux display-message -p '#S')
current_window_id=$(tmux display-message -p '#{window_id}')
current_window=$(tmux display-message -p '#I')
window_count=$(tmux list-windows -t "$session" | wc -l | tr -d ' ')
pane_count=$(tmux list-panes -t "$session:$current_window" | wc -l | tr -d ' ')

if [ "$window_count" -gt 1 ]; then
    for w in $(tmux list-windows -t "$session" -F '#{window_id}' \
               | grep -v "^${current_window_id}$"); do
        tmux join-pane -h -s "$w"
    done
    tmux select-layout -t "$session:$current_window" even-horizontal
    tmux display-message "merged: #{window_panes} panes in 1 window"
elif [ "$pane_count" -gt 1 ]; then
    while [ "$(tmux list-panes -t "$session:$current_window" | wc -l | tr -d ' ')" -gt 1 ]; do
        last_pane=$(tmux list-panes -t "$session:$current_window" -F '#{pane_id}' | tail -n 1)
        tmux break-pane -d -s "$last_pane"
    done
    tmux display-message "split: panes broken into separate windows"
else
    tmux display-message "nothing to toggle (1 window, 1 pane)"
fi
