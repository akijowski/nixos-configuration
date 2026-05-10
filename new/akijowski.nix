{
  config,
  pkgs,
  lib,
  ...
}: let
  concatWith = lib.strings.concatStringsSep;
  link = config.lib.file.mkOutOfStoreSymlink; # home-manager helper function
in {
  home.username = "akijowski";
  home.homeDirectory = "/home/akijowski";

  home.file.".nixos" = {
    source = link /etc/nixos;
    recursive = true;
    onChange = concatWith "\n" ["sudo chown -R akijowski:users ${config.home.homeDirectory}/.nixos"];
  };

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    settings = {
      user.name = "Adam Kijowski";
      user.email = "agkijow@gmail.com";
    };
  };

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
