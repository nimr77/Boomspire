import 'package:boomspire/shared/app_theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

class GameMeshBackgroundWidget extends StatelessWidget {
  const GameMeshBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.1,
      child: AnimatedMeshGradient(
        colors: [
          const Color.fromARGB(255, 3, 135, 135),
          AppThemeColors.accentDeepOrange,
          const Color.fromARGB(255, 244, 244, 244),
          const Color.fromARGB(255, 71, 2, 169),
        ],

        options: AnimatedMeshGradientOptions(speed: 2),
        child: SizedBox.expand(),
      ).animate(effects: [FadeEffect(duration: 3.seconds)]),
    );
  }
}
