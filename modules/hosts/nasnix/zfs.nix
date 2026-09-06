{
  services.zfs.autoScrub = {
    enable = true;
    pools = [
      "tank1600"
      "tank0400"
    ];
    # Monthly tank scrubs
    interval = "*-*-01 02:00:00";
    randomizedDelaySec = "15min";
  };
}
