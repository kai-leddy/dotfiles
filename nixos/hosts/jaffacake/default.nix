# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  nixos-hardware =
    builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; };
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # use the nixos-hardware config for t490
    "${nixos-hardware}/lenovo/thinkpad/t490"
  ];

  modules = {
    laptop = {
      enable = true;
      swapAltWin = true;
      networkmanager.enable = true;
    };

    shell = {
      fish.enable = true;
      thefuck.enable = true;
    };

    emacs.enable = true;

    audio.enable = true;

    desktop = {
      enable = true;
      bspwm.enable = true;
    };

    apps = {
      flameshot.enable = true;
      spotify.enable = true;
      # mpv.enable = true
    };

    browsers = {
      firefox.enable = true;
      # qutebrowser.enable = true;
    };
  };

  # TODO: throttled config
  # TODO: work apps
  # TODO: autorandr,
  # TODO: btops needs a service
  # TODO: setup hibernation
  # TODO: sleep/hibernate on lid close,
  # TODO: make sure redox keyboard config works
  # TODO: setup any project w/ shell.nix
  # TODO: seutp greenclip for rofi
  # TODO: ssh-agent automated setup?
  # TODO: lightdm theme
}
