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

  bool isSubRoute(String input) {
    int slashCount = 0;

    for (int i = 0; i < input.length; i++) {
      if (input[i] == '/') {
        slashCount++;
      }

      if (slashCount >= 2) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    var navigationDestinations = getDestinations(context);
    return SelectionArea(
        child: Scaffold(
            body: body,
            bottomNavigationBar: NavigationBar(
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
