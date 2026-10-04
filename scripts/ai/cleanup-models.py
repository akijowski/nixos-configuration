#!/usr/bin/env nix-shell
#! nix-shell -i python3 --packages python3 python314Packages.pyyaml
# /// script
# dependencies = [
#   "PyYAML",
# ]
# ///
import os
import re
import sys
import yaml
import glob
import argparse

CONFIG_YAML_PATH = "/etc/llama-swap/config.yaml"
CACHE_DIR = os.path.expanduser("~/.cache/huggingface/hub/")


def get_configured_models():
    if not os.path.exists(CONFIG_YAML_PATH):
        print(f"Error: {CONFIG_YAML_PATH} not found.", file=sys.stderr)
        sys.exit(1)

    with open(CONFIG_YAML_PATH, "r") as f:
        yaml_text = f.read()

    try:
        config = yaml.safe_load(yaml_text)
        models = config.get("models", {})

        configured_repos = []
        configured_files = []

        for model_config in models.values():
            cmd = model_config.get("cmd", "")

            match = re.search(r"(?:-hf|--hf-repo)\s+([^\s]+)", cmd)
            if match:
                repo_tag = match.group(1)
                if ":" in repo_tag:
                    repo_tag = repo_tag.split(":")[0]
                configured_repos.append(repo_tag)

            match_mmproj = re.search(r"--mmproj-url\s+([^\s]+)", cmd)
            if match_mmproj:
                url = match_mmproj.group(1)
                filename = url.split("/")[-1]
                configured_files.append(filename)

        return configured_repos, configured_files
    except yaml.YAMLError as e:
        print(f"Error parsing YAML: {e}", file=sys.stderr)
        sys.exit(1)


def get_cached_files():
    if not os.path.exists(CACHE_DIR):
        print(f"Cache directory {CACHE_DIR} does not exist.", file=sys.stderr)
        return []

    return glob.glob(os.path.join(CACHE_DIR, "**", "*.gguf"), recursive=True)


def find_unused_files(configured_repos, configured_files):
    cached_files = get_cached_files()

    unused = []
    total_size = 0

    for f in cached_files:
        if os.path.isdir(f):
            continue

        fname = os.path.basename(f)

        is_configured = False

        for repo in configured_repos:
            repo_path = "models--" + repo.replace("/", "--") + "/"
            if repo_path in f:
                is_configured = True
                break

        if not is_configured:
            for cf in configured_files:
                if cf in fname:
                    is_configured = True
                    break

        if not is_configured:
            size = os.path.getsize(f)
            size_gb = size / (1024 ** 3)
            unused.append((f, size_gb))
            total_size += size_gb

    return unused, total_size


def main():
    parser = argparse.ArgumentParser(
        description="Clean unused cached models from llama.cpp cache"
    )
    parser.add_argument(
        "--force",
        "-y",
        action="store_true",
        help="Skip confirmation prompt and delete immediately",
    )
    args = parser.parse_args()

    configured_repos, configured_files = get_configured_models()
    unused_files, total_size = find_unused_files(configured_repos, configured_files)

    print(f"{'File':<60} | {'Size (GB)':<10}")
    print("-" * 75)

    for f, size_gb in unused_files:
        print(f"{os.path.basename(f):<60} | {size_gb:.2f}")

    print("-" * 75)
    print(f"Total potentially unused: {total_size:.2f} GB")

    if not unused_files:
        print("No unused files found.")
        return

    if not args.force:
        response = input(
            "\nDo you want to delete these files? (y/N): "
        ).strip().lower()
        if response != "y":
            print("No files deleted.")
            return

    deleted = 0
    errors = 0
    for f, _ in unused_files:
        try:
            os.remove(f)
            print(f"Deleted {os.path.basename(f)}")
            deleted += 1
        except Exception as e:
            print(f"Error deleting {f}: {e}", file=sys.stderr)
            errors += 1

    print(f"\nCleanup complete: {deleted} deleted, {errors} errors.")

    if errors:
        sys.exit(1)


if __name__ == "__main__":
    main()
