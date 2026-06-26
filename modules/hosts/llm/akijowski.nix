{pkgs, ...}: {
  imports = [
    ../../home-manager/base.nix
    ../../home-manager/llm.nix
  ];

  home.packages = [
    pkgs.llama-cpp
    pkgs.llama-swap
  ];

  home.stateVersion = "26.05";
}
