import '../enums/human_unit_type.dart';
import '../enums/unit_body_type.dart';
import '../enums/vehicle_unit_type.dart';
import '../unit_kind.dart';

/// Classifies each [UnitKind] into its physical [UnitBodyType] family - see
/// `MobileUnitComponent` for how humans vs vehicles (and each vehicle
/// sub-kind) differ in their movement/combat visuals.
extension UnitKindExtensions on UnitKind {
  UnitBodyType get bodyType => switch (this) {
    UnitKind.soldier ||
    UnitKind.heavySoldier ||
    UnitKind.antiTankSoldier ||
    UnitKind.antiAirSoldier => HumanUnitType.infantry,
    UnitKind.helicopter => VehicleUnitType.helicopter,
    UnitKind.attackPlane || UnitKind.aircraft => VehicleUnitType.plane,
    UnitKind.tank ||
    UnitKind.artilleryBarrage ||
    UnitKind.antiAirVehicle => VehicleUnitType.heavyVehicle,
    UnitKind.lightVehicle ||
    UnitKind.rocketBarrage => VehicleUnitType.lightVehicle,
  };
}
