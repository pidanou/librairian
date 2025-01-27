import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:librairian/models/item.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/providers/item.dart';
import 'package:librairian/providers/storage.dart';
import 'package:librairian/providers/items_in_storage.dart';
import 'package:librairian/widgets/alert_dialog_confirm.dart';
import 'package:librairian/widgets/alert_dialog_delete_storage.dart';
import 'package:librairian/widgets/item_edit_form.dart';
import 'package:librairian/widgets/items_list.dart';
import 'package:librairian/widgets/page_switcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    Item? newItem = await ref
        .read(itemsInStorageProvider(page, limit, widget.storage.id).notifier)
        .save(item);

    if (!mounted) return true;
    if (newItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.error)));
      return false;
    }
    // ref.invalidate(itemsInStorageProvider(page, limit, widget.storage.id));
    return true;
  }

  void deleteSelected() async {
    setState(() {
      deleting = true;
    });
    for (var itemId in selected) {
      await ref
          .read(itemsInStorageProvider(page, limit, storage.id).notifier)
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
    controller.text = storage.alias;
  }

  @override
  void didUpdateWidget(EditStorage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.storage.id != oldWidget.storage.id) {
      controller.text = widget.storage.alias;
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
    var items =
        ref.watch(itemsInStorageProvider(page, limit, widget.storage.id));
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
                      : Text(widget.storage.alias,
                          style: Theme.of(context).textTheme.titleMedium),
                  trailing: editingStorage
                      ? Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                              icon: const Icon(
                                Icons.cancel,
                              ),
                              onPressed: () {
                                setState(() {
                                  editingStorage = false;
                                });
                              }),
                          IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                              ),
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
                              icon: const Icon(
                                Icons.edit,
                              ),
                              onPressed: () {
                                setState(() {
                                  editingStorage = true;
                                });
                              }),
                          IconButton(
                              icon: const Icon(
                                Icons.delete,
                              ),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialogDeleteStorage(
                                          onDelete: widget.onDelete,
                                          storageID: widget.storage.id);
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
                  ListTile(
                      dense: true,
                      leading: Checkbox(
                        onChanged: (value) {
                          setState(() {
                            selectAll = !selectAll;
                            if (selectAll == true) {
                              for (var item in items.value!.data) {
                                selected.add(item.id);
                              }
                            } else {
                              selected = [];
                            }
                          });
                        },
                        value: selectAll,
                      ),
                      title: Row(children: [
                        deleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator())
                            : IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                ),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialogConfirm(
                                          icon: const Icon(Icons.warning),
                                          title: const Text(
                                              "Are you sure you want to delete these items?"),
                                          message: const Text(
                                              "This cannot be undone."),
                                          confirmMessage: Text(
                                              AppLocalizations.of(context)!
                                                  .delete),
                                          action: deleteSelected,
                                        );
                                      });
                                },
                                tooltip: AppLocalizations.of(context)!.delete,
                              ),
                        IconButton(
                            tooltip: AppLocalizations.of(context)!.add,
                            icon: const Icon(
                              Icons.add_circle,
                            ),
                            onPressed: () async {
                              Item? newItem = await ref
                                  .read(itemControllerProvider(null).notifier)
                                  .add(
                                    Item(name: "New Item", locations: [
                                      Location(storageId: widget.storage.id)
                                    ]),
                                  );
                              newItem = await ref
                                  .read(itemControllerProvider(null).notifier)
                                  .addLocation(
                                      Location(storageId: widget.storage.id, itemId: newItem!.id)
                                  );
                              if (!context.mounted) {
                                return;
                              }
                              if (MediaQuery.of(context).size.width < 840) {
                                if (newItem == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              AppLocalizations.of(context)!
                                                  .error)));
                                  return;
                                }
                                ref.invalidate(itemsInStorageProvider(
                                    page, limit, widget.storage.id));
                                if (MediaQuery.of(context).size.width < 840) {
                                  GoRouter.of(context).go(
                                    '/storage/${widget.storage.id}/${newItem.id}',
                                  );
                                }
                              }
                              setState(() {
                                editingItem = newItem;
                              });
                            }),
                        if (MediaQuery.of(context).size.width > 840)
                          IconButton(
                              tooltip: AppLocalizations.of(context)!.refresh,
                              icon: const Icon(
                                Icons.refresh,
                              ),
                              onPressed: () {
                                ref.invalidate(itemsInStorageProvider(
                                    page, limit, storage.id));
                              })
                      ])),
                  Divider(
                    color: Theme.of(context).colorScheme.surfaceDim,
                    height: 0,
                  ),
                  items is AsyncData
                      ? Expanded(
                          child: ItemsList(
                              items: [...items.value?.data ?? []],
                              onRefresh: () => ref.refresh(
                                  itemsInStorageProvider(
                                          page, limit, storage.id)
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
                                  GoRouter.of(context).go(
                                      "/storage/${widget.storage.id}/${editingItem!.id}");
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
                  itemID: editingItem!.id,
                  onEdit: (item) async {
                    ref.invalidate(
                        itemsInStorageProvider(page, limit, widget.storage.id));
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
