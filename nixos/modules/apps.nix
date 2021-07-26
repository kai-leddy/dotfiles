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
    espanso.enable = mkEnableOption "espanso";
    peek.enable = mkEnableOption "peek";
    myki.enable = mkEnableOption "myki";
  };

  config = {
    environment.systemPackages = with pkgs;
      let
        todoist = callPackage ../pkgs/todoist.nix { };
        myki = callPackage ../pkgs/myki.nix { };
      in [
        (mkIf cfg.mpv.enable unstable.mpv)
        (mkIf cfg.flameshot.enable flameshot)
        (mkIf cfg.spotify.enable spotify)
        (mkIf cfg.slack.enable slack)
        (mkIf cfg.zoom.enable zoom-us)
        (mkIf cfg.libreoffice.enable libreoffice)
        (mkIf cfg.discord.enable (unstable.discord.overrideAttrs (_: {
          # always use latest discord or it refuses to open
          src = fetchTarball
            "https://discord.com/api/download?platform=linux&format=tar.gz";
        })))
        (mkIf cfg.todoist.enable todoist)
        (mkIf cfg.peek.enable peek)
        (mkIf cfg.myki.enable myki)
      ];

    # for viewing pdfs and such (only if in graphical env)
    programs.evince.enable = config.modules.desktop.enable;

    services.espanso.enable = cfg.espanso.enable;

    services.gnome3.gnome-keyring.enable = cfg.myki.enable;
  };
}
