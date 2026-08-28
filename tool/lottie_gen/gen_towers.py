"""Generates `assets/models/tower_<UnitType.name>.json` Lottie files that
port the base-plate geometry from
`lib/features/towers/presentation/tower_sprites.dart`'s `_paintBase` (the
shared hex plate used by 11 of the 13 tower/building types) and its two
bespoke building shapes (`_paintTrainingCenterBase`, `_paintWarFactoryBase`).

Turrets are intentionally NOT ported - see `assets/models/README.md`: a
turret's rotation logic depends on it staying a separate procedural Flame
component, so only the static base plate is replaced here. Run with:

    tool/lottie_gen/.venv/bin/python3 tool/lottie_gen/gen_towers.py
"""
import math
import os

from lottie_shapes import (
    circle,
    fill,
    gradient_fill,
    line_shape,
    op,
    polygon,
    rrect,
    stroke,
    write_layer,
)

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "models")

SIZE = 64
CX = CY = 32.0

# Matches `TowerSpriteFactory.accentColor` - every one of these types
# shares the same hex-plate base shape and only differs by this color.
HEX_PLATE_TYPES = {
    "machineGun": 0xFF4FC3F7,
    "rocket": 0xFFFF6B35,
    "cannon": 0xFFFFC107,
    "antiAir": 0xFF7C4DFF,
    "laser": 0xFFFF3D9A,
    "rocketSilo": 0xFFFF8A00,
    "artilleryBunker": 0xFF8D6E63,
    "sam": 0xFF00E5FF,
    "techLab": 0xFF1DE9B6,
    "commandPost": 0xFFFFD54A,
    "goldMine": 0xFFFFB300,
}


def hex_plate(accent):
    pts = []
    for i in range(6):
        a = math.pi / 6 + i * math.pi / 3
        pts.append((CX + math.cos(a) * 28, CY + math.sin(a) * 28))
    plate = polygon(pts)
    hole = circle(CX, CY, 10)
    return [
        op(plate, gradient_fill([0xFF636D7A, 0xFF20242A], CX, CY, 60, 60, "diagonal")),
        op(plate, stroke(accent, 2, alpha=0.85)),
        op(hole, fill(0xFF11151A)),
        op(hole, stroke(accent, 1.5)),
    ]


def training_center_base():
    accent = 0xFF66BB6A
    body = rrect(32, 42, 44, 28, 4)
    roof = polygon([(6, 28), (32, 9), (58, 28)])
    door = rrect(32, 48, 10, 16, 2)
    ops = [
        op(body, gradient_fill([0xFF4C7A4F, 0xFF20242A], 32, 42, 44, 28, "diagonal")),
        op(body, stroke(accent, 2, alpha=0.85)),
        op(roof, fill(0xFF2F4A31)),
        op(roof, stroke(accent, 1.5)),
        op(door, fill(0xFF11151A)),
    ]
    for dx in (-14, 14):
        window = rrect(32 + dx, 37, 8, 8, 1.5)
        ops.append(op(window, fill(0xFF11151A)))
        ops.append(op(window, stroke(accent, 1)))
    return ops


def war_factory_base():
    accent = 0xFFB0BEC5
    body = rrect(32, 41, 52, 30, 3)
    ops = [
        op(body, gradient_fill([0xFF607D8B, 0xFF20242A], 32, 41, 52, 30, "diagonal")),
        op(body, stroke(accent, 2, alpha=0.85)),
    ]
    x = 12.0
    while x <= 52:
        ops.append(op(line_shape((x, 26), (x, 19)), stroke(0xFF37474F, 2)))
        x += 8
    door = rrect(32, 48, 20, 16, 2)
    ops.append(op(door, fill(0xFF11151A)))
    y = 43.0
    while y < 56:
        ops.append(op(line_shape((24, y), (40, y)), stroke(accent, 1, alpha=0.5)))
        y += 4
    return ops


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for name, accent in HEX_PLATE_TYPES.items():
        write_layer(hex_plate(accent), SIZE, SIZE, os.path.join(OUT_DIR, f"tower_{name}.json"))
    write_layer(training_center_base(), SIZE, SIZE, os.path.join(OUT_DIR, "tower_trainingCenter.json"))
    write_layer(war_factory_base(), SIZE, SIZE, os.path.join(OUT_DIR, "tower_warFactory.json"))


if __name__ == "__main__":
    main()
