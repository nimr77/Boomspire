import 'unit_body_type.dart';

/// Every infantry `UnitKind` maps to this one value - all infantry share
/// identical movement/combat visual behavior (see [Human]), so unlike
/// [Vehicle]'s sub-kinds there's no need for further variants here.
enum HumanUnitType implements Human { infantry }
