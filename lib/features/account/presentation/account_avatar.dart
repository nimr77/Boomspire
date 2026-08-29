import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../shared/app_theme/app_theme_colors.dart';

/// Circular commander avatar. Loads [avatarUrl] via [CachedNetworkImage]
/// when present; falls back to a plain icon glyph on a null/empty url or
/// on any load failure (no default image asset exists in this project).
class AccountAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double size;

  const AccountAvatar({super.key, required this.avatarUrl, this.size = 18});

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    if (url == null || url.isEmpty) return _fallbackIcon();
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => _fallbackIcon(),
        errorWidget: (context, url, error) => _fallbackIcon(),
      ),
    );
  }

  Widget _fallbackIcon() => Icon(
    Icons.account_circle,
    color: AppThemeColors.textSecondary,
    size: size,
  );
}
