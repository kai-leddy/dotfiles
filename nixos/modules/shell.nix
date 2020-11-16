{ pkgs, options, lib, config, ... }:

with lib;
let cfg = config.modules.shell;
in {
  options.modules.shell = {
    fish.enable = mkEnableOption "fish shell";
    thefuck.enable = mkEnableOption "thefuck";
  };

  config = {
    # setup fish
    programs.fish = mkIf cfg.fish.enable {
      enable = true;
      promptInit = ''
        any-nix-shell fish --info-right | source
      '';
    };
    users.users.kai.shell = mkIf cfg.fish.enable pkgs.fish;

    # setup thefuck
    programs.thefuck.enable = cfg.thefuck.enable;

    environment.systemPackages = with pkgs; [
      tree
      bat
      killall
      neofetch
      fzf
      ripgrep
      fd
      lsd
      (mkIf cfg.fish.enable unstable.any-nix-shell)
    ];
  };
}
