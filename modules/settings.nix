{...}: {
  flake.nixosModules.systemModule = {...}: {
    system.autoUpgrade = {
      enable = true;
      allowReboot = true;
    };

    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 15d";
      };
      optimise.automatic = true;
      settings = {
        experimental-features = ["nix-command" "flakes"];
        trusted-users = ["root" "akijowski"];
      };
    };
  };

  flake.nixosModules.vmModule = {pkgs, ...}: {
    # Configure network connections interactively with nmcli or nmtui.
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "America/Denver";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    # List packages installed in system profile.
    # You can use https://search.nixos.org/ to find more packages (and options).
    environment.systemPackages = with pkgs; [
      gitFull
      # Baseline vim configuration
      # https://nixos.wiki/wiki/Vim
      ((vim-full.override {}).customize {
        name = "vim";
        vimrcConfig.customRC = builtins.readFile ./files/vimrc;
      })
      wget
      just
      htop
      dig
      jq
      yq-go
      pciutils
    ];

    environment.variables = {
      EDITOR = "vim";
    };

    programs = {
      zsh.enable = true;
      nix-ld.enable = true;
      direnv = {
        enable = true;
        enableZshIntegration = true;
      };
      _1password.enable = true;
    };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = ["akijowski"];
      };
    };
    services.qemuGuest.enable = true;
  };

  flake.nixosModules.tailscaleModule = {config, ...}: {
    # https://wiki.nixos.org/wiki/Tailscale
    services.tailscale.enable = true;

    networking = {
      nftables.enable = true;
      firewall = {
        enable = true;
        # Always allow traffic from your Tailscale network
        trustedInterfaces = [config.services.tailscale.interfaceName];
        # Allow the Tailscale UDP port through the firewall
        allowedUDPPorts = [config.services.tailscale.port];
      };
    };

    systemd.services.tailscaled.serviceConfig.Environment = [
      "TS_DEBUG_FIREWALL_MODE=nftables"
    ];
  };
}
