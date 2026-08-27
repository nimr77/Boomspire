/// Common marker for anything buildable on the battlefield grid - a combat
/// [TowerType] or a non-combat [BuildingType] - so shared code (the build
/// menu, [UnitBlueprint], `BoomspireGame`'s build pipeline) can work with
/// either without caring which concrete enum it is. Implementing [Enum]
/// gives every unit type the usual `.name`/`.index` getters for free.
abstract class UnitType implements Enum {}
