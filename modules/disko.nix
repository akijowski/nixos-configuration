{...}: {
  flake.diskoConfigurations = {
    devnix = ./hosts/devnix/disk-config.nix;
    llm = ./hosts/llm/disk-config.nix;
  };
}
