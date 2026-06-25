{pkgs, ...}: {
  # --- llama-swap --- #
  # Transparent proxy for automatic model swapping with llama.cpp
  # https://github.com/mostlygeek/llama-swap
  #

  # Harness-friendly fork of Qwen's Qwen3.6 chat template, tuned for agentic
  # coding harnesses (preserve_thinking + unwrap_tool_envelope defaults flipped).
  # Source: https://gist.github.com/jscott3201/e4b155885cc68c038d6ac8909a3bd9fe
  environment.etc."llama-templates/qwen36-custom.jinja".source = pkgs.fetchurl {
    url = "https://gist.githubusercontent.com/jscott3201/e4b155885cc68c038d6ac8909a3bd9fe/raw/a9c457e1c0c9d91f11babff2164ac8c9f9ea8476/custom_pub_chat_template_qwen36.jinja";
    sha256 = "sha256-JT+jJ8Uk3ZtFOaYUVFZyTeR9+o969x7C6KL0Leth9Uk=";
  };

  environment.etc."llama-swap/config.yaml".text = ''
    # llama-swap configuration
    # This config uses llama.cpp's server to serve models on demand

    models:  # Ordered from newest to oldest

      # size 16.7 GB, max ctx: 262144, layers: 65
      # Qwen3.6 aliases keep mmproj enabled and speculative MTP disabled
      # https://huggingface.co/unsloth/Qwen3.6-27B-MTP-GGUF
      "qwen3.6:27B-q4":
        cmd: |
          ${pkgs.llama-cpp}/bin/llama-server
          --hf-repo unsloth/Qwen3.6-27B-MTP-GGUF
          --hf-file Qwen3.6-27B-UD-Q4_K_XL.gguf
          --mmproj-url https://huggingface.co/unsloth/Qwen3.6-27B-MTP-GGUF/resolve/main/mmproj-F16.gguf
          --chat-template-file /etc/llama-templates/qwen36-custom.jinja
          --port ''${PORT}
          --ctx-size 0
          --fit on
          --fit-target 2048
          --fit-ctx 16384
          --parallel 1
          --batch-size 2048
          --ubatch-size 512
          --flash-attn on
          --cache-type-k q8_0
          --cache-type-v q8_0
          --split-mode layer
          --threads 1
          --jinja

    healthcheckTimeout: 28800 # 8 hours for large model download + loading
    # TTL keeps models in memory for specified seconds after last use
    ttl: 3600  # Keep models loaded for 1 hour (like OLLAMA_KEEP_ALIVE)
  '';

  systemd.services.llama-swap = {
    description = "llama-swap - OpenAI compatible proxy with automatic model swapping";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      User = "akijowski";
      Group = "users";
      ExecStart = "${pkgs.llama-swap}/bin/llama-swap --config /etc/llama-swap/config.yaml --listen 0.0.0.0:9292 --watch-config";
      Restart = "always";
      RestartSec = 10;
      # Environment for CUDA support
      Environment = [
        "PATH=/run/current-system/sw/bin"
        "LD_LIBRARY_PATH=/run/opengl-driver/lib:/run/opengl-driver-32/lib"
      ];
      # Environment needs access to cache directories for model downloads
      # Simplified security settings to avoid namespace issues
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };
}
