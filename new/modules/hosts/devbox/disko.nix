{ self, ...}: {
  flake.nixosModules.devboxDiskoModule = { pkgs, ... }: {
    disko.devices = {
      disk = {
        sda = {
          type = "disk";
          device = "/dev/sda";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                type = "EF00";
                size = "512M";
                label = "EFI-DEV";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              primary = {
                size = "100%";
                label = "ROOT-DEV";
                content = {
                  type = "lvm_pv";
                  vg = "vg-main";
                };
              };
            };
          };
        };
      };
    lvm_vg = {
      vg-main = {
        type = "lvm_vg";
        lvs = {
          swap = {
            size = "8G";
            content = {
              type = "swap";
            };
          };
          nix = {
            size = "50G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/nix";
              mountOptions = [
                "noatime" # Reduce writes, access time is not necessary
              ];
            };
          };
          root = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [
                "defaults"
              ];
            };
          };
        };
      };
    };
  };
};
}

