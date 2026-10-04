{pkgs, ...}: let
  llamaSwapConfig = import ./llama-swap-config.yaml.nix {inherit pkgs;};
in {
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

  environment.etc."llama-swap/config.yaml".text = llamaSwapConfig;

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

  # --- Invoke.AI --- #
  # Open source image generation software

  # see containers.nix
  virtualisation.oci-containers.containers.invokeai = {
    # https://github.com/invoke-ai/InvokeAI/pkgs/container/invokeai
    image = "ghcr.io/invoke-ai/invokeai:sha-4432fa5-cuda@sha256:73d2ad054fe1888974a5430b3cbb7ca538fef5a4a6d1983b4f307163fde86bf1";
    ports = ["9090:9090"];
    devices = ["nvidia.com/gpu=all"];
    volumes = [
      "invokeai:/invokeai"
    ];
  };

  # --- Tailscale Serve --- #
  # Expose these services to the Tailnet
  # https://tailscale.com/docs/features/tailscale-services
  # TODO: This does not seem to be working correctly for HTTPS
  # Manually made the services with `tailscale serve --service=<> --https=443 <>`

  #environment.etc."tailscale-serve/services.json".text = ''
  #  {
  #    "version": "0.0.1",
  #    "services": {
  #      "svc:invoke-ai": {
  #        "endpoints": {
  #          "tcp:443": "http://localhost:9090"
  #         }
  #       },
  #       "svc:llama-swap": {
  #         "endpoints": {
  #           "tcp:443": "http://localhost:9292"
  #         }
  #       }
  #     }
  #   }
  #'';

  #services.tailscale.serve = {
  #  enable = true;
  #  configFile = "/etc/tailscale-serve/services.json";
  #};
}
