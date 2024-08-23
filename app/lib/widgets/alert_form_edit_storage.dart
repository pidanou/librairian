import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/constants/storage_type.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/providers/storage.dart';

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
        title: const Text('Edit storage'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                ref.read(storagesProvider.notifier).edit(widget.storage);
                Navigator.of(context).pop();
              },
              child: const Text('Submit')),
        ],
        content: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownMenu<String>(
                  label: const Text('Type'),
                  leadingIcon: Icon(storageTypeIcon[widget.storage.type]),
                  onSelected: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      widget.storage.type = value;
                    });
                  },
                  inputDecorationTheme: Theme.of(context).inputDecorationTheme,
                  initialSelection: widget.storage.type,
                  dropdownMenuEntries: storageTypeIcon.entries.map((entry) {
                    return DropdownMenuEntry<String>(
                        value: entry.key,
                        label: entry.key,
                        leadingIcon: Icon(entry.value));
                  }).toList()),
              const SizedBox(height: 10),
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
