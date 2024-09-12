import 'package:flutter/material.dart';
import 'package:librairian/widgets/custom_appbar.dart';
import 'package:librairian/widgets/settings_content.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 840) {
      return const Scaffold(
        appBar: CustomAppBar(title: Text('Settings')),
        body: SettingsContent(),
      );
    }

    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceBright,
          borderRadius: MediaQuery.of(context).size.width < 840
              ? const BorderRadius.all(Radius.circular(0))
              : const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0))),
      child: const SettingsContent(),
    );
  }
}
