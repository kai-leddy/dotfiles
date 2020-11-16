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

  # setup thinkfan and throttled (the default fan curve is pathetic)
  services.thinkfan.enable = true;
  services.throttled.enable = true;

  modules = {
    laptop = {
      enable = true;
      swapAltWin = true;
      networkmanager.enable = true;
      autorandr.enable = true;
      hibernate.enable = true;
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
      slack.enable = true;
      zoom.enable = true;
    };

    browsers = {
      firefox.enable = true;
      firefox-dev.enable = true;
      # qutebrowser.enable = true;
    };
  };

  # TODO: auto nix garbage collection older than 7d
  # TODO: setup any project w/ shell.nix
  # TODO: direnv & (nix-direnv / lorri)
  # TODO: lightdm theme
  # TODO: grub theme
}
