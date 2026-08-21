{
  pkgs,
  lib,
  config,
  ...
}: {
  # --- OpenCode --- #
  programs.opencode = {
    enable = true;
    settings = {
      autoshare = false;
      autoupdate = true;
      default_agent = "plan";
      enabled_providers = ["llama.cpp"];
      provider = {
        "llama.cpp" = {
          npm = "@ai-sdk/openai-compatible";
          name = "llama-swap (local)";
          options = {
            # use the Tailscale service (see hosts/llm/ai.nix)
            baseURL = "https://llama-swap.tail1936d9.ts.net/v1";
          };
          models = {
            "qwen3.6:27B-q4" = {
              name = "Qwen3.6 27B (local)";
              limit = {
                context = 65536;
                output = 65536;
              };
            };
            "gemma-4:26B-q4" = {
              name = "Gemma4 26B (local)";
              limit = {
                context = 262144;
                output = 65536;
              };
            };
            "ornith-1:35B-q4" = {
              name = "Ornith v1 35B (local)";
              limit = {
                context = 262144;
                output = 65536;
              };
            };
          };
        };
      };
    };
    tui = {
      theme = "tokyonight";
    };
  };
  # --- Herdr --- #
  programs.herdr = {
    enable = true;
    settings = {
      theme.name = "rose-pine";
      keys = {
        prefix = "ctrl+a";
        split_vertical = "prefix+%";
        split_horizontal = "prefix+shift+'";
      };
    };
  };

  # --- Herdr Agent Skill --- #
  home.file.".agents/skills/herdr/SKILL.md" =
    lib.mkIf
    (config.programs.opencode.enable && config.programs.herdr.enable)
    {
      source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/herdrdev/herdr/v0.8.0/skills/herdr/SKILL.md";
        sha256 = "17xjkpxx1w9ari1pcczw1g1skl8l8sgdg0lxw042gygb08pii1h7";
      };
    };
}
