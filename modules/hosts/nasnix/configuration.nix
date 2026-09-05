{...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "nasnix";

  system.stateVersion = "26.05";
}
