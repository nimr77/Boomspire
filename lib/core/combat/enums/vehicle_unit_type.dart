import 'unit_body_type.dart';

/// Vehicle sub-kind - each has its own extra movement telegraph layered on
/// top of the shared [Vehicle] engine smoke (see `MobileUnitComponent`):
/// [heavyVehicle] leaves tracked tread marks on the ground, [lightVehicle]
/// only kicks up dust, [plane] trails visible jet exhaust while flying, and
/// [helicopter] keeps its existing spinning-rotor visual.
enum VehicleUnitType implements Vehicle { plane, helicopter, heavyVehicle, lightVehicle }
