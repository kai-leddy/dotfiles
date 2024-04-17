# Setup FZF to use FD (like ripgrep but for files/folders)
set -x FZF_DEFAULT_OPTS --ansi
set -x FZF_DEFAULT_COMMAND 'fd --type file --color=always --follow --hidden --exclude .git . $dir'
set -x FZF_ALT_C_COMMAND 'fd --type directory --color=always --follow --hidden --exclude .git . $dir'
set -x FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND

# Compatibility with XDG tools for config home
set -x XDG_CONFIG_HOME $HOME/.config

# Fucking Java GUI applications...
set -x _JAVA_AWT_WM_NONREPARENTING 1
# Fucking SXHKD
set -x SXHKD_SHELL /bin/sh
# Fucking slow make builds
set -x MAKEFLAGS '-j 8'

# Setup env vars for various other stuff
set -x EDITOR nvim
set -x VISUAL nvim

# Make emacs LSP faster
set -x LSP_USE_PLISTS true

# get OpenAI API key out of the keychain and set it in the env
set -x OPENAI_API_KEY (security find-generic-password -w -a $LOGNAME -s neovim-openai-key)
set -x GH_TOKEN (security find-generic-password -w -a $LOGNAME -s github-cli-key)

# Setup QMK global CLI tool
set -x QMK_HOME $HOME/repos/qmk_firmware

# Sort out homebrew PATH variables in the right order
set -gx HOMEBREW_PREFIX /opt/homebrew
set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
set -gx HOMEBREW_REPOSITORY /opt/homebrew
fish_add_path --path /opt/homebrew/bin /opt/homebrew/sbin

# Setup Android development variables
# set -gx ANDROID_HOME $HOME/Library/Android/sdk
# set android_path $ANDROID_HOME/emulator $ANDROID_HOME/tools $ANDROID_HOME/tools/bin $ANDROID_HOME/platform-tools
# alias emu '$ANDROID_HOME/emulator/emulator'

# Setup Go path variables
set -x GOPATH $HOME/go
set -x GOBIN $GOPATH/bin

# Setup user PATH variables all at once (for performance)
set gnu_sed /opt/homebrew/opt/gnu-sed/libexec/gnubin
set gnu_grep /opt/homebrew/opt/grep/libexec/gnubin
set emacs $HOME/.config/emacs/bin
set local_bin $HOME/.local/bin
set pip3_bin (python3 -m site --user-base)/bin
set go_bin $GOBIN
# set composer $HOME/.composer/vendor/bin
# set mint $HOME/.mint/bin
fish_add_path --universal $gnu_sed $gnu_grep $emacs $android_path $composer $mint $local_bin $pip3_bin $go_bin

# use lsd instead of ls
alias ls lsd

# React Native dev aliases
alias rndev 'adb shell input keyevent KEYCODE_MENU'

# QMK aliases
alias qc 'qmk compile'
alias qf 'qmk flash -kb redox/rev1 -km FrogInABox'

# Setup git aliases
alias g lazygit

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

# Kubernetes abbreviations
# abbr -a -g k kubectl
# abbr -a -g kg 'kubectl get'
# abbr -a -g kga 'kubectl get --all-namespaces'
# abbr -a -g kgp 'kubectl get pods'
# abbr -a -g kgl 'kubectl get pods --show-labels'
# abbr -a -g kd 'kubectl describe'
# abbr -a -g kdp 'kubectl describe pods'
# abbr -a -g ke 'kubectl exec -it'
# abbr -a -g kl 'kubectl logs'
# abbr -a -g kp 'kubectl port-forward'
# abbr -a -g kr 'kubectl rollout restart'
# abbr -a -g kt 'kubectl top pods'
# abbr -a -g ktn 'kubectl top nodes'
# abbr -a -g ca 'ctlptl apply -f ctlptl-cluster.yaml'
# abbr -a -g cx 'ctlptl delete -f ctlptl-cluster.yaml'
# abbr -a -g tu 'tilt up'

# Terraform abbreviations
# abbr -a -g ti 'terraform init'
# abbr -a -g twl 'terraform workspace list'
# abbr -a -g tws 'terraform workspace select'
# abbr -a -g tp 'terraform plan'
# abbr -a -g ta 'terraform apply'
# abbr -a -g td 'terraform destroy'
# abbr -a -g ts 'terraform state'
# abbr -a -g tsl 'terraform state list'

# Bindings for copying and pasting to clipboard in normal mode
bind yy fish_clipboard_copy
bind p fish_clipboard_paste

# Enable AWS CLI autocompletion: github.com/aws/aws-cli/issues/1079
complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'

# setup various shell extensions
thefuck --alias | source
starship init fish | source
zoxide init fish | source
direnv hook fish | source
