{ pkgs, options, lib, config, ... }:

let
  btops = pkgs.callPackage ../pkgs/btops { };
  fantasque-nerdfont = pkgs.callPackage ../pkgs/fantasque-nerdfont.nix { };
in {
  services.xserver.windowManager.bspwm.enable = true;

  services.picom.enable = true;

  environment.systemPackages = with pkgs; [
    btops
    polybar
    rofi
    dunst
    feh
    # TODO: enable the systemd service for betterlockscreen on suspend
    betterlockscreen
  ];

  fonts.fonts = [
    # TODO: parameterize this as various modules depend on the font
    # (pkgs.unstable.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
    fantasque-nerdfont # custom derivation due to issues with above v2.1.0
  ];

}
