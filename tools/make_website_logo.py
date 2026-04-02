#!/usr/bin/env python3
"""Generate website/logo.png — simple FN mark (replace with brand asset if you have one)."""
from __future__ import annotations

import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("pip install pillow", file=sys.stderr)
    sys.exit(1)

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "website" / "logo.png"
W = H = 256
BG = (11, 17, 32, 255)
ACCENT = (37, 99, 235, 255)


def main() -> int:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    img = Image.new("RGBA", (W, H), BG)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((8, 8, W - 9, H - 9), radius=24, outline=ACCENT, width=3)
    font = None
    for path in (
        Path(r"C:\Windows\Fonts\segoeuib.ttf"),
        Path(r"C:\Windows\Fonts\arialbd.ttf"),
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    ):
        p = Path(path)
        if p.is_file():
            try:
                font = ImageFont.truetype(str(p), 72)
                break
            except OSError:
                continue
    if font is None:
        font = ImageFont.load_default()
    text = "FN"
    x0, y0, x1, y1 = d.textbbox((0, 0), text, font=font)
    tw, th = x1 - x0, y1 - y0
    d.text(((W - tw) // 2, (H - th) // 2 - 6), text, fill=(248, 250, 252, 255), font=font)
    img.save(OUT, "PNG")
    print("Wrote", OUT)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
