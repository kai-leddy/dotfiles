{ pkgs, options, lib, config, ... }:

with lib;
let cfg = config.modules.emacs;
in {
  options.modules.emacs = { enable = mkEnableOption "emacs module"; };

  config = mkIf cfg.enable {
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
  };

}
