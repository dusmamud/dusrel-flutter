import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:notes/main.dart';

void main() {
  testWidgets('home renders mock notes with pinned section',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: NotesApp()));
    await tester.pumpAndSettle();

    expect(find.text('Notes'), findsWidgets);
    expect(find.text('Pinned'), findsOneWidget);
    expect(find.text('Grocery list'), findsOneWidget);
    expect(find.text('Sprint planning notes'), findsOneWidget);
    expect(find.text('Trip to Jaipur plan'), findsOneWidget);
  });

  testWidgets('editor saves a note via autosave', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: NotesApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Grocery list'));
    await tester.pumpAndSettle();

    expect(find.byType(QuillEditor), findsOneWidget);
    expect(find.byType(QuillSimpleToolbar), findsOneWidget);

    // Type at the top of the document through the Quill controller.
    final editor = tester.widget<QuillEditor>(find.byType(QuillEditor));
    editor.controller.replaceText(0, 0, 'Updated title\n', null);
    // Let the 800 ms autosave debounce fire.
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Updated title'), findsOneWidget);
  });

  testWidgets('trash restore brings the note back home',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: NotesApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trash').last);
    await tester.pumpAndSettle();

    expect(find.text('Duplicate shopping list'), findsOneWidget);

    await tester.tap(find.byTooltip('Restore'));
    await tester.pumpAndSettle();
    expect(find.text('Duplicate shopping list'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Duplicate shopping list'), findsOneWidget);
  });

  testWidgets('search finds a note by title', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: NotesApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Jaipur');
    await tester.pumpAndSettle();

    expect(find.text('Trip to Jaipur plan'), findsOneWidget);
    expect(find.text('Grocery list'), findsNothing);
  });
}
