{ config, lib, pkgs, ... }:

{
  # use throttled to not throttle CPU early (thanks Lenovo)
  services.throttled.enable = true;

  # we dont need full performance all the time - it's a laptop
  powerManagement.cpuFreqGovernor = lib.mkForce "powersave";

  # use thinkfan to actually use the fans (thanks again Lenovo)
  services.thinkfan = {
    enable = true;
    sensors = ''
      hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input
      hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon5/temp2_input
      hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon5/temp3_input
      hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon5/temp4_input
      hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon5/temp5_input
    '';
    levels = ''
      (0, 0, 50)
      ("level auto", 45, 85)
      ("level disengaged", 80, 255)
    '';
  };
}
