{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../home-manager/base.nix
  ];

  programs.zsh.envExtra = ''
    export OP_SERVICE_ACCOUNT_TOKEN=$(cat ${config.sops.secrets.onepass_svc_acct_nixos.path})
  '';

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      hashicorp.terraform
    ];
  };

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    age.generateKey = false;
    defaultSopsFile = ../../../secrets/secrets.yaml;
    secrets = {
      onepass_svc_acct_nixos = {format = "yaml";};
    };
  };

  home.packages = [
    pkgs.devenv
    pkgs.secretspec
  ];

  xdg.configFile."direnv/direnv.toml" = {
    enable = true;
    text = ''
      [global]
      warn_timeout = "3m"
    '';
  };

  home.stateVersion = "25.11";
}
