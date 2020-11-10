# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  nixos-hardware =
    builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # use the nixos-hardware config for t490
    "${nixos-hardware}/lenovo/thinkpad/t490"
  ];

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  # use network-manager for handling wifi and ethernet
  networking.networkmanager.enable = true;

  services.xserver = {
    libinput.enable = true; # enable touchpad
    xkbOptions = "altwin:swap_lalt_lwin"; # swap alt and win keys
  };

  environment.systemPackages = with pkgs; [
    brightnessctl # for changing brightness
  ];

  # TODO: throttled config, work apps, autorandr,
  # audio?, btops?, hibernation, sleep/hibernate on lid close,
  # redox keyboard config, touchpad config, project w/ shell.nix
}
