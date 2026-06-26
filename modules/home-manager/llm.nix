{...}: {
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
                context = 128000;
                output = 65536;
              };
            };
            "gemma-4:26B-q4" = {
              name = "Gemma4 26B (local)";
              limit = {
                context = 128000;
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
}
