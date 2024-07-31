import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/constants/storage_type.dart';
import 'package:librairian/models/item.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/providers/storage.dart' as sp;
import 'package:librairian/providers/user_items.dart';
import 'package:librairian/widgets/alert_dialog_delete_storage.dart';
import 'package:librairian/widgets/file_picker.dart';
import 'package:librairian/widgets/item_edit_form.dart';
import 'package:librairian/widgets/items_list.dart';
import 'package:librairian/helpers/uuid.dart';
import 'package:librairian/widgets/page_switcher.dart';

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
  Item? editingItem;
  int page = 1;
  int limit = 20;
  List<String> selected = [];
  bool selectAll = false;
  List<Item> newItems = [];

  void _addItemsFromFiles(List<XFile>? listItems) async {
    List<Item> files = [];
    for (var pfile in listItems ?? []) {
      var file = await Item.fromXFile(pfile);
      file.storageLocations = [
        StorageLocation(
            storage: storage, location: pfile.path, storageId: storage.id)
      ];
      files.add(file);
    }
    setState(() {
      newItems.addAll(files);
    });
  }

  void deleteSelected() {
    for (var itemId in selected) {
      if (!isValidUUID(itemId)) {
        ref
            .read(userItemsProvider(page, limit, storage.id).notifier)
            .remove(itemId);
        continue;
      }
      ref
          .read(userItemsProvider(page, limit, storage.id).notifier)
          .delete(itemId);
    }
    setState(() {
      selectAll = false;
      selected.clear();
    });
  }

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
      selectAll = false;
      newItems = [];
      editingItem = null;
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
                  Row(children: [
                    const SizedBox(width: 16),
                    Checkbox(
                      onChanged: (value) {
                        setState(() {
                          selectAll = !selectAll;
                          if (selectAll == true) {
                            for (var item in items.value!.data) {
                              selected.add(item.id ?? item.tmpId ?? "");
                            }
                          } else {
                            selected = [];
                          }
                        });
                      },
                      value: selectAll,
                    ),
                    const SizedBox(width: 48),
                    IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          deleteSelected();
                        },
                        tooltip: 'Delete selected'),
                    IconButton(
                        tooltip: 'Add item',
                        icon: const Icon(Icons.add_circle),
                        onPressed: () {
                          setState(() {
                            final newItem = Item.newPhysicalItem();
                            newItem.storageLocations = [
                              StorageLocation(storage: widget.storage)
                            ];
                            newItems.add(newItem);
                          });
                        }),
                    FilePicker(onSelect: (List<XFile>? files) {
                      _addItemsFromFiles(files);
                    }),
                    IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          ref.invalidate(
                              userItemsProvider(page, limit, storage.id));
                        })
                  ]),
                  if (MediaQuery.of(context).size.width > 840) ...[
                    Divider(
                      color: Theme.of(context).colorScheme.surfaceDim,
                      height: 0,
                    ),
                    items is AsyncData
                        ? Expanded(
                            child: ItemsList(
                                items: [
                                ...newItems,
                                ...items.value?.data ?? []
                              ],
                                storage: storage,
                                selectAll: selectAll,
                                onSelected: (List<String> list) {
                                  setState(() {
                                    selected = list;
                                  });
                                },
                                onTap: (Item item) {
                                  setState(() {
                                    editingItem = item;
                                  });
                                }))
                        : const Expanded(
                            child: Center(child: CircularProgressIndicator())),
                    PageSwitcher(
                        prevPage: () {
                          setState(() {
                            page = page - 1;
                          });
                        },
                        nextPage: () {
                          setState(() {
                            page = page + 1;
                          });
                        },
                        pageSize: limit,
                        currentPage: page,
                        totalItem: (items.value?.metadata.total ?? 0) +
                            newItems.length)
                  ]
                ])),
          ]))),
      if (MediaQuery.of(context).size.width > 840)
        if (editingItem == null)
          Container()
        else ...[
          VerticalDivider(
            color: Theme.of(context).colorScheme.surfaceDim,
            width: 1,
          ),
          Expanded(
              child: ItemEditForm(
                  item: editingItem!,
                  onSave: (item) {
                    ref
                        .read(
                            userItemsProvider(page, limit, storage.id).notifier)
                        .save(item);
                    if (!isValidUUID(item.id)) {
                      newItems.removeWhere(
                          (element) => element.tmpId == item.tmpId);
                    }
                    ref.invalidate(userItemsProvider(page, limit, storage.id));
                    editingItem = null;
                  },
                  onCancel: () {
                    setState(() {
                      editingItem = null;
                    });
                  }))
        ]
    ]);
  }
}
