{pkgs, ...}: {
  users.users.akijowski = {
    isNormalUser = true;
    description = "Adam Kijowski";
    extraGroups = ["wheel" "networkmanager"];
    initialPassword = "password123";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbCjI+CHR4DJAjZk8zfhcvs/cKks5SFarnI65qTGouk akijowski@mbp14"
    ];
  };
}
