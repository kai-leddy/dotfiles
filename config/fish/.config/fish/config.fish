# Setup FZF to use FD (like ripgrep but for files/folders)
set -x FZF_DEFAULT_OPTS '--ansi'
set -x FZF_DEFAULT_COMMAND 'fd --type file --color=always --follow --hidden --exclude .git . $dir'
set -x FZF_ALT_C_COMMAND 'fd --type directory --color=always --follow --hidden --exclude .git . $dir'
set -x FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND

# Fucking Java GUI applications...
set -x _JAVA_AWT_WM_NONREPARENTING 1
# Fucking SXHKD
set -x SXHKD_SHELL '/bin/sh'
# Fucking slow make builds
set -x MAKEFLAGS '-j 8'

# Setup env vars for various other stuff
set -x EDITOR emacsclient
set -x VISUAL emacsclient

# Setup QMK global CLI tool
set -x QMK_HOME $HOME/repos/qmk_firmware

# Setup user PATH variables all at once (for performance)
set -e fish_user_paths
set -U fish_user_paths $HOME/.emacs.d/bin $HOME/.local/bin $HOME/.linkerd2/bin

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
