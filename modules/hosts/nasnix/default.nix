{...}: {
  imports = [
    ./configuration.nix
    ./sops.nix
    ./users.nix
    ./zfs.nix
    ./nfs.nix
    ./samba.nix
    ./power.nix
  ];
}
