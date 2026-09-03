{...}: {
  flake.diskoConfigurations = {
    devnix = import ./disko/vm-lvm-single.nix;
    llm = import ./disko/vm-lvm-single.nix;
    nasnix = import ./disko/vm-lvm-single.nix;
  };
}
