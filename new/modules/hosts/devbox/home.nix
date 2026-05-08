{ self, inputs, ... }: {

  # This is your standalone home-manager configuration, meant to be used on non-nixos machines
  # with the home-manager command
  flake.homeConfigurations.akijowski = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
    modules = [
      self.homeModules.akijowskiModule
      {
        home.username = "akijowski";
        home.homeDirectory = "/home/akijowski";
      }
    ];
  };

  # This is your home.nix, your module where you configure home-manager
  # It's imported both in standalone configuration above, and in your nixos configuration
  flake.homeModules.akijowskiModule = { pkgs, ... }: {
    programs = {
      zsh = {
        enable = true;
        shellAliases = {
          ll = "ls -la";
          ".." = "cd ..";
        };
        syntaxHighlighting.enable = true;
        oh-my-zsh = {
          enable = true;
          theme = "agnoster";
          plugins = [ "git" "sudo" ];
        };
      };

      # let home-manager install and manage itself
      home-manager.enable = true;
    };

    home.packages = [ pkgs.hello ];
    home.stateVersion = "25.11";
  };

}
