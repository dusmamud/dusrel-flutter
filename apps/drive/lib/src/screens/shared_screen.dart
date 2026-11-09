import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../widgets/file_widgets.dart';

/// Shared tab: files shared with the user or by the user.
class SharedScreen extends StatelessWidget {
  const SharedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FilteredFileList(
      filter: (f) => !f.isTrashed && f.isShared,
      emptyIcon: Symbols.group,
    );
  }
}
