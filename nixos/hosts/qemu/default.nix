{ pkgs, options, lib, config, ... }: {
  imports = [ ./hardware.nix ];

  services.xserver.enable = true;
}
