{ config, lib, pkgs, ... }:

with lib;
let cfg = config.modules.apps;
in {
  options.modules.apps = {
    mpv.enable = mkEnableOption "mpv";
    flameshot.enable = mkEnableOption "flameshot";
    spotify.enable = mkEnableOption "spotify";
  };

  config = {
    environment.systemPackages = with pkgs; [
      (mkIf cfg.mpv.enable mpv)
      (mkIf cfg.flameshot.enable flameshot)
      (mkIf cfg.spotify.enable spotify)
    ];

    # for viewing pdfs and such
    programs.evince.enable = config.modules.desktop.enable;
  };
}
