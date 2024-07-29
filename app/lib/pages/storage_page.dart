import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/providers/storage.dart';
import 'package:librairian/widgets/alert_dialog_add_storage.dart';
import 'package:librairian/widgets/manage_storages.dart';

class StoragePage extends ConsumerStatefulWidget {
  const StoragePage({super.key});
  @override
  StoragePageState createState() => StoragePageState();
}

class StoragePageState extends ConsumerState<StoragePage> {
  bool selectAll = false;
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceBright,
            borderRadius: MediaQuery.of(context).size.width < 600
                ? const BorderRadius.all(Radius.circular(0))
                : const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0))),
        child: Column(children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 8, top: 5, bottom: 5, right: 16),
            child: Row(children: [
              IconButton(
                  tooltip: 'Add storage',
                  icon: const Icon(Icons.add_circle),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const AlertDialogAddStorage();
                        });
                  }),
              IconButton(
                  tooltip: 'Refresh data',
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.invalidate(storageProvider);
                  })
            ]),
          ),
          Divider(
            color: Theme.of(context).colorScheme.surfaceDim,
            height: 0,
          ),
          Expanded(
              child: ManageStorages(
            selectAll: selectAll,
          )),
        ]));
  }
}
