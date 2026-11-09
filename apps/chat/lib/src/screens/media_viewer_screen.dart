import 'package:cached_network_image/cached_network_image.dart';
import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';

/// Full-screen view for an image message. Offline-safe: a failed load
/// shows a designed error state instead of a broken page.
class MediaViewerScreen extends StatelessWidget {
  const MediaViewerScreen({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatMedia)),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (_, _) => const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(),
            ),
            errorWidget: (_, _, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 56,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  semanticLabel: l10n.error,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.error,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
