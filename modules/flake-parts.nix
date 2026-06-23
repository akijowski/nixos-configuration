{inputs, ...}: {
  imports = [
    inputs.home-manager.flakeModules.home-manager
    inputs.disko.flakeModules.default
  ];
}
