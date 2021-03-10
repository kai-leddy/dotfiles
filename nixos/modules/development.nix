{ config, lib, pkgs, ... }:

with lib;
let cfg = config.modules.development;
in {
  options.modules.development = {
    android.enable = mkEnableOption "android dev stuff";
    docker.enable = mkEnableOption "docker dev stuff";
    kubernetes.enable = mkEnableOption "kubernetes gcloud stuff";
  };

  config = mkMerge [
    (mkIf cfg.android.enable {
      # install adb, permissions and udev rules for devices
      programs.adb.enable = true;
      services.udev.packages = with pkgs; [ android-udev-rules ];
      users.users.kai.extraGroups = [ "adbusers" ];
      # add scrcpy for screen sharing
      environment.systemPackages = with pkgs; [ scrcpy ];
    })
    (mkIf cfg.docker.enable {
      # enable virtualisations and permissions
      virtualisation.docker.enable = true;
      users.users.kai.extraGroups = [ "docker" ];
    })
    (mkIf cfg.kubernetes.enable {
      environment.systemPackages = with pkgs; [
        google-cloud-sdk
        kubectl
        kubectx
        kubernetes-helm
      ];
    })
  ];
}
