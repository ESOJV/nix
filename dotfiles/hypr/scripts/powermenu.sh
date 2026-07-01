#!/bin/bash

options="⏻ Shutdown\n↺ Reboot\n󰤄 Suspend\n󰍃 Logout"
chosen=$(echo -e "$options" | wofi --dmenu --prompt "Power" --width 220 --height 185 --no-actions)

case "$chosen" in
    "⏻ Shutdown") systemctl poweroff ;;
    "↺ Reboot")   systemctl reboot ;;
    "󰤄 Suspend")  systemctl suspend ;;
    "󰍃 Logout")   hyprctl dispatch exit ;;
esac
