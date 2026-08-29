/// Whether a hand-drawn water feature is an open flowing channel or a
/// closed body of water. [river]/[lava] are channels (rasterized as a
/// stroke, `WaterPath.width` wide); [lake]/[volcanicLake] are closed loops
/// (rasterized as a filled polygon). [lava]/[volcanicLake] are the molten
/// counterparts of [river]/[lake].
enum WaterFeatureKind { river, lake, lava, volcanicLake }
