/// Whether a scene's terrain objects (trees) always automatically match the
/// map's own biome, or an author can manually mix tree styles instead - e.g.
/// snow-dusted trees on a desert map. Wind type is a separate concern, not
/// gated by this: every keyframe always has its own editable [WindType]
/// (see `WeatherKeyframe.resolvedWindType`).
enum EnvironmentAdaptation { automatic, manual }
