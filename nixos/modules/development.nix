{ config, lib, pkgs, ... }:

with lib;
let cfg = config.modules.development;
in {
  options.modules.development = {
    emacs.enable = mkEnableOption "emacs dev environment";
    android.enable = mkEnableOption "android dev stuff";
    docker.enable = mkEnableOption "docker dev stuff";
    kubernetes.enable = mkEnableOption "kubernetes gcloud stuff";
  };

  config = mkMerge [
    (mkIf cfg.emacs.enable {
      # TODO: use Emacs 28 emacsGcc from the overlay
      environment.systemPackages = with pkgs; [
        # Required for doom emacs to work properly
        unstable.emacs # 27.1
        git
        ripgrep

        # optional stuff
        fd # faster projectile indexing
        zstd # for undo-tree compression

        # Module dependencies
        nixfmt # :lang nix
        nodejs_latest # needed for installing language servers
      ];

      fonts.fonts = [ pkgs.emacs-all-the-icons-fonts ];
    })
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
