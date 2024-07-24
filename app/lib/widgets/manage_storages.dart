import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/constants/storage_type.dart';
import 'package:librairian/providers/storage.dart';
import 'package:librairian/widgets/alert_dialog_delete_storage.dart';
import 'package:librairian/widgets/edit_storage.dart';

class ManageStorages extends ConsumerStatefulWidget {
  const ManageStorages({super.key});

  @override
  ManageStoragesState createState() => ManageStoragesState();
}

class ManageStoragesState extends ConsumerState<ManageStorages> {
  List<String> editing = [];

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(storageProvider);
    if (storage is AsyncError) {
      return const Column(children: [Center(child: Text('Error'))]);
    }
    if (storage is AsyncData) {
      return Column(children: [
        Expanded(
            child: ListView(children: [
          for (var storage in storage.value ?? [])
            editing.contains(storage.id)
                ? EditStorage(
                    initialType: storage.type,
                    initialAlias: storage.alias,
                    onCancel: () {
                      setState(() {
                        editing.remove(storage.id);
                      });
                    })
                : ListTile(
                    title: storage.id == ref.watch(defaultStorageProvider)?.id
                        ? Text("${storage.alias} (default)")
                        : Text(storage.alias),
                    leading: Tooltip(
                        message: storage.type,
                        child: Icon(storageTypeIcon[storage.type])),
                    trailing: MenuAnchor(
                        menuChildren: [
                          MenuItemButton(
                              onPressed: () {
                                ref
                                    .read(defaultStorageProvider.notifier)
                                    .set(storage);
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.star, size: 15),
                                  SizedBox(width: 5),
                                  Text("Set as default")
                                ],
                              )),
                          MenuItemButton(
                              onPressed: () {
                                setState(() {
                                  editing.add(storage.id);
                                });
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.edit, size: 15),
                                  SizedBox(width: 5),
                                  Text("Edit")
                                ],
                              )),
                          MenuItemButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialogDeleteStorage(
                                          storageID: storage.id);
                                    });
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.delete, size: 15),
                                  SizedBox(width: 5),
                                  Text("Delete")
                                ],
                              ))
                        ],
                        builder: (context, controller, child) {
                          return IconButton(
                              icon: const Icon(Icons.more_horiz),
                              onPressed: () {
                                if (controller.isOpen) {
                                  controller.close();
                                } else {
                                  controller.open();
                                }
                              });
                        }))
        ]))
      ]);
    }
    return const Column(children: [Center(child: CircularProgressIndicator())]);
  }
}
