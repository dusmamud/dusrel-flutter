import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../widgets/file_widgets.dart';

/// Starred tab: files the user starred.
class StarredScreen extends StatelessWidget {
  const StarredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FilteredFileList(
      filter: (f) => !f.isTrashed && f.isStarred,
      emptyIcon: Symbols.star_border,
    );
  }
}
