#!/bin/bash

SESSION="$1"

tmux new-session -d -s "$SESSION"
tmux send-keys -t "$SESSION":0 "nvim" C-m
tmux split-window -h -t "$SESSION":0
tmux attach -t "$SESSION"
