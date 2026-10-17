{config, ...}: {
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "%h server (Samba)";
        "netbios name" = "%h server";
        "server role" = "standalone";
        "hosts allow" = "10.10.10. 192.168.50. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";

        "guest account" = "nobody";
        "admin users" = "root";
        "map to guest" = "bad user";
        "restrict anonymous" = "2";
        "security" = "user";

        "log file" = "/var/log/samba/samba.log";
        "max log size" = "1000";

        "vfs objects" = "fruit streams_xattr";

        "fruit:aapl" = "yes";
        "fruit:model" = "iMacPro1,1";
        "fruit:metadata" = "stream";
        "fruit:veto_appledouble" = "yes";
        "fruit:posix_rename" = "yes";
        "fruit:zero_file_id" = "yes";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
        "fruit:advertise_fullsync" = "true";

        "veto files" = "/._*/.DS_Store/.Trashes/.TemporaryItems";
        "delete veto files" = "yes";

        "socket options" = "SO_KEEPALIVE TCP_NODELAY IPTOS_LOWDELAY";
        "server signing" = "no";
        "ea support" = "yes";
        "read raw" = "yes";
        "write raw" = "yes";
        "strict locking" = "no";
        "oplocks" = "yes";
        "deadtime" = "15";
        "getwd cache" = "yes";
        "max xmit" = "65535";
        "use sendfile" = "true";
        "aio read size" = "16384";
        "aio write size" = "16384";
      };
      games = {
        "path" = "/mnt/tank0400/samba/games";
        "comment" = "samba games folder shares";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "${config.users.users.samba_games.name}";
        "force group" = "${config.users.groups.smbgames.name}";
        "valid users" = "${config.users.users.samba_games.name}";
      };
    };
  };

  # TODO: Re-evaluate this approach. Need to try to run as root
  # for now: sudo smbpasswd -a samba_games
  ## Activation scripts run every time nixos switches build profiles. So if you're
  ## pulling the user/samba password from a file then it will be updated during
  ## nixos-rebuild. Again, in this example we're using sops-nix with a "samba" entry
  ## to avoid cleartext password, but this could be replaced with a static path.
  #system.activationScripts = {
  #  # The "init_smbpasswd" script name is arbitrary, but a useful label for tracking
  #  # failed scripts in the build output. An absolute path to smbpasswd is necessary
  #  # as it is not in $PATH in the activation script's environment. The password
  #  # is repeated twice with newline characters as smbpasswd requires a password
  #  # confirmation even in non-interactive mode where input is piped in through stdin.
  #  init_smbpasswd.text = ''
  #    /run/current-system/sw/bin/printf "$(/run/wrappers/bin/sudo /run/current-system/sw/bin/cat
  #    ${config.sops.secrets.samba_games_password.path})\n$(/run/wrappers/bin/sudo /run/current-system/sw/bin/cat
  #    ${config.sops.secrets.samba_games_password.path})\n"
  #    | /run/current-system/sw/bin/smbpasswd -sa samba_games
  #  '';
  #};
}
