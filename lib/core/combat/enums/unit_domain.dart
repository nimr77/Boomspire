/// Marker for enums that represent a unit's physical domain, mirroring the
/// `UnitType implements Enum` pattern used for buildable types. Lets shared
/// code accept "some domain enum" without hard-coding [UnitDomain].
abstract class Domain implements Enum {}

/// The three physical domains a battlefield unit can occupy - drives which
/// units can attack which (see [Unit] in `unit.dart`).
enum UnitDomain implements Domain {
  ground,
  air,
  sea;

  /// Reconstructs a [UnitDomain] from its serialized name - e.g. when a
  /// unit blueprint is loaded from JSON instead of declared in Dart.
  static UnitDomain fromValue(String value) => UnitDomain.values.byName(value);
}
