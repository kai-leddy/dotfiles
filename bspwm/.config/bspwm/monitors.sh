#!/bin/bash

# kill polybar instances so they can be restarted on correct monitors
killall polybar

# put monitors in the order I want for iterating in
# including those which should never exist, just in case
bspc wm --reorder-monitors HDMI-2 DP-1 eDP-1

mapfile -t monitors < <(xrandr | grep ' connected' | awk '{print $1}')
monitor_count=${#monitors[@]}

# create polybar instances for each monitor
for mon in "${monitors[@]}"; do
    if [ "$mon" = "eDP-1" ]; then
        MONITOR=$mon polybar main &
    else
        MONITOR=$mon polybar external &
    fi
done

# re-initialise the wallpaper to force tiling instead of stretching
feh --bg-fill ~/.config/wallpaper
