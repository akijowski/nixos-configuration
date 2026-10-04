#!/usr/bin/env nix-shell
#! nix-shell -i python3 -p python3
import os
import re
import sys
import struct
import glob
import json
import argparse
import urllib.request
import datetime

CACHE_DIR = os.path.expanduser("~/.cache/huggingface/hub/")

GGUF_TYPE_UINT8 = 0
GGUF_TYPE_INT8 = 1
GGUF_TYPE_UINT16 = 2
GGUF_TYPE_INT16 = 3
GGUF_TYPE_UINT32 = 4
GGUF_TYPE_INT32 = 5
GGUF_TYPE_FLOAT32 = 6
GGUF_TYPE_BOOL = 7
GGUF_TYPE_STRING = 8
GGUF_TYPE_ARRAY = 9
GGUF_TYPE_UINT64 = 10
GGUF_TYPE_INT64 = 11
GGUF_TYPE_FLOAT64 = 12


QUANT_PATTERNS = [
    r"(Q[0-9]+_[A-Z]+_[A-Z]+)",
    r"(Q[0-9]+_[A-Z]+)",
    r"(Q[0-9]+)",
    r"(I[0-9]+)",
]


def read_string(f):
    len_bytes = f.read(8)
    if not len_bytes:
        return None
    length = struct.unpack("<Q", len_bytes)[0]
    if length > 1000000:
        return f.read(length).decode("utf-8", errors="ignore")
    return f.read(length).decode("utf-8", errors="ignore")


def skip_value(f, val_type):
    if val_type == GGUF_TYPE_STRING:
        read_string(f)
    elif val_type == GGUF_TYPE_ARRAY:
        arr_type = struct.unpack("<I", f.read(4))[0]
        arr_len = struct.unpack("<Q", f.read(8))[0]
        for _ in range(arr_len):
            skip_value(f, arr_type)
    else:
        size_map = {
            GGUF_TYPE_UINT8: 1,
            GGUF_TYPE_INT8: 1,
            GGUF_TYPE_BOOL: 1,
            GGUF_TYPE_UINT16: 2,
            GGUF_TYPE_INT16: 2,
            GGUF_TYPE_UINT32: 4,
            GGUF_TYPE_INT32: 4,
            GGUF_TYPE_FLOAT32: 4,
            GGUF_TYPE_UINT64: 8,
            GGUF_TYPE_INT64: 8,
            GGUF_TYPE_FLOAT64: 8,
        }
        if val_type in size_map:
            f.seek(size_map[val_type], 1)
        else:
            raise ValueError(f"Unknown type {val_type}")


def read_value_scalar(f, val_type):
    if val_type == GGUF_TYPE_UINT32:
        return struct.unpack("<I", f.read(4))[0]
    if val_type == GGUF_TYPE_INT32:
        return struct.unpack("<i", f.read(4))[0]
    if val_type == GGUF_TYPE_UINT64:
        return struct.unpack("<Q", f.read(8))[0]
    if val_type == GGUF_TYPE_INT64:
        return struct.unpack("<q", f.read(8))[0]
    skip_value(f, val_type)
    return None


def read_gguf_info(filepath):
    try:
        with open(filepath, "rb") as f:
            magic = f.read(4)
            if magic != b"GGUF":
                return None

            f.read(4)
            tensor_count = struct.unpack("<Q", f.read(8))[0]
            kv_count = struct.unpack("<Q", f.read(8))[0]

            candidates_ctx = {}
            candidates_layers = {}

            for _ in range(kv_count):
                key = read_string(f)
                if key is None:
                    break

                val_type = struct.unpack("<I", f.read(4))[0]

                if key.endswith(".context_length") or key.endswith(
                    ".context_length_train"
                ):
                    val = read_value_scalar(f, val_type)
                    if val is not None:
                        candidates_ctx[key] = val
                elif key.endswith(".block_count"):
                    val = read_value_scalar(f, val_type)
                    if val is not None:
                        candidates_layers[key] = val
                else:
                    skip_value(f, val_type)

            ctx = None
            non_train = {
                k: v for k, v in candidates_ctx.items() if not k.endswith("_train")
            }
            if non_train:
                ctx = max(non_train.values())
            elif candidates_ctx:
                ctx = max(candidates_ctx.values())

            layers = None
            if candidates_layers:
                layers = max(candidates_layers.values())

            return {
                "ctx": ctx,
                "layers": layers,
            }
    except Exception:
        return None


def parse_quant(filepath):
    fname = os.path.basename(filepath)
    for pattern in QUANT_PATTERNS:
        match = re.search(pattern, fname, re.IGNORECASE)
        if match:
            return match.group(1)
    return "?"


def find_files(query):
    if os.path.exists(query) and os.path.isfile(query):
        return [query]

    repo = query
    tag = None

    if ":" in query:
        repo, tag = query.split(":", 1)

    safe_repo = repo.replace("/", "--")
    pattern = os.path.join(CACHE_DIR, f"**", f"*{safe_repo}*", "**", "*.gguf")
    candidates = glob.glob(pattern, recursive=True)

    valid_files = []
    for c in candidates:
        if tag and tag.lower() not in c.lower():
            continue
        valid_files.append(c)

    return valid_files


def find_all_cached_files():
    if not os.path.exists(CACHE_DIR):
        return []

    return glob.glob(os.path.join(CACHE_DIR, "**", "*.gguf"), recursive=True)


def fetch_hf_date(repo):
    try:
        url = f"https://huggingface.co/api/models/{repo}"
        with urllib.request.urlopen(url, timeout=5) as response:
            data = json.load(response)
            date_str = data.get("createdAt")
            if date_str:
                dt = datetime.datetime.fromisoformat(date_str.replace("Z", "+00:00"))
                return dt.strftime("%Y-%m-%d")
    except Exception:
        pass
    return None


def format_size_gb(size_bytes):
    return f"{size_bytes / (1024**3):.1f} GB"


def extract_repo_from_path(filepath):
    parts = filepath.split("/")
    models_idx = None
    for i, p in enumerate(parts):
        if p == "models--" or "--" in p:
            if p.startswith("models--"):
                return p.replace("models--", "")
            elif "--" in p:
                return p.replace("--", "/").replace("-", " ", 1)
    return None


def print_model_info(files, show_path=True, fetch_date=True, main_file=None):
    total_size = sum(os.path.getsize(f) for f in files)

    if not main_file:
        main_file = files[0]
        for f in files:
            if "mmproj" not in f and "split" not in f and "mtp" not in f and f.endswith(".gguf"):
                main_file = f
                break
            elif "00001-of-" in f:
                main_file = f

    info = read_gguf_info(main_file)
    ctx = info["ctx"] if info else None
    layers = info["layers"] if info else None

    quant = parse_quant(main_file)

    repo_name = None
    repo_name = extract_repo_from_path(main_file)
    if not repo_name:
        fname = os.path.basename(main_file)
        for pattern in [r"[/_]([A-Za-z0-9]+-[A-Za-z0-9.]+-GGUF)", r"[/_]([A-Za-z0-9]+-[A-Za-z0-9.]+)"]:
            match = re.search(pattern, fname)
            if match:
                repo_name = match.group(1)
                break

    date_str = None
    if fetch_date and repo_name:
        date_str = fetch_hf_date(repo_name)
    if not date_str:
        date_str = "????"

    ctx_str = str(ctx) if ctx else "????"
    layers_str = str(layers) if layers is not None else "?"

    aux_files = [f for f in files if f != main_file]

    if show_path:
        print(f"  File: {main_file}")
        for af in aux_files:
            print(f"        {os.path.basename(af)} ({format_size_gb(os.path.getsize(af))})")

    print(
        f"  Uploaded: {date_str} | {format_size_gb(total_size)} | "
        f"Quant: {quant} | Ctx: {ctx_str} | Layers: {layers_str}"
    )


def main():
    parser = argparse.ArgumentParser(
        description="Show info about cached LLM models"
    )
    parser.add_argument(
        "query",
        nargs="?",
        default=None,
        help="Repo/name:tag or path to file",
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="List all cached models",
    )
    parser.add_argument(
        "--no-date",
        action="store_true",
        help="Skip HuggingFace API call for upload date",
    )
    args = parser.parse_args()

    if args.all:
        files = find_all_cached_files()
        if not files:
            print("No cached files found.")
            return

        print(f"Cache: {CACHE_DIR}")
        print(f"{'='*70}")

        repos = {}
        for f in sorted(files):
            dirname = os.path.dirname(f)
            if dirname not in repos:
                repos[dirname] = []
            repos[dirname].append(f)

        repo_dirs = list(repos.keys())
        deduped = []
        seen_base = set()
        for rd in repo_dirs:
            base = rd.split("models--")[1] if "models--" in rd else rd
            base = re.sub(r"/snapshots.*$", "", base)
            if base not in seen_base:
                seen_base.add(base)
                deduped.append(rd)

        for repo_dir in deduped:
            repo_files = repos[repo_dir]
            main_file = None
            for f in repo_files:
                if "mmproj" not in f and "split" not in f and "mtp" not in f and f.endswith(".gguf"):
                    main_file = f
                    break
            if not main_file:
                main_file = repo_files[0]

            print_model_info(repo_files, main_file=main_file, fetch_date=not args.no_date)
            print()

    elif args.query:
        files = find_files(args.query)
        if not files:
            print(f"No files found for '{args.query}'", file=sys.stderr)
            sys.exit(1)

        print_model_info(files, fetch_date=not args.no_date)
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
