{pkgs, ...}: {
  # --- Podman --- #
  # Used to run Invoke.AI (see ai.nix)
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      # create a docker compat so 'docker' is an alias
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  environment.systemPackages = with pkgs; [
    podman-tui
  ];
}
