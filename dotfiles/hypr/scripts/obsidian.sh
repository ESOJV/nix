#!/bin/bash
# Toggle Obsidian scratchpad
if hyprctl clients | grep -q "class: obsidian"; then
    hyprctl dispatch togglespecialworkspace Obsidian
else
    obsidian &
    sleep 2
    hyprctl dispatch movetoworkspace special:Obsidian,class:obsidian
fi
