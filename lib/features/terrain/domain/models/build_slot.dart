/// A single buildable pad on the terrain.
///
/// Each slot represents one unit of "space" a tower can occupy - placement is
/// only legal on an existing, unoccupied [BuildSlot].
class BuildSlot {
  BuildSlot({required this.id, required this.x, required this.y, this.size = 64});

  final int id;
  final double x;
  final double y;
  final double size;

  bool occupied = false;
}
