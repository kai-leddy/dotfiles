#!/bin/bash

# kill polybar instances so they can be restarted on correct monitors
killall polybar

# make sure there is exactly 10 desktops
if [ "$(bspc query -D | wc -l)" -ne "10" ]; then
    bspc monitor eDP1 -d 1 2 3 4 5 6 7 8 9 10
fi

# map desktops to the correct monitors and restart polybar instances
if [ "$(bspc query -M | wc -l)" -eq "2" ]; then
    for d in {1,2,3,4,5}; do bspc desktop $d -m eDP1 ; done
    for d in {6,7,8,9,10}; do bspc desktop $d -m HDMI1 ; done
    bspc wm --reorder-monitors eDP1 HDMI1
    bspc desktop Desktop --remove
    polybar external &
    polybar main &
else
    for d in {1,2,3,4,5,6,7,8,9,10}; do bspc desktop $d -m eDP1 ; done
    polybar main &
fi

# re-map touch screen viewport to only map to built in monitor
xinput --map-to-output $(xinput list --id-only "Wacom Pen and multitouch sensor Finger touch") eDP1
xinput --map-to-output $(xinput list --id-only "Wacom Pen and multitouch sensor Pen stylus") eDP1
xinput --map-to-output $(xinput list --id-only "Wacom Pen and multitouch sensor Pen eraser") eDP1

# re-initialise the wallpaper to force tiling instead of stretching
feh --bg-fill ~/.config/wallpaper
