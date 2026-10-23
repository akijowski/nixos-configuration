{
  self,
  inputs,
  ...
}: {
  imports = [
    ./settings.nix
    ./home-manager.nix
    ./disko.nix
  ];

  flake.nixosConfigurations = let
    defaultModules = [
      self.nixosModules.vmModule
      self.nixosModules.tailscaleModule
      self.nixosModules.systemModule
      self.nixosModules.homeManagerModule
      inputs.disko.nixosModules.disko
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
          ./hosts/devnix
          self.diskoConfigurations.devnix
        ];
    };
    llm = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit (inputs) stable;
      };
      modules =
        defaultModules
        ++ [
          ./hosts/llm
          self.diskoConfigurations.llm
        ];
    };
    nasnix = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        defaultModules
        ++ [
          ./hosts/nasnix
          # uses sops outside of home-manager
          inputs.sops-nix.nixosModules.sops
          self.diskoConfigurations.nasnix
        ];
    };
  };
}
