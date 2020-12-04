{ pkgs, options, lib, config, ... }:

with lib;
let cfg = config.modules.shell;
in {
  options.modules.shell = {
    fish.enable = mkEnableOption "fish shell";
    thefuck.enable = mkEnableOption "thefuck";
    direnv.enable = mkEnableOption "direnv";
  };

  config = {
    # setup fish
    programs.fish = mkIf cfg.fish.enable {
      enable = true;
      promptInit = ''
        any-nix-shell fish --info-right | source
      '' + (if cfg.direnv.enable then ''
        set -x DIRENV_LOG_FORMAT ""
        eval (direnv hook fish)
      '' else
        "");
    };
    users.users.kai.shell = mkIf cfg.fish.enable pkgs.fish;

    # setup thefuck
    programs.thefuck.enable = cfg.thefuck.enable;

    environment.systemPackages = with pkgs; [
      tree
      bat
      neofetch
      fzf
      ripgrep
      fd
      lsd
      pigz
      (mkIf cfg.fish.enable unstable.any-nix-shell)
      (mkIf cfg.direnv.enable direnv)
      (mkIf cfg.direnv.enable nix-direnv)
    ];

    # dont garbage collect direnvs
    nix.extraOptions = mkIf cfg.direnv.enable ''
      keep-outputs = true
      keep-derivations = true
    '';
    environment.pathsToLink = mkIf cfg.direnv.enable [ "/share/nix-direnv" ];
  };
}
