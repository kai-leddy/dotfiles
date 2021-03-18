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
1. install oh-my-fish with `curl -L https://get.oh-my.fish | fish`
1. install oh-my-fish plugins with `omf install`
1. install doom emacs by following their guide
1. setup a wallpaper at `~/.config/wallpaper` or the **LOCK SCREEN WONT WORK**

## Nix shell boilerplates

### Kubernetes, Helm, GCloud

``` nix
{ pkgs ? import <nixpkgs> { } }:

with pkgs;

mkShell {
  buildInputs = [ google-cloud-sdk kubernetes-helm kubectl ];
}
```

### Terraform

``` nix
{ pkgs ? import <nixpkgs> { } }:

with pkgs;

mkShell {
  buildInputs = [
    ((terraform.withPlugins (plugins: [
      plugins.google
      plugins.helm
      plugins.kubernetes
    ])).overrideAttrs (_:
      let
        version = "0.12.28";
        sha256 = "05ymr6vc0sqh1sia0qawhz0mag8jdrq157mbj9bkdpsnlyv209p3";
      in {
        name = "terraform-${version}";
        src = fetchFromGitHub {
          owner = "hashicorp";
          repo = "terraform";
          rev = "v${version}";
          inherit sha256;
        };
      }))
  ];
}
```
