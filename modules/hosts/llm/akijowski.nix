{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../home-manager/base.nix
  ];

  programs.opencode = {
    enable = true;
    settings = {
      autoshare = false;
      autoupdate = true;
      provider = {
        "llama.cpp" = {
          npm = "@ai-sdk/openai-compatible";
          name = "llama-swap (local)";
          options = {
            baseURL = "http://localhost:9292/v1";
          };
          models = {
            "qwen3.6:27B-q4" = {
              name = "Qwen3.6 27B (local)";
              limit = {
                context = 128000;
                output = 65536;
              };
            };
          };
        };
      };
    };
  };

  home.packages = [
    pkgs.llama-cpp
    pkgs.llama-swap
  ];

  home.stateVersion = "26.05";
}
