{ config, lib, pkgs, ... }:

{
  imports = [
    ./laptop.nix
    ./desktop.nix
    ./emacs.nix
    ./shell.nix
    ./apps.nix
    ./browsers.nix
    ./audio.nix
  ];
}
