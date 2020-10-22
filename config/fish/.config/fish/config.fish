# Settings for the 'bobthefish' theme
set -g theme_color_scheme dracula
set -g theme_display_git yes
set -g theme_display_git_untracked yes
set -g theme_display_docker_machine yes
set -g theme_display_k8s_context no
set -g theme_display_user ssh
set -g theme_display_hostname ssh
set -g theme_display_vi yes
set -g theme_display_date yes
set -g theme_display_cmd_duration yes
set -g theme_title_display_process yes
set -g theme_title_display_path yes
set -g theme_title_use_abbreviated_path yes
set -g theme_date_format "+%a %d/%m %H:%M"
set -g theme_avoid_ambiguous_glyphs no
set -g theme_powerline_fonts yes
set -g theme_nerd_fonts yes
set -g theme_show_exit_status yes
set -g fish_prompt_pwd_dir_length 1
set -g theme_project_dir_length 1

# Setup FZF to use FD (like ripgrep but for files/folders)
set -x FZF_DEFAULT_OPTS '--ansi'
set -x FZF_DEFAULT_COMMAND 'fd --type file --color=always --follow --hidden --exclude .git . $dir'
set -x FZF_ALT_C_COMMAND 'fd --type directory --color=always --follow --hidden --exclude .git . $dir'
set -x FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND

# Fucking Java GUI applications...
set -x _JAVA_AWT_WM_NONREPARENTING 1
# Fucking SXHKD
set -x SXHKD_SHELL '/usr/bin/sh'
# Fucking Intel
set -x LIBVA_DRIVER_NAME iHD
# Fucking slow make builds
set -x MAKEFLAGS '-j 8'

# Setup env vars for various other stuff
set -x EDITOR emacsclient
set -x VISUAL emacsclient
set -x ANDROID_HOME $HOME/Android/Sdk

# Setup QMK global CLI tool
set -x QMK_HOME $HOME/repos/qmk_firmware

# Setup Google cloud credentials properly
set -x GOOGLE_APPLICATION_CREDENTIALS $HOME/.config/gcloud/legacy_credentials/kai.leddy@azuri-technologies.com/adc.json

# Setup user PATH variables all at once (for performance)
set -e fish_user_paths
set -U fish_user_paths $HOME/.emacs.d/bin $ANDROID_HOME/emulator $ANDROID_HOME/tools $ANDROID_HOME/tools/bin $ANDROID_HOME/platform-tools $HOME/.local/bin
# set -U fish_user_paths (ruby -e 'puts Gem.user_dir')/bin (go env GOPATH)/bin

# use lsd instead of ls
alias ls lsd

# Magic to make using `-` on its own work
abbr -a -- - 'cd -'
# Git abbreviations
abbr -a -g ga 'git add'
abbr -a -g gb 'git branch'
abbr -a -g gc 'git commit'
abbr -a -g gco 'git checkout'
abbr -a -g gd 'git diff'
abbr -a -g gl 'git lg'
abbr -a -g gs 'git status'
abbr -a -g gf 'git flow'
abbr -a -g rndev 'adb shell input keyevent KEYCODE_MENU'

# QMK abbreviations
abbr -a -g qc 'qmk compile'
abbr -a -g qf 'qmk flash -kb redox/rev1 -km FrogInABox'

# Bindings for copying and pasting to clipboard in normal mode
bind yy fish_clipboard_copy
bind p fish_clipboard_paste

# Use Jabba to manage JAVA SDK versions
[ -s "/home/kai/.jabba/jabba.fish" ]
and source "/home/kai/.jabba/jabba.fish"
