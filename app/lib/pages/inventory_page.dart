import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:librairian/models/item.dart';
import 'package:librairian/providers/inventory.dart';
import 'package:librairian/providers/item.dart';
import 'package:librairian/providers/items_in_storage.dart';
import 'package:librairian/widgets/alert_dialog_confirm.dart';
import 'package:librairian/widgets/custom_appbar.dart';
import 'package:librairian/widgets/default_error.dart';
import 'package:librairian/widgets/item_edit_form.dart';
import 'package:librairian/widgets/items_list.dart';
import 'package:librairian/widgets/order_by_selector.dart';
import 'package:librairian/widgets/page_switcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => InventoryPageState();
}

class InventoryPageState extends ConsumerState<InventoryPage> {
  MenuController menuController = MenuController();
  int page = 1;
  int pageSize = 20;
  bool asc = false;
  String orderBy = "created_at";
  Item? editingItem;
  String orderByLabel = "New items to old";
  List<String> selected = [];
  bool deleting = false;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 840) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceBright,
        appBar: CustomAppBar(
          title: Text(AppLocalizations.of(context)!.myItems),
          actions: [
            deleting
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator())
                : IconButton(
                    tooltip: AppLocalizations.of(context)!.delete,
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      selected.isNotEmpty
                          ? showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialogConfirm(
                                    icon: const Icon(Icons.warning),
                                    title: const Text(
                                        "Are you sure you want to delete these items?"),
                                    message: const Text(
                                        "This action cannot be undone"),
                                    confirmMessage: Text(
                                        AppLocalizations.of(context)!.delete),
                                    action: () async {
                                      setState(() {
                                        deleting = true;
                                      });
                                      for (String id in selected) {
                                        await ref
                                            .read(itemControllerProvider(id)
                                                .notifier)
                                            .delete(id);
                                      }
                                      setState(() {
                                        deleting = false;
                                      });
                                      if (!context.mounted) return;
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) {
                                        Navigator.pop(
                                            context); // Safely pop after async operation
                                      });
                                      ref.invalidate(itemsInStorageProvider(
                                          page, pageSize, null, orderBy, asc));
                                    });
                              })
                          : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .noItemSelected)));
                    }),
            IconButton(
                tooltip: AppLocalizations.of(context)!.add,
                icon: const Icon(Icons.add_circle),
                onPressed: () async {
                  var newItem =
                      await ref.read(itemControllerProvider(null).notifier).add(
                            Item(name: "New Item"),
                          );
                  if (!context.mounted) {
                    return;
                  }
                  if (newItem == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(AppLocalizations.of(context)!.error)));
                    return;
                  }
                  ref.invalidate(itemsInStorageProvider(
                      page, pageSize, null, orderBy, asc));
                  if (MediaQuery.of(context).size.width < 840) {
                    GoRouter.of(context).go(
                      '/inventory/${newItem.id}',
                    );
                  }
                  setState(() {
                    editingItem = Item(name: "New Item");
                  });
                }),
          ],
        ),
        body: content(context),
      );
    }
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceBright,
            borderRadius: MediaQuery.of(context).size.width < 840
                ? const BorderRadius.all(Radius.circular(0))
                : const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0))),
        child: content(context));
  }

  Widget content(BuildContext context) {
    var items = ref.watch(inventoryProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          color: MediaQuery.of(context).size.width < 840
              ? Theme.of(context).colorScheme.surfaceDim
              : null,
          child: ListTile(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                Row(children: [
                  OrderBySelector(
                    controller: menuController,
                    options: [
                      ListTile(
                          onTap: () {
                            ref
                                .read(inventoryOrderProvider.notifier)
                                .set("name");
                            ref.read(inventoryAscProvider.notifier).set(false);
                            setState(() {
                              orderByLabel = "Name A-Z";
                            });
                            menuController.close();
                          },
                          dense: true,
                          title: Text(AppLocalizations.of(context)!.nameAZ)),
                      ListTile(
                          onTap: () {
                            ref
                                .read(inventoryOrderProvider.notifier)
                                .set("name");
                            ref.read(inventoryAscProvider.notifier).set(true);
                            setState(() {
                              orderByLabel = "Name Z-A";
                            });
                            menuController.close();
                          },
                          dense: true,
                          title: Text(AppLocalizations.of(context)!.nameZA)),
                      ListTile(
                          onTap: () {
                            ref
                                .read(inventoryOrderProvider.notifier)
                                .set("created_at");
                            ref.read(inventoryAscProvider.notifier).set(false);
                            setState(() {
                              orderByLabel = "Old items to new";
                            });
                            menuController.close();
                          },
                          dense: true,
                          title: Text(
                              AppLocalizations.of(context)!.oldItemsToNew)),
                      ListTile(
                          onTap: () {
                            ref
                                .read(inventoryOrderProvider.notifier)
                                .set("created_at");
                            ref.read(inventoryAscProvider.notifier).set(true);
                            setState(() {
                              orderByLabel = "New items to old";
                            });
                            menuController.close();
                          },
                          dense: true,
                          title: Text(
                              AppLocalizations.of(context)!.newItemsToOld)),
                      ListTile(
                          onTap: () {
                            ref
                                .read(inventoryOrderProvider.notifier)
                                .set("updated_at");
                            ref.read(inventoryAscProvider.notifier).set(true);
                            setState(() {
                              orderByLabel = "Last updated";
                            });
                            menuController.close();
                          },
                          dense: true,
                          title:
                              Text(AppLocalizations.of(context)!.lastUpdated)),
                    ],
                    child: Text(orderByLabel),
                  ),
                  if (MediaQuery.of(context).size.width > 840) ...[
                    IconButton(
                        tooltip: AppLocalizations.of(context)!.refresh,
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          ref.invalidate(inventoryProvider);
                        }),
                    IconButton(
                        tooltip: AppLocalizations.of(context)!.add,
                        icon: const Icon(Icons.add_circle),
                        onPressed: () async {
                          var newItem =
                              await ref.read(itemRepositoryProvider).postItem(
                                    Item(
                                      name: "New Item",
                                    ),
                                  );
                          if (!context.mounted) {
                            return;
                          }
                          if (newItem == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text(AppLocalizations.of(context)!.error)));
                            return;
                          }
                          ref.invalidate(inventoryProvider);
                          setState(() {
                            editingItem = newItem;
                          });
                        }),
                    deleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator())
                        : IconButton(
                            tooltip: AppLocalizations.of(context)!.delete,
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              selected.isNotEmpty
                                  ? showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialogConfirm(
                                            icon: const Icon(Icons.warning),
                                            title: const Text(
                                                "Are you sure you want to delete these items?"),
                                            message: const Text(
                                                "This action cannot be undone"),
                                            confirmMessage: Text(
                                                AppLocalizations.of(context)!
                                                    .delete),
                                            action: () async {
                                              setState(() {
                                                deleting = true;
                                              });
                                              for (String id in selected) {
                                                await ref
                                                    .read(
                                                        itemControllerProvider(
                                                                id)
                                                            .notifier)
                                                    .delete(id);
                                              }
                                              setState(() {
                                                editingItem = null;
                                                deleting = false;
                                              });
                                              ref.invalidate(inventoryProvider);
                                            });
                                      })
                                  : ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              AppLocalizations.of(context)!
                                                  .noItemSelected)));
                            }),
                  ]
                ])
              ]))),
      Divider(
        color: Theme.of(context).colorScheme.surfaceDim,
        height: 0,
      ),
      items is AsyncError
          ? const DefaultError()
          : Expanded(
              child: Row(children: [
              Expanded(
                  child: Column(children: [
                Expanded(
                    child: items is AsyncData
                        ? ItemsList(
                            selected: selected,
                            editing: editingItem?.id.toString() ?? "",
                            onRefresh: () =>
                                ref.refresh(inventoryProvider.future),
                            onSelected: (List<String> selectedItem) {
                              setState(() {
                                selected = selectedItem;
                              });
                            },
                            onTap: (item) async {
                              if (MediaQuery.of(context).size.width > 840) {
                                setState(() {
                                  editingItem = item;
                                });
                              }
                              if (MediaQuery.of(context).size.width < 840) {
                                GoRouter.of(context)
                                    .go('/inventory/${item.id}', extra: item);
                              }
                            },
                            items: items.value?.data ?? [],
                          )
                        : const Center(child: CircularProgressIndicator())),
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
                    pageSize: pageSize,
                    currentPage: page,
                    totalItem: (items.value?.metadata.total ?? 0)),
              ])),
              if (MediaQuery.of(context).size.width > 840)
                if (editingItem != null) ...[
                  VerticalDivider(
                    color: Theme.of(context).colorScheme.surfaceDim,
                    width: 1,
                  ),
                  Expanded(
                      child: ItemEditForm(
                    onEdit: (item) {
                      ref.invalidate(inventoryProvider);
                    },
                    onCancel: () {
                      setState(() {
                        editingItem = null;
                        selected = [];
                      });
                    },
                    itemID: editingItem!.id,
                  ))
                ] else ...[
                  VerticalDivider(
                    color: Theme.of(context).colorScheme.surfaceDim,
                    width: 1,
                  ),
                  Expanded(
                      child: Center(
                          child: Text(
                              AppLocalizations.of(context)!.noItemSelected))),
                ]
            ]))
    ]);
  }
}
