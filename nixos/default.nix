# this is heavily based on hlissner's config at
# https://github.com/hlissner/dotfiles

# TODO: upgrade to 20.09
# TODO: after some usage, consider converting nixos config to a flake
# TODO: after some usage, consider converting to home-manager

hostname:
{ pkgs, options, lib, config, ... }: {
  # TODO: use flakes instead of fetchTarball
  imports = [
    "${./hosts}/${hostname}"
    ./modules/bspwm.nix
    ./modules/emacs.nix
    ./modules/fish.nix
  ];

  networking.hostName = hostname; # Define your hostname.

  nix.autoOptimiseStore = true; # does what it says on the tin

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
  environment.systemPackages = with pkgs; [ curl wget vim git stow ];

  # setup user account
  users.users.kai = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  services.xserver = {
    enable = true; # use graphical session
    layout = "gb"; # use gb layout keyboard
    xkbOptions = "caps:escape"; # use caps as escape key

    displayManager.lightdm.enable = true;
  };

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
