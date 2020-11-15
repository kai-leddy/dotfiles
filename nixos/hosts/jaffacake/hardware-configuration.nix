# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" "sr_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Use the grub EFI boot loader.
  boot.loader = {
    grub = {
      enable = true; # use grub
      efiSupport = true; # with support for efi
      device = "nodev"; # not in the efi partition
    };
    efi = {
      canTouchEfiVariables = false; # dont change bootloader
      efiSysMountPoint = "/boot/efi"; # efi is mounted here
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/50867688-316b-4aec-b263-25154ba16703";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/3052-EBC5";
    fsType = "vfat";
  };

  swapDevices = [ ];

  nix.maxJobs = 8;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

}
