# FLAKES AND STUFF

TODO: Clean this up

Link Dump:

- https://nixos.org/manual/nixos/stable/#sec-installation-manual
- https://nixos.wiki/wiki/flakes
- https://discourse.nixos.org/t/fetching-ssh-public-keys/12076/7
- https://nix-community.github.io/home-manager/options.xhtml
- https://nixos.wiki/wiki/Visual_Studio_Code#Remote_SSH

Secrets:

TODO: rewrite

Uses [sops-nix](https://github.com/Mic92/sops-nix) to provide secrets from
encrypted values.
SOPS config is stored in [.sops.yaml](./.sops.yaml).
Secrets are stored in [./secrets](./secrets).

[ALWAYS git add files so the flake source is
updated](https://discourse.nixosstag.fcio.net/t/reference-a-local-file-from-flake-nix/66521).
This took a while to solve, but basically if the local files are not present in
git, the flake will not load them and they cannot be referenced, like a new
secrets file, for example.

- [sops-nix
  + home-manager](https://github.com/Mic92/sops-nix?tab=readme-ov-file#use-with-home-manager)
- [nixos + sops
  + home-manager](https://zohaib.me/managing-secrets-in-nixos-home-manager-with-sops/)
- [nixos + sops
  + home-manager](https://haseebmajid.dev/posts/2024-01-28-how-to-get-sops-nix-working-with-home-manager-modules/)
- [sops and onepass
  overview](https://paulocurado.com/blog/managing-secrets-with-sops-age-and-1password/)
- [onepass service
  account](https://developer.1password.com/docs/service-accounts/use-with-1password-cli)
