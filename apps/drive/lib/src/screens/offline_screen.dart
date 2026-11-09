import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../widgets/file_widgets.dart';

/// Offline: files marked available offline.
class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.driveOffline)),
      body: FilteredFileList(
        filter: (f) => !f.isTrashed && f.isOffline,
        emptyIcon: Symbols.cloud_off,
      ),
    );
  }
}
