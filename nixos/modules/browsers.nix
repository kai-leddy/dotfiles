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
      (mkIf cfg.qutebrowser.enable qutebrowser)
      (mkIf cfg.firefox.enable firefox-bin)
      (mkIf cfg.firefox-dev.enable unstable.firefox-devedition-bin)
      # desktop entry for firefox-devedition so it can be xdg-mime default
      (mkIf cfg.firefox-dev.enable (makeDesktopItem {
        name = "firefox-devedition";
        desktopName = "firefox-devedition";
        exec = "firefox-devedition %U";
        categories = concatMapStrings (x: x + ";") [
          "Application"
          "Network"
          "WebBrowser"
        ];
        icon = "firefox-devedition";
        genericName = "Web Browser";
        mimeType = concatStringsSep ";" [
          "text/html"
          "text/xml"
          "application/xhtml+xml"
          "application/vnd.mozilla.xul+xml"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/ftp"
        ];
      }))
    ];
  };
}
