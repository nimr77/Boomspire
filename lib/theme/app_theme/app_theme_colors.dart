import 'package:flutter/material.dart';

/// Named UI-chrome colors shared by the app's Flutter pages/widgets (menus,
/// HUD panels, cards). Does NOT cover procedural gameplay art (terrain/
/// sprite palettes painted by Flame components) - those are per-biome/
/// per-unit artistic palettes, not reusable UI theme tokens.
abstract final class AppThemeColors {
  /// Full-screen page background (near-black navy).
  static const Color background = Color(0xFF0A0E14);

  /// Translucent dark pill background used by floating HUD/back buttons.
  static const Color glassPill = Color(0xB31A1F26);

  /// Hairline border color for glass pills and outlined panels.
  static const Color borderSubtle = Colors.white24;

  /// End-stop color for accent-tinted gradients (e.g. menu option cards).
  static const Color gradientPanelEnd = Color(0xFF11161D);

  /// Flat panel surface (e.g. difficulty selector background).
  static const Color surfacePanel = Color(0xFF1A1F26);

  /// Border for [surfacePanel]-style panels.
  static const Color surfacePanelBorder = Color(0xFF2A323C);

  /// Flat card surface (e.g. a list row/tile background).
  static const Color surfaceCard = Color(0xFF161B22);

  /// Strong dark scrim behind a blocking loading overlay.
  static const Color scrimStrong = Color(0x99000000);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white54;
  static const Color textMuted = Colors.white70;
  static const Color textFaint = Colors.white38;
  static const Color textDim = Colors.white60;

  static const Color accentCyan = Colors.cyanAccent;
  static const Color accentOrange = Colors.orangeAccent;
  static const Color accentRed = Colors.redAccent;
  static const Color accentGreen = Colors.greenAccent;
  static const Color accentAmber = Colors.amberAccent;
  static const Color accentLightBlue = Colors.lightBlueAccent;
  static const Color accentLightGreen = Colors.lightGreenAccent;

  /// Gold-mine payout stat chip.
  static const Color accentGold = Color(0xFFFFB300);

  /// Gold-mine kill-bonus stat chip.
  static const Color accentDeepOrange = Color(0xFFFF8A65);

  /// Produce-unit button when a producer building is ready.
  static const Color accentEmerald = Color(0xFF66BB6A);

  static const Color transparent = Colors.transparent;

  /// Button label/icon color on top of a light accent-colored button
  /// background (e.g. the end-screen restart button, account continue
  /// button).
  static const Color textOnAccent = Colors.black;

  /// Small dark chip background for a cost/count badge over game art
  /// (e.g. the build-menu tower button's cost/build-count corners).
  static const Color overlayChipBackground = Colors.black87;

  /// Full-tile scrim over a build-menu tower button that's locked.
  static const Color overlayLockScrim = Colors.black54;

  /// Soft drop shadow behind the map editor's canvas panel.
  static const Color scrimSubtle = Colors.black45;

  /// Full-screen dim behind the victory/defeat end screen (tinted
  /// [background]).
  static const Color scrimBackground = Color(0xCC0A0E14);

  /// Modal barrier behind a `showGlassMessage` dialog/sheet.
  static const Color scrimDialog = Color(0x66050608);

  /// Bottom HUD command bar background.
  static const Color hudBarBackground = Color(0xCC12161C);

  /// Minimap panel background.
  static const Color minimapBackground = Color(0xCC0F1319);

  /// Top stop of the subtle top-to-bottom scrim overlaid on preview-image
  /// cards (~5% black) so light artwork doesn't wash out overlaid text.
  static Color get cardOverlayTop => Colors.black.withValues(alpha: 0.05);

  /// Bottom stop of the same scrim for cards with a short text block
  /// (~55% black).
  static Color get cardOverlayBottom => Colors.black.withValues(alpha: 0.55);

  /// Bottom stop variant for cards needing stronger legibility (~65% black).
  static Color get cardOverlayBottomStrong =>
      Colors.black.withValues(alpha: 0.65);
}
