/// How many directions enemies attack from, relative to the base.
enum SpawnLayout {
  /// A single approach, opposite the base.
  single,

  /// Two opposing approaches.
  twoSided,

  /// Every open edge around the base.
  surround,
}
