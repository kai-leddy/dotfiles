{ config, lib, pkgs, ... }:

with lib;
let cfg = config.modules.common;
in {
  options.modules.common = {
    audio = { enable = mkEnableOption "audio module"; };
    flakes = { enable = mkEnableOption "experimental flakes support"; };
  };

  config = mkMerge [
    (mkIf cfg.audio.enable {
      hardware.pulseaudio.enable = true;

      users.users.kai.extraGroups = [ "audio" ];

      environment.systemPackages = with pkgs; [ pulsemixer playerctl ];
    })
    (mkIf cfg.flakes.enable {
      nix = {
        package = pkgs.nixUnstable;
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
      };
    })
  ];
}
