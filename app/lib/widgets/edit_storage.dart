import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/constants/storage_type.dart';

class EditStorage extends ConsumerWidget {
  const EditStorage(
      {this.onSubmit,
      this.onCancel,
      required this.initialAlias,
      required this.initialType,
      super.key});

  final String initialType;
  final String initialAlias;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Row(children: [
        DropdownMenu<String>(
            inputDecorationTheme: Theme.of(context).inputDecorationTheme,
            initialSelection: initialType,
            dropdownMenuEntries: storageTypeIcon.entries.map((entry) {
              return DropdownMenuEntry<String>(
                  value: entry.key,
                  label: entry.key,
                  leadingIcon: Icon(entry.value));
            }).toList()),
        const SizedBox(width: 10),
        Expanded(
            child: TextFormField(
          initialValue: initialAlias,
        )),
        IconButton(
            tooltip: 'Submit',
            onPressed: () {
              onSubmit?.call();
            },
            icon: const Icon(Icons.check)),
        IconButton(
            tooltip: 'Cancel',
            onPressed: () {
              onCancel?.call();
            },
            icon: const Icon(Icons.cancel)),
      ]),
    );
  }
}
