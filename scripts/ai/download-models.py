#!/usr/bin/env nix-shell
#! nix-shell -i python3 --packages python3 python314Packages.pyyaml
# /// script
# dependencies = [
#   "PyYAML",
# ]
# ///
import os
import sys
import yaml
import shlex
import argparse
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed

CONFIG_YAML_PATH = "/etc/llama-swap/config.yaml"
CACHE_DIR = os.path.expanduser("~/.cache/huggingface/hub/")


def parse_args_from_cmd(cmd_str):
    """
    Extracts relevant arguments (-hf, --hf-repo, --hf-file)
    from the command string.
    """
    args = shlex.split(cmd_str)
    relevant_args = []

    i = 0
    while i < len(args):
        arg = args[i]
        if arg in ["-hf", "--hf-repo", "--hf-file"]:
            relevant_args.append(arg)
            if i + 1 < len(args):
                relevant_args.append(args[i + 1])
                i += 1
        i += 1

    return relevant_args


def load_config():
    if not os.path.exists(CONFIG_YAML_PATH):
        print(f"Error: {CONFIG_YAML_PATH} not found.", file=sys.stderr)
        sys.exit(1)

    print(f"Reading configuration from {CONFIG_YAML_PATH}...")
    with open(CONFIG_YAML_PATH, "r") as f:
        yaml_text = f.read()

    try:
        config = yaml.safe_load(yaml_text)
    except yaml.YAMLError as e:
        print(f"Error parsing YAML: {e}", file=sys.stderr)
        sys.exit(1)

    return config.get("models", {})


def download_model(model_name, model_config, dry_run=False):
    """Download a single model. Returns (model_name, status, message)."""
    cmd = model_config.get("cmd", "")
    if not cmd:
        return (model_name, "skipped", "No command found")

    dl_args = parse_args_from_cmd(cmd)
    if not dl_args:
        return (model_name, "skipped", "No HuggingFace arguments found")

    cli_cmd = (
        ["llama-completion"]
        + dl_args
        + [
            "-p",
            "System check",
            "-n",
            "1",
            "--no-display-prompt",
            "--simple-io",
        ]
    )

    print(f"  Processing: {model_name}")
    print(f"  Running: {' '.join(cli_cmd)}")

    if dry_run:
        print(f"  -> Would run")
        return (model_name, "dry-run", f"Would run: {' '.join(cli_cmd)}")

    try:
        subprocess.run(cli_cmd, check=True, stdin=subprocess.DEVNULL)
        print(f"  -> Success/Verified")
        return (model_name, "success", "Verified")
    except subprocess.CalledProcessError:
        print(f"  -> Failed (or interrupted)")
        return (model_name, "failed", "Command failed (or interrupted)")
    except FileNotFoundError:
        print(
            f"  -> Error: 'llama-completion' not found in PATH"
        )
        return (
            model_name,
            "failed",
            "'llama-completion' not found in PATH",
        )


def main():
    parser = argparse.ArgumentParser(
        description="Download/cached-check LLM models from llama-swap config"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be downloaded without actually downloading",
    )
    parser.add_argument(
        "--jobs",
        type=int,
        default=1,
        help="Number of parallel downloads (default: 1)",
    )
    args = parser.parse_args()

    models = load_config()

    print(f"Found {len(models)} models.")

    if not models:
        return

    results = []

    if args.jobs > 1 and not args.dry_run:
        with ThreadPoolExecutor(max_workers=args.jobs) as executor:
            futures = {
                executor.submit(download_model, name, cfg, args.dry_run): name
                for name, cfg in models.items()
            }
            for future in as_completed(futures):
                results.append(future.result())
    else:
        for model_name, model_config in models.items():
            result = download_model(model_name, model_config, args.dry_run)
            results.append(result)

    # Summary
    print("\n" + "-" * 60)
    success = sum(1 for _, s, _ in results if s == "success")
    failed = sum(1 for _, s, _ in results if s == "failed")
    skipped = sum(1 for _, s, _ in results if s == "skipped")
    dry_run = sum(1 for _, s, _ in results if s == "dry-run")

    print(f"Summary: {success} succeeded, {failed} failed, {skipped} skipped" + (f", {dry_run} dry-run" if dry_run else ""))

    if failed:
        sys.exit(1)


if __name__ == "__main__":
    main()
