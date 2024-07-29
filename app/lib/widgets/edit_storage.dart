import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/constants/storage_type.dart';
import 'package:librairian/models/item.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/providers/storage.dart' as sp;
import 'package:librairian/providers/user_items.dart';
import 'package:librairian/widgets/alert_dialog_delete_storage.dart';
import 'package:librairian/widgets/item_edit_form.dart';
import 'package:librairian/widgets/items_list.dart';

class EditStorage extends ConsumerStatefulWidget {
  const EditStorage({this.onDelete, required this.storage, super.key});

  final Storage storage;
  final VoidCallback? onDelete;

  @override
  EditStorageState createState() => EditStorageState();
}

class EditStorageState extends ConsumerState<EditStorage> {
  late Storage storage;
  bool editing = false;
  TextEditingController controller = TextEditingController();
  Item? selectedItem;
  int page = 1;
  int limit = 10;

  @override
  void initState() {
    super.initState();
    storage = widget.storage;
  }

  @override
  void didUpdateWidget(EditStorage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.storage.id != oldWidget.storage.id) {
      controller.text = widget.storage.alias ?? "";
      storage = widget.storage;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var items = ref.watch(userItemsProvider(page, limit, widget.storage.id));
    return Row(children: [
      Expanded(
          child: FocusTraversalGroup(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            !editing
                ? ListTile(
                    leading: Icon(storageTypeIcon[widget.storage.type]),
                    title: Text(widget.storage.alias ?? 'No name',
                        style: Theme.of(context).textTheme.titleMedium),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () {
                            setState(() {
                              editing = true;
                            });
                          }),
                      IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialogDeleteStorage(
                                      onDelete: widget.onDelete,
                                      storageID: widget.storage.id ?? "");
                                });
                          })
                    ]))
                : Padding(
                    padding: const EdgeInsets.all(10),
                    child: Wrap(spacing: 5, runSpacing: 10, children: [
                      DropdownMenu<String>(
                          label: const Text('Type'),
                          leadingIcon:
                              Icon(storageTypeIcon[widget.storage.type]),
                          onSelected: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              storage.type = value;
                            });
                          },
                          inputDecorationTheme:
                              Theme.of(context).inputDecorationTheme,
                          initialSelection: widget.storage.type,
                          dropdownMenuEntries:
                              storageTypeIcon.entries.map((entry) {
                            return DropdownMenuEntry<String>(
                                value: entry.key,
                                label: entry.key,
                                leadingIcon: Icon(entry.value));
                          }).toList()),
                      const SizedBox(width: 10),
                      Row(children: [
                        Expanded(
                            child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                ),
                                controller: controller,
                                onChanged: (value) {
                                  setState(() {
                                    storage.alias = value;
                                  });
                                })),
                        IconButton(
                            tooltip: 'Submit',
                            onPressed: () {
                              ref
                                  .read(sp.storageProvider.notifier)
                                  .edit(storage);
                              setState(() {
                                editing = false;
                              });
                            },
                            icon: const Icon(Icons.check)),
                        IconButton(
                            tooltip: 'Cancel',
                            onPressed: () {
                              setState(() {
                                editing = false;
                              });
                            },
                            icon: const Icon(Icons.cancel)),
                      ])
                    ])),
            const SizedBox(height: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  items is AsyncData
                      ? Expanded(
                          child: ItemsList(
                              items: items.value?.data ?? [],
                              storage: storage,
                              onDelete: (List<String> itemsID) {
                                for (var itemID in itemsID) {
                                  ref
                                      .read(userItemsProvider(
                                              page, limit, storage.id)
                                          .notifier)
                                      .delete(itemID);
                                }
                              },
                              onSelect: (Item item) {
                                setState(() {
                                  selectedItem = item;
                                });
                              }))
                      : const Center(child: CircularProgressIndicator())
                ])),
          ]))),
      if (selectedItem == null)
        Container()
      else ...[
        VerticalDivider(
          color: Theme.of(context).colorScheme.surfaceDim,
          width: 1,
        ),
        Expanded(
            child: ItemEditForm(
                item: selectedItem!,
                onSave: (item) {
                  ref
                      .read(userItemsProvider(page, limit, storage.id).notifier)
                      .save(item);
                  selectedItem = null;
                },
                onCancel: () {
                  setState(() {
                    selectedItem = null;
                  });
                }))
      ]
    ]);
  }
}
