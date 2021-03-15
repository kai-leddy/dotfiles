#!/usr/bin/env fish

function bobthefish_colors -S -d 'Define a custom bobthefish color scheme'
    __bobthefish_colors dracula
    # override color_k8s to be more readable
    set -x color_k8s ffb86c 282a36 --bold
end
