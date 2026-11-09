import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// One destination in the app shell's navigation.
class DusDestination {
  const DusDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// The shared app shell for all DusRel apps.
///
/// Narrow screens (< 768px) get a bottom [NavigationBar]; wider screens
/// get a side [NavigationRail]. The parent owns the selected index —
/// typically wired to a go_router `StatefulShellRoute`.
class DusAppShell extends StatelessWidget {
  const DusAppShell({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
  });

  final List<DusDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useRail =
            constraints.maxWidth >= AppSizes.railBreakpoint;
        if (useRail) {
          return Scaffold(
            appBar: title != null
                ? AppBar(title: Text(title!), actions: actions)
                : null,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final d in destinations)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
            floatingActionButton: floatingActionButton,
          );
        }
        return Scaffold(
          appBar: title != null
              ? AppBar(title: Text(title!), actions: actions)
              : null,
          body: body,
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: [
              for (final d in destinations)
                NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: d.label,
                ),
            ],
          ),
        );
      },
    );
  }
}
