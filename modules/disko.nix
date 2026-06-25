{...}: {
  flake.diskoConfigurations = {
    devnix = import ./disko/lvm-single.nix;
    llm = import ./disko/lvm-single.nix;
  };
}
