{ config, pkgs, lib, inputs, ... }:

{
  sops = {
    age.keyFile = "/home/admin/.config/sops/age/keys.txt";
    age.generateKey = false;
    defaultSopsFile = ../../../secrets/admin_user.yaml;
    secrets = {
      onepass_svc_acct_nixos = {
        # default will be symlinked at ~/.config/sops-nix/secrets/<name>
        #path = "%r/onepass_svc_acct.txt";
      };
    };
  };
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "admin";
  home.homeDirectory = "/home/admin";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello
    # todo: remove devbox
    pkgs.devbox
    # https://discourse.nixos.org/t/installing-only-a-single-package-from-unstable/5598/28
    # https://wiki.nixos.org/wiki/FAQ/Pinning_Nixpkgs
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.devenv
    pkgs.go-task

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/root/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "vscode"
  ];

  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
      ".." = "cd ..";
      sudo-env = "sudo -E";
      nixos-update = "sudo nixos-rebuild switch --flake /home/nixos/#";
      nixos-clean = "sudo nix-collect-garbage --delete-older-than 15d";
    };
    # https://zohaib.me/managing-secrets-in-nixos-home-manager-with-sops/
    # initContent = ''
    #   export OP_SERVICE_ACCOUNT_TOKEN=$(cat
    #   ${config.sops.secrets.onepass_svc_acct_nixos.path})
    # '';
    envExtra = ''
      export OP_SERVICE_ACCOUNT_TOKEN=$(cat ~/.config/sops-nix/secrets/onepass_svc_acct_nixos)
    '';
    syntaxHighlighting = {
      enable = true;
    };
    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git" "sudo" ];
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

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
