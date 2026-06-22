{inputs, ...}: {
  imports = [
    inputs.home-manager.flakeModules.home-manager
    ./users.nix
  ];
}
