{
  config,
  lib,
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

  nixpkgs.config.cudaSupport = true;
  # Build CUDA kernels only for the RTX 3090 instead of every supported GPU;
  # this trades cache.nixos-cuda.org hits for ~10x faster local CUDA builds.
  nixpkgs.config.cudaCapabilities = ["8.6"];

  networking.useDHCP = lib.mkDefault true;
  # disk configuration managed by disko

  services.xserver.videoDrivers = ["nvidia"];
  hardware.graphics.enable = true;

  # 10/23/2026: Bug in NixOS/patchelf utility breaks nvidia-smi - causes seg
  # fault
  # Upstream patchelf was fixed in the past couple of days, waiting for
  # nixos-unstable to pull changes.
  # https://github.com/NixOS/nixpkgs/issues/576412
  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    #
    # See: https://nixos.wiki/wiki/Nvidia#Running_Specific_NVIDIA_Driver_Versions
    # Where the latest working drivers are pinned:
    # https://github.com/NixOS/nixpkgs/blob/nixos-26.05/pkgs/os-specific/linux/nvidia-x11/default.nix#L92-L99
    # Where this hardware.nvidia is implemented:
    # https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/hardware/video/nvidia.nix#L342-L359
    #package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    #  version = "595.45.04";
    #  sha256_64bit = "sha256-zUllSSRsuio7dSkcbBTuxF+dN12d6jEPE0WgGvVOj14=";
    #  sha256_aarch64 = "sha256-jl6lQWsgF6ya22sAhYPpERJ9r+wjnWzbGnINDpUMzsk=";
    #  openSha256 = "sha256-uqNfImwTKhK8gncUdP1TPp0D6Gog4MSeIJMZQiJWDoE=";
    #  settingsSha256 = "sha256-Y45pryyM+6ZTJyRaRF3LMKaiIWxB5gF5gGEEcQVr9nA=";
    #  persistencedSha256 = "sha256-5FoeUaRRMBIPEWGy4Uo0Aho39KXmjzQsuAD9m/XkNpA=";
    #};
    powerManagement.enable = true;
  };
  hardware.nvidia-container-toolkit.enable = true;
}
