import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Shows a modal bottom sheet with the suite-standard shape:
/// rounded top corners, a drag handle, and scroll-controlled sizing.
Future<T?> showDusBottomSheet<T>(
  BuildContext context, {
  required Widget child,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadii.lg),
      ),
    ),
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
        Flexible(child: child),
      ],
    ),
  );
}
