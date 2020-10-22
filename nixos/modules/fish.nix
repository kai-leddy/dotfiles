{ pkgs, options, lib, config, ... }: {
  programs.fish.enable = true;

  users.users.kai.shell = pkgs.fish;

  environment.systemPackages = with pkgs; [
    git
    tree
    bat
    killall
    neofetch
    fzf
    ripgrep
    fd
    lsd
  ];

  programs.thefuck.enable = true;
}
