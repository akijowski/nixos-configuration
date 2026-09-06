{
  # Allow NFS and RPC services
  networking.firewall.allowedTCPPorts = [111 2049 20048 32768 32767 875];
  networking.firewall.allowedUDPPorts = [111 2049 20048 32768 32767 875];

  services.nfs.server = {
    enable = true;
    # Fix ports for firewall configuration
    mountdPort = 20048;
    lockdPort = 32768;
    statdPort = 32767;

    exports = {
      "/mnt/tank1600/plex/libraries/audio/music" = {
        "192.168.50.0/24" = ["rw" "all_squash" "anonuid=1800" "anongid=1800"];
        "10.10.10.0/24" = ["rw" "all_squash" "anonuid=1800" "anongid=1800"];
        "172.17.6.0/24" = ["rw" "all_squash" "anonuid=1800" "anongid=1800"];
      };
      "/mnt/tank1600/plex/libraries/video/movies" = {
        "192.168.50.0/24" = ["rw" "all_squash" "anonuid=1800" "anongid=1800"];
        "10.10.10.0/24" = ["rw" "all_squash" "anonuid=1800" "anongid=1800"];
        "172.17.6.0/24" = ["rw" "all_squash" "anonuid=1800" "anongid=1800"];
      };
      "/mnt/tank1600/plex/libraries/video/uhd-movies" = {
        "192.168.50.0/24" = ["rw" "all_squash" "anonuid=1800" "anongid=1800"];
        "10.10.10.0/24" = ["rw" "all_squash" "anonuid=1800" "anongid=1800"];
        "172.17.6.0/24" = ["rw" "all_squash" "anonuid=1800" "anongid=1800"];
      };
      "/mnt/tank1600/plex/libraries/video/tv-shows" = {
        "192.168.50.0/24" = ["rw" "all_squash" "anonuid=1800" "anongid=1800"];
        "10.10.10.0/24" = ["rw" "all_squash" "anonuid=1800" "anongid=1800"];
        "172.17.6.0/24" = ["rw" "all_squash" "anonuid=1800" "anongid=1800"];
      };
      "/mnt/tank1600/plex/libraries/video/9round" = {
        "192.168.50.0/24" = ["rw" "all_squash" "anonuid=1800" "anongid=1800"];
        "10.10.10.0/24" = ["rw" "all_squash" "anonuid=1800" "anongid=1800"];
        "172.17.6.0/24" = ["rw" "all_squash" "anonuid=1800" "anongid=1800"];
      };
      "/mnt/tank1600/plex/metadata" = {
        "192.168.50.0/24" = ["rw" "all_squash" "anonuid=1800" "anongid=1800"];
        "10.10.10.0/24" = ["rw" "all_squash" "anonuid=1800" "anongid=1800"];
        "172.17.6.0/24" = ["rw" "all_squash" "anonuid=1800" "anongid=1800"];
      };

      "/mnt/tank0400/proxmox/storage-iso" = {
        "172.17.6.0/24" = ["rw" "all_squash" "anonuid=2000" "anongid=2000"];
      };
    };
  };
}
