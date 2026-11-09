import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  test('AppTheme exposes light and dark themes', () {
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
    expect(AppTheme.light.useMaterial3, isTrue);
  });

  testWidgets('DusEmptyState renders title and action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: DusEmptyState(
          icon: Icons.note,
          title: 'No notes yet',
          message: 'Create one to get started.',
          actionLabel: 'New note',
          onAction: () => tapped = true,
        ),
      ),
    );
    expect(find.text('No notes yet'), findsOneWidget);
    expect(find.text('Create one to get started.'), findsOneWidget);
    await tester.tap(find.text('New note'));
    expect(tapped, isTrue);
  });

  testWidgets('DusButton calls onPressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: DusButton(
          label: 'Save',
          onPressed: () => tapped = true,
        ),
      ),
    );
    await tester.tap(find.text('Save'));
    expect(tapped, isTrue);
  });

  test('themeModeProvider defaults to system', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(themeModeProvider), ThemeMode.system);
  });
}
