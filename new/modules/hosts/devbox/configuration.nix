{ self, inputs, ...}: {
  # This is configuration.nix for system configuration
  flake.nixosModules.devboxModule = {pkgs, ... }: {
    environment = {
      variables = {
        EDITOR = "vim";
      };
      systemPackages = with pkgs; [
        vim
        wget
        gitFull
        htop
        dig
        jq
        yq-go
        _1password-cli
      ];
    };

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "1password-cli"
    ];

    programs = {
      zsh.enable = true;
      nix-ld.enable = true;
    };

    networking = {
      hostName = "devbox";
      networkmanager.enable = true;
      firewall = {
        enable = true;
      };
    };

    time.timeZone = "America/Denver";

    users.users.akijowski = {
      isNormalUser = true;
      description = "Adam Kijowski";
      initialPassword = "password";
      home = "/home/akijowski";
      shell = pkgs.zsh;
      extraGroups = [ "wheel" "networkmanager" ];
    };

    home-manager.users.akijowski = self.homeModules.akijowskiModule;

    services = {
      openssh.enable = true;
      qemuGuest.enable = true;
    };

    nix = {
      optimise.automatic = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 15d";
      };
      settings = {
        experimental-features = [ "nix-command" "flakes"];
        trusted-users = ["root" "akijowski"];
      };
    };

    system = {
      autoUpgrade = {
        enable = true;
        allowReboot = true;
      };
    };

    system.stateVersion = "25.11";
  };
}

