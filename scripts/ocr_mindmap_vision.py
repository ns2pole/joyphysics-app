#!/usr/bin/env python3
"""OCR mind-map landscape images via macOS Vision (pyobjc)."""

from __future__ import annotations

import json
import sys
from pathlib import Path

import Quartz
import Vision
from Cocoa import NSURL
from Foundation import NSData


def ocr_image(path: Path) -> list[dict]:
    url = NSURL.fileURLWithPath_(str(path.resolve()))
    # Load via CGImageSource for reliable CGImage
    src = Quartz.CGImageSourceCreateWithURL(url, None)
    if src is None:
        raise RuntimeError(f"Cannot open image: {path}")
    cg_image = Quartz.CGImageSourceCreateImageAtIndex(src, 0, None)
    if cg_image is None:
        raise RuntimeError(f"Cannot decode image: {path}")

    request = Vision.VNRecognizeTextRequest.alloc().init()
    request.setRecognitionLevel_(Vision.VNRequestTextRecognitionLevelAccurate)
    request.setUsesLanguageCorrection_(False)
    path_s = str(path)
    languages = (
        ["en-US"]
        if "/en/" in path_s or path.stem.endswith("_en")
        else ["ja-JP", "en-US"]
    )
    try:
        request.setRecognitionLanguages_(languages)
    except Exception:
        pass

    handler = Vision.VNImageRequestHandler.alloc().initWithCGImage_options_(
        cg_image, None
    )
    ok = handler.performRequests_error_([request], None)
    if not ok:
        raise RuntimeError("Vision performRequests failed")

    boxes: list[dict] = []
    for obs in request.results() or []:
        candidates = obs.topCandidates_(1)
        if not candidates:
            continue
        cand = candidates[0]
        text = str(cand.string()).replace("\n", "").strip()
        if not text:
            continue
        # Vision: origin bottom-left, normalized
        r = obs.boundingBox()
        left = float(r.origin.x)
        width = float(r.size.width)
        height = float(r.size.height)
        top = float(1.0 - r.origin.y - r.size.height)
        boxes.append(
            {
                "text": text,
                "left": left,
                "top": top,
                "width": width,
                "height": height,
                "confidence": float(cand.confidence()),
            }
        )

    boxes.sort(key=lambda b: (b["top"], b["left"]))
    return boxes


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: ocr_mindmap_vision.py <image> [out.json]", file=sys.stderr)
        sys.exit(1)
    image = Path(sys.argv[1])
    boxes = ocr_image(image)
    out = json.dumps(boxes, ensure_ascii=False, indent=2)
    if len(sys.argv) >= 3:
        Path(sys.argv[2]).write_text(out + "\n", encoding="utf-8")
        print(f"wrote {sys.argv[2]} ({len(boxes)} boxes)", file=sys.stderr)
    else:
        print(out)


if __name__ == "__main__":
    main()
