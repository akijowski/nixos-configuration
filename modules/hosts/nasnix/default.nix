{...}: {
  imports = [
    ./configuration.nix
    ./users.nix
    ./zfs.nix
    ./nfs.nix
  ];
}
