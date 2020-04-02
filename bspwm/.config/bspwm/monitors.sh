#!/bin/bash

# kill polybar instances so they can be restarted on correct monitors
killall polybar

# get the current hwmon path for CPU temp
export TEMP_PATH=$(find /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input)

# put monitors in the order I want for iterating in
# including those which should never exist, just in case
bspc wm --reorder-monitors DP-1 HDMI-2 eDP-1

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
