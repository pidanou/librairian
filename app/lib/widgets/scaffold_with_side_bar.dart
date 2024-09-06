import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:librairian/widgets/default_storage_selector.dart';
import 'package:librairian/widgets/navigation_destinations.dart';
import 'package:librairian/widgets/tutorial.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ScaffoldWithSideBar extends ConsumerStatefulWidget {
  const ScaffoldWithSideBar({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  ConsumerState<ScaffoldWithSideBar> createState() =>
      ScaffoldWithSideBarState();
}

class ScaffoldWithSideBarState extends ConsumerState<ScaffoldWithSideBar> {
  final activeSession = Supabase.instance.client.auth.currentSession;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TutorialCoachMark tutorialCoachMark;

  bool _extendedRail = false;
  bool _fixedRail = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tutorialCoachMark = createTutorial(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              scrolledUnderElevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surfaceDim,
              title: const Row(children: [
                Text("Librairian"),
                SizedBox(width: 10),
                DefaultStorageSelector()
              ]),
              leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    setState(() {
                      _fixedRail = !_fixedRail;
                      _extendedRail = !_extendedRail;
                    });
                  }),
              leadingWidth: 80,
              // actions: [
              //   IconButton(
              //     onPressed: () {
              //       tutorialCoachMark.show(context: context);
              //     },
              //     icon: const Icon(Icons.help),
              //   ),
              //   const SizedBox(width: 10),
              // ],
            ),
            body: SafeArea(
              child: Container(
                  color: Theme.of(context).colorScheme.surfaceDim,
                  child: Row(
                    children: [
                      MouseRegion(
                          onEnter: (_) {
                            if (!_fixedRail) {
                              setState(() {
                                _extendedRail = true;
                              });
                            }
                          },
                          onExit: (_) {
                            if (!_fixedRail) {
                              setState(() {
                                _extendedRail = false;
                              });
                            }
                          },
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: NavigationRail(
                                  selectedIconTheme: IconThemeData(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceDim),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surfaceDim,
                                  indicatorColor:
                                      Theme.of(context).colorScheme.onSurface,
                                  groupAlignment: 0.0,
                                  selectedIndex: widget.selectedIndex,
                                  onDestinationSelected:
                                      widget.onDestinationSelected,
                                  extended: _extendedRail,
                                  labelType: NavigationRailLabelType.none,
                                  destinations: [
                                    for (var navigationDestination
                                        in navigationDestinations)
                                      NavigationRailDestination(
                                          label:
                                              Text(navigationDestination.label),
                                          icon: Icon(navigationDestination.icon,
                                              key: navigationDestination.key)),
                                    // NavigationDestination(
                                    //     label: 'Paramètres', icon: Icon(Icons.settings)),
                                  ],
                                )),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        right: 12, left: 12, bottom: 20),
                                    child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          SizedBox(
                                              width: _extendedRail ? 150 : 56,
                                              height: 32,
                                              child: FilledButton(
                                                child: const SizedBox(),
                                                onPressed: () {
                                                  Supabase.instance.client.auth
                                                      .signOut();
                                                  GoRouter.of(context)
                                                      .go('/login');
                                                },
                                              )),
                                          IgnorePointer(
                                              child: Row(children: [
                                            Icon(Icons.logout,
                                                size: 24,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surfaceDim),
                                            _extendedRail
                                                ? const SizedBox(width: 28)
                                                : const SizedBox(),
                                            _extendedRail
                                                ? Text('Sign Out',
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surfaceDim))
                                                : const SizedBox(),
                                          ]))
                                        ])),
                              ])),
                      Expanded(
                        child: widget.body,
                      ),
                    ],
                  )),
            )));
  }
}
