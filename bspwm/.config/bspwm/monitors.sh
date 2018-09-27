#!/bin/bash

if [ "$(bspc query -M | wc -l)" -eq "2" ]; then
    for d in {1,2,3,4,5}; do bspc desktop $d -m eDP1 ; done
    for d in {6,7,8,9,10}; do bspc desktop $d -m HDMI1 ; done
    bspc wm --reorder-monitors eDP1 HDMI1
    bspc desktop Desktop --remove
else
    for d in {1,2,3,4,5,6,7,8,9,10}; do bspc desktop $d -m eDP1 ; done
fi

feh --bg-fill ~/.config/wallpaper
