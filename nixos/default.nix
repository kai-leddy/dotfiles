# this is heavily based on hlissner's config at
# https://github.com/hlissner/dotfiles

hostname: 
{ pkgs, options, lib, config, ... }:
{
  imports = [
    "${./hosts}/${hostname}"
./modules/bspwm.nix
];

  networking.hostName = hostname; # Define your hostname.

  nix.autoOptimiseStore = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim git alacritty tree
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kai = {
    isNormalUser = true;
    #shell = pkgs.fish;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
