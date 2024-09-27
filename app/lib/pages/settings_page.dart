import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/widgets/custom_appbar.dart';
import 'package:librairian/widgets/settings_content.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key, this.initialSetting});

  final String? initialSetting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (MediaQuery.of(context).size.width < 840) {
      return Scaffold(
          appBar:
              CustomAppBar(title: Text(AppLocalizations.of(context)!.settings)),
          backgroundColor: Theme.of(context).colorScheme.surfaceBright,
          body: const SettingsContent());
    }

    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceBright,
          borderRadius: MediaQuery.of(context).size.width < 840
              ? const BorderRadius.all(Radius.circular(0))
              : const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0))),
      child: Column(children: [
        if (MediaQuery.of(context).size.width > 840) ...[
          ListTile(title: Text(AppLocalizations.of(context)!.settings)),
          Divider(height: 0, color: Theme.of(context).colorScheme.surfaceDim)
        ],
        Expanded(child: SettingsContent(initialSetting: initialSetting))
      ]),
    );
  }
}
