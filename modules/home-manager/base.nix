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
  };

  home.packages = lib.mkBefore [
    pkgs.go-task
  ];

  programs.home-manager.enable = true;
}
