{ options, config, lib, ... }:

with lib; {
  options.user = mkOption {
    type = options.home-manager.users.type;
    default = { };
    description = "home-manager config for the user";
  };

  config = {

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.kai = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    };

    # setup home-manager
    home-manager.useUserPackages = true;
    home-manager.useGlobalPkgs = true;

    # alias home manager user config to just `user`
    home-manager.users.kai = mkAliasDefinitions options.user;
  };
}
