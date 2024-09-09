import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/models/item.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/providers/item.dart' as provider;
import 'package:librairian/providers/storage.dart';
import 'package:librairian/providers/user_items.dart';
import 'package:librairian/widgets/alert_dialog_confirm.dart';
import 'package:librairian/widgets/alert_dialog_delete_storage.dart';
import 'package:librairian/widgets/item_edit_form.dart';
import 'package:librairian/widgets/items_list.dart';
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
  TextEditingController controller = TextEditingController();
  Item? editingItem;
  int page = 1;
  int limit = 20;
  List<String> selected = [];
  bool selectAll = false;
  bool editingStorage = false;
  bool deleting = false;

  Future<bool> save(Item item) async {
    bool success = await ref.read(provider.itemProvider.notifier).save(item);

    if (!mounted) return true;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item could not be saved")));
      return false;
    }
    ref.invalidate(userItemsProvider(page, limit, widget.storage.id));
    return true;
  }

  void deleteSelected() async {
    setState(() {
      deleting = true;
    });
    for (var itemId in selected) {
      await ref
          .read(userItemsProvider(page, limit, storage.id).notifier)
          .delete(itemId);
    }
    setState(() {
      selectAll = false;
      deleting = false;
      selected.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    storage = widget.storage;
    controller.text = storage.alias ?? "";
  }

  @override
  void didUpdateWidget(EditStorage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.storage.id != oldWidget.storage.id) {
      controller.text = widget.storage.alias ?? "";
      storage = widget.storage;
      selectAll = false;
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
            if (MediaQuery.of(context).size.width > 840)
              ListTile(
                  title: editingStorage
                      ? TextField(
                          controller: controller,
                        )
                      : Text(widget.storage.alias ?? 'No name',
                          style: Theme.of(context).textTheme.titleMedium),
                  trailing: editingStorage
                      ? Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                              icon: const Icon(Icons.cancel, size: 20),
                              onPressed: () {
                                setState(() {
                                  editingStorage = false;
                                });
                              }),
                          IconButton(
                              icon: const Icon(Icons.check_circle, size: 20),
                              onPressed: () {
                                storage.alias = controller.text;
                                ref
                                    .read(storagesProvider.notifier)
                                    .edit(storage);
                                setState(() {
                                  editingStorage = false;
                                });
                              })
                        ])
                      : Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () {
                                setState(() {
                                  editingStorage = true;
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
                        ])),
            Divider(
              color: Theme.of(context).colorScheme.surfaceDim,
              height: 0,
            ),
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
                              selected.add(item.id ?? "");
                            }
                          } else {
                            selected = [];
                          }
                        });
                      },
                      value: selectAll,
                    ),
                    const SizedBox(width: 48),
                    deleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator())
                        : IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialogConfirm(
                                      icon: const Icon(Icons.warning),
                                      title: const Text(
                                          "Are you sure you want to delete these items?"),
                                      message:
                                          const Text("This cannot be undone."),
                                      confirmMessage: const Text("Delete"),
                                      action: deleteSelected,
                                    );
                                  });
                            },
                            tooltip: 'Delete selected'),
                    IconButton(
                        tooltip: 'Add item',
                        icon: const Icon(Icons.add_circle),
                        onPressed: () {
                          if (MediaQuery.of(context).size.width < 840) {
                            showModalBottomSheet<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Expanded(
                                            child: ItemEditForm(
                                          item: Item(
                                              name: "New Item",
                                              storageLocations: [
                                                StorageLocation(
                                                    storage: widget.storage)
                                              ]),
                                          onSave: (item) {
                                            save(item);
                                            Navigator.pop(context);
                                          },
                                        )),
                                      ],
                                    ),
                                  );
                                });
                          }
                          setState(() {
                            editingItem = Item(
                                name: "New Item",
                                storageLocations: [
                                  StorageLocation(storage: widget.storage)
                                ]);
                          });
                        }),
                    // FilePicker(onSelect: (List<XFile>? files) {
                    //   _addItemsFromFiles(files);
                    // }),
                    if (MediaQuery.of(context).size.width > 840)
                      IconButton(
                          tooltip: 'Refresh data',
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            ref.invalidate(
                                userItemsProvider(page, limit, storage.id));
                          })
                  ]),
                  Divider(
                    color: Theme.of(context).colorScheme.surfaceDim,
                    height: 0,
                  ),
                  items is AsyncData
                      ? Expanded(
                          child: ItemsList(
                              items: [...items.value?.data ?? []],
                              onRefresh: () => ref.refresh(
                                  userItemsProvider(page, limit, storage.id)
                                      .future),
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
                                if (MediaQuery.of(context).size.width < 840) {
                                  showModalBottomSheet<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Expanded(
                                                  child: ItemEditForm(
                                                      item: editingItem!,
                                                      onSave: (item) {
                                                        ref
                                                            .read(
                                                                userItemsProvider(
                                                                        page,
                                                                        limit,
                                                                        storage
                                                                            .id)
                                                                    .notifier)
                                                            .save(item);
                                                        ref.invalidate(
                                                            userItemsProvider(
                                                                page,
                                                                limit,
                                                                storage.id));
                                                        editingItem = null;
                                                      },
                                                      onCancel: () {
                                                        setState(() {
                                                          editingItem = null;
                                                        });
                                                      }))
                                            ],
                                          ),
                                        );
                                      });
                                }
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
                      totalItem: (items.value?.metadata.total ?? 0))
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
                  onSave: (item) async {
                    bool success = false;
                    if (item.id != null) {
                      await ref
                          .read(userItemsProvider(page, limit, storage.id)
                              .notifier)
                          .save(item);
                      success = true;
                    } else {
                      success = await ref
                          .read(provider.itemProvider.notifier)
                          .save(item);
                    }
                    if (!mounted) return;
                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Item could not be saved")));
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
