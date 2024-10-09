import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:librairian/pages/account_page.dart';
import 'package:librairian/pages/item_edit_form_page.dart';
import 'package:librairian/pages/language_page.dart';
import 'package:librairian/pages/storage_detail_page.dart';
import 'package:librairian/pages/theme_page.dart';
import 'package:librairian/widgets/scaffold_with_nested_navigation.dart';
import 'package:librairian/pages/login_page.dart';
import 'package:librairian/pages/settings_page.dart';
import 'package:librairian/pages/inventory_page.dart';
import 'package:librairian/pages/storage_page.dart';
import 'package:librairian/pages/search_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorSearch =
    GlobalKey<NavigatorState>(debugLabel: 'shellSearch');
final _shellNavigatorStorage =
    GlobalKey<NavigatorState>(debugLabel: 'shellStorage');
final _shellNavigatorInventory =
    GlobalKey<NavigatorState>(debugLabel: 'shellInventory');
final _shellNavigatorSettings =
    GlobalKey<NavigatorState>(debugLabel: 'shellSettings');

// the one and only GoRouter instance
final goRouter = GoRouter(
  initialLocation: '/login',
  navigatorKey: _rootNavigatorKey,
  routes: [
    // Stateful nested navigation based on:
    // https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // the UI shell
        return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSearch,
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SearchPage(),
              ),
              routes: const [],
            ),
            // top route inside branch
            GoRoute(
              path: '/search',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SearchPage(),
              ),
              routes: [
                GoRoute(
                    path: "detail/:id",
                    builder: (context, state) {
                      final itemId = state.pathParameters['id'];
                      return ItemEditFormPage(itemId: itemId ?? "");
                    })
              ],
            ),
          ],
        ),
        // first branch (A)
        // second branch (B)
        StatefulShellBranch(
          navigatorKey: _shellNavigatorStorage,
          routes: [
            // top route inside branch
            GoRoute(
              path: '/storage',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: StoragePage(),
              ),
              routes: [
                GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      return StorageDetailPage(
                        storageID: state.pathParameters['id']!,
                      );
                    },
                    routes: [
                      GoRoute(
                        path: ':itemID',
                        builder: (context, state) {
                          final itemId = state.pathParameters['itemID'];
                          return ItemEditFormPage(itemId: itemId ?? "");
                        },
                      ),
                    ]),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorInventory,
          routes: [
            // top route inside branch
            GoRoute(
              path: '/inventory',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: InventoryPage(),
              ),
              routes: [
                GoRoute(
                    path: ":id",
                    builder: (context, state) {
                      final itemId = state.pathParameters['id'];
                      return ItemEditFormPage(itemId: itemId ?? "");
                    })
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSettings,
          routes: [
            // top route inside branch
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SettingsPage(),
              ),
              routes: [
                GoRoute(
                    path: "account",
                    pageBuilder: (context, state) => const NoTransitionPage(
                          child: AccountPage(),
                        )),
                GoRoute(
                    path: "theme",
                    pageBuilder: (context, state) => const NoTransitionPage(
                          child: ThemePage(),
                        )),
                GoRoute(
                    path: "language",
                    pageBuilder: (context, state) => const NoTransitionPage(
                          child: LanguagePage(),
                        ))
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
