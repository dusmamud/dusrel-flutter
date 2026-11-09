import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// Placeholder tab for v1: Updates / Communities / Calls are not built
/// yet. Shows a designed empty state instead of faking the feature.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DusEmptyState(icon: icon, title: title),
    );
  }
}
