{ config, lib, pkgs, ... }:

{
  # use throttled to not throttle CPU early (thanks Lenovo)
  services.throttled.enable = true;

  # we dont need full performance all the time - it's a laptop
  powerManagement.cpuFreqGovernor = lib.mkForce "powersave";

  # use thinkfan to actually use the fans (thanks again Lenovo)
  services.thinkfan = {
    enable = true;
    fan = ''
      fans:
        - tpacpi: /proc/acpi/ibm/fan
    '';
    sensors = ''
      sensors:
        - hwmon: /sys/devices/platform/coretemp.0/hwmon
          indices: [1, 2, 3, 4, 5]

        #- hwmon: /sys/devices/virtual/thermal/thermal_zone0/hwmon0
        #  indices: [1]
        #  optional: true
    '';
    levels = ''
      levels:
        - [0,     0,      50]
        - ["level auto",     45,     85]
        - ["level disengaged",   80,     255]
    '';
  };
}
