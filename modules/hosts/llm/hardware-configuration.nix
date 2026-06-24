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

  boot.initrd.kernelModules = ["dm-snapshot"];
  # force nvidia modules to be loaded
  # nvidia_udm is managed automatically so should not be installed here
  # setting server.xserver.enable = true; will apply these kernel modules
  # but we do not need the entire xserver module, just nvidia drivers
  # https://github.com/NixOS/nixpkgs/blob/26.05/nixos/modules/hardware/video/nvidia.nix#L820-L824
  # Do not add nvidia_udm:
  # https://github.com/NixOS/nixpkgs/blob/26.05/nixos/modules/hardware/video/nvidia.nix#L438
  boot.kernelModules = ["kvm-amd" "nvidia" "nvidia_modeset" "nvidia_drm"];
  # add nvidia x11 drivers
  # TODO: not sure if needed
  # https://nixos.wiki/wiki/Nvidia#Booting_to_Text_Mode
  boot.extraModulePackages = [config.boot.kernelPackages.nvidia_x11_beta];

  # TODO: look in to this, I think it is for Prime configurations only
  #boot.kernelParams = ["nvidia_drm.fbdev=1" "nvidia.NVreg_UsePageAttributeTable=1" ];

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
  hardware.nvidia-container-toolkit.enable = true;
}
