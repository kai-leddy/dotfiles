# Dotfiles

These dotfiles are now managed by [`yadm`](https://yadm.io/). See their docs for usage instructions.

## OLD Nixos Install instructions (-ish)

1. replace `/etc/nixos/configuration.nix` with `import /home/<user>/nixos "hostname"`
1. add the unstable channel with `nix-channel --add https://nixos.org/channels/nixpkgs-unstable unstable`
1. update channels with `nix-channel --update`
1. build the system with `sudo nixos-rebuild --switch`
1. set a user password with `passwd <user>`
1. reboot and login as <user>
1. setup a wallpaper at `~/.config/wallpaper` or the **LOCK SCREEN WONT WORK**
1. symlink LLM templates with `ln -s ~/dotfiles/llm-templates (llm templates path)`
