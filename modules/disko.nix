{...}: {
  flake.diskoConfigurations = {
    devnix = import ./hosts/devnix/disk-config.nix;
    llm = import ./hosts/llm/disk-config.nix;
  };
}
