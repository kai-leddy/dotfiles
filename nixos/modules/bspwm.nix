
{ pkgs, options, lib, config, ... }:
{
    services.xserver = {
        windowManager.bspwm = {
            enable = true;
        };

        displayManager.lightdm = {
            enable = true;
        };
    };
}
