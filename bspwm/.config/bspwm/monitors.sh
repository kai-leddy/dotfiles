#!/bin/bash

# kill polybar instances so they can be restarted on correct monitors
killall polybar

# make sure there is always at least 10 desktops
if [ "$(bspc query -D | wc -l)" -lt "10" ]; then
    bspc monitor eDP1 -d 1 2 3 4 5 6 7 8 9 10
fi

monitor_count="$(xrandr | grep ' connected' | wc -l)"

# map desktops to the correct monitors and restart polybar instances
if [ "$monitor_count" -eq "3" ]
then
    for d in {1..4}; do bspc desktop $d -m eDP1 ; done
    for d in {5..7}; do bspc desktop $d -m HDMI1 ; done
    for d in {8..10}; do bspc desktop $d -m DP2 ; done
    bspc wm --reorder-monitors eDP1 HDMI1 DP2
    bspc desktop Desktop --remove
    bspc desktop Desktop --remove
    polybar external &
    polybar external_extra &
    polybar main &
elif [ "$monitor_count" -eq "2" ]
then
    for d in {1..5}; do bspc desktop $d -m eDP1 ; done
    for d in {6..9}; do bspc desktop $d -m HDMI1 ; done
    # fix for 10 being residual and already being in the wrong place
    bspc desktop 10 -m eDP1
    bspc desktop 10 -m HDMI1
    # end fix
    bspc wm --reorder-monitors eDP1 HDMI1
    bspc desktop Desktop --remove
    polybar external &
    polybar main &
else
    for d in {1..10}; do bspc desktop $d -m eDP1 ; done
    polybar main &
fi

# re-map touch screen viewport to only map to built in monitor
xinput map-to-output $(xinput list --id-only "Wacom Pen and multitouch sensor Finger") eDP1
#xinput map-to-output $(xinput list --id-only "Wacom Pen and multitouch sensor Pen Pen (0x9cd3158b)") eDP1

# re-initialise the wallpaper to force tiling instead of stretching
feh --bg-fill ~/.config/wallpaper
