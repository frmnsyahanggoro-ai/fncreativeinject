#!/usr/bin/env python3
"""
Magisk banner 1024×500 — premium FN CREATIVE (navy/black, glow cyan + gold, Orbitron/techno).

Layout: FN CREATIVE → [LOGO] → Android Props Engine → Powered by FN CREATIVE
Logo: module/branding/logo.png atau fn_logo.png

Powered by FN CREATIVE.
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFilter, ImageFont
except ImportError:
    print("Install Pillow: pip install pillow", file=sys.stderr)
    sys.exit(1)

ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "module"
OUT = MODULE / "banner.png"
LOGO_CANDIDATES = [
    MODULE / "branding" / "logo.png",
    MODULE / "branding" / "fn_logo.png",
]

W, H = 1024, 500
BG_TOP = (6, 10, 26)
BG_BOT = (0, 0, 2)
CYAN = (34, 211, 238)
CYAN_GLOW = (56, 189, 248)
GOLD = (250, 204, 21)
GOLD_SOFT = (234, 179, 8)
GOLD_MUTED = (180, 150, 90)
WHITE = (248, 250, 252)
TEXT_MUTED = (148, 163, 184)


def font_candidates() -> list[Path]:
    if sys.platform == "win32":
        wf = Path(os.environ.get("WINDIR", r"C:\Windows")) / "Fonts"
        return [
            wf / "Orbitron-Bold.ttf",
            wf / "Orbitron-Regular.ttf",
            wf / "Montserrat-Bold.ttf",
            wf / "segoeuib.ttf",
            wf / "segoeui.ttf",
            wf / "arialbd.ttf",
        ]
    return [
        Path("/usr/share/fonts/truetype/orbitron/Orbitron-Bold.ttf"),
        Path("/usr/share/fonts/truetype/orbitron/Orbitron-Regular.ttf"),
        Path("/usr/share/fonts/truetype/montserrat/Montserrat-Bold.ttf"),
        Path("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"),
    ]


def load_font(size: int, prefer_bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    paths = font_candidates()
    if prefer_bold:
        paths = sorted(paths, key=lambda p: 0 if "Bold" in p.name or "Orbitron" in p.name else 1)
    for path in paths:
        if path.is_file():
            try:
                return ImageFont.truetype(str(path), size)
            except OSError:
                continue
    return ImageFont.load_default()


def draw_v_gradient(img: Image.Image, top: tuple[int, int, int], bot: tuple[int, int, int]) -> None:
    px = img.load()
    for y in range(H):
        t = y / max(1, H - 1)
        r = int(top[0] * (1 - t) + bot[0] * t)
        g = int(top[1] * (1 - t) + bot[1] * t)
        b = int(top[2] * (1 - t) + bot[2] * t)
        for x in range(W):
            px[x, y] = (r, g, b)


def text_width(d: ImageDraw.ImageDraw, text: str, font: ImageFont.ImageFont) -> float:
    if hasattr(d, "textlength"):
        return float(d.textlength(text, font=font))
    b = d.textbbox((0, 0), text, font=font)
    return float(b[2] - b[0])


def draw_glow_text(
    base: Image.Image,
    xy: tuple[int, int],
    text: str,
    font: ImageFont.ImageFont,
    fill: tuple[int, int, int],
    glow: tuple[int, int, int],
) -> None:
    d = ImageDraw.Draw(base)
    gx, gy = xy
    for ox, oy in ((2, 0), (-2, 0), (0, 2), (0, -2), (2, 2), (-2, -2)):
        d.text((gx + ox, gy + oy), text, font=font, fill=glow)
    d.text((gx, gy), text, font=font, fill=fill)


def main() -> int:
    MODULE.mkdir(parents=True, exist_ok=True)
    (MODULE / "branding").mkdir(parents=True, exist_ok=True)

    img = Image.new("RGB", (W, H), BG_TOP)
    draw_v_gradient(img, BG_TOP, BG_BOT)
    draw = ImageDraw.Draw(img)

    margin = 6
    for i, col in enumerate((CYAN_GLOW, GOLD_SOFT)):
        off = margin - i
        draw.rectangle((off, off, W - 1 - off, H - 1 - off), outline=col, width=1)

    font_title = load_font(46, prefer_bold=True)
    font_mid = load_font(28, prefer_bold=True)
    font_tag = load_font(22)
    font_foot = load_font(13)

    title = "FN CREATIVE"
    tw = text_width(draw, title, font_title)
    tx = (W - tw) // 2
    ty = 34
    img_rgba = img.convert("RGBA")
    draw_glow_text(img_rgba, (tx, ty), title, font_title, GOLD, (*CYAN, 120))
    img = img_rgba.convert("RGB")
    draw = ImageDraw.Draw(img)

    y_cursor = ty + 58

    logo_path = next((p for p in LOGO_CANDIDATES if p.is_file()), None)
    if logo_path:
        logo = Image.open(logo_path).convert("RGBA")
        max_h = 195
        ratio = max_h / max(1, logo.height)
        nw = max(1, int(logo.width * ratio))
        nh = max(1, int(logo.height * ratio))
        logo = logo.resize((nw, nh), Image.Resampling.LANCZOS)
        x0 = (W - nw) // 2
        y0 = y_cursor
        pad = 28
        sheet = Image.new("RGBA", (nw + pad * 2, nh + pad * 2), (0, 0, 0, 0))
        sheet.paste(logo, (pad, pad), logo)
        glow_g = sheet.filter(ImageFilter.GaussianBlur(18))
        glow_c = sheet.filter(ImageFilter.GaussianBlur(10))
        base = img.convert("RGBA")
        gold_tint = Image.new("RGBA", glow_g.size, (*GOLD_SOFT, 0))
        gold_tint.putalpha(glow_g.split()[3])
        cyan_tint = Image.new("RGBA", glow_c.size, (*CYAN, 0))
        cyan_tint.putalpha(glow_c.split()[3])
        base.paste(gold_tint, (x0 - pad, y0 - pad), gold_tint)
        base.paste(cyan_tint, (x0 - pad + 2, y0 - pad - 2), cyan_tint)
        base.paste(logo, (x0, y0), logo)
        img = base.convert("RGB")
        draw = ImageDraw.Draw(img)
        y_cursor = y0 + nh + 30
    else:
        cx, cy = W // 2, y_cursor + 80
        r = 68
        halo = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        hd = ImageDraw.Draw(halo)
        hd.ellipse((cx - r - 18, cy - r - 18, cx + r + 18, cy + r + 18), fill=(*CYAN, 55))
        halo = halo.filter(ImageFilter.GaussianBlur(16))
        hb = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        hbDraw = ImageDraw.Draw(hb)
        hbDraw.ellipse((cx - r - 10, cy - r - 10, cx + r + 10, cy + r + 10), fill=(*GOLD, 40))
        hb = hb.filter(ImageFilter.GaussianBlur(10))
        base = img.convert("RGBA")
        base.paste(halo, (0, 0), halo)
        base.paste(hb, (0, 0), hb)
        img = base.convert("RGB")
        draw = ImageDraw.Draw(img)
        draw.ellipse((cx - r, cy - r, cx + r, cy + r), outline=CYAN, width=3)
        fn_f = load_font(32, prefer_bold=True)
        t = "FN"
        twf = text_width(draw, t, fn_f)
        draw.text((cx - int(twf // 2), cy - 16), t, fill=GOLD, font=fn_f)
        y_cursor = cy + r + 34

    line_mid = "Android Props Engine"
    wm = text_width(draw, line_mid, font_mid)
    draw.text(((W - wm) // 2, y_cursor), line_mid, fill=CYAN, font=font_mid)
    y_cursor += 44

    line_lo = "Powered by FN CREATIVE"
    wl = text_width(draw, line_lo, font_tag)
    draw.text(((W - wl) // 2, y_cursor), line_lo, fill=GOLD_MUTED, font=font_tag)

    foot = "1024×500  ·  FN CREATIVE  ·  v25 Final"
    wf = text_width(draw, foot, font_foot)
    draw.text(((W - wf) // 2, H - 38), foot, fill=(71, 85, 105), font=font_foot)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.save(OUT, "PNG", optimize=True)
    print(f"Wrote {OUT} (logo={'yes' if logo_path else 'no; add module/branding/logo.png'})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
