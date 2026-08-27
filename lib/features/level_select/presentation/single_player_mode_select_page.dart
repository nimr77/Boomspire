import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/widgets/hover_scale_card.dart';
import '../../../core/widgets/menu_option_content.dart';
import '../../../core/widgets/window_controls.dart';
import '../../../generated/l10n.dart';
import 'level_select_page.dart';
import 'skirmish_level_select_page.dart';

/// Single Player drill-down: choose Tower Defense (the original wave
/// survival campaigns) or Skirmish (home-vs-home battles against the AI),
/// each leading to its own map/scene listing.
class SinglePlayerModeSelectPage extends StatelessWidget {
  const SinglePlayerModeSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                            S.current.modeSelectTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 360.ms)
                          .slideY(begin: -0.2, end: 0),
                      const SizedBox(height: 6),
                      Text(
                            S.current.modeSelectSubtitle,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 15,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 360.ms, delay: 60.ms)
                          .slideY(begin: -0.2, end: 0),
                      const SizedBox(height: 32),
                      HoverScaleCard(
                            accentColor: Colors.orangeAccent,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LevelSelectPage(),
                              ),
                            ),
                            child: MenuOptionContent(
                              icon: Icons.shield,
                              title: S.current.modeTowerDefenseTitle,
                              subtitle: S.current.modeTowerDefenseSubtitle,
                              accentColor: Colors.orangeAccent,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 360.ms, delay: 140.ms)
                          .scale(
                            begin: const Offset(0.94, 0.94),
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 18),
                      HoverScaleCard(
                            accentColor: Colors.redAccent,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SkirmishLevelSelectPage(),
                              ),
                            ),
                            child: MenuOptionContent(
                              icon: Icons.swap_horiz,
                              title: S.current.modeSkirmishTitle,
                              subtitle: S.current.modeSkirmishSubtitle,
                              accentColor: Colors.redAccent,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 360.ms, delay: 220.ms)
                          .scale(
                            begin: const Offset(0.94, 0.94),
                            curve: Curves.easeOutCubic,
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: SafeArea(child: const WindowControls()),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xB31A1F26),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24),
                ),
                child: IconButton(
                  tooltip: 'Back',
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
