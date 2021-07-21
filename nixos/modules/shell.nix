{ pkgs, options, lib, config, ... }:

with lib;
let cfg = config.modules.shell;
in {
  options.modules.shell = {
    fish.enable = mkEnableOption "fish shell";
    thefuck.enable = mkEnableOption "thefuck";
    direnv.enable = mkEnableOption "direnv";
  };

  config = mkMerge [
    {
      # setup thefuck
      programs.thefuck.enable = cfg.thefuck.enable;

      # enable GPG agent properly
      programs.gnupg.agent.enable = true;

      environment.systemPackages = with pkgs; [
        bat
        neofetch
        fzf
        ripgrep
        fd
        lsd
        pigz
        jq
        gnupg
        unstable.tealdeer
        unstable.delta
      ];
    }
    (mkIf cfg.fish.enable {
      # setup fish
      programs.fish = {
        enable = true;
        # TODO: change fish prompt and use double-line prompt
        promptInit = ''
          any-nix-shell fish | source
        '' + (if cfg.direnv.enable then ''
          set -x DIRENV_LOG_FORMAT ""
          eval (direnv hook fish)
        '' else
          "");
      };
      users.users.kai.shell = pkgs.fish;
      environment.systemPackages = with pkgs; [ unstable.any-nix-shell ];
    })
    (mkIf cfg.direnv.enable {
      environment.systemPackages = with pkgs; [ direnv nix-direnv ];
      # dont garbage collect direnvs
      nix.extraOptions = ''
        keep-outputs = true
        keep-derivations = true
      '';
      environment.pathsToLink = [ "/share/nix-direnv" ];
    })
  ];
}
