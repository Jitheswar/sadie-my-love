"""Oklch colour maths shared by the theme's generators.

Every generated artefact in this theme is the reference palette under a hue
rotation derived from the wallpaper. The rotation is done in Oklch because it
is perceptually even across the whole palette; a naive HSL rotation swings the
yellows far more than the reds and pulls the palette apart. Lightness and
chroma are never touched, so contrast ratios and tonal separation survive the
rotation by construction rather than by luck.
"""

import math


def _srgb_to_linear(c):
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def _linear_to_srgb(c):
    return 12.92 * c if c <= 0.0031308 else 1.055 * (c ** (1 / 2.4)) - 0.055


def hex_to_oklch(hex_str):
    h = hex_str.lstrip("#")
    r, g, b = (_srgb_to_linear(int(h[i:i + 2], 16) / 255) for i in (0, 2, 4))
    l = (0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b) ** (1 / 3)
    m = (0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b) ** (1 / 3)
    s = (0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b) ** (1 / 3)
    L = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s
    a = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s
    bb = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
    return L, math.hypot(a, bb), math.degrees(math.atan2(bb, a)) % 360


def _to_linear_rgb(L, C, H):
    a = C * math.cos(math.radians(H))
    b = C * math.sin(math.radians(H))
    l = (L + 0.3963377774 * a + 0.2158037573 * b) ** 3
    m = (L - 0.1055613458 * a - 0.0638541728 * b) ** 3
    s = (L - 0.0894841775 * a - 1.2914855480 * b) ** 3
    return (+4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
            -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
            -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s)


def oklch_to_hex(L, C, H):
    out = []
    for v in _to_linear_rgb(L, C, H):
        v = _linear_to_srgb(v)
        out.append(max(0, min(255, round(v * 255))))
    return "#{:02x}{:02x}{:02x}".format(*out)


def in_gamut(L, C, H):
    return all(-0.0005 <= v <= 1.0005 for v in _to_linear_rgb(L, C, H))


def clip_to_gamut(L, C, H):
    """Reduce chroma until the colour is representable, keeping L and H.

    Lightness is what carries the contrast guarantee, so chroma is the only
    axis allowed to give way.
    """
    if in_gamut(L, C, H):
        return L, C, H
    lo, hi = 0.0, C
    for _ in range(24):
        mid = (lo + hi) / 2
        if in_gamut(L, mid, H):
            lo = mid
        else:
            hi = mid
    return L, lo, H


def rotate(hex_str, degrees, damping=1.0):
    """Rotate one colour's hue, preserving lightness and chroma.

    `damping` scales the rotation for near-neutral slots: a full hue shift on
    something with almost no chroma reads as a colour cast on what should be
    plain text or plain surface.
    """
    L, C, H = hex_to_oklch(hex_str)
    L, C, H = clip_to_gamut(L, C, (H + degrees * damping) % 360)
    return oklch_to_hex(L, C, H)


def hue_delta(from_hex, to_hex):
    """Signed shortest angular distance between two colours' hues, in degrees."""
    a = hex_to_oklch(from_hex)[2]
    b = hex_to_oklch(to_hex)[2]
    return ((b - a + 180) % 360) - 180
