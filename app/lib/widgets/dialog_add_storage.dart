import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/constants/storage_type.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/providers/storage.dart' as sp;

class DialogAddStorage extends ConsumerStatefulWidget {
  const DialogAddStorage({super.key});

  @override
  DialogAddStorageState createState() => DialogAddStorageState();
}

class DialogAddStorageState extends ConsumerState<DialogAddStorage> {
  TextEditingController controller = TextEditingController();
  String type = "Device";

  Widget content(context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      DropdownMenu<String>(
          expandedInsets: EdgeInsets.zero,
          leadingIcon: Icon(storageTypeIcon[type]),
          initialSelection: type,
          onSelected: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              type = value;
            });
          },
          inputDecorationTheme: Theme.of(context).inputDecorationTheme,
          dropdownMenuEntries: storageTypeIcon.entries.map((entry) {
            return DropdownMenuEntry<String>(
                value: entry.key,
                label: entry.key,
                leadingIcon: Icon(entry.value));
          }).toList()),
      const SizedBox(height: 10),
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Storage Name',
        ),
        controller: controller,
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Storage newStorage = Storage(type: type, alias: controller.text);
            ref
                .read(sp.storagesProvider.notifier)
                .add(newStorage)
                .then((value) {
              Navigator.pop(context);
            }).catchError((e) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("An error occured")));
            });
          },
          child: const Text('Add'),
        )
      ],
      title: const Text('Add Storage'),
      content: content(context),
    );
  }
}
