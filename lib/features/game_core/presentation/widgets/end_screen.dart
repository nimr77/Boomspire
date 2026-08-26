import 'package:flutter/material.dart';

/// Shared full-screen result panel used by both the victory and defeat
/// overlays.
class EndScreen extends StatelessWidget {
  final String title;

  final String subtitle;
  final Color accentColor;
  final VoidCallback onRestart;
  final VoidCallback? onChangeMap;
  const EndScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onRestart,
    this.onChangeMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xCC0A0E14),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.6),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.35),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: accentColor,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'PLAY AGAIN',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
            if (onChangeMap != null) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: onChangeMap,
                child: const Text(
                  'CHANGE MAP',
                  style: TextStyle(color: Colors.white70, letterSpacing: 1),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
