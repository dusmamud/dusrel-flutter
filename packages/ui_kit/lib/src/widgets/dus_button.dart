import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Button variants available across all DusRel apps.
enum DusButtonVariant { filled, tonal, outlined, text }

/// The standard button for the DusRel suite.
///
/// Uses only theme colors — never a raw color — so light/dark mode
/// and rebranding work everywhere at once.
class DusButton extends StatelessWidget {
  const DusButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = DusButtonVariant.filled,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final DusButtonVariant variant;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(child: Text(label)),
      ],
    );

    final Widget button = switch (variant) {
      DusButtonVariant.filled =>
        FilledButton(onPressed: onPressed, child: child),
      DusButtonVariant.tonal =>
        FilledButton.tonal(onPressed: onPressed, child: child),
      DusButtonVariant.outlined =>
        OutlinedButton(onPressed: onPressed, child: child),
      DusButtonVariant.text => TextButton(onPressed: onPressed, child: child),
    };

    if (expanded) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    return button;
  }
}
