import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/helpers/date.dart';
import 'package:librairian/models/item.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/widgets/item_listtile.dart';

class ItemsList extends ConsumerStatefulWidget {
  const ItemsList(
      {this.items,
      this.storage,
      this.selectAll = false,
      this.onSelected,
      this.onTap,
      this.onDelete,
      this.onRefresh,
      this.selected,
      this.editing,
      super.key});

  final Storage? storage;
  final bool selectAll;
  final Future<void> Function()? onRefresh;
  final Function(Item)? onTap;
  final Function(List<String>)? onDelete;
  final Function(List<String>)? onSelected;
  final List<String>? selected;
  final String? editing;
  final List<Item>? items;

  @override
  ItemsListState createState() => ItemsListState();
}

class ItemsListState extends ConsumerState<ItemsList> {
  List<String> selected = [];
  String editing = "";
  bool selectAll = false;
  Storage? storage;
  late List<Item> items;

  @override
  void initState() {
    super.initState();
    selected = widget.selected ?? [];
    editing = widget.editing ?? "";
    storage = widget.storage;
    items = widget.items ?? [];
    selectAll = widget.selectAll;
  }

  @override
  void didUpdateWidget(ItemsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editing != oldWidget.editing) {
      editing = widget.editing ?? "";
    }
    if (widget.selected != oldWidget.selected) {
      selected = widget.selected ?? [];
    }
    if (widget.storage?.id != oldWidget.storage?.id) {
      storage = widget.storage;
    }
    if (widget.items != oldWidget.items) {
      items = widget.items ?? [];
    }
    if (widget.selectAll != oldWidget.selectAll) {
      selectAll = widget.selectAll;
      if (selectAll == false) {
        selected = [];
      }
      if (selectAll == true) {
        for (var item in items) {
          selected.add(item.id ?? "");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: widget.onRefresh ??
            () {
              return Future.value();
            },
        child: ListView(children: [
          for (Item item in items)
            Material(
                type: MaterialType.transparency,
                child: ItemListTile(
                    item: item,
                    onTap: () async {
                      widget.onTap?.call(item).whenComplete(() {
                        if (MediaQuery.sizeOf(context).width < 840) {
                          setState(() {
                            editing = "";
                          });
                        }
                      });
                      setState(() {
                        editing = item.id ?? "";
                        selected = [];
                        selectAll = false;
                      });
                    },
                    selected: selected.contains(item.id) || editing == item.id,
                    leading: widget.onSelected != null
                        ? Checkbox(
                            value: selected.contains(item.id),
                            onChanged: (value) {
                              setState(() {
                                editing = "";
                                selected.contains(item.id)
                                    ? selected.remove(item.id)
                                    : selected.add(item.id ?? "");
                              });
                              widget.onSelected?.call(selected);
                            },
                          )
                        : null,
                    title: Text(item.name ?? ""),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Last updated:"),
                        Text(formatTimestamp(item.updatedAt?.toString() ?? ""))
                      ],
                    ))),
        ]));
  }
}
