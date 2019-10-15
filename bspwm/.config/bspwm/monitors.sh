#!/bin/bash

# kill polybar instances so they can be restarted on correct monitors
killall polybar

# put monitors in the order I want for iterating in
# including those which should never exist, just in case
bspc wm --reorder-monitors eDP-1 DVI-I-1-1 DVI-I-2-2

#monitors="$(xrandr | grep ' connected' | awk '{print $1}')"
mapfile -t monitors < <(bspc query -M --names)
monitor_count=${#monitors[@]}

# make sure there is always at least 10 desktops
if [ "$(bspc query -D | wc -l)" -lt "10" ]; then
    bspc monitor eDP-1 -d 1 2 3 4 5 6 7 8 9 10
fi

# map desktops to the correct monitors and restart polybar instances
if [ "$monitor_count" -eq "3" ]
then
    for d in {1..4}; do bspc desktop $d -m ${monitors[0]} ; done
    for d in {5..7}; do bspc desktop $d -m ${monitors[1]} ; done
    for d in {8..10}; do bspc desktop $d -m ${monitors[2]} ; done
    bspc desktop Desktop --remove
    bspc desktop Desktop --remove
    MONITOR=${monitors[2]} polybar external_extra &
    MONITOR=${monitors[1]} polybar external &
    MONITOR=${monitors[0]} polybar main &
elif [ "$monitor_count" -eq "2" ]
then
    for d in {1..5}; do bspc desktop $d -m ${monitors[0]} ; done
    for d in {6..10}; do bspc desktop $d -m ${monitors[1]} ; done
    bspc desktop Desktop --remove
    MONITOR=${monitors[1]} polybar external &
    MONITOR=${monitors[0]} polybar main &
else
    for d in {1..10}; do bspc desktop $d -m ${monitors[0]} ; done
    MONITOR=${monitors[0]} polybar main &
fi

# re-initialise the wallpaper to force tiling instead of stretching
feh --bg-fill ~/.config/wallpaper
