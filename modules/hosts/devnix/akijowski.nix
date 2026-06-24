{
  config,
  pkgs,
  lib,
  ...
}: {
  home.username = "akijowski";
  home.homeDirectory = "/home/akijowski";

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      side-by-side = true;
      hyperlinks = true;
    };
  };

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    settings = {
      user.name = "Adam Kijowski";
      user.email = "agkijow@gmail.com";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      cmd_duration = {
        min_time = 500;
      };
      directory = {
        fish_style_pwd_dir_length = 2;
      };
    };
  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "sudo"];
    };
    # https://zohaib.me/managing-secrets-in-nixos-home-manager-with-sops/
    # initContent = ''
    #   export OP_SERVICE_ACCOUNT_TOKEN=$(cat
    #   ${config.sops.secrets.onepass_svc_acct_nixos.path})
    # '';
    envExtra = ''
      export OP_SERVICE_ACCOUNT_TOKEN=$(cat ${config.sops.secrets.onepass_svc_acct_nixos.path})
    '';
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      hashicorp.terraform
    ];
    # profiles = {
    #   admin = {
    #     enableExtensionUpdateCheck = true;
    #     extensions = with pkgs.vscode-extensions; [
    #       hashicorp.terraform
    #     ];
    #   };
    # };
  };
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    age.generateKey = false;
    defaultSopsFile = ../../../secrets/secrets.yaml;
    secrets = {
      onepass_svc_acct_nixos = {format = "yaml";};
    };
  };

  # https://discourse.nixos.org/t/installing-only-a-single-package-from-unstable/5598/28
  home.packages = [
    pkgs.go-task
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

  programs.home-manager.enable = true;
}
