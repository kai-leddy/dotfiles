{ pkgs, options, lib, config, ... }:

{
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
    nodePackages.javascript-typescript-langserver # :lang javascript
  ];

  fonts.fonts = [ pkgs.emacs-all-the-icons-fonts ];
}
