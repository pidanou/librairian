import 'package:flutter/material.dart';
import 'package:librairian/widgets/navigation_destinations.dart';

class ScaffoldWithBottomBar extends StatelessWidget {
  const ScaffoldWithBottomBar({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
        child: Scaffold(
            body: body,
            bottomNavigationBar: NavigationBar(
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              selectedIndex: selectedIndex,
              destinations: [
                for (var navigationDestination in navigationDestinations)
                  NavigationDestination(
                      label: navigationDestination.label,
                      icon: Icon(navigationDestination.icon)),
              ],
              onDestinationSelected: onDestinationSelected,
            )));
  }
}
