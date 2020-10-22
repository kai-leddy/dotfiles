# Installation instructions

1. checkout to `~/dotfiles` 
1. create a config in `nixos/hosts/` for the host
1. replace `/etc/nixos/configuration.nix` with `import /home/kai/dotfiles/nixos "hostname"`
1. build the system with `sudo nixos-rebuild --switch`
1. cd into the config folder `cd ~/dotfiles/config`
1. stow all relevant config dotfiles with `ls | xargs stow -t ~`
1. install oh-my-fish with `curl -L https://get.oh-my.fish | fish`
1. install oh-my-fish plugins with `omf install`
