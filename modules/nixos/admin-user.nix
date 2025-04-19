# Nix module
# Create an Admin user

{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.admin-user;
in
{
  options.admin-user = {
   enable = lib.mkEnableOption "enable admin user";
   userName = lib.mkOption {
     default = "admin";
     description = ''
       username
     '';
   };
  };
  config = lib.mkIf cfg.enable {
    users.users.${cfg.userName} = {
      isNormalUser = true;
      initialPassword = "password";
      description = "admin user";
      createHome = true;
      home = "/home/${cfg.userName}";
      extraGroups = [ "wheel" "networkmanager" ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keyFiles = [ inputs.ssh-keys-gh.outPath ];
      # openssh.authorizedKeys.keys = let
      #   authKeys = pkgs.fetchurl {
      #     url = "https://github.com/akijowski.keys";
      #     hash = "sha256-ButVfHhoXm6LOqGOiYTLa8ahf6FhZq2wBYt757v6WvI=";
      #   };
      # in pkgs.lib.splitString "\n" (builtins.readFile authKeys);
    };
  };
}

