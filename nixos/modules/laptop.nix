{ options, config, lib, pkgs, ... }:

with lib;
let cfg = config.modules.laptop;
in {
  options.modules.laptop = {
    enable = mkEnableOption "laptop module";
    networkmanager.enable = mkEnableOption "networkmanager";
    swapAltWin = mkEnableOption "swapping LAlt & LWin keys";
  };

  config = mkIf cfg.enable {
    # use network-manager for handling wifi and ethernet
    networking.networkmanager.enable = cfg.networkmanager.enable;

    services.xserver = {
      libinput.enable = true; # enable touchpad
      xkbOptions = mkIf cfg.swapAltWin "altwin:swap_lalt_lwin";
    };

    environment.systemPackages = with pkgs;
      [
        brightnessctl # for changing brightness
      ];
  };
}
