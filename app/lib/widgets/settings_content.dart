import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:librairian/providers/locale.dart';
import 'package:librairian/providers/settings.dart';
import 'package:librairian/providers/supabase.dart';
import 'package:librairian/widgets/account_form.dart';
import 'package:librairian/widgets/language_form.dart';
import 'package:librairian/widgets/theme_form.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsContent extends ConsumerWidget {
  const SettingsContent({super.key, this.initialSetting});
  final String? initialSetting;

  Widget _getWidgetForSelection(String? selection) {
    switch (selection) {
      case 'account':
        return const AccountForm(); // Your AccountForm widget here
      case 'theme':
        return const ThemeForm(); // Your ThemeForm widget here
      case 'language':
        return const LanguageForm(); // Your LanguageForm widget here
      default:
        return Container(); // Return an empty container if no match
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? selected = ref.watch(selectedSettingProvider);
    if (initialSetting != null) {
      selected = initialSetting;
    }
    var googleSignIn = GoogleSignIn();
    return Row(children: [
      Expanded(
          child: Column(
              mainAxisSize: MediaQuery.of(context).size.height < 840
                  ? MainAxisSize.min
                  : MainAxisSize.max,
              children: [
            Expanded(
                child: Material(
              type: MaterialType.transparency,
              child: ListView(
                children: [
                  ListTile(
                      dense: true,
                      title: Text(AppLocalizations.of(context)!.account,
                          style: Theme.of(context).textTheme.titleSmall)),
                  ListTile(
                    selectedColor: Theme.of(context).colorScheme.onSurface,
                    selectedTileColor: Theme.of(context).colorScheme.surfaceDim,
                    selected: ref.watch(selectedSettingProvider) == "account",
                    leading: const Icon(Icons.mail),
                    title: Text(ref.watch(supabaseUserProvider)?.email ?? ""),
                    onTap: () {
                      ref.read(selectedSettingProvider.notifier).set("account");
                      if (MediaQuery.of(context).size.width < 840) {
                        GoRouter.of(context).go('/settings/account');
                      }
                    },
                  ),
                  const Divider(height: 0),
                  ListTile(
                      dense: true,
                      title: Text("App",
                          style: Theme.of(context).textTheme.titleSmall)),
                  ListTile(
                    selectedColor: Theme.of(context).colorScheme.onSurface,
                    selectedTileColor: Theme.of(context).colorScheme.surfaceDim,
                    selected: ref.watch(selectedSettingProvider) == "language",
                    onTap: () {
                      ref
                          .read(selectedSettingProvider.notifier)
                          .set("language");
                      if (MediaQuery.of(context).size.width < 840) {
                        GoRouter.of(context).go('/settings/language');
                      }
                    },
                    leading: const Icon(Icons.language),
                    title: Text(AppLocalizations.of(context)!.language),
                    subtitle: Text(
                        ref.watch(localeStateProvider).toString() == "fr"
                            ? "Français"
                            : "English"),
                  ),
                  ListTile(
                      selectedColor: Theme.of(context).colorScheme.onSurface,
                      selectedTileColor:
                          Theme.of(context).colorScheme.surfaceDim,
                      selected: ref.watch(selectedSettingProvider) == "theme",
                      leading: const Icon(Icons.brightness_6),
                      title: Text(
                        AppLocalizations.of(context)!.theme,
                      ),
                      subtitle: AdaptiveTheme.of(context).mode.isDark
                          ? Text(AppLocalizations.of(context)!.dark)
                          : AdaptiveTheme.of(context).mode.isLight
                              ? Text(AppLocalizations.of(context)!.light)
                              : Text(
                                  AppLocalizations.of(context)!.systemDefault),
                      onTap: () {
                        ref.read(selectedSettingProvider.notifier).set("theme");
                        if (MediaQuery.of(context).size.width < 840) {
                          GoRouter.of(context).go('/settings/theme');
                        }
                      }),
                  const Divider(height: 0),
                  if (MediaQuery.of(context).size.width < 840)
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: Text(
                        AppLocalizations.of(context)!.signOut,
                      ),
                      onTap: () async {
                        await Supabase.instance.client.auth
                            .signOut()
                            .then((value) {
                          googleSignIn.signOut();
                          if (!context.mounted) return;
                          GoRouter.of(context).go('/login');
                        });
                      },
                    )
                ],
              ),
            ))
          ])),
      if (MediaQuery.of(context).size.width > 840) ...[
        VerticalDivider(
          width: 0,
          color: Theme.of(context).colorScheme.surfaceDim,
        ),
        Expanded(child: _getWidgetForSelection(selected)),
      ]
    ]);
  }
}
