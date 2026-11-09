import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../widgets/file_widgets.dart';

/// Recent: all files sorted by most recently modified.
class RecentScreen extends StatelessWidget {
  const RecentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.driveRecent)),
      body: FilteredFileList(
        filter: (f) => !f.isTrashed,
        emptyIcon: Symbols.schedule,
      ),
    );
  }
}
