{ pkgs, options, lib, config, ... }:

with lib;
let
  cfg = config.modules.desktop;
  btops = pkgs.callPackage ../pkgs/btops { };
in {
  options.modules.desktop = {
    enable = mkEnableOption "desktop module";
    bspwm.enable = mkEnableOption "bspwm";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true; # use graphical session
      displayManager.lightdm.enable = true;
      windowManager.bspwm.enable = cfg.bspwm.enable;
    };

    services.picom.enable = true;
    services.greenclip.enable = true;

    environment.variables = mkIf cfg.bspwm.enable {
      # less java nonsense with tiling WMs
      _JAVA_AWT_WM_NONREPARENTING = "1";
      # faster sxhkd when its not running user shell (fish)
      SXHKD_SHELL = "/bin/sh";
    };

    environment.systemPackages = with pkgs;
      [ betterlockscreen feh alacritty pcmanfm ] ++ (if cfg.bspwm.enable then [
        (polybar.override { pulseSupport = config.modules.audio.enable; })
        btops
        rofi
        dunst
      ] else
        [ ]);

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
  };
}
