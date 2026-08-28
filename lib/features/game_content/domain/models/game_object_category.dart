/// Which existing feature a synced [GameObjectDefinition] hydrates into -
/// mirrors the tower/building vs. mobile-unit split already modeled by
/// `UnitType` (`TowerType`/`BuildingType`) and `UnitKind`.
enum GameObjectCategory { tower, building, unit }
