import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import 'package:librairian/widgets/scaffold_with_nested_navigation.dart';
import 'package:librairian/pages/login_page.dart';
import 'package:librairian/pages/add_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorAdd = GlobalKey<NavigatorState>(debugLabel: 'shellAdd');
final _shellNavigatorSearch =
    GlobalKey<NavigatorState>(debugLabel: 'shellSearch');
final _shellNavigatorManage =
    GlobalKey<NavigatorState>(debugLabel: 'shellManage');

// the one and only GoRouter instance
final goRouter = GoRouter(
  initialLocation: '/add',
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
          navigatorKey: _shellNavigatorAdd,
          routes: [
            // top route inside branch
            GoRoute(
              path: '/add',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: AddPage(),
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
          navigatorKey: _shellNavigatorSearch,
          routes: [
            // top route inside branch
            GoRoute(
              path: '/search',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: AddPage(),
              ),
              routes: const [],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorManage,
          routes: [
            // top route inside branch
            GoRoute(
              path: '/manage',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: AddPage(),
              ),
              routes: const [],
            ),
          ],
        ),
      ],
    ),
  ],
);
