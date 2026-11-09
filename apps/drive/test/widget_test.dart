import 'package:drive/main.dart';
import 'package:drive/src/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

Future<void> pumpDriveApp(WidgetTester tester) async {
  // Narrow viewport so the shell uses the bottom NavigationBar
  // (the rail layout starts at 768px).
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const ProviderScope(child: DriveApp()));
  // The mock repository loads with a short delay.
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump();
}

Future<void> openFilesTab(WidgetTester tester) async {
  // The shared GoRouter keeps its route between tests (a test may end
  // on a pushed route with no navigation bar), so navigate directly.
  driveRouter.go('/files');
  await tester.pump();
}

void main() {
  testWidgets('Files tab renders mock folders and files',
      (WidgetTester tester) async {
    await pumpDriveApp(tester);
    await openFilesTab(tester);

    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('Photos'), findsOneWidget);
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('Flight Tickets.pdf'), findsOneWidget);
    expect(find.text('Invoice March.pdf'), findsOneWidget);
  });

  testWidgets('Star toggle adds a file to Starred',
      (WidgetTester tester) async {
    await pumpDriveApp(tester);
    await openFilesTab(tester);

    final tile = find.widgetWithText(ListTile, 'Flight Tickets.pdf');
    await tester.tap(
      find.descendant(
        of: tile,
        matching: find.byIcon(Symbols.star_border),
      ),
    );
    // The mock repository refreshes after the mutation.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    await tester.tap(find.text('Starred'));
    await tester.pump();

    expect(find.text('Flight Tickets.pdf'), findsOneWidget);
    expect(find.text('Beach Sunset.jpg'), findsOneWidget);
  });

  testWidgets('Search filters files by name', (WidgetTester tester) async {
    await pumpDriveApp(tester);

    await tester.tap(find.byIcon(Symbols.search));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Beach');
    await tester.pump();

    expect(find.text('Beach Sunset.jpg'), findsOneWidget);
    expect(find.text('Budget 2026.xlsx'), findsNothing);
  });

  testWidgets('Tapping a folder opens it', (WidgetTester tester) async {
    await pumpDriveApp(tester);
    await openFilesTab(tester);

    await tester.tap(find.text('Documents'));
    await tester.pump();

    expect(find.text('Project Proposal.docx'), findsOneWidget);
    expect(find.text('Budget 2026.xlsx'), findsOneWidget);
    // Root files are not inside the folder.
    expect(find.text('Flight Tickets.pdf'), findsNothing);
  });
}
