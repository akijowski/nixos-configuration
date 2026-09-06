{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/qemu-guest.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = ["uhci_hcd" "ehci_pci" "ahci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = [
    "kvm-amd"
    # Exposes SATA drive temps as hwmon sensors
    # Can read spun-down disks safely
    "drivetemp"
  ];
  boot.extraModulePackages = [];

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  boot.supportedFilesystems = ["zfs"];
  boot.zfs = {
    devNodes = "/dev/disk/by-id";
    extraPools = [
      "tank0400"
      "tank1600"
    ];
    forceImportRoot = lib.mkForce false;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.useDHCP = lib.mkDefault true;
  # ZFS requires a stable host ID
  # Generate a static string:
  # head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "0c92833a";
  # disk configuration managed by disko
}
