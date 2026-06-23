{
  self,
  inputs,
  ...
}: {
  # Import modules
  imports = [
    ./settings.nix
    ./home-manager.nix
    ./users.nix
    ./disko.nix
  ];

  flake.nixosConfigurations = let
    defaultModules = [
      self.nixosModules.vmModule
      self.nixosModules.tailscaleModule
      self.nixosModules.userModule
      self.nixosModules.systemModule
      self.nixosModules.homeManagerModule
      inputs.disko.nixosModules.disko
      #inputs.sops-nix.nixosModules.sops
      inputs.home-manager.nixosModules.home-manager
      {
        nixpkgs.config.allowUnfree = true;
      }
    ];
  in {
    devnix = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        defaultModules
        ++ [
          ./hosts/devnix/configuration.nix
          self.diskoConfigurations.devnix
        ];
    };
    llm = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        defaultModules
        ++ [
          ./hosts/llm/configuration.nix
          self.diskoConfigurations.llm
        ];
    };
  };
}
