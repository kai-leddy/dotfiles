{ config, lib, pkgs, ... }:

with lib;
let cfg = config.modules.browsers;
in {
  options.modules.browsers = {
    firefox.enable = mkEnableOption "firefox";
    qutebrowser.enable = mkEnableOption "qutebrowser";
  };

  config = {
    environment.systemPackages = with pkgs; [
      (mkIf cfg.firefox.enable firefox)
      (mkIf cfg.qutebrowser.enable qutebrowser)
    ];
  };
}
