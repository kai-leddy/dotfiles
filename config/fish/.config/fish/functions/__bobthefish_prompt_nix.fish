#!/usr/bin/env fish

function __bobthefish_prompt_nix -S -d 'Display current nix environment'
    [ "$theme_display_nix" = 'no' -o -z "$IN_NIX_SHELL" ]
    and return

    __bobthefish_start_segment $color_nix
    echo -ns $nix_glyph $IN_NIX_SHELL

    [ -n "$ANY_NIX_SHELL_PKGS" ]
    and echo -ns "+run"

    echo -ns " "

    set_color normal
end
