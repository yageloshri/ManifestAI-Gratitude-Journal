#!/usr/bin/env python3
"""Pixel-diff a simulator screenshot against a Figma reference export.

Usage: diff.py <figma.png> <app.png> <diff_out.png> [--crop-top PX] [--crop-bottom PX]

Outputs the percentage of differing pixels (anti-aliasing aware, pixelmatch
threshold 0.1) and writes a highlighted diff image. Also reports the worst
mismatch regions on a 12x12 grid to help localize problems.
"""
import sys
import numpy as np
from PIL import Image
from pixelmatch.contrib.PIL import pixelmatch


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    figma_path, app_path, out_path = args[0], args[1], args[2]
    crop_top = crop_bottom = 0
    for a in sys.argv[1:]:
        if a.startswith("--crop-top="):
            crop_top = int(a.split("=")[1])
        if a.startswith("--crop-bottom="):
            crop_bottom = int(a.split("=")[1])

    fig = Image.open(figma_path).convert("RGBA")
    app = Image.open(app_path).convert("RGBA")

    if fig.size != app.size:
        print(f"FATAL: size mismatch figma={fig.size} app={app.size}")
        sys.exit(2)

    w, h = fig.size
    if crop_top or crop_bottom:
        box = (0, crop_top, w, h - crop_bottom)
        fig = fig.crop(box)
        app = app.crop(box)
        w, h = fig.size

    diff = Image.new("RGBA", (w, h))
    mismatched = pixelmatch(fig, app, diff, threshold=0.1, includeAA=False)
    total = w * h
    pct = 100.0 * mismatched / total
    diff.save(out_path)
    print(f"diff_pixels={mismatched} total={total} pct={pct:.3f}%")

    # localize worst regions on a 12x12 grid
    d = np.array(diff)
    # pixelmatch marks differing pixels in red/yellow tones; alpha>0 & red channel high
    mask = (d[:, :, 0] > 200) & (d[:, :, 1] < 150)
    gh, gw = 12, 12
    cells = []
    for gy in range(gh):
        for gx in range(gw):
            y0, y1 = h * gy // gh, h * (gy + 1) // gh
            x0, x1 = w * gx // gw, w * (gx + 1) // gw
            frac = mask[y0:y1, x0:x1].mean()
            if frac > 0.01:
                cells.append((frac, gx, gy, x0, y0, x1, y1))
    cells.sort(reverse=True)
    for frac, gx, gy, x0, y0, x1, y1 in cells[:10]:
        print(f"region grid=({gx},{gy}) px=({x0},{y0})-({x1},{y1}) mismatch={frac*100:.1f}%")

    print("PASS" if pct < 2.0 else "FAIL")


if __name__ == "__main__":
    main()
