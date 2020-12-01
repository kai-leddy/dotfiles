{ config, lib, pkgs, ... }:

with lib;
let cfg = config.modules.development;
in {
  options.modules.development = {
    android.enable = mkEnableOption "android dev stuff";
    docker.enable = mkEnableOption "docker dev stuff";
  };

  config = {
    # install adb and udev rules for devices
    programs.adb.enable = cfg.android.enable;
    services.udev.packages = with pkgs;
      mkIf cfg.android.enable [ android-udev-rules ];

    # give user permissions for stuff
    users.users.kai.extraGroups = [
      (mkIf cfg.android.enable "adbusers")
      (mkIf cfg.docker.enable "docker")
    ];

    virtualisation.docker.enable = cfg.docker.enable;
  };
}
