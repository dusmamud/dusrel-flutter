import 'package:chat/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sending a message appends it to the conversation',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ChatApp()));
    // Advance past the 400ms mock load delay (pumpAndSettle alone
    // returns before a pending timer fires — it only waits for frames).
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Open the Aarav chat (text-only, no simulated reply).
    await tester.tap(find.text('Aarav Sharma'));
    await tester.pumpAndSettle();

    // Existing history is rendered.
    expect(find.text('Sounds good, see you at 6!'), findsOneWidget);

    // Type and send a new message. The composer is material_ui's
    // TextField (a different class from flutter/material's), so target
    // the EditableText it builds internally.
    const newMessage = 'Hello from the widget test';
    await tester.enterText(find.byType(EditableText), newMessage);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    // The sent message appears in the thread.
    expect(find.text(newMessage), findsOneWidget);
  });
}
