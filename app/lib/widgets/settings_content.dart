import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    var _googleSignIn = GoogleSignIn();
    return Column(
        mainAxisSize: MediaQuery.of(context).size.height < 600
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
                  title: const Text("Email"),
                  subtitle: Text(
                      Supabase.instance.client.auth.currentUser?.email ??
                          "No email"),
                ),
                ListTile(
                    leading: const Icon(Icons.wallet),
                    title: const Text("Plan"),
                    onTap: () {}),
                ListTile(
                    leading: const Icon(Icons.bar_chart),
                    title: const Text("Usage"),
                    onTap: () {}),
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
                                        AdaptiveTheme.of(context).setThemeMode(
                                            value ?? AdaptiveThemeMode.system);
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
                const ListTile(
                  dense: true,
                ),
                if (MediaQuery.of(context).size.width < 600)
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text(
                      'Logout',
                    ),
                    onTap: () async {
                      await Supabase.instance.client.auth
                          .signOut()
                          .then((value) {
                        _googleSignIn.signOut();
                        GoRouter.of(context).go('/login');
                      });
                    },
                  )
              ],
            ),
          )
        ]);
  }
}