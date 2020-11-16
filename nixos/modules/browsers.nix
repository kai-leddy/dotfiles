{ config, lib, pkgs, ... }:

with lib;
let cfg = config.modules.browsers;
in {
  options.modules.browsers = {
    firefox.enable = mkEnableOption "firefox";
    firefox-dev.enable = mkEnableOption "firefox developer edition";
    qutebrowser.enable = mkEnableOption "qutebrowser";
  };

  config = {
    # TODO: use mozilla overlay for newer firefox packages
    environment.systemPackages = with pkgs; [
      (mkIf cfg.firefox.enable firefox-bin)
      (mkIf cfg.firefox-dev.enable unstable.firefox-devedition-bin)
      (mkIf cfg.qutebrowser.enable qutebrowser)
    ];
  };
}
