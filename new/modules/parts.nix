{inputs, ...}: {
  imports = [
    # adds home-manager options to flake-parts
    inputs.home-manager.flakeModules.home-manager
    # adds disko options
    inputs.disko.flakeModules.default
  ];
}

