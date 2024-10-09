import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ThemeForm extends ConsumerWidget {
  const ThemeForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(children: [
      RadioListTile(
        title: Text(AppLocalizations.of(context)!.light),
        value: AdaptiveThemeMode.light,
        groupValue: AdaptiveTheme.of(context).mode,
        onChanged: (value) {
          AdaptiveTheme.of(context)
              .setThemeMode(value ?? AdaptiveThemeMode.system);
        },
      ),
      RadioListTile(
          title: Text(AppLocalizations.of(context)!.dark),
          value: AdaptiveThemeMode.dark,
          groupValue: AdaptiveTheme.of(context).mode,
          onChanged: (value) {
            AdaptiveTheme.of(context)
                .setThemeMode(value ?? AdaptiveThemeMode.system);
          }),
      RadioListTile(
          value: AdaptiveThemeMode.system,
          groupValue: AdaptiveTheme.of(context).mode,
          title: Text(AppLocalizations.of(context)!.systemDefault),
          onChanged: (value) {
            AdaptiveTheme.of(context)
                .setThemeMode(value ?? AdaptiveThemeMode.system);
          }),
    ]);
  }
}
