#!/usr/bin/env python3
"""Validate device DB lines (Brand|Model|Fingerprint|YYYY-MM-DD) in a shard or merged file."""

import re
import sys
from pathlib import Path

PATCH_RE = re.compile(r"^[0-9]{4}-[0-9]{2}-[0-9]{2}$")


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: validate_device_db.py path/to/file.txt", file=sys.stderr)
        return 2
    path = Path(sys.argv[1])
    if not path.is_file():
        print(f"missing: {path}", file=sys.stderr)
        return 2

    errors = 0
    data_lines = 0
    for i, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
        raw = line.strip()
        if not raw or raw.startswith("#"):
            continue
        parts = raw.split("|")
        if len(parts) != 4:
            print(f"{i}: need 4 fields: {raw[:120]!r}")
            errors += 1
            continue
        brand, model, fp, patch = (p.strip() for p in parts)
        if not brand or not model or not fp or not patch:
            print(f"{i}: empty field: {raw[:120]!r}")
            errors += 1
            continue
        if not PATCH_RE.match(patch):
            print(f"{i}: bad patch (use YYYY-MM-DD): {patch!r}")
            errors += 1
            continue
        if "/" not in fp or fp.count(":") < 2:
            print(f"{i}: fingerprint should look like brand/codename/device:a/b/c:tag keys: {fp[:80]!r}")
            errors += 1
            continue
        data_lines += 1

    if data_lines == 0:
        print("no data rows (only blank/comments?)")
        return 1
    if errors:
        print(f"--- {errors} error(s), {data_lines} ok row(s) ---")
        return 1
    print(f"OK: {data_lines} data row(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
