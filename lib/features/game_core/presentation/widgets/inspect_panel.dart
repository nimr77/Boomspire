import 'package:flutter/material.dart';

import '../../domain/models/inspected_info.dart';
import '../boomspire_game.dart';

/// Floating read-only info card shown above the command bar whenever the
/// player taps something that isn't theirs to command - an enemy tower,
/// any mobile unit, or a resource node (see [BoomspireGame.inspected]).
/// Mutually exclusive with `TowerActionPanel`: only one of
/// `BoomspireGame.selectedTower`/`inspected` is ever non-null at a time.
class InspectPanel extends StatelessWidget {
  final BoomspireGame game;

  const InspectPanel({super.key, required this.game});

  IconData _iconFor(InspectedKind kind) => switch (kind) {
    InspectedKind.tower => Icons.apartment,
    InspectedKind.unit => Icons.directions_walk,
    InspectedKind.resourceNode => Icons.diamond,
  };

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<InspectedInfo?>(
      valueListenable: game.inspected,
      builder: (context, info, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1).animate(animation),
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
          child: info == null
              ? const SizedBox.shrink(key: ValueKey('no-inspection'))
              : _buildCard(info),
        );
      },
    );
  }

  Widget _buildCard(InspectedInfo info) {
    final ownerColor = info.owner?.color ?? Colors.white54;
    return Container(
      key: ValueKey(info),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xF00F1216),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ownerColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_iconFor(info.kind), color: ownerColor, size: 18),
              const SizedBox(width: 8),
              Text(
                info.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: ownerColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ownerColor.withValues(alpha: 0.7)),
                ),
                child: Text(
                  info.owner?.label ?? 'Unclaimed',
                  style: TextStyle(
                    color: ownerColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => game.inspected.value = null,
                borderRadius: BorderRadius.circular(12),
                child: const Icon(
                  Icons.close,
                  color: Colors.white54,
                  size: 16,
                ),
              ),
            ],
          ),
          if (info.description != null) ...[
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                info.description!,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
