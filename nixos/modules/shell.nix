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
    programs.fish.enable = cfg.fish.enable;
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
    ];
  };
}
