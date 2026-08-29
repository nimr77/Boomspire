import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

/// Persistent app backdrop (see `AppShellWidget`) - a soft, blurred
/// animated mesh gradient reading as frosted glass rather than a flat
/// color wash.
class GameMeshBackgroundWidget extends StatelessWidget {
  const GameMeshBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.16,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: AnimatedMeshGradient(
          colors: [
            const Color.fromARGB(255, 15, 146, 146),
            const Color.fromARGB(255, 247, 95, 48),
            const Color.fromARGB(255, 5, 0, 37),
            const Color.fromARGB(255, 103, 3, 243),
          ],

          options: AnimatedMeshGradientOptions(speed: 2),
          child: SizedBox.expand(),
        ),
      ).animate(effects: [FadeEffect(duration: 3.seconds)]),
    );
  }
}
