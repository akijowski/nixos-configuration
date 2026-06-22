{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations = {
    devnix = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/devnix/configuration.nix
        inputs.disko.nixosModules.disko
        #inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.home-manager
        self.nixosModules.userModule
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit inputs;};
          home-manager.backupFileExtension = "backup";
          home-manager.overwriteBackup = true;
          home-manager.sharedModules = [
            inputs.sops-nix.homeManagerModules.sops
          ];
        }
        {
          nixpkgs.config.allowUnfree = true;
        }
      ];
    };
  };
}
