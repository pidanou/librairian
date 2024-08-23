import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/providers/storage.dart';

class AlertDialogDeleteStorage extends ConsumerWidget {
  const AlertDialogDeleteStorage(
      {this.onDelete, required this.storageID, super.key});

  final String storageID;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      icon: const Icon(Icons.warning),
      title: const Text('Are you sure you want to delete this storage?'),
      content: const Text(
          'Items inside the storage will ALL be deleted. You will not be able to undo this action.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            ref.read(storagesProvider.notifier).delete(storageID);
            onDelete?.call();
            Navigator.pop(context, true);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
