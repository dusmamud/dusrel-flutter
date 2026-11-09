import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:ui_kit/ui_kit.dart';

/// Typing indicator row shown above the message list while the other
/// side is "typing" (mock simulation in the group chat).
class TypingIndicatorRow extends StatelessWidget {
  const TypingIndicatorRow({
    super.key,
    required this.userName,
  });

  final String userName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenEdge,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          DusAvatar(name: userName, size: AppSizes.avatarSm),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$userName ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            l10n.chatTyping,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const IsTypingIndicator(),
        ],
      ),
    );
  }
}
