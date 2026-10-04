{pkgs}: ''
  # llama-swap configuration
  # This config uses llama.cpp's server to serve models on demand

  models:  # Ordered from newest to oldest

  # https://huggingface.co/unsloth/Qwen3.8-27B-GGUF
    "qwen3.8:27B-q4":
      cmd: |
        ${pkgs.llama-cpp}/bin/llama-server
        --hf-repo unsloth/Qwen3.8-27B-GGUF
        --hf-file Qwen3.8-27B-UD-Q4_K_XL.gguf
        --port ''${PORT}
        --n-gpu-layers 99
        --ctx-size 0
        --fit on
        --fit-target 512
        --fit-ctx 65536
        --parallel 1
        --batch-size 2048
        --ubatch-size 1024
        --flash-attn on
        --cache-type-k q8_0
        --cache-type-v q8_0
        --temp 1.0
        --top-p 0.95
        --top-k 20
        --min-p 0
        #--split-mode layer
        --threads 2
        --jinja

  # Another thinking coding model
  # Settings based on typical qwen3.5 model as a start
  # Based on:
  # https://huggingface.co/ornith-ai/Ornith-1.0-35B
    "ornith-1:35B-q4":
      cmd: |
        ${pkgs.llama-cpp}/bin/llama-server
        --hf-repo bartowski/deepreinforce-ai_Ornith-1.0-35B-GGUF
        --hf-file deepreinforce-ai_Ornith-1.0-35B-Q4_1.gguf
        --port ''${PORT}
        --ctx-size 0
        --fit on
        --fit-target 2048
        --fit-ctx 262144
        --parallel 1
        --batch-size 2048
        --ubatch-size 512
        --flash-attn on
        --cache-type-k q8_0
        --cache-type-v q8_0
        --threads 2
        --jinja

    # QAT GGUF. Source: https://huggingface.co/unsloth/gemma-4-26B-A4B-it-qat-GGUF
    # Using MTP to see if there are improvements
    # Unsloth recommends UD-Q4_K_XL with temp=1.0, top_p=0.95, top_k=64.
    "gemma-4:26B-q4":
      cmd: |
        ${pkgs.llama-cpp}/bin/llama-server
        --hf-repo unsloth/gemma-4-26B-A4B-it-qat-GGUF
        --hf-file gemma-4-26B-A4B-it-qat-UD-Q4_K_XL.gguf
        --mmproj-url https://huggingface.co/unsloth/gemma-4-26B-A4B-it-qat-GGUF/resolve/main/mmproj-F16.gguf
        --spec-type draft-mtp
        --spec-draft-n-max 4
        --port ''${PORT}
        --ctx-size 0
        --fit on
        --fit-target 2048
        --fit-ctx 262144
        --parallel 1
        --batch-size 2048
        --ubatch-size 512
        --flash-attn on
        --cache-type-k q8_0
        --cache-type-v q8_0
        #--split-mode layer
        --temp 1.0
        --top-p 0.95
        --top-k 64
        --threads 1
        #--chat-template-kwargs '{"enable_thinking": true}'
        --reasoning on
        --jinja

    # QAT GGUF. Source: https://huggingface.co/unsloth/gemma-4-31B-it-qat-GGUF
    # Unsloth recommends UD-Q4_K_XL with temp=1.0, top_p=0.95, top_k=64.
    # Gemma 4 31B supports a 262144-token context window.
    # Ran too slow for now, removing
    #"gemma-4:31b-q4":
    #  cmd: |
    #    ${pkgs.llama-cpp}/bin/llama-server
    #    --hf-repo unsloth/gemma-4-31B-it-qat-GGUF
    #    --hf-file gemma-4-31B-it-qat-UD-Q4_K_XL.gguf
    #    --mmproj-url https://huggingface.co/unsloth/gemma-4-31B-it-qat-GGUF/resolve/main/mmproj-F16.gguf
    #    --port ''${PORT}
    #    --ctx-size 0
    #    --fit on
    #    --fit-target 2048
    #    --fit-ctx 262144
    #    --parallel 1
    #    --batch-size 2048
    #    --ubatch-size 512
    #    --flash-attn on
    #    --cache-type-k q8_0
    #    --cache-type-v q8_0
    #    #--split-mode layer
    #    --temp 1.0
    #    --top-p 0.95
    #    --top-k 64
    #    --threads 1
    #    --chat-template-kwargs '{"enable_thinking": true}'
    #    --jinja

    # size 16.7 GB, max ctx: 262144, layers: 65
    # Qwen3.6 aliases keep mmproj enabled and speculative MTP disabled
    # https://huggingface.co/unsloth/Qwen3.6-27B-MTP-GGUF
    #"qwen3.6:27B-q4":
    #  cmd: |
    #    ${pkgs.llama-cpp}/bin/llama-server
    #    --hf-repo unsloth/Qwen3.6-27B-MTP-GGUF
    #    --hf-file Qwen3.6-27B-UD-Q4_K_XL.gguf
    #    --mmproj-url https://huggingface.co/unsloth/Qwen3.6-27B-MTP-GGUF/resolve/main/mmproj-F16.gguf
    #    --chat-template-file /etc/llama-templates/qwen36-custom.jinja
    #    --port ''${PORT}
    #    --n-gpu-layers 99
    #    --ctx-size 0
    #    --fit on
    #    --fit-target 2048
    #    --fit-ctx 65536
    #    --parallel 1
    #    --batch-size 2048
    #    --ubatch-size 512
    #    --flash-attn on
    #    --cache-type-k q8_0
    #    --cache-type-v q8_0
    #    #--split-mode layer
    #    --threads 2
    #    --jinja

  # size 0.1 GB, max ctx: 8192, layers: 30
    "smollm2:135m":
      cmd: |
        ${pkgs.llama-cpp}/bin/llama-server
        --hf-repo unsloth/SmolLM2-135M-Instruct-GGUF:Q8_0
        --port ''${PORT}
        --ctx-size 0

  healthcheckTimeout: 28800 # 8 hours for large model download + loading
  # TTL keeps models in memory for specified seconds after last use
  ttl: 3600  # Keep models loaded for 1 hour (like OLLAMA_KEEP_ALIVE)
''
