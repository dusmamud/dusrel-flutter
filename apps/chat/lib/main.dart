import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:ui_kit/ui_kit.dart';

import 'src/router.dart';

void main() {
  runApp(const ProviderScope(child: ChatApp()));
}

class ChatApp extends ConsumerWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      routerConfig: router,
      // flutter_chat_ui is built on the material_ui fork, whose widgets
      // need material_ui's own MaterialLocalizations (a different class
      // from flutter/material's) in addition to the app's delegates.
      localizationsDelegates: [
        mui.GlobalMaterialLocalizations.delegate,
        ...AppLocalizations.localizationsDelegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) =>
          AppLocalizations.of(context).chatAppTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
    );
  }
}
