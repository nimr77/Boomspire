import 'dart:math';

LavaFlowEmberRise lavaFlowEmberRise({
  required int index,
  required double phase,
}) {
  final rise = ((phase * 30 + index * 37) % 60);
  return (rise: rise, alpha: sin(pi * (rise / 60)).clamp(0.0, 1.0));
}

/// How far one lava ember has risen off the flow, and its fade-in/fade-out
/// alpha across that rise, for `TerrainPainter.paintLavaFlow` - embers
/// drift upward off the flow instead of along it, fading in then out so
/// none of them pops in/out at full brightness.
typedef LavaFlowEmberRise = ({double rise, double alpha});
