#!/usr/bin/env bash

version_pat='s/^tmux[^0-9]*([.0-9]+).*/\1/p'

# Test if vim open in pane.
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

# Test if fzf open in pane.
is_fzf="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?fzf$'"

# Change behaviour of <ctrl-{h,j,k,l}> only when required pane exists.
# https://github.com/christoomey/vim-tmux-navigator/pull/198
#
# -n : flag is a shorthand for '-T root' to use the 'root' table, in which key
#      kombinations enters without prefix.
#
tmux bind-key -n 'C-h' \
  if-shell "$is_vim || $is_fzf || [ #{pane_at_left} -eq 1 ]" \
      "send-keys C-h" "select-pane -L"

tmux bind-key -n 'C-j' \
    if-shell "$is_vim || $is_fzf || [ #{pane_at_bottom} -eq 1 ]" \
        "send-keys C-j"  "select-pane -D"

tmux bind-key -n 'C-k' \
    if-shell "$is_vim || $is_fzf || [ #{pane_at_top} -eq 1 ]" \
        "send-keys C-k"  "select-pane -U"

tmux bind-key -n 'C-l' \
    if-shell "$is_vim || $is_fzf || [ #{pane_at_right} -eq 1 ]" \
        "send-keys C-l"  "select-pane -R"

tmux_version="$(tmux -V | sed -En "$version_pat")"
tmux setenv -g tmux_version "$tmux_version"

#echo "{'version' : '${tmux_version}', 'sed_pat' : '${version_pat}' }" > ~/.tmux_version.json

tmux if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
  "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
tmux if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
  "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

tmux bind-key -T copy-mode-vi 'C-h' select-pane -L
tmux bind-key -T copy-mode-vi 'C-j' select-pane -D
tmux bind-key -T copy-mode-vi 'C-k' select-pane -U
tmux bind-key -T copy-mode-vi 'C-l' select-pane -R
tmux bind-key -T copy-mode-vi 'C-\' select-pane -l

# tmux bind-key -T copy-mode-vi C-\\ select-pane -l
