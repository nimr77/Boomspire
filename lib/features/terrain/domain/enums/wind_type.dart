/// Flavor of wind-blown particle effect a scene's live weather renders -
/// [automatic] (the default on every [WeatherKeyframe]) inherits whichever
/// look the map's own [Biome] naturally has (see
/// `BiomeExtensions.defaultWindType`); every other value is an explicit
/// author override on top of that, letting a scene mix styles - e.g. an
/// ash-fall wind over a grassland, or snow flurries on a desert map.
enum WindType { automatic, grassLeaves, autumnLeaves, sand, dust, snow, ash }
