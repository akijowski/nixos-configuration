{...}: {
  imports = [
    ../../common-users.nix
  ];

  home-manager.users.akijowski = ./akijowski.nix;
}
