import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/providers/locale.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageForm extends ConsumerWidget {
  const LanguageForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(children: [
      RadioListTile(
        title: const Text("English"),
        value: const Locale("en"),
        groupValue: ref.watch(localeStateProvider),
        onChanged: (value) {
          ref
              .read(localeStateProvider.notifier)
              .set(value ?? const Locale("en"));
        },
      ),
      RadioListTile(
          title: const Text("Français"),
          value: const Locale("fr"),
          groupValue: ref.watch(localeStateProvider),
          onChanged: (value) {
            ref
                .read(localeStateProvider.notifier)
                .set(value ?? const Locale("fr"));
          }),
    ]);
  }
}
