import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import 'package:librairian/widgets/scaffold_with_nested_navigation.dart';
import 'package:librairian/pages/login_page.dart';
import 'package:librairian/pages/home_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHome = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorReappro =
    GlobalKey<NavigatorState>(debugLabel: 'shellReappro');

// the one and only GoRouter instance
final goRouter = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  routes: [
    // Stateful nested navigation based on:
    // https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    StatefulShellRoute.indexedStack(
      redirect: (context, state) {
        if (Supabase.instance.client.auth.currentSession == null) {
          return "/login";
        }
        return null;
      },
      builder: (context, state, navigationShell) {
        // the UI shell
        return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
      },
      branches: [
        // first branch (A)
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHome,
          routes: [
            // top route inside branch
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: MyHomePage(),
              ),
              routes: const [
                // child route
                // GoRoute(
                //   path: '/move',
                //   builder: (context, state) => DetailsScreen(label: 'A'),
                // ),
              ],
            ),
          ],
        ),
        // second branch (B)
        StatefulShellBranch(
          navigatorKey: _shellNavigatorReappro,
          routes: [
            // top route inside branch
            GoRoute(
              path: '/reappro',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: MyHomePage(),
              ),
              routes: const [
                // child route
                // GoRoute(
                //   path: 'summary',
                //   builder: (context, state) => ReapproSummaryPage(),
                // ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
