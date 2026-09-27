#!/usr/bin/env python3
"""単元全体像を OCR して assets/mindMap/ocr/ に書き出す。

使い方（リポジトリルート）:
  .venv-ocr/bin/python scripts/ocr_mindmap_vision.py \\
      assets/mindMap/dynamicsLandScope.jpeg assets/mindMap/ocr/dynamicsLandScope.json

一括:
  .venv-ocr/bin/python scripts/generate_mindmap_ocr.py
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OCR_PY = ROOT / "scripts" / "ocr_mindmap_vision.py"
OUT_DIR = ROOT / "assets" / "mindMap" / "ocr"

IMAGES = [
    ROOT / "assets/mindMap/dynamicsLandScope.jpeg",
    ROOT / "assets/mindMap/emTheoryLandScope.jpeg",
    ROOT / "assets/mindMap/thermoDynamicsLandScope.jpeg",
    ROOT / "assets/mindMap/waveLandScope.jpeg",
]


def main() -> None:
    py = sys.executable
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for image in IMAGES:
        if not image.exists():
            print(f"skip (missing): {image}", file=sys.stderr)
            continue
        out = OUT_DIR / f"{image.stem}.json"
        print(f"OCR {image.name} -> {out.relative_to(ROOT)}")
        subprocess.check_call([py, str(OCR_PY), str(image), str(out)])


if __name__ == "__main__":
    main()
