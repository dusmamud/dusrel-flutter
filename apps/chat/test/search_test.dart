import 'package:chat/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('search filters chats by name', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ChatApp()));
    // Advance past the 400ms mock load delay (pumpAndSettle alone
    // returns before a pending timer fires — it only waits for frames).
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Aarav Sharma'), findsOneWidget);
    expect(find.text('Ananya Iyer'), findsOneWidget);

    // 'Ananya' matches exactly one chat (name + last message).
    await tester.enterText(find.byType(TextField), 'Ananya');
    await tester.pumpAndSettle();

    expect(find.text('Ananya Iyer'), findsOneWidget);
    expect(find.text('Aarav Sharma'), findsNothing);
    expect(find.text('Flutter Devs'), findsNothing);
  });

  testWidgets('search with no match shows the empty state', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ChatApp()));
    // Advance past the 400ms mock load delay (pumpAndSettle alone
    // returns before a pending timer fires — it only waits for frames).
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzz-no-such-chat');
    await tester.pumpAndSettle();

    expect(find.text('No results found'), findsOneWidget);
    expect(find.text('Aarav Sharma'), findsNothing);
  });
}
