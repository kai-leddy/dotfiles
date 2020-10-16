{ pkgs, options, lib, config, ... }:

let
  unstable = import <unstable> { config = config.nixpkgs.config; };
  # TODO: put this somewhere else
  btops = with pkgs;
    buildGoPackage {
      pname = "btops";
      version = "1.0.0";
      goPackagePath = "github.com/cmschuetz/btops";

      src = fetchFromGitHub {
        owner = "cmschuetz";
        repo = "btops";
        rev = "b7f90a54af5cfc86460fc1acaa4b3fa156ad634f";
        sha256 = "1xzhbvc0lxdjh4bsc3g93fv68zbhn7rdn9m391p5fnxnxb3ikbgp";
      };

      goDeps = ./btops-deps.nix;
    };
in {
  services.xserver = {
    windowManager.bspwm = { enable = true; };

    displayManager.lightdm = { enable = true; };
  };

  environment.systemPackages = with pkgs; [ btops polybar rofi ];

  fonts.fonts =
    [ (unstable.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; }) ];

}
