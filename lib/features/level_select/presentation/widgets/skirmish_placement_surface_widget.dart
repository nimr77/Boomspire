import 'package:flutter/material.dart';

import 'skirmish_placement_home_site_marker_widget.dart';

/// Renders [background] with a numbered/colored marker per fractional site
/// position, and reports taps near a marker via [onTapSlot]. Each marker is
/// a real interactive widget (not just painted pixels) so it can glow and
/// scale up under the mouse.
class SkirmishPlacementSurfaceWidget extends StatefulWidget {
  final List<Offset> sites;
  final int? selectedSlot;
  final ValueChanged<int> onTapSlot;
  final Widget background;

  const SkirmishPlacementSurfaceWidget({
    super.key,
    required this.sites,
    required this.selectedSlot,
    required this.onTapSlot,
    required this.background,
  });

  @override
  State<SkirmishPlacementSurfaceWidget> createState() =>
      _SkirmishPlacementSurfaceWidgetState();
}

class _SkirmishPlacementSurfaceWidgetState
    extends State<SkirmishPlacementSurfaceWidget> {
  final ValueNotifier<int?> _hoveredSlot = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: _hoveredSlot,
      builder: (context, hoveredSlot, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            return Stack(
              fit: StackFit.expand,
              children: [
                widget.background,
                for (final (index, fraction) in widget.sites.indexed)
                  SkirmishPlacementHomeSiteMarkerWidget(
                    center: Offset(
                      fraction.dx * size.width,
                      fraction.dy * size.height,
                    ),
                    index: index,
                    selected: widget.selectedSlot == index,
                    hovered: hoveredSlot == index,
                    onHoverChanged: (hovering) =>
                        _hoveredSlot.value = hovering ? index : null,
                    onTap: () => widget.onTapSlot(index),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _hoveredSlot.dispose();
    super.dispose();
  }
}
