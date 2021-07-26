{ config, lib, pkgs, ... }:

{
  # use throttled to not throttle CPU early (thanks Lenovo)
  services.throttled.enable = true;

  # we dont need full performance all the time - it's a laptop
  powerManagement.cpuFreqGovernor = lib.mkForce "powersave";

  # use thinkfan to actually use the fans (thanks again Lenovo)
  services.thinkfan = {
    enable = true;
    fans = [{
      type = "tpacpi";
      query = "/proc/acpi/ibm/fan";
    }];
    sensors = [{
      type = "hwmon";
      query = "/sys/devices/platform/coretemp.0/hwmon";
      indices = [ 1 2 3 4 5 ];
    }];
    levels = [ # [LEVEL LOW HIGH]
      [ 0 0 50 ]
      [ "level auto" 45 85 ]
      [ "level full-speed" 80 255 ]
    ];
  };
}
