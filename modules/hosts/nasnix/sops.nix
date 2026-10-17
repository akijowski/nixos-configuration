{config, ...}: {
  sops = {
    # Use the static keys file in the home directory
    age.keyFile = "${config.home-manager.users.akijowski.home.homeDirectory}/.config/sops/age/keys.txt";
    age.generateKey = false;
    defaultSopsFile = ../../../secrets/secrets.yaml;
    secrets = {
      samba_games_password_hash = {
        neededForUsers = true;
      };
      samba_games_password = {};
    };
  };
}
