import 'package:flutter/material.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/widgets/alert_dialog_delete_storage.dart';
import 'package:librairian/widgets/edit_storage.dart';
import 'package:librairian/widgets/alert_form_edit_storage.dart';

class StorageDetailPage extends StatelessWidget {
  const StorageDetailPage(
      {required this.storageID, required this.storage, super.key});

  final String storageID;
  final Storage storage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surfaceDim,
            actions: [
              IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertFormEditStorage(storage: storage);
                        });
                  }),
              IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialogDeleteStorage(
                              storageID: storage.id ?? "");
                        });
                  })
            ],
            title: Text(storage.alias ?? 'No name'),
            centerTitle: true),
        body: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceBright,
                borderRadius: MediaQuery.of(context).size.width < 600
                    ? const BorderRadius.all(Radius.circular(0))
                    : const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0))),
            child: EditStorage(
              storage: storage,
            )));
  }
}
