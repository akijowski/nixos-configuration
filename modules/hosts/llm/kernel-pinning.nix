{stable, ...}: {
  nixpkgs.overlays = [
    (_final: prev: {
      boot =
        prev.boot
        // {
          kernelPackages = stable.linuxPackages_latest;
        };
    })
  ];
}
