#!/usr/bin/env python3
"""Apply the debloat list once over archive-root, then exit.

No daemon is started. The Home key is not remapped. Masks live in /run on
the TV until a cold boot; run this again after one.
"""
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

import debloat  # noqa: E402


def tool_path() -> Path:
    name = "samsung-tv-root.exe" if os.name == "nt" else "samsung-tv-root"
    beside = Path(sys.executable).with_name(name)
    if beside.is_file():
        return beside
    return Path(name)


def main() -> int:
    host = os.environ.get("TV_IP", "").strip()
    sdb = os.environ.get("SDB", "").strip()
    payload = os.environ.get("SAMSUNG_TV_ROOT_COMMON_PAYLOAD_DIRECTORY", "").strip()
    if not host:
        print("TV_IP is not set.", file=sys.stderr)
        return 1
    if not sdb or not Path(sdb).is_file():
        print(f"sdb not found: {sdb or '(unset)'}", file=sys.stderr)
        return 1
    if not payload or not Path(payload).is_dir():
        print(f"payload directory not found: {payload or '(unset)'}", file=sys.stderr)
        return 1
    services = debloat.parse()
    commands = [debloat.mask_loop(services), debloat.HOLD, "id"]
    argv = [
        str(tool_path()),
        "--sdb",
        sdb,
        "archive-root",
        "root",
        host,
        "--command-timeout",
        "150",
        "--payload-directory",
        payload,
    ]
    for command in commands:
        argv.extend(["--command", command])
    print(f"Applying {len(services)} masks on {host}, then exiting.")
    return subprocess.call(argv)


if __name__ == "__main__":
    sys.exit(main())
