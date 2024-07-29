import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/constants/storage_type.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/providers/storage.dart' as sp;

class AlertDialogAddStorage extends ConsumerStatefulWidget {
  const AlertDialogAddStorage({super.key});

  @override
  AlertDialogAddStorageState createState() => AlertDialogAddStorageState();
}

class AlertDialogAddStorageState extends ConsumerState<AlertDialogAddStorage> {
  TextEditingController controller = TextEditingController();
  String type = "Device";
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
            ref.read(sp.storageProvider.notifier).add(newStorage).then((value) {
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
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownMenu<String>(
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
      ]),
    );
  }
}
