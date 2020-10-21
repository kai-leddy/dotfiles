{ pkgs, options, lib, config, ... }:

let
  unstable = import <unstable> { config = config.nixpkgs.config; };
  btops = pkgs.callPackage ../pkgs/btops { };
  fantasque-nerdfont = pkgs.callPackage ../pkgs/fantasque-nerdfont.nix { };
in {
  services.xserver = {
    windowManager.bspwm = { enable = true; };

    displayManager.lightdm = { enable = true; };
  };

  services.picom.enable = true;

  environment.systemPackages = with pkgs; [ btops polybar rofi ];

  fonts.fonts = [
    # (unstable.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
    fantasque-nerdfont # custom derivation due to issues with above v2.1.0
  ];

}
