"""Draws the ShopSphere mark (an ink sphere with a tilted orbit and one moon) at 1024 px.

    python tool/generate_icon.py     # writes assets/images/app_icon*.png

The same geometry is repainted in Dart by lib/core/widgets/orbit_logo.dart, so the launcher
icon and the in-app logo stay identical.
"""
import math
import os

from PIL import Image, ImageDraw, ImageFilter

S = 4096                      # work at 4x, then scale down for clean edges
INK, VOLT, CORAL = (16, 17, 20), (212, 255, 63), (255, 94, 77)
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'images')


def ring_layer(front: bool, width: int, colour, a: float, b: float, tilt: float) -> Image.Image:
    """Half of the orbit ellipse (back = upper half, front = lower half), tilted about the centre."""
    layer = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    box = [S / 2 - a, S / 2 - b, S / 2 + a, S / 2 + b]
    d.arc(box, 0 if front else 180, 180 if front else 360, fill=colour, width=width)
    return layer.rotate(tilt, resample=Image.BICUBIC, center=(S / 2, S / 2))


def mark(scale: float = 1.0) -> Image.Image:
    k = S / 1024 * scale
    a, b, tilt = 300 * k, 104 * k, 24
    img = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    img.alpha_composite(ring_layer(False, int(22 * k), INK + (255,), a, b, tilt))
    # the sphere, lit from the upper left
    r = 188 * k
    sphere = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    ImageDraw.Draw(sphere).ellipse([S / 2 - r, S / 2 - r, S / 2 + r, S / 2 + r], fill=INK + (255,))
    glow = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    gr = r * 0.62
    cx, cy = S / 2 - r * 0.34, S / 2 - r * 0.38
    ImageDraw.Draw(glow).ellipse([cx - gr, cy - gr, cx + gr, cy + gr], fill=(255, 255, 255, 70))
    glow = glow.filter(ImageFilter.GaussianBlur(r * 0.22))
    mask = sphere.split()[3]
    glow.putalpha(Image.composite(glow.split()[3], Image.new('L', (S, S), 0), mask))
    sphere.alpha_composite(glow)
    img.alpha_composite(sphere)
    # front half of the orbit: a volt halo first so it reads where it crosses the ink sphere
    img.alpha_composite(ring_layer(True, int(54 * k), VOLT + (255,), a, b, tilt))
    img.alpha_composite(ring_layer(True, int(22 * k), INK + (255,), a, b, tilt))
    # the moon, sitting on the front of the orbit
    t = math.radians(62)
    ex, ey = a * math.cos(t), b * math.sin(t)
    c, s_ = math.cos(math.radians(-tilt)), math.sin(math.radians(-tilt))
    mx, my = S / 2 + ex * c - ey * s_, S / 2 + ex * s_ + ey * c
    mr = 40 * k
    d = ImageDraw.Draw(img)
    d.ellipse([mx - mr - 14 * k, my - mr - 14 * k, mx + mr + 14 * k, my + mr + 14 * k], fill=VOLT + (255,))
    d.ellipse([mx - mr, my - mr, mx + mr, my + mr], fill=CORAL + (255,))
    return img


def down(img: Image.Image) -> Image.Image:
    return img.resize((1024, 1024), Image.LANCZOS)


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    full = Image.new('RGBA', (S, S), VOLT + (255,))
    full.alpha_composite(mark(0.92))
    down(full).convert('RGB').save(os.path.join(OUT, 'app_icon.png'))
    down(mark(0.84)).save(os.path.join(OUT, 'app_icon_foreground.png'))   # adaptive icons keep to a smaller safe zone
    down(mark(1.0)).save(os.path.join(OUT, 'logo_mark.png'))
    print('wrote app_icon.png, app_icon_foreground.png, logo_mark.png to', os.path.normpath(OUT))
