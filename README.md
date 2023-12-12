# Dotfiles

## Install instructions (-ish)

1. checkout to `/home/<user>/dotfiles`
1. create a config in `nixos/hosts/` for the host
1. replace `/etc/nixos/configuration.nix` with `import /home/<user>/dotfiles/nixos "hostname"`
1. add the unstable channel with `nix-channel --add https://nixos.org/channels/nixpkgs-unstable unstable`
1. update channels with `nix-channel --update`
1. build the system with `sudo nixos-rebuild --switch`
1. set a user password with `passwd <user>`
1. reboot and login as <user>
1. cd into the config folder `cd ~/dotfiles/config`
1. stow all relevant config dotfiles with `ls | xargs stow -t ~`
1. install fisher with `curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher`
1. install fisher plugins with `fisher install`
1. install doom emacs by following their guide
1. setup a wallpaper at `~/.config/wallpaper` or the **LOCK SCREEN WONT WORK**
1. symlink LLM templates with `ln -s ~/dotfiles/llm-templates (llm templates path)`
