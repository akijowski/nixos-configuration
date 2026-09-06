{
  pkgs,
  lib,
  ...
}: let
  # Data disks (exclude /dev/sda - VM system disk)
  dataDisks = [
    "/dev/sdb"
    "/dev/sdc"
    "/dev/sdd"
    "/dev/sde"
    "/dev/sdf"
    "/dev/sdg"
  ];

  # Spin-down timeout: 248 = 4 hours
  spinDownTimeout = 248; # 4 hours
in {
  environment.systemPackages = with pkgs; [
    hdparm
    smartmontools
  ];

  services.smartd = {
    enable = true;
    devices = [
      {
        device = "/dev/sdb";
      }
      {
        device = "/dev/sdc";
      }
      {
        device = "/dev/sdd";
      }
      {
        device = "/dev/sde";
      }
      {
        device = "/dev/sdf";
      }
      {
        device = "/dev/sdg";
      }
    ];
  };
  # Set HDD spin-down timer
  systemd.services.set-hdd-spin-down = {
    description = "Set HDD spin-down timer to ${toString spinDownTimeout} (4 hours)";
    after = ["local-fs.target"];
    wants = ["local-fs.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.hdparm}/bin/hdparm -S ${toString spinDownTimeout} ${lib.concatStringsSep " " dataDisks}";
      RemainAfterExit = true;
    };
  };
}
