{ config, lib, pkgs, ... }:

with lib; {
  services.xserver = mkIf config.services.xserver.enable {
    layout = "gb"; # use gb layout keyboard
    xkbOptions = "caps:escape"; # use caps as escape key

    # setup keyboard configs
    inputClassSections = [
      ''
        Identifier "magicforce-68"
          MatchIsKeyboard "on"
          MatchUSBID "04d9:a0f8"
          Option "XkbLayout" "us"
      ''
      ''
        Identifier "redox-keyboard"
          MatchIsKeyboard "on"
          MatchUSBID "feed:0000"
          Option "XkbLayout" "us"
          Option "XkbOptions" "caps:escape"
      ''
    ];
  };
}
