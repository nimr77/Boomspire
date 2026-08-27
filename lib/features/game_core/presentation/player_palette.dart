import 'package:flutter/material.dart';

/// Shared numbered/colored identity for a player seat, so the map editor's
/// home-site tool and the skirmish/VS AI pre-game placement screen agree
/// on what "Player N" looks like.
class PlayerPalette {
  const PlayerPalette._();

  static const List<Color> colors = [
    Colors.blueAccent,
    Colors.redAccent,
    Colors.amberAccent,
    Colors.purpleAccent,
  ];

  static Color colorFor(int slot) => colors[slot % colors.length];

  static String labelFor(int slot) => 'P${slot + 1}';
}
