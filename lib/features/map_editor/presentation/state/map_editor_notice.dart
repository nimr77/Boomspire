import 'package:flutter/material.dart';

/// A brief, one-shot message a state class wants surfaced to the user (as a
/// toast) - kept free of [BuildContext]/[Overlay] so state classes stay
/// plain Dart. The page listens for these and clears them once shown.
class MapEditorNotice {
  final String message;
  final IconData icon;

  const MapEditorNotice(this.message, {this.icon = Icons.check_circle});
}
