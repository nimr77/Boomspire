# Model assets

Drop hand-authored animated models here to replace the built-in procedural
sprites, no code changes required (see `lib/core/rendering/model_loader.dart`):

- `enemy_<type>.riv` or `enemy_<type>.json` - e.g. `enemy_soldier.riv`,
  `enemy_heavySoldier.json`, `enemy_air.riv` (type names come from
  `EnemyType` in `lib/features/enemies/domain/models/enemy_type.dart`).
- `tower_<type>.riv` or `tower_<type>.json` - e.g. `tower_machineGun.riv`
  (type names come from `TowerType` in
  `lib/features/towers/domain/models/tower_type.dart`). This only replaces
  the tower's base plate; the turret stays procedural since its rotation
  logic depends on it being a separate component.

`.riv` (Rive) files are tried first, then `.json` (Lottie). If neither
exists for a given key, the existing procedural sprite is used - nothing
changes visually until you add a file here.

No real model files ship with the game today: this repo/dev environment has
no way to source or verify third-party binary art assets, so only the
loading plumbing is provided.
