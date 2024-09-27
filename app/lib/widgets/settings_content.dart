import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:librairian/providers/locale.dart';
import 'package:librairian/providers/settings.dart';
import 'package:librairian/providers/supabase.dart';
import 'package:librairian/widgets/account_form.dart';
import 'package:librairian/widgets/theme_form.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsContent extends ConsumerWidget {
  const SettingsContent({super.key, this.initialSetting});
  final String? initialSetting;

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
              child: ListView(
                children: [
                  ListTile(
                      dense: true,
                      title: Text("Account",
                          style: Theme.of(context).textTheme.titleSmall)),
                  ListTile(
                    leading: const Icon(Icons.mail),
                    title: Text(ref.watch(supabaseUserProvider)?.email ?? ""),
                    onTap: () {
                      ref.read(selectedSettingProvider.notifier).set("account");
                      if (MediaQuery.of(context).size.width < 840) {
                        GoRouter.of(context).go('/settings/account');
                      }
                    },
                  ),
                  ListTile(
                      leading: const Icon(Icons.bar_chart),
                      title: const Text("Usage"),
                      onTap: () {}),
                  const Divider(height: 0),
                  ListTile(
                      dense: true,
                      title: Text("App",
                          style: Theme.of(context).textTheme.titleSmall)),
                  ListTile(
                      title: IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () {
                            ref
                                .read(localeStateProvider.notifier)
                                .set(const Locale('fr'));
                          })),
                  ListTile(
                      leading: const Icon(Icons.brightness_6),
                      title: const Text(
                        "Theme",
                      ),
                      subtitle: AdaptiveTheme.of(context).mode.isDark
                          ? const Text("Dark")
                          : AdaptiveTheme.of(context).mode.isLight
                              ? const Text("Light")
                              : const Text("System (default)"),
                      onTap: () {
                        ref.read(selectedSettingProvider.notifier).set("theme");
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
            )
          ])),
      if (MediaQuery.of(context).size.width > 840) ...[
        VerticalDivider(
          width: 0,
          color: Theme.of(context).colorScheme.surfaceDim,
        ),
        if (selected == null) Expanded(child: Container()),
        if (selected == "account") const Expanded(child: AccountForm()),
        if (selected == "theme") const Expanded(child: ThemeForm()),
      ]
    ]);
  }
}
