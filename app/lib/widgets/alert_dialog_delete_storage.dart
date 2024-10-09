import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/providers/storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AlertDialogDeleteStorage extends ConsumerWidget {
  const AlertDialogDeleteStorage(
      {this.onDelete, required this.storageID, super.key});

  final String storageID;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      icon: const Icon(Icons.warning),
      title: Text(AppLocalizations.of(context)!.confirmDelete),
      content: Text(AppLocalizations.of(context)!.confirmDeleteNotice),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () {
            ref.read(storagesProvider.notifier).delete(storageID);
            onDelete?.call();
            Navigator.pop(context, true);
          },
          child: Text(AppLocalizations.of(context)!.delete),
        ),
      ],
    );
  }
}
