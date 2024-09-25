import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:librairian/providers/settings.dart';
import 'package:librairian/providers/supabase.dart';
import 'package:librairian/widgets/account_form.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

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
                    title: Text(
                        ref.watch(supabaseUserProvider)?.email ?? "No email"),
                    onTap: () {
                      ref.read(selectedSettingProvider.notifier).set("account");
                      GoRouter.of(context).go('/settings/account');
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
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                    content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                      RadioMenuButton(
                                        value: AdaptiveThemeMode.light,
                                        groupValue:
                                            AdaptiveTheme.of(context).mode,
                                        onChanged: (value) {
                                          AdaptiveTheme.of(context)
                                              .setThemeMode(value ??
                                                  AdaptiveThemeMode.system);
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Light'),
                                      ),
                                      RadioMenuButton(
                                          value: AdaptiveThemeMode.dark,
                                          groupValue:
                                              AdaptiveTheme.of(context).mode,
                                          child: const Text('Dark'),
                                          onChanged: (value) {
                                            AdaptiveTheme.of(context)
                                                .setThemeMode(value ??
                                                    AdaptiveThemeMode.system);
                                            Navigator.of(context).pop();
                                          }),
                                      RadioMenuButton(
                                          value: AdaptiveThemeMode.system,
                                          groupValue:
                                              AdaptiveTheme.of(context).mode,
                                          child: const Text('System (default)'),
                                          onChanged: (value) {
                                            AdaptiveTheme.of(context)
                                                .setThemeMode(value ??
                                                    AdaptiveThemeMode.system);
                                            Navigator.of(context).pop();
                                          }),
                                    ])));
                      }),
                  const Divider(height: 0),
                  if (MediaQuery.of(context).size.width < 840)
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text(
                        'Logout',
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
      ]
    ]);
  }
}
