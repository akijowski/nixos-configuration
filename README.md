# NixOS Configuration

Personal NixOS flake managing two hosts:

| Host | Role |
|------|------|
| `devnix` | Primary development workstation |
| `llm` | AI/ML server (llama-swap, InvokeAI) |

Built with [flake-parts](https://flake.parts) for modular organization.

---

## Directory Structure

```
.
├── flake.nix                  # Flake entrypoint, inputs, pre-commit hooks
├── .sops.yaml                 # SOPS encryption rules (age key)
├── .gitignore                 # Generated files (.pre-commit-config.yaml)
├── secrets/                   # SOPS-encrypted secrets
│   └── secrets.yaml
└── modules/
    ├── flake-parts.nix        # flake-parts module imports (home-manager, disko, git-hooks)
    ├── nixos.nix              # NixOS configurations for devnix and llm
    ├── settings.nix           # Reusable NixOS modules (system, VM, Tailscale, home-manager)
    ├── home-manager.nix       # home-manager module (shared across hosts)
    ├── disko.nix              # Disk layouts (LVM single-disk)
    ├── common-users.nix       # Shared user definition (SSH keys, groups)
    ├── hosts/
    │   ├── devnix/            # devnix-specific modules
    │   │   ├── default.nix
    │   │   ├── configuration.nix
    │   │   ├── hardware-configuration.nix
    │   │   ├── users.nix
    │   │   └── akijowski.nix  # home-manager config
    │   └── llm/               # llm-specific modules
    │       ├── default.nix
    │       ├── configuration.nix
    │       ├── hardware-configuration.nix
    │       ├── package-overrides.nix  # CUDA / GPU overrides
    │       ├── users.nix
    │       ├── akijowski.nix  # home-manager config
    │       ├── ai.nix         # llama-swap, InvokeAI, Tailscale serve
    │       └── containers.nix # OCI container definitions
    └── home-manager/
        ├── base.nix           # Shared home config (git, zsh, starship, delta)
        └── llm.nix            # LLM-specific home config (OpenCode)
```

## Development

### Dev Shell

Enter a development shell with pre-commit hooks auto-installed:

```bash
nix develop
```

Inside the shell, `git commit` will run the configured hooks. To run hooks manually:

```bash
nix develop -c pre-commit run --all-files
```

### Pre-commit Hooks

Two hooks are configured:

- **alejandra** — Nix code formatter (runs on `.nix` files)
- **deadnix** — detects unused variable bindings

Run the full check suite (used in CI):

```bash
nix flake check
```

Format all Nix files:

```bash
nix fmt
```

## Secrets

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix) using [age](https://github.com/FiloSottile/age) encryption.

### How it works

- Encrypted secrets live in `secrets/secrets.yaml`
- `.sops.yaml` defines which age key decrypts each path
- The age key file is stored at `~/.config/sops/age/keys.txt`
- Secrets are exposed to NixOS modules and home-manager at evaluation time

### Adding a secret

1. Add the key to `secrets/secrets.yaml`:
   ```yaml
   my_secret: "my-value"
   ```
2. Encrypt with sops:
   ```bash
   sops secrets/secrets.yaml
   ```
   (SOPS will prompt for editing, then encrypt on save)
3. Reference in NixOS modules:
   ```nix
   config.sops.secrets.my_secret.path
   ```
4. Reference in home-manager:
   ```nix
   config.sops.secrets.my_secret.path
   ```

### Important: `git add` before building

Files inside `secrets/` must be tracked by git for the flake to see them. If you add a new secret file or modify an existing one, run `git add` before building — otherwise the flake evaluator won't find the file.

## Installing on a New Machine

### Prerequisites

- Boot from a NixOS installation ISO
- Ensure internet connectivity

### Disk Layout

Partition, format, and mount with disko:

```bash
sudo -i

nix --experimental-features 'nix-command flakes' run \
  github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  --yes-wipe-all-disks \
  --flake github:akijowski/nixos-configuration#<hostname>
```

Replace `<hostname>` with `devnix` or `llm`.

### Install Flake

```bash
nixos-install \
  --root /mnt \
  --no-channel-copy \
  --flake github:akijowski/nixos-configuration#<hostname>
```

### Post-Install

```bash
reboot
```

After first boot, ensure the age key is in place at `~/.config/sops/age/keys.txt` so secrets can be decrypted on subsequent builds.

## References

### NixOS & Flakes

- [NixOS Installation Manual](https://nixos.org/manual/nixos/stable/#sec-installation-manual)
- [NixOS Wiki: Flakes](https://nixos.wiki/wiki/flakes)
- [Flake-parts Documentation](https://flake.parts)

### Home Manager

- [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)
- [sops-nix + home-manager](https://github.com/Mic92/sops-nix?tab=readme-ov-file#use-with-home-manager)
- [Managing Secrets with sops-nix + home-manager](https://zohaib.me/managing-secrets-in-nixos-home-manager-with-sops/)
- [sops-nix with home-manager modules](https://haseebmajid.dev/posts/2024-01-28-how-to-get-sops-nix-working-with-home-manager-modules/)

### Secrets & Encryption

- [SOPS + Age + 1Password overview](https://paulocurado.com/blog/managing-secrets-with-sops-age-and-1password/)
- [1Password Service Accounts](https://developer.1password.com/docs/service-accounts/use-with-1password-cli)

### SSH & Remote Development

- [Fetching SSH Public Keys](https://discourse.nixos.org/t/fetching-ssh-public-keys/12076/7)
- [VS Code Remote SSH](https://nixos.wiki/wiki/Visual_Studio_Code#Remote_SSH)

### Inspiration

- [EmergentMind/nix-config](https://github.com/EmergentMind/nix-config/tree/dev)
