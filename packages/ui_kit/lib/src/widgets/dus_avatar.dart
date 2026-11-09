import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// A circular avatar.
///
/// Shows the network image when [imageUrl] is set, otherwise the user's
/// initials on a theme-colored background. Always has a semantic label.
class DusAvatar extends StatelessWidget {
  const DusAvatar({
    super.key,
    this.imageUrl,
    this.name = '',
    this.size = AppSizes.avatarMd,
  });

  final String? imageUrl;
  final String name;
  final double size;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Widget fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.38,
        ),
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Semantics(label: name.isEmpty ? 'Avatar' : 'Avatar of $name', child: fallback);
    }

    return Semantics(
      label: name.isEmpty ? 'Avatar' : 'Avatar of $name',
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, _) => fallback,
          errorWidget: (_, _, _) => fallback,
        ),
      ),
    );
  }
}
