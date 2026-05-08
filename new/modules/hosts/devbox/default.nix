{ self, inputs, ...}: {

  # System configuration entry-point
  flake.nixosConfigurations.devbox = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.devboxDiskoModule
      self.nixosModules.devboxModule
      self.nixosModules.basicHomeManager
    ];
  };
}
  
