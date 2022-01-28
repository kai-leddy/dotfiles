# this is heavily based on hlissner's config at
# https://github.com/hlissner/dotfiles

# TODO: convert nixos config to a flake

hostname:
{ pkgs, options, lib, config, ... }:

with lib; {
  imports = [ "${./hosts}/${hostname}" ./modules ];

  networking.hostName = hostname; # Define your hostname.

  nix = {
    trustedUsers = [ "root" "kai" ];
    autoOptimiseStore = true; # does what it says on the tin
    # use cachix for community packages
    binaryCaches =
      [ "https://cache.nixos.org/" "https://nix-community.cachix.org" ];
    binaryCachePublicKeys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # add unstable repo to pkgs with `unstable.` prefix
  nixpkgs.config = {
    allowUnfree = true;

    packageOverrides = pkgs: {
      unstable = import <unstable> { config = config.nixpkgs.config; };
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  time.timeZone = "Europe/London";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ curl vim git unzip ];

  # TODO: username in some sort of variable
  # setup user account
  users.users.kai = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  # Use Cloudflare DNS servers (more reliable than local router)
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  # TODO: some sort of fonts.nix maybe?
  fonts.fonts = with pkgs;
    let fantasque-nerdfont = callPackage ./pkgs/fantasque-nerdfont.nix { };
    in [
      corefonts
      # (pkgs.unstable.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
      fantasque-nerdfont # custom derivation due to issues with above v2.1.0
      roboto
    ];

  # don't require sudo password for users in wheel group
  security.sudo.wheelNeedsPassword = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
