{pkgs, ...}: {
  nixpkgs.config = {
    cudaSupport = true;
    packageOverrides = pkgs: {
      # Override llama-cpp to use CUDA Support
      # Modifications for improvement for GPU
      llama-cpp =
        (pkgs.llama-cpp.override {
          cudaSupport = true;
          # Enable BLAS for optimized CPU layer performance (OpenBLAS)
          # Required for models using split-mode or CPU offloading
          blasSupport = true;
        }).overrideAttrs
        (oldAttrs: rec {
          # Enable native CPU optimizations for massively better CPU performance
          # This enables AVX, AVX2, AVX-512, FMA, etc. for your specific CPU
          # NOTE: This is intentionally opposite of nixpkgs (which uses -DGGML_NATIVE=off
          # for reproducible builds). We sacrifice portability for faster CPU layers.
          cmakeFlags =
            (oldAttrs.cmakeFlags or [])
            ++ [
              "-DGGML_NATIVE=ON"
              "-DCMAKE_CUDA_ARCHITECTURES=86" # RTX 3090 - needed since sandbox has no GPU
            ];
          # Disable Nix's NIX_ENFORCE_NO_NATIVE which strips -march=native flags
          # See: https://github.com/NixOS/nixpkgs/issues/357736
          # See: https://github.com/NixOS/nixpkgs/pull/377484 (intentionally contradicts this)
          preConfigure = ''
            export NIX_ENFORCE_NO_NATIVE=0
            ${oldAttrs.preConfigure or ""}
          '';
        });
    };
  };
}
