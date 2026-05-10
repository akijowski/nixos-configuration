{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations = {
    devbox = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ../configuration.nix
        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit inputs;};
        }
        {
          home-manager.users.akijowski = ../akijowski.nix;
        }
      ];
    };
  };
}
