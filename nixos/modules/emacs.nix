{ pkgs, options, lib, config, ... }: {
  #TODO: upgrade to emacs 27
  environment.systemPackages = with pkgs; [ emacs nixfmt ];
}
