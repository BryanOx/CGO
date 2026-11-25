#!/usr/bin/env python3
"""Verify copied Conga card PNGs against the pinned source manifest."""

from __future__ import annotations

import hashlib
import json
import struct
import sys
from pathlib import Path
from typing import Any

EXPECTED_COUNT = 50
EXPECTED_WIDTH = 160
EXPECTED_HEIGHT = 247
PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"
MANIFEST_PATH = (
    Path(__file__).resolve().parent.parent
    / "assets"
    / "cards"
    / "conga"
    / "classic_red"
    / "manifest.json"
)


def png_dimensions(data: bytes) -> tuple[int, int]:
    """Return the IHDR width and height, rejecting non-PNG input."""
    if len(data) < 24 or data[:8] != PNG_SIGNATURE or data[12:16] != b"IHDR":
        raise ValueError("missing PNG signature or IHDR chunk")
    return struct.unpack(">II", data[16:24])


def verify() -> list[str]:
    """Return a list of verification errors; an empty list means success."""
    errors: list[str] = []
    if not MANIFEST_PATH.is_file():
        return [f"manifest not found: {MANIFEST_PATH}"]

    try:
        manifest: Any = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return [f"cannot read manifest: {exc}"]

    files: Any = manifest.get("files") if isinstance(manifest, dict) else None
    if not isinstance(files, dict):
        return ["manifest has no 'files' object"]

    if len(files) != EXPECTED_COUNT:
        errors.append(f"expected {EXPECTED_COUNT} manifest entries, found {len(files)}")

    card_dir: Path = MANIFEST_PATH.parent / "cards"
    for name in sorted(files):
        if name != Path(name).name:
            errors.append(f"unsafe manifest filename: {name}")
            continue
        entry: Any = files[name]
        if not isinstance(entry, dict):
            errors.append(f"invalid manifest entry: {name}")
            continue

        expected_sha: Any = entry.get("sha256")
        expected_bytes: Any = entry.get("bytes")
        expected_width: Any = entry.get("width")
        expected_height: Any = entry.get("height")
        path: Path = card_dir / name
        if not path.is_file():
            errors.append(f"missing file: {name}")
            continue

        data: bytes = path.read_bytes()
        if hashlib.sha256(data).hexdigest() != expected_sha:
            errors.append(f"SHA-256 mismatch: {name}")
        if len(data) != expected_bytes:
            errors.append(f"byte size mismatch: {name}")
        try:
            width, height = png_dimensions(data)
        except ValueError as exc:
            errors.append(f"{name}: {exc}")
            continue
        if (width, height) != (expected_width, expected_height):
            errors.append(
                f"dimension mismatch: {name} is {width}x{height}, "
                f"manifest declares {expected_width}x{expected_height}"
            )
        if (width, height) != (EXPECTED_WIDTH, EXPECTED_HEIGHT):
            errors.append(
                f"unexpected dimensions: {name} is {width}x{height}, "
                f"expected {EXPECTED_WIDTH}x{EXPECTED_HEIGHT}"
            )

    return errors


def main() -> int:
    errors: list[str] = verify()
    if errors:
        for error in errors:
            print(f"FAIL: {error}", file=sys.stderr)
        return 1
    print(f"Verified {EXPECTED_COUNT} card assets.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
