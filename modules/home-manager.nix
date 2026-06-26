{inputs, ...}: {
  flake.nixosModules.homeManagerModule = {...}: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = {inherit inputs;};
    home-manager.backupFileExtension = "backup";
    home-manager.overwriteBackup = true;
    home-manager.sharedModules = [
      inputs.sops-nix.homeManagerModules.sops
    ];
  };
}
