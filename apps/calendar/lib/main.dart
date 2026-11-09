import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import 'src/screens/calendar_home_screen.dart';
import 'src/screens/calendars_screen.dart';
import 'src/screens/event_form_screen.dart';
import 'src/screens/search_screen.dart';
import 'src/screens/settings_screen.dart';

void main() {
  runApp(const ProviderScope(child: CalendarApp()));
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CalendarHomeScreen(),
    ),
    GoRoute(
      path: '/event/new',
      builder: (context, state) {
        final dateParam = state.uri.queryParameters['date'];
        final date = dateParam != null
            ? DateTime.tryParse(dateParam)
            : null;
        return EventFormScreen(initialDate: date);
      },
    ),
    GoRoute(
      path: '/event/:id/edit',
      builder: (context, state) =>
          EventFormScreen(eventId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/calendars',
      builder: (context, state) => const CalendarsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class CalendarApp extends ConsumerWidget {
  const CalendarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      routerConfig: _router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) =>
          AppLocalizations.of(context).calendarAppTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
    );
  }
}
