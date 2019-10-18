# Settings for the 'bobthefish' theme
set -g theme_display_git yes
set -g theme_display_git_untracked yes
set -g theme_git_worktree_support yes
set -g theme_display_vagrant yes
set -g theme_display_docker_machine yes
set -g theme_display_user no
set -g theme_display_vi yes
set -g theme_display_date yes
set -g theme_display_cmd_duration yes
set -g theme_title_display_process yes
set -g theme_title_display_path yes
set -g theme_title_use_abbreviated_path yes
set -g theme_date_format "+%a %H:%M"
set -g theme_avoid_ambiguous_glyphs no
set -g theme_powerline_fonts yes
set -g theme_nerd_fonts yes
set -g theme_show_exit_status yes
set -g theme_color_scheme dark
set -g fish_prompt_pwd_dir_length 1
set -g theme_project_dir_length 0

# Setup FZF to use FD (like ripgrep but for files/folders)
set -x FZF_DEFAULT_OPTS '--ansi'
set -x FZF_DEFAULT_COMMAND 'fd --type file --color=always --follow --hidden --exclude .git . $dir'
set -x FZF_ALT_C_COMMAND 'fd --type directory --color=always --follow --hidden --exclude .git . $dir'
set -x FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND

# Fucking Java GUI applications...
set -x _JAVA_AWT_WM_NONREPARENTING 1

# Setup env vars for building Android with React Native
set -x ANDROID_HOME $HOME/Android/Sdk
set -Ua fish_user_paths $ANDROID_HOME/emulator
set -Ua fish_user_paths $ANDROID_HOME/tools
set -Ua fish_user_paths $ANDROID_HOME/tools/bin
set -Ua fish_user_paths $ANDROID_HOME/platform-tools

# Setup env vars for other stuff
set -x EDITOR emacs
set -x VISUAL emacs
set -Ua fish_user_paths $HOME/.emacs.d/bin

# Use Jabba to manage JAVA SDK versions
[ -s "/home/kai/.jabba/jabba.fish" ]; and source "/home/kai/.jabba/jabba.fish"
