{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.development;

  unstableWithEmacs = import (fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
      overlays = [
        (import (builtins.fetchTarball {
          url =
            "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
        }))
      ];
    };
in {
  options.modules.development = {
    emacs.enable = mkEnableOption "emacs dev environment";
    android.enable = mkEnableOption "android dev stuff";
    docker.enable = mkEnableOption "docker dev stuff";
    kubernetes.enable = mkEnableOption "kubernetes gcloud stuff";
  };

  config = mkMerge [
    (mkIf cfg.emacs.enable {
      services.emacs = {
        enable = true;
        package = unstableWithEmacs.emacsPgtkGcc;
      };

      environment.systemPackages = with pkgs; [
        # Required for doom emacs to work properly
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
      users.users.kai.extraGroups = [ "adbusers" ];
      # add scrcpy for screen sharing
      environment.systemPackages = with pkgs; [ scrcpy ];
    })
    (mkIf cfg.docker.enable {
      # enable virtualisations and permissions
      # TODO: swap to using podman & buildah
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
