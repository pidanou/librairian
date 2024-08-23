import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/models/item.dart';
import 'package:librairian/providers/user_items.dart';
import 'package:librairian/widgets/custom_appbar.dart';
import 'package:librairian/widgets/item_edit_form.dart';
import 'package:librairian/widgets/items_list.dart';
import 'package:librairian/widgets/order_by_selector.dart';
import 'package:librairian/widgets/page_switcher.dart';

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

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 600) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: Text("All Items"),
        ),
        body: content(context),
      );
    }
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceBright,
            borderRadius: MediaQuery.of(context).size.width < 600
                ? const BorderRadius.all(Radius.circular(0))
                : const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0))),
        child: content(context));
  }

  Widget content(BuildContext context) {
    var items =
        ref.watch(userItemsProvider(page, pageSize, null, orderBy, asc));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 8, top: 5, bottom: 5, right: 16),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              OrderBySelector(
                controller: menuController,
                options: [
                  ListTile(
                      onTap: () {
                        setState(() {
                          asc = false;
                          orderBy = "name";
                          orderByLabel = "Name A-Z";
                        });
                        menuController.close();
                      },
                      dense: true,
                      title: const Text("Name A-Z")),
                  ListTile(
                      onTap: () {
                        setState(() {
                          asc = true;
                          orderBy = "name";
                          orderByLabel = "Name Z-A";
                        });
                        menuController.close();
                      },
                      dense: true,
                      title: const Text("Name Z-A")),
                  ListTile(
                      onTap: () {
                        setState(() {
                          asc = false;
                          orderBy = "created_at";
                          orderByLabel = "Old items to new";
                        });
                        menuController.close();
                      },
                      dense: true,
                      title: const Text("Old items to new")),
                  ListTile(
                      onTap: () {
                        setState(() {
                          asc = true;
                          orderBy = "created_at";
                          orderByLabel = "New items to old";
                        });
                        menuController.close();
                      },
                      dense: true,
                      title: const Text("New items to old")),
                  ListTile(
                      onTap: () {
                        setState(() {
                          asc = true;
                          orderBy = "updated_at";
                          orderByLabel = "Last updated";
                        });
                        menuController.close();
                      },
                      dense: true,
                      title: const Text("Last updated")),
                ],
                child: Text(orderByLabel),
              ),
              IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.invalidate(
                        userItemsProvider(page, pageSize, null, orderBy, asc));
                  })
            ])
          ])),
      Divider(
        color: Theme.of(context).colorScheme.surfaceDim,
        height: 0,
      ),
      items is AsyncError
          ? const Text("Error")
          : Expanded(
              child: Row(children: [
              Expanded(
                  child: Column(children: [
                Expanded(
                    child: items is AsyncData
                        ? ItemsList(
                            onRefresh: () => ref.refresh(userItemsProvider(
                                    page, pageSize, null, orderBy, asc)
                                .future),
                            onTap: (item) {
                              setState(() {
                                editingItem = item;
                              });
                              if (MediaQuery.of(context).size.width < 600) {
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
                                                onSave: (item) {
                                                  ref
                                                      .read(userItemsProvider(
                                                              page, pageSize)
                                                          .notifier)
                                                      .save(item)
                                                      .then((value) {
                                                    ref.invalidate(
                                                        userItemsProvider(
                                                            page,
                                                            pageSize,
                                                            null,
                                                            orderBy,
                                                            asc));
                                                    setState(() {
                                                      editingItem = null;
                                                    });
                                                    Navigator.pop(context);
                                                  });
                                                },
                                                onCancel: () {
                                                  setState(() {
                                                    editingItem = null;
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                item: editingItem!,
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    });
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
                    totalItem: (items.value?.metadata.total ?? 0))
              ])),
              if (MediaQuery.of(context).size.width > 600)
                if (editingItem != null) ...[
                  VerticalDivider(
                    color: Theme.of(context).colorScheme.surfaceDim,
                    width: 1,
                  ),
                  Expanded(
                      child: ItemEditForm(
                    onSave: (item) {
                      ref
                          .read(userItemsProvider(page, pageSize).notifier)
                          .save(item)
                          .then((value) {
                        ref.invalidate(userItemsProvider(
                            page, pageSize, null, orderBy, asc));
                        setState(() {
                          editingItem = null;
                        });
                      });
                    },
                    onCancel: () {
                      setState(() {
                        editingItem = null;
                      });
                    },
                    item: editingItem!,
                  ))
                ] else ...[
                  VerticalDivider(
                    color: Theme.of(context).colorScheme.surfaceDim,
                    width: 1,
                  ),
                  const Expanded(
                      child: Center(child: Text("No item selected"))),
                ]
            ]))
    ]);
  }
}
