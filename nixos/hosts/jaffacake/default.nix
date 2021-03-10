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
    # sort out the thermal nonsense on these T490s
    ./thermal.nix
  ];

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
      direnv.enable = true;
    };

    development = {
      emacs.enable = true;
      android.enable = true;
      docker.enable = true;
      kubernetes.enable = true;
      # TODO: Add NodeJS, prettier, VMD etc globally
    };

    # TODO: move this into a "common" module with garbage collection etc
    audio.enable = true;

    desktop = {
      enable = true;
      bspwm.enable = true;
    };

    apps = {
      flameshot.enable = true;
      spotify.enable = true;
      mpv.enable = true;
      slack.enable = true;
      zoom.enable = true;
      libreoffice.enable = true;
      discord.enable = true;
      todoist.enable = true;
    };

    browsers = {
      firefox.enable = true;
      firefox-dev.enable = true;
      # qutebrowser.enable = true;
    };
  };

  # TODO: auto nix garbage collection older than 7d
  # TODO: lightdm theme
  # TODO: grub theme
}
