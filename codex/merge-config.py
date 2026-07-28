#!/usr/bin/env python3
"""Merge a dotfiles-managed TOML fragment into a live config file.

Usage: merge-config.py <fragment> <target>

The target (e.g. ~/.codex/config.toml) is owned by the app and holds
machine-local state, so instead of symlinking we deep-merge the fragment's
keys into it — fragment values win, everything else (including comments)
is preserved via tomlkit. Idempotent: no write when nothing changes.
"""

import os
import sys
import tempfile

import tomlkit
from tomlkit.items import Table


def deep_merge(target, fragment):
    for key, value in fragment.items():
        if isinstance(value, (dict, Table)) and isinstance(target.get(key), (dict, Table)):
            deep_merge(target[key], value)
        else:
            target[key] = value


def main():
    if len(sys.argv) != 3:
        print(__doc__.strip().splitlines()[2], file=sys.stderr)
        return 2
    fragment_path, target_path = sys.argv[1], sys.argv[2]

    with open(fragment_path, encoding="utf-8") as f:
        fragment_text = f.read()
    fragment = tomlkit.parse(fragment_text)

    if os.path.exists(target_path):
        with open(target_path, encoding="utf-8") as f:
            original = f.read()
        doc = tomlkit.parse(original)
        deep_merge(doc, fragment)
        merged = tomlkit.dumps(doc)
    else:
        original = None
        merged = fragment_text

    if merged == original:
        return 0

    # Write via a temp file in the same directory so a crash can't truncate
    # the live config; preserve the original mode (Codex keeps it at 600).
    target_dir = os.path.dirname(os.path.abspath(target_path)) or "."
    os.makedirs(target_dir, exist_ok=True)
    mode = os.stat(target_path).st_mode & 0o777 if original is not None else 0o600
    fd, tmp_path = tempfile.mkstemp(dir=target_dir, prefix=".merge-config-")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            f.write(merged)
        os.chmod(tmp_path, mode)
        os.replace(tmp_path, target_path)
    except BaseException:
        os.unlink(tmp_path)
        raise
    print(f"Merged {fragment_path} into {target_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
