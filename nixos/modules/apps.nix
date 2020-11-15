{ config, lib, pkgs, ... }:

with lib;
let cfg = config.modules.apps;
in {
  options.modules.apps = {
    mpv.enable = mkEnableOption "mpv";
    flameshot.enable = mkEnableOption "flameshot";
  };

  config = {
    environment.systemPackages = with pkgs; [
      (mkIf cfg.mpv.enable mpv)
      (mkIf cfg.flameshot.enable flameshot)
    ];
  };
}
