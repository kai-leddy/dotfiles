{ config, lib, pkgs, ... }:

{
  imports = [
    ./laptop.nix
    ./desktop.nix
    ./development.nix
    ./shell.nix
    ./apps.nix
    ./browsers.nix
    ./audio.nix
    ./keyboards.nix
  ];
}
