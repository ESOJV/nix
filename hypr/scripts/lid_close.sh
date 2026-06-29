#!/bin/bash
# If external monitor is connected, just disable the laptop screen
if hyprctl monitors all | grep -q "DP-3"; then
    hyprctl keyword monitor "eDP-1,disable"
else
    systemctl suspend
fi
