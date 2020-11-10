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
    betterlockscreen
  ];

  fonts.fonts = [
    # TODO: parameterize this as various modules depend on the font
    # (pkgs.unstable.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
    fantasque-nerdfont # custom derivation due to issues with above v2.1.0
  ];

  # Define systemd service for betterlockscreen to run on suspend
  systemd.services.betterlockscreen = {
    enable = true;
    description = "Locks screen when going to sleep/suspend";
    environment = { DISPLAY = ":0"; };
    wantedBy = [ "sleep.target" "suspend.target" ];
    before = [ "sleep.target" "suspend.target" ];
    serviceConfig = {
      User = "kai";
      Type = "simple";
      ExecStart = "${pkgs.betterlockscreen}/bin/betterlockscreen -l blur";
      ExecStartPost = "${pkgs.coreutils}/bin/sleep 1";
      TimeoutSec = "infinity";
    };
  };
}
