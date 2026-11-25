#!/usr/bin/env python3
"""Verify the licensed audio assets and the audio exclusion gate."""

from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path
from typing import Any

EXPECTED_EFFECT_COUNT = 13
EXPECTED_MUSIC_COUNT = 4
EXPECTED_COUNT = EXPECTED_EFFECT_COUNT + EXPECTED_MUSIC_COUNT
EXPECTED_EFFECT_SOURCE = "kenney:casino-audio:1.1"
EXPECTED_MUSIC_SOURCE = "user-declared-cc0:holizna"
AUDIO_EXTENSIONS = {".mp3", ".wav", ".ogg"}
CLIENT_DIR = Path(__file__).resolve().parent.parent
ASSETS_DIR = CLIENT_DIR / "assets"
AUDIO_DIR = ASSETS_DIR / "common" / "audio"
EFFECTS_DIR = AUDIO_DIR / "effects"
MUSIC_DIR = AUDIO_DIR / "music"
LICENSE_PATH = EFFECTS_DIR / "LICENSE.txt"
DOC_CHECKS: tuple[tuple[Path, tuple[str, ...]], ...] = (
    (LICENSE_PATH, ("CC0", "Kenney")),
    (EFFECTS_DIR / "ATTRIBUTION.md", ("Kenney", "creativecommons.org")),
    (MUSIC_DIR / "ATTRIBUTION.md", ("HoliznaCC0", "CC0", "creativecommons.org")),
)


def verify_group(directory: Path, expected_count: int, expected_source: str, extension: str) -> list[str]:
    """Verify one manifest and its files; an empty list means success."""
    errors: list[str] = []
    manifest_path: Path = directory / "manifest.json"
    if not manifest_path.is_file():
        return [f"manifest not found: {manifest_path}"]

    try:
        manifest: Any = json.loads(manifest_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return [f"cannot read manifest {directory.name}: {exc}"]

    files: Any = manifest.get("files") if isinstance(manifest, dict) else None
    if not isinstance(files, dict):
        return [f"{directory.name} manifest has no 'files' object"]

    if len(files) != expected_count:
        errors.append(f"expected {expected_count} {directory.name} entries, found {len(files)}")

    for name in sorted(files):
        if name != Path(name).name:
            errors.append(f"unsafe manifest filename: {name}")
            continue
        entry: Any = files[name]
        if not isinstance(entry, dict):
            errors.append(f"invalid manifest entry: {name}")
            continue
        if Path(name).suffix.lower() != extension:
            errors.append(f"unexpected extension in {directory.name}: {name}")

        expected_sha: Any = entry.get("sha256")
        expected_bytes: Any = entry.get("bytes")
        source: Any = entry.get("source")
        path: Path = directory / name
        if not path.is_file():
            errors.append(f"missing file: {name}")
            continue

        data: bytes = path.read_bytes()
        if hashlib.sha256(data).hexdigest() != expected_sha:
            errors.append(f"SHA-256 mismatch: {name}")
        if len(data) != expected_bytes:
            errors.append(f"byte size mismatch: {name}")
        if source != expected_source:
            errors.append(f"source mismatch: {name}")

    return errors


def verify() -> list[str]:
    """Return a list of verification errors; an empty list means success."""
    errors: list[str] = []
    errors.extend(verify_group(EFFECTS_DIR, EXPECTED_EFFECT_COUNT, EXPECTED_EFFECT_SOURCE, ".ogg"))
    errors.extend(verify_group(MUSIC_DIR, EXPECTED_MUSIC_COUNT, EXPECTED_MUSIC_SOURCE, ".mp3"))

    for path, needles in DOC_CHECKS:
        if not path.is_file():
            errors.append(f"missing documentation: {path.name}")
            continue
        text: str = path.read_text(encoding="utf-8", errors="replace")
        for needle in needles:
            if needle not in text:
                errors.append(f"{path.parent.name}/{path.name} does not contain {needle!r}")

    licensed_roots: tuple[Path, ...] = (EFFECTS_DIR.resolve(), MUSIC_DIR.resolve())
    for path in ASSETS_DIR.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in AUDIO_EXTENSIONS:
            continue
        if any(path.resolve().is_relative_to(root) for root in licensed_roots):
            continue
        errors.append(f"audio file outside licensed folders: {path.relative_to(CLIENT_DIR)}")

    return errors


def main() -> int:
    errors: list[str] = verify()
    if errors:
        for error in errors:
            print(f"FAIL: {error}", file=sys.stderr)
        return 1
    print(f"Verified {EXPECTED_COUNT} audio assets.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
