{ config, lib, pkgs, ... }:

with lib;
let cfg = config.modules.apps;
in {
  options.modules.apps = {
    mpv.enable = mkEnableOption "mpv";
    flameshot.enable = mkEnableOption "flameshot";
    spotify.enable = mkEnableOption "spotify";
    slack.enable = mkEnableOption "slack";
    zoom.enable = mkEnableOption "zoom";
    libreoffice.enable = mkEnableOption "libreoffice";
    discord.enable = mkEnableOption "discord";
    todoist.enable = mkEnableOption "todoist";
  };

  config = {
    environment.systemPackages = with pkgs;
      let todoist = callPackage ../pkgs/todoist.nix { };
      in [
        (mkIf cfg.mpv.enable unstable.mpv)
        (mkIf cfg.flameshot.enable flameshot)
        (mkIf cfg.spotify.enable spotify)
        (mkIf cfg.slack.enable slack)
        (mkIf cfg.zoom.enable zoom-us)
        (mkIf cfg.libreoffice.enable libreoffice)
        (mkIf cfg.discord.enable unstable.discord)
        (mkIf cfg.todoist.enable todoist)
      ];

    # for viewing pdfs and such (only if in graphical env)
    programs.evince.enable = config.modules.desktop.enable;
  };
}
