"""Reusable helpers for hand-authoring static Lottie/Bodymovin JSON shape
layers that faithfully port the existing procedural `Canvas`-paint sprite
recipes (see `lib/features/allies/presentation/ally_sprites.dart`,
`lib/features/enemies/presentation/enemy_sprites.dart` and
`lib/features/towers/presentation/tower_sprites.dart`) into `.json` model
files consumed by `LottieUnitRenderRepositoryImpl`
(`lib/core/rendering/impl/lottie_unit_render_repository_impl.dart`) via
`flame_lottie`.

Each generated file is a single, static (1-frame) composition - the goal is
a 1:1 faithful re-encoding of the current baked sprite geometry/colors as
an editable vector asset, NOT a redesign. Per-frame animation (bobbing,
rotor spin, recoil) stays owned by the existing Flame components and is
intentionally NOT baked into these files.

Coordinate system matches Dart's `Canvas` exactly: origin top-left, y-down,
same units - so geometry can be transcribed directly from the paint
methods without any flips or rescaling.

Shape stacking order follows Lottie/Bodymovin ("front-to-back", i.e. the
first item in a shapes array is the *topmost*) - the OPPOSITE of a
`Canvas`'s back-to-front paint order. `build_layer` takes ops in the same
chronological order the Dart code paints them (first call = bottom-most)
and reverses them automatically so callers never have to think about it.
"""
from __future__ import annotations

import copy
import json
from typing import Iterable

from lottie import objects


def _static(k):
    return {"a": 0, "k": k}


def _identity_transform():
    return {
        "ty": "tr",
        "a": _static([0, 0]),
        "p": _static([0, 0]),
        "s": _static([100, 100]),
        "r": _static(0),
        "o": _static(100),
        "sk": _static(0),
        "sa": _static(0),
    }


def rgb_alpha(argb: int, alpha: float | None = None) -> tuple[list[float], float]:
    """Splits a Dart `0xAARRGGBB` color int into a Lottie RGB triple (0-1
    floats, alpha baked out) plus a separate 0-1 alpha - mirrors how Dart's
    `Color(0xAARRGGBB)` / `.withValues(alpha: x)` pattern is used in the
    source paint methods. `alpha`, if given, overrides the color's own
    alpha nibble (matching `.withValues(alpha: x)`)."""
    a = alpha if alpha is not None else ((argb >> 24) & 0xFF) / 255
    r = ((argb >> 16) & 0xFF) / 255
    g = ((argb >> 8) & 0xFF) / 255
    b = (argb & 0xFF) / 255
    return [r, g, b, 1.0], a


# --- shapes ------------------------------------------------------------


def rrect(cx: float, cy: float, w: float, h: float, radius: float = 0):
    return {"ty": "rc", "d": 1, "p": _static([cx, cy]), "s": _static([w, h]), "r": _static(radius)}


def rect(cx: float, cy: float, w: float, h: float):
    return rrect(cx, cy, w, h, 0)


def ellipse(cx: float, cy: float, w: float, h: float):
    return {"ty": "el", "d": 1, "p": _static([cx, cy]), "s": _static([w, h])}


def circle(cx: float, cy: float, r: float):
    return ellipse(cx, cy, r * 2, r * 2)


def polygon(points: Iterable[tuple[float, float]], closed: bool = True):
    """A straight-edged polygon path (mirrors a Dart `Path` built purely
    from `moveTo`/`lineTo`/`close`, as used for torsos, wings, etc.)."""
    pts = [list(p) for p in points]
    zero = [0, 0]
    bezier = {
        "i": [zero[:] for _ in pts],
        "o": [zero[:] for _ in pts],
        "v": pts,
        "c": closed,
    }
    return {"ty": "sh", "d": 1, "ks": _static(bezier)}


def line_shape(p1: tuple[float, float], p2: tuple[float, float]):
    """An open 2-point path, meant to be paired with a `stroke()` style -
    mirrors a Dart `canvas.drawLine`."""
    return polygon([p1, p2], closed=False)


def bounds(points: Iterable[tuple[float, float]]):
    """Axis-aligned bounding box (cx, cy, w, h) of `points` - mirrors
    Dart's `Path.getBounds()`, used to size a gradient shader rect for
    polygon shapes (e.g. the torso trapezoid)."""
    xs = [p[0] for p in points]
    ys = [p[1] for p in points]
    minx, maxx = min(xs), max(xs)
    miny, maxy = min(ys), max(ys)
    return (minx + maxx) / 2, (miny + maxy) / 2, maxx - minx, maxy - miny


# --- styles --------------------------------------------------------------


def fill(argb: int, alpha: float | None = None):
    color, a = rgb_alpha(argb, alpha)
    return {"ty": "fl", "c": _static(color), "o": _static(round(a * 100, 3)), "r": 1}


def stroke(argb: int, width: float, alpha: float | None = None, round_cap: bool = False):
    color, a = rgb_alpha(argb, alpha)
    return {
        "ty": "st",
        "c": _static(color),
        "o": _static(round(a * 100, 3)),
        "w": _static(width),
        "lc": 2 if round_cap else 1,
        "lj": 1,
    }


def _gradient_points(cx, cy, w, h, direction: str):
    """Computes absolute start/end points for a 2-stop linear gradient,
    mirroring Flutter's `Alignment`-based `LinearGradient` conventions used
    in the source (`topCenter`->`bottomCenter` is by far the most common;
    a bare `LinearGradient(colors: [...])` with no begin/end defaults to
    `centerLeft`->`centerRight`)."""
    left, right = cx - w / 2, cx + w / 2
    top, bottom = cy - h / 2, cy + h / 2
    if direction == "vertical":  # topCenter -> bottomCenter
        return (cx, top), (cx, bottom)
    if direction == "diagonal":  # topLeft -> bottomRight
        return (left, top), (right, bottom)
    # "horizontal": centerLeft -> centerRight (Flutter's un-specified default)
    return (left, cy), (right, cy)


def gradient_fill(
    colors: list[int],
    cx: float,
    cy: float,
    w: float,
    h: float,
    direction: str = "vertical",
):
    """A 2+ stop linear-gradient fill over the shape's own bounding box -
    mirrors `Paint()..shader = LinearGradient(colors: [...]).createShader(rect)`.
    Every gradient in the source art is fully opaque, so alpha isn't
    supported here (keeps the color-stop encoding simple)."""
    start, end = _gradient_points(cx, cy, w, h, direction)
    stops = []
    n = len(colors)
    for i, argb in enumerate(colors):
        offset = i / (n - 1) if n > 1 else 0
        (r, g, b, _a) = rgb_alpha(argb)[0]
        stops += [offset, r, g, b]
    return {
        "ty": "gf",
        "o": _static(100),
        "s": _static(list(start)),
        "e": _static(list(end)),
        "t": 1,
        "g": {"p": n, "k": _static(stops)},
    }


# --- assembly ------------------------------------------------------------


def op(shape, *styles):
    """One paired (shape, style...) unit - mirrors a single Dart
    `canvas.draw*` call plus the `Paint` it was given. Wrapped in its own
    isolated Lottie group so styles never bleed across unrelated shapes."""
    return {"ty": "gr", "it": [shape, *styles, _identity_transform()]}


def build_layer(ops: list[dict], w: int, h: int) -> dict:
    """Builds a single shape layer containing `ops` (given in Dart
    chronological/back-to-front paint order) and wraps it in a full,
    static (1-frame) `Animation` dict ready to write to disk."""
    anim = objects.Animation(1, 30)
    anim.width = w
    anim.height = h
    layer = objects.ShapeLayer()
    anim.add_layer(layer)
    raw = anim.to_dict()
    raw["layers"][0]["shapes"] = list(reversed(copy.deepcopy(ops)))
    # Round-trip through the object model as a structural validity check -
    # raises if the hand-authored dict isn't valid Bodymovin/Lottie.
    objects.Animation.load(raw)
    return raw


def write_layer(ops: list[dict], w: int, h: int, out_path: str) -> None:
    data = build_layer(ops, w, h)
    with open(out_path, "w") as f:
        json.dump(data, f)
    print(f"wrote {out_path}")
