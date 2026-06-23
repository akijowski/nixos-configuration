{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/qemu-guest.nix
    (modulesPath + "/profiles/qemu-guest.nix")
    # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/scan/not-detected.nix
    # Enables non-free packages (like Nvidia drivers)
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "uhci_hcd"
    "ehci_pci"
    "ahci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];
  # force nvidia modules to be loaded
  # nvidia_udm is managed automatically so should not be installed here
  # This should have been handled automatically but was not
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/hardware/video/nvidia.nix#L445
  boot.initrd.kernelModules = ["dm-snapshot" "nvidia" "nvidia_modeset"
"nvidia_drm"];
  boot.kernelModules = ["kvm-amd"];
  # add nvidia x11 drivers
  # TODO: not sure if needed
  # https://nixos.wiki/wiki/Nvidia#Booting_to_Text_Mode
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11_beta ];

  # TODO: look in to this
  boot.kernelParams = ["nvidia_drm.fbdev=1"
"nvidia.NVreg_UsePageAttributeTable=1" ];

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.useDHCP = lib.mkDefault true;
  # disk configuration managed by disko

  services.xserver.videoDrivers = ["nvidia"];
  hardware.graphics.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    powerManagement.enable = true;
  };
  #hardware.nvidia-container-toolkit.enable = true;
}
