"""Generates the AutiMate launcher icon and splash mark.

Draws the same mascot the app renders in Dart, so the icon on the home
screen is the character the child meets inside. Colours come straight from
the design tokens in lib/core/theme/app_colors.dart.
"""
import os
from PIL import Image, ImageDraw

TEAL = (15, 118, 110, 255)      # palette.communicate
BELLY = (201, 233, 228, 255)    # accentTint(communicate, .72)
INK = (18, 34, 32, 255)
CANVAS = (246, 247, 245, 255)   # palette.canvas

OUT = 'assets/icon'
os.makedirs(OUT, exist_ok=True)


def mascot(size, background, pad_ratio):
    """Renders the mascot at `size` px, supersampled 4x for clean edges."""
    ss = 4
    s = size * ss
    img = Image.new('RGBA', (s, s), background)
    d = ImageDraw.Draw(img)

    cx = cy = s / 2
    r = s * pad_ratio

    def circle(x, y, rad, fill):
        d.ellipse([x - rad, y - rad, x + rad, y + rad], fill=fill)

    # Ears
    circle(cx - r * 0.62, cy - r * 0.80, r * 0.30, TEAL)
    circle(cx + r * 0.62, cy - r * 0.80, r * 0.30, TEAL)

    # Body
    bw, bh = r * 1.9, r * 1.8
    d.rounded_rectangle(
        [cx - bw / 2, cy - bh / 2 + s * 0.02,
         cx + bw / 2, cy + bh / 2 + s * 0.02],
        radius=r * 0.78, fill=TEAL,
    )

    # Belly patch
    d.ellipse(
        [cx - r * 0.62, cy - r * 0.50 + s * 0.04,
         cx + r * 0.62, cy + r * 0.65 + s * 0.04],
        fill=BELLY,
    )

    # Eyes
    eye = r * 0.10
    circle(cx - r * 0.34, cy - r * 0.02, eye, INK)
    circle(cx + r * 0.34, cy - r * 0.02, eye, INK)

    # Smile
    mw, mh = r * 0.52, r * 0.40
    d.arc(
        [cx - mw / 2, cy + r * 0.18, cx + mw / 2, cy + r * 0.18 + mh],
        start=20, end=160, fill=INK, width=int(r * 0.085),
    )

    return img.resize((size, size), Image.LANCZOS)


# Full-bleed launcher icon (legacy + iOS).
mascot(1024, CANVAS, 0.30).save(f'{OUT}/app_icon.png')

# Adaptive foreground: transparent, with the safe-zone inset Android crops to.
mascot(1024, (0, 0, 0, 0), 0.22).save(f'{OUT}/app_icon_foreground.png')

# Splash mark on the canvas ground.
mascot(768, CANVAS, 0.30).save(f'{OUT}/splash.png')

print('wrote', os.listdir(OUT))
