import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/widgets/custom_appbar.dart';
import 'package:librairian/widgets/settings_content.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key, this.initialSetting});

  final String? initialSetting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (MediaQuery.of(context).size.width < 840) {
      return Scaffold(
          appBar: const CustomAppBar(title: Text('Settings')),
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
          const ListTile(title: Text('Settings')),
          Divider(height: 0, color: Theme.of(context).colorScheme.surfaceDim)
        ],
        Expanded(child: SettingsContent(initialSetting: initialSetting))
      ]),
    );
  }
}
