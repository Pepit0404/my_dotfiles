#!/usr/bin/env bash

# Get current window position and size
read -r pos_x pos_y width height < <(hyprctl activewindow | grep -E 'at:|size:' | sed 's/,/ /g' | awk '{print $2, $3, $5, $6}' | paste -s)

# Calculate corner positions
positions=("$pos_x $((pos_y + height))" "$((pos_x + width)) $((pos_y + height))" "$((pos_x + width)) $pos_y" "$pos_x $pos_y")

# Move cursor based on input. see https://wiki.hyprland.org/Configuring/Dispatchers/#list-of-dispatchers
hyprctl dispatch movecursor ${positions[$1]:-${positions[3]}}
