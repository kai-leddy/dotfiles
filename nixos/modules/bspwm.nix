
{ pkgs, options, lib, config, ... }:

let
  unstable = import <unstable> {
    config = config.nixpkgs.config;
  };
in
{
    services.xserver = {
        windowManager.bspwm = {
            enable = true;
        };

        displayManager.lightdm = {
            enable = true;
        };
    };

    environment.systemPackages = with pkgs; [
        polybar
    ];

    fonts.fonts = [
      (unstable.nerdfonts.override {
       fonts = [ "FantasqueSansMono" ];
      })
    ];
}
