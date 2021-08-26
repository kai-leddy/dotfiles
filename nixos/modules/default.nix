{ config, lib, pkgs, ... }:

{
  imports = [
    ./common.nix
    ./laptop.nix
    ./desktop.nix
    ./development.nix
    ./shell.nix
    ./apps.nix
    ./browsers.nix
    ./keyboards.nix
  ];
}
