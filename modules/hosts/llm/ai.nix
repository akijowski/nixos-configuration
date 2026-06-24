{pkgs, ...}: {
  # --- llama-swap --- #
  # Transparent proxy for automatic model swapping with llama.cpp
  # https://github.com/mostlygeek/llama-swap
  #

  environment.etc."llama-swap/config.yaml".text = ''
    # llama-swap configuration
    # This config uses llama.cpp's server to serve models on demand

    #models:  # Ordered from newest to oldest

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
