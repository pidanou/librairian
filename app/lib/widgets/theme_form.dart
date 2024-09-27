import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeForm extends ConsumerWidget {
  const ThemeForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(children: [
      RadioListTile(
        title: const Text('Light'),
        value: AdaptiveThemeMode.light,
        groupValue: AdaptiveTheme.of(context).mode,
        onChanged: (value) {
          AdaptiveTheme.of(context)
              .setThemeMode(value ?? AdaptiveThemeMode.system);
        },
      ),
      RadioListTile(
          title: const Text('Dark'),
          value: AdaptiveThemeMode.dark,
          groupValue: AdaptiveTheme.of(context).mode,
          onChanged: (value) {
            AdaptiveTheme.of(context)
                .setThemeMode(value ?? AdaptiveThemeMode.system);
          }),
      RadioListTile(
          value: AdaptiveThemeMode.system,
          groupValue: AdaptiveTheme.of(context).mode,
          title: const Text('System (Default)'),
          onChanged: (value) {
            AdaptiveTheme.of(context)
                .setThemeMode(value ?? AdaptiveThemeMode.system);
          }),
    ]);
  }
}
