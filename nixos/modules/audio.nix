{ config, lib, pkgs, ... }:

with lib;
let cfg = config.modules.audio;
in {
  options.modules.audio = { enable = mkEnableOption "audio module"; };

  config = mkIf cfg.enable {
    hardware.pulseaudio.enable = true;

    users.users.kai.extraGroups = [ "audio" ];

    environment.systemPackages = with pkgs; [ pulsemixer playerctl ];
  };
}
