import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/providers/storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AlertFormEditStorage extends ConsumerStatefulWidget {
  const AlertFormEditStorage({super.key, required this.storage});

  final Storage storage;

  @override
  ConsumerState<AlertFormEditStorage> createState() =>
      AlertFormEditStorageState();
}

class AlertFormEditStorageState extends ConsumerState<AlertFormEditStorage> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(AppLocalizations.of(context)!.edit),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel)),
          TextButton(
              onPressed: () {
                ref.read(storagesProvider.notifier).edit(widget.storage);
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.save)),
        ],
        content: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Flexible(
                  child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                      controller: controller,
                      onChanged: (value) {
                        setState(() {
                          widget.storage.alias = value;
                        });
                      })),
            ])));
  }
}
