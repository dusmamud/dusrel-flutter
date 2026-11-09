import 'package:chat/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('chats list renders mock chats', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ChatApp()));
    // Advance past the 400ms mock load delay (pumpAndSettle alone
    // returns before a pending timer fires — it only waits for frames).
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Title (app bar + bottom nav label) and all mock chats are visible.
    expect(find.text('Chats'), findsWidgets);
    expect(find.text('Aarav Sharma'), findsOneWidget);
    expect(find.text('Flutter Devs'), findsOneWidget);
    expect(find.text('Priya Patel'), findsOneWidget);
    expect(find.text('Family Group'), findsOneWidget);
    expect(find.text('Rohan Verma'), findsOneWidget);
    expect(find.text('Ananya Iyer'), findsOneWidget);

    // Last-message preview and the unread badge show.
    expect(find.text('Sounds good, see you at 6!'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    // The last chat is below the fold in the test viewport.
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Vikram Singh'), findsOneWidget);
  });
}
