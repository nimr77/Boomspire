"""Generates `assets/models/{ally,enemy}_<UnitKind.name>.json` Lottie files
that faithfully port the static shape geometry from
`lib/features/allies/presentation/ally_sprites.dart` and
`lib/features/enemies/presentation/enemy_sprites.dart`.

Each `*_unit` function below mirrors one Dart `_paint*` method line-for-line
(same `size`/`center` variables, same multipliers) so it can be diffed
against the source by eye. Run with:

    tool/lottie_gen/.venv/bin/python3 tool/lottie_gen/gen_units.py
"""
import os

from lottie_shapes import (
    bounds,
    circle,
    ellipse,
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

# --- shared building blocks ------------------------------------------------


def shadow(cx, cy, w, h, argb=0x40000000):
    return op(ellipse(cx, cy, w, h), fill(argb))


def legs(cx, cy, s, color):
    return [
        op(rrect(cx + dx, cy + 0.28 * s, 0.1 * s, 0.26 * s, 3), fill(color))
        for dx in (-0.075 * s, 0.075 * s)
    ]


def torso(cx, cy, s, colors):
    pts = [
        (cx - 0.26 * s, cy - 0.2 * s),
        (cx + 0.26 * s, cy - 0.2 * s),
        (cx + 0.17 * s, cy + 0.2 * s),
        (cx - 0.17 * s, cy + 0.2 * s),
    ]
    bx, by, bw, bh = bounds(pts)
    return polygon(pts), gradient_fill(colors, bx, by, bw, bh, "vertical")


def shoulder_pads(cx, cy, s, color_left, color_right=None):
    color_right = color_left if color_right is None else color_right
    return [
        op(rrect(cx + dx, cy - 0.18 * s, 0.13 * s, 0.1 * s, 2), fill(c))
        for dx, c in zip((-0.24 * s, 0.24 * s), (color_left, color_right))
    ]


def rifle(cx, cy, s, width):
    return op(
        line_shape((cx + 0.14 * s, cy - 0.12 * s), (cx + 0.34 * s, cy - 0.46 * s)),
        stroke(0xFF1A1A1A, width, round_cap=True),
    )


def helmet(cx, cy, s, dark, light, visor_bg, glint_color, glint_alpha=None, r_back=0.16, r_front=0.14):
    ops = [
        op(circle(cx, cy - 0.3 * s, r_back * s), fill(dark)),
        op(circle(cx, cy - 0.32 * s, r_front * s), fill(light)),
    ]
    vw, vh = 0.22 * s, 0.05 * s
    vcx, vcy = cx, cy - 0.3 * s
    ops.append(op(rrect(vcx, vcy, vw, vh, 2), fill(visor_bg)))
    gcx, gcy = vcx - vw * 0.22, vcy - 0.6
    ops.append(op(rrect(gcx, gcy, vw * 0.32, vh * 0.5, 1), fill(glint_color, alpha=glint_alpha)))
    return ops


def wheel_grid(cx, cy, s, dxs, dys, w, h, r, color=0xFF0D0D0D):
    return [
        op(rrect(cx + dx, cy + dy, w, h, r), fill(color))
        for dy in dys
        for dx in dxs
    ]


# --- ally (cyan livery) ------------------------------------------------

HULL = 0xFF2B3A42
HULL_DARK = 0xFF172126
ACCENT = 0xFF00E5FF


def ally_aircraft():
    s = 50.0
    cx = cy = s / 2
    ops = [shadow(cx, cy, s * 0.7, s * 0.22)]
    wing_pts = [
        (cx, cy - 0.4 * s),
        (cx + 0.46 * s, cy + 0.34 * s),
        (cx + 0.1 * s, cy + 0.2 * s),
        (cx, cy + 0.4 * s),
        (cx - 0.1 * s, cy + 0.2 * s),
        (cx - 0.46 * s, cy + 0.34 * s),
    ]
    wing = polygon(wing_pts)
    r = 0.4 * s
    ops.append(op(wing, gradient_fill([0xFFCFD8DC, HULL], cx, cy, 2 * r, 2 * r, "vertical")))
    ops.append(op(wing, stroke(ACCENT, 1.5, alpha=0.8)))
    ops.append(op(ellipse(cx, cy - 0.06 * s, 0.13 * s, 0.28 * s), fill(0xFF1A1C20)))
    ops.append(op(ellipse(cx, cy - 0.1 * s, 0.08 * s, 0.14 * s), fill(ACCENT, alpha=0.9)))
    for dx in (-0.12 * s, 0.12 * s):
        ops.append(op(circle(cx + dx, cy + 0.36 * s, 0.06 * s), fill(ACCENT, alpha=0.7)))
    return ops, s, s


def ally_anti_air():
    s = 48.0
    cx = cy = s / 2
    weapon = 0xFFFFB300
    ops = [shadow(cx, cy + 0.3 * s, 0.5 * s, 0.18 * s, 0x59000000)]
    ops += legs(cx, cy, s, HULL_DARK)
    shape, style = torso(cx, cy, s, [HULL, HULL_DARK])
    ops.append(op(shape, style))
    ops.append(op(line_shape((cx, cy - 0.18 * s), (cx, cy + 0.18 * s)), stroke(weapon, 2, alpha=0.7)))
    ops += shoulder_pads(cx, cy, s, HULL_DARK)
    ops.append(op(line_shape((cx + 0.04 * s, cy - 0.12 * s), (cx + 0.36 * s, cy - 0.5 * s)),
                  stroke(0xFF2B2B2B, 5, round_cap=True)))
    ops.append(op(circle(cx + 0.36 * s, cy - 0.5 * s, 0.06 * s), fill(weapon)))
    ops += helmet(cx, cy, s, HULL_DARK, HULL, 0xFF0D1A1E, weapon, glint_alpha=0.9)
    return ops, s, s


def ally_anti_tank():
    s = 48.0
    cx = cy = s / 2
    weapon = 0xFFFF5252
    ops = [shadow(cx, cy + 0.3 * s, 0.5 * s, 0.18 * s, 0x59000000)]
    ops += legs(cx, cy, s, HULL_DARK)
    shape, style = torso(cx, cy, s, [HULL, HULL_DARK])
    ops.append(op(shape, style))
    ops.append(op(line_shape((cx, cy - 0.18 * s), (cx, cy + 0.18 * s)), stroke(weapon, 2, alpha=0.7)))
    ops += shoulder_pads(cx, cy, s, HULL_DARK)
    ops.append(op(line_shape((cx - 0.02 * s, cy - 0.14 * s), (cx + 0.44 * s, cy - 0.24 * s)),
                  stroke(0xFF2B2B2B, 6, round_cap=True)))
    ops.append(op(circle(cx + 0.44 * s, cy - 0.24 * s, 0.07 * s), fill(weapon)))
    ops += helmet(cx, cy, s, HULL_DARK, HULL, 0xFF0D1A1E, weapon, glint_alpha=0.9)
    return ops, s, s


def ally_soldier():
    s = 48.0
    cx = cy = s / 2
    ops = [shadow(cx, cy + 0.3 * s, 0.5 * s, 0.18 * s, 0x59000000)]
    ops += legs(cx, cy, s, HULL_DARK)
    shape, style = torso(cx, cy, s, [HULL, HULL_DARK])
    ops.append(op(shape, style))
    ops.append(op(line_shape((cx, cy - 0.18 * s), (cx, cy + 0.18 * s)), stroke(ACCENT, 2, alpha=0.7)))
    ops += shoulder_pads(cx, cy, s, HULL_DARK)
    ops.append(rifle(cx, cy, s, 3))
    ops += helmet(cx, cy, s, HULL_DARK, HULL, 0xFF0D1A1E, ACCENT, glint_alpha=0.9)
    return ops, s, s


def ally_tank():
    s = 54.0
    cx = cy = s / 2
    ops = [shadow(cx, cy, 0.85 * s, 0.3 * s)]
    ops += wheel_grid(cx, cy, s, (-0.36 * s, 0.36 * s), (0,), 0.14 * s, 0.66 * s, 3, 0xFF1A1C20)
    ops.append(op(rrect(cx, cy, 0.68 * s, 0.46 * s, 8), gradient_fill([HULL, HULL_DARK], cx, cy, 0.68 * s, 0.46 * s, "vertical")))
    ops.append(op(rrect(cx, cy, 0.68 * s, 0.46 * s, 8), stroke(ACCENT, 1.5, alpha=0.8)))
    turret = circle(cx, cy - 0.04 * s, 0.2 * s)
    ops.append(op(turret, gradient_fill([HULL, HULL_DARK], cx, cy, 0.4 * s, 0.4 * s, "horizontal")))
    ops.append(op(turret, stroke(ACCENT, 1.5)))
    ops.append(op(rrect(cx, cy - 0.34 * s, 0.1 * s, 0.4 * s, 3), fill(0xFF1A1C20)))
    return ops, s, s


def ally_light_vehicle():
    s = 46.0
    cx = cy = s / 2
    ops = [shadow(cx, cy, 0.8 * s, 0.26 * s)]
    ops.append(op(rrect(cx, cy, 0.56 * s, 0.6 * s, 8), gradient_fill([HULL, HULL_DARK], cx, cy, 0.56 * s, 0.6 * s, "vertical")))
    ops.append(op(rrect(cx, cy, 0.56 * s, 0.6 * s, 8), stroke(ACCENT, 1.5, alpha=0.8)))
    ops.append(op(rrect(cx, cy - 0.14 * s, 0.32 * s, 0.16 * s, 3), fill(ACCENT, alpha=0.55)))
    ops.append(op(rrect(cx, cy + 0.06 * s, 0.08 * s, 0.26 * s, 2), fill(0xFF1A1C20)))
    ops += wheel_grid(cx, cy, s, (-0.3 * s, 0.3 * s), (-0.22 * s, 0.22 * s), 0.12 * s, 0.2 * s, 2)
    return ops, s, s


def ally_rocket_barrage():
    s = 50.0
    cx = cy = s / 2
    ops = [shadow(cx, cy, 0.86 * s, 0.3 * s)]
    body = cx, cy + 0.1 * s
    ops.append(op(rrect(body[0], body[1], 0.62 * s, 0.56 * s, 6),
                  gradient_fill([HULL, HULL_DARK], body[0], body[1], 0.62 * s, 0.56 * s, "vertical")))
    ops.append(op(rrect(body[0], body[1], 0.62 * s, 0.56 * s, 6), stroke(ACCENT, 1.5, alpha=0.8)))
    pod = cx, cy - 0.22 * s
    ops.append(op(rrect(pod[0], pod[1], 0.5 * s, 0.3 * s, 4), fill(0xFF37474F)))
    for dx in (-0.16 * s, 0.0, 0.16 * s):
        ops.append(op(circle(cx + dx, cy - 0.22 * s, 0.06 * s), fill(ACCENT, alpha=0.9)))
    ops += wheel_grid(cx, cy, s, (-0.32 * s, 0.32 * s), (-0.06 * s, 0.32 * s), 0.14 * s, 0.22 * s, 2)
    return ops, s, s


# --- enemy (green infantry / grey-brown vehicles) --------------------------


def enemy_infantry(heavy: bool):
    s = 60.0 if heavy else 48.0
    cx = cy = s / 2
    body = 0xFF33691E if heavy else 0xFF4C7A2A
    dark = 0xFF1B3D0F if heavy else 0xFF2E4B18
    ops = [shadow(cx, cy + 0.3 * s, 0.5 * s, 0.18 * s, 0x59000000)]
    ops += legs(cx, cy, s, dark)
    shape, style = torso(cx, cy, s, [body, dark])
    ops.append(op(shape, style))
    if heavy:
        ops.append(op(rrect(cx, cy + 0.02 * s, 0.22 * s, 0.24 * s, 4), fill(0xFF263A17)))
    ops.append(op(line_shape((cx, cy - 0.18 * s), (cx, cy + 0.18 * s)), stroke(dark, 2)))
    pad = 0xFFB71C1C if heavy else dark
    ops += shoulder_pads(cx, cy, s, pad)
    ops.append(rifle(cx, cy, s, 4 if heavy else 3))
    ops += helmet(cx, cy, s, dark, body, 0xFF0D1A06, 0xCCBEEFFF, r_back=0.17, r_front=0.15)
    return ops, s, s


def enemy_anti_air_vehicle():
    s = 52.0
    cx = cy = s / 2
    ops = [shadow(cx, cy, 0.85 * s, 0.3 * s)]
    ops += wheel_grid(cx, cy, s, (-0.3 * s, 0.3 * s), (0.06 * s,), 0.13 * s, 0.6 * s, 3, 0xFF1A1C20)
    ops.append(op(rrect(cx, cy, 0.58 * s, 0.4 * s, 6),
                  gradient_fill([0xFF78909C, 0xFF263238], cx, cy, 0.58 * s, 0.4 * s, "vertical")))
    for dx in (-0.08 * s, 0.08 * s):
        ops.append(op(rrect(cx + dx, cy - 0.3 * s, 0.07 * s, 0.32 * s, 2), fill(0xFF2B2F36)))
    ops.append(op(circle(cx, cy - 0.02 * s, 0.13 * s), fill(0xFF37474F)))
    ops.append(op(circle(cx, cy - 0.02 * s, 0.08 * s), fill(0xFFFFCA28, alpha=0.85)))
    ops.append(op(circle(cx, cy + 0.16 * s, 0.045 * s), fill(0xFFFFF59D)))
    return ops, s, s


def enemy_artillery_barrage():
    s = 52.0
    cx = cy = s / 2
    ops = [shadow(cx, cy, 0.85 * s, 0.3 * s)]
    ops += wheel_grid(cx, cy, s, (-0.3 * s, 0.3 * s), (0.08 * s,), 0.14 * s, 0.58 * s, 3, 0xFF1A1C20)
    ops.append(op(rrect(cx, cy, 0.6 * s, 0.4 * s, 6),
                  gradient_fill([0xFF5D4037, 0xFF2E1A16], cx, cy, 0.6 * s, 0.4 * s, "vertical")))
    ops.append(op(rrect(cx, cy - 0.16 * s, 0.5 * s, 0.16 * s, 3), fill(0xFF3E2723)))
    for dx in (-0.14 * s, 0.0, 0.14 * s):
        ops.append(op(rrect(cx + dx, cy - 0.24 * s, 0.1 * s, 0.22 * s, 2), fill(0xFF3E2723)))
    ops.append(op(circle(cx, cy + 0.02 * s, 0.05 * s), fill(0xFFE53935)))
    return ops, s, s


def enemy_attack_plane():
    s = 50.0
    cx = cy = s / 2
    ops = [shadow(cx, cy, 0.7 * s, 0.22 * s)]
    wing_pts = [
        (cx, cy - 0.4 * s),
        (cx + 0.46 * s, cy + 0.34 * s),
        (cx + 0.1 * s, cy + 0.2 * s),
        (cx, cy + 0.4 * s),
        (cx - 0.1 * s, cy + 0.2 * s),
        (cx - 0.46 * s, cy + 0.34 * s),
    ]
    ops.append(op(polygon(wing_pts), gradient_fill([0xFFB0BEC5, 0xFF37474F], cx, cy, 0.8 * s, 0.8 * s, "vertical")))
    ops.append(op(ellipse(cx, cy - 0.06 * s, 0.13 * s, 0.28 * s), fill(0xFF1A1C20)))
    ops.append(op(ellipse(cx, cy - 0.1 * s, 0.08 * s, 0.14 * s), fill(0xCC00E5FF)))
    for dx in (-0.12 * s, 0.12 * s):
        ops.append(op(circle(cx + dx, cy + 0.36 * s, 0.07 * s), fill(0xFFFF7043)))
        ops.append(op(circle(cx + dx, cy + 0.36 * s, 0.035 * s), fill(0xFFFFF3C4)))
    return ops, s, s


def enemy_helicopter():
    s = 46.0
    cx = cy = s / 2
    ops = [shadow(cx, cy, 0.9 * s, 0.28 * s)]
    boom_pts = [
        (cx - 0.1 * s, cy - 0.08 * s),
        (cx - 0.46 * s, cy - 0.03 * s),
        (cx - 0.46 * s, cy + 0.05 * s),
        (cx - 0.1 * s, cy + 0.1 * s),
    ]
    ops.append(op(polygon(boom_pts), fill(0xFF37474F)))
    ops.append(op(circle(cx - 0.46 * s, cy, 0.1 * s), stroke(0x99B0BEC5, 1.6)))
    ops.append(op(rrect(cx + 0.06 * s, cy, 0.5 * s, 0.34 * s, 14),
                  gradient_fill([0xFF616161, 0xFF263238], cx + 0.06 * s, cy, 0.5 * s, 0.34 * s, "vertical")))
    for dy in (0.19 * s, 0.24 * s):
        ops.append(op(line_shape((cx - 0.1 * s, cy + dy), (cx + 0.24 * s, cy + dy)), stroke(0xFF1A1C20, 1.6)))
    cockpit = (cx + 0.26 * s, cy - 0.02 * s)
    ops.append(op(circle(*cockpit, 0.15 * s), fill(0xFF1A1C20)))
    ops.append(op(circle(*cockpit, 0.12 * s), fill(0xFFE53935)))
    ops.append(op(circle(*cockpit, 0.15 * s), stroke(0xFF9E9E9E, 1.5)))
    ops.append(op(circle(cockpit[0] - 0.04 * s, cockpit[1] - 0.04 * s, 0.03 * s), fill(0xCCFFFFFF)))
    ops.append(op(rrect(cx, cy - 0.16 * s, 0.06 * s, 0.14 * s, 2), fill(0xFF1A1C20)))
    return ops, s, s


def enemy_rocket_barrage():
    s = 50.0
    cx = cy = s / 2
    ops = [shadow(cx, cy, 0.86 * s, 0.3 * s)]
    body = cx, cy + 0.1 * s
    ops.append(op(rrect(body[0], body[1], 0.62 * s, 0.56 * s, 6),
                  gradient_fill([0xFF5D4037, 0xFF2E1A16], body[0], body[1], 0.62 * s, 0.56 * s, "vertical")))
    ops.append(op(rrect(cx, cy - 0.22 * s, 0.5 * s, 0.3 * s, 4), fill(0xFF37474F)))
    for dx in (-0.16 * s, 0.0, 0.16 * s):
        ops.append(op(circle(cx + dx, cy - 0.22 * s, 0.06 * s), fill(0xFFE53935)))
    ops += wheel_grid(cx, cy, s, (-0.32 * s, 0.32 * s), (-0.06 * s, 0.32 * s), 0.14 * s, 0.22 * s, 2)
    return ops, s, s


def enemy_tank():
    s = 54.0
    cx = cy = s / 2
    ops = [shadow(cx, cy, 0.85 * s, 0.3 * s)]
    ops += wheel_grid(cx, cy, s, (-0.3 * s, 0.3 * s), (0.06 * s,), 0.13 * s, 0.6 * s, 3, 0xFF1A1C20)
    ops.append(op(rrect(cx, cy, 0.58 * s, 0.4 * s, 6),
                  gradient_fill([0xFF6D4C41, 0xFF3E2723], cx, cy, 0.58 * s, 0.4 * s, "vertical")))
    turret = circle(cx, cy, 0.19 * s)
    ops.append(op(turret, gradient_fill([0xFF8D6E63, 0xFF3E2723], cx, cy, 0.38 * s, 0.38 * s, "horizontal")))
    ops.append(op(rrect(cx, cy - 0.28 * s, 0.09 * s, 0.34 * s, 2), fill(0xFF2B2F36)))
    ops.append(op(rrect(cx, cy + 0.02 * s, 0.1 * s, 0.04 * s, 2), fill(0xFFE53935)))
    ops.append(op(circle(cx, cy + 0.16 * s, 0.045 * s), fill(0xFFFFF59D)))
    return ops, s, s


# Flying-wing stealth bomber - one silhouette shared by both `ally_` and
# `enemy_` keys (team ownership shown by `TeamStripeMarkerComponent`
# instead of recoloring the model), mirroring
# `AllySpriteFactory._paintStealthBomber`/`EnemySpriteFactory._paintStealthBomber`.
def stealth_bomber():
    s = 54.0
    cx = cy = s / 2
    ops = [shadow(cx, cy, 0.8 * s, 0.22 * s)]
    wing_pts = [
        (cx, cy - 0.12 * s),
        (cx + 0.48 * s, cy + 0.34 * s),
        (cx + 0.3 * s, cy + 0.4 * s),
        (cx, cy + 0.16 * s),
        (cx - 0.3 * s, cy + 0.4 * s),
        (cx - 0.48 * s, cy + 0.34 * s),
    ]
    ops.append(op(polygon(wing_pts), gradient_fill([0xFF3A3F44, 0xFF0D0F10], cx, cy, 0.8 * s, 0.8 * s, "vertical")))
    ops.append(op(ellipse(cx, cy - 0.02 * s, 0.1 * s, 0.16 * s), fill(0xFF1A1C1E)))
    for dx in (-0.14 * s, 0.14 * s):
        ops.append(op(rrect(cx + dx, cy + 0.3 * s, 0.05 * s, 0.1 * s, 0), fill(0xFF1A1C1E)))
    return ops, s, s


UNITS = {
    "ally_soldier": ally_soldier,
    "ally_tank": ally_tank,
    "ally_lightVehicle": ally_light_vehicle,
    "ally_aircraft": ally_aircraft,
    "ally_rocketBarrage": ally_rocket_barrage,
    "ally_antiTankSoldier": ally_anti_tank,
    "ally_antiAirSoldier": ally_anti_air,
    "ally_stealthBomber": stealth_bomber,
    "enemy_soldier": lambda: enemy_infantry(False),
    "enemy_heavySoldier": lambda: enemy_infantry(True),
    "enemy_tank": enemy_tank,
    "enemy_helicopter": enemy_helicopter,
    "enemy_attackPlane": enemy_attack_plane,
    "enemy_artilleryBarrage": enemy_artillery_barrage,
    "enemy_rocketBarrage": enemy_rocket_barrage,
    "enemy_antiAirVehicle": enemy_anti_air_vehicle,
    "enemy_stealthBomber": stealth_bomber,
}


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for key, builder in UNITS.items():
        ops, w, h = builder()
        write_layer(ops, int(w), int(h), os.path.join(OUT_DIR, f"{key}.json"))


if __name__ == "__main__":
    main()
