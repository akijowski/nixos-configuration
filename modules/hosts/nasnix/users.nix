{config, ...}: {
  imports = [
    ../../common-users.nix
  ];

  home-manager.users.akijowski = ./akijowski.nix;

  users.groups = {
    sambaetc = {gid = 1200;};
    # autoripm/fileflows
    fileencode = {gid = 1400;};
    plex = {gid = 1800;};
    proxmox = {gid = 2000;};
    k3s = {gid = 2200;};
    nomad = {gid = 2400;};
    smbgames = {gid = 2600;};
  };
  # Make the samba user "samba_games" on the system
  users.users = {
    samba_games = {
      description = "Write-access to samba shares games";
      uid = 2600;
      createHome = false;
      extraGroups = [config.users.groups.smbgames.name];
      hashedPasswordFile = config.sops.secrets.samba_games_password_hash.path;
      isNormalUser = true;
    };
  };
}
