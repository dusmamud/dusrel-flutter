import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/chat.dart';

/// Actions offered on long-press of a message.
enum MessageAction { reply, forward, copy, delete }

/// Long-press context menu for a message. Returns the chosen action,
/// or null when dismissed. Copy is executed here; reply/forward/delete
/// are handled by the caller.
Future<MessageAction?> showMessageContextMenu(
  BuildContext context,
  ChatMessage message,
) async {
  final l10n = AppLocalizations.of(context);
  final action = await showModalBottomSheet<MessageAction>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadii.lg),
      ),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: Text(l10n.chatReply),
              onTap: () => Navigator.of(context).pop(MessageAction.reply),
            ),
            ListTile(
              leading: const Icon(Icons.forward),
              title: Text(l10n.chatForward),
              onTap: () => Navigator.of(context).pop(MessageAction.forward),
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(l10n.chatCopy),
              onTap: () => Navigator.of(context).pop(MessageAction.copy),
            ),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                l10n.delete,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () => Navigator.of(context).pop(MessageAction.delete),
            ),
          ],
        ),
      );
    },
  );
  if (action == MessageAction.copy && message.text.isNotEmpty) {
    await Clipboard.setData(ClipboardData(text: message.text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.chatCopy)),
      );
    }
  }
  return action;
}

/// Attachment picker shown from the composer. Tapping an option only
/// acknowledges it with a snackbar — v1 has no real picker (mock).
Future<void> showAttachmentSheet(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final options = <({IconData icon, String label})>[
    (icon: Icons.camera_alt, label: l10n.attachCamera),
    (icon: Icons.photo_library, label: l10n.attachGallery),
    (icon: Icons.insert_drive_file, label: l10n.attachDocument),
    (icon: Icons.location_on, label: l10n.calendarLocation),
  ];
  final picked = await showDusBottomSheet<String>(
    context,
    child: SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options)
            ListTile(
              leading: Icon(option.icon),
              title: Text(option.label),
              onTap: () => Navigator.of(context).pop(option.label),
            ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    ),
  );
  if (picked != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(picked)),
    );
  }
}
