import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/helpers/date.dart';
import 'package:librairian/models/item.dart';
import 'package:librairian/models/storage.dart';

class ItemsList extends ConsumerStatefulWidget {
  const ItemsList(
      {this.items,
      this.storage,
      this.selectAll = false,
      this.onSelected,
      this.onTap,
      this.onDelete,
      this.onRefresh,
      super.key});

  final Storage? storage;
  final bool selectAll;
  final Future<void> Function()? onRefresh;
  final Function(Item)? onTap;
  final Function(List<String>)? onDelete;
  final Function(List<String>)? onSelected;
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
    storage = widget.storage;
    items = widget.items ?? [];
    selectAll = widget.selectAll;
  }

  @override
  void didUpdateWidget(ItemsList oldWidget) {
    super.didUpdateWidget(oldWidget);
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
          selected.add(item.id ?? item.tmpId ?? "");
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
                child: ListTile(
                    onTap: () {
                      widget.onTap?.call(item);
                      setState(() {
                        editing = item.id ?? item.tmpId ?? "";
                        selected = [];
                        selectAll = false;
                      });
                    },
                    selected: selected.contains(item.id) ||
                        selected.contains(item.tmpId) ||
                        editing == item.id ||
                        editing == item.tmpId,
                    selectedColor: Theme.of(context).colorScheme.onSurface,
                    selectedTileColor: Theme.of(context).colorScheme.surfaceDim,
                    leading: widget.onSelected != null
                        ? Checkbox(
                            value: selected.contains(item.id) ||
                                selected.contains(item.tmpId),
                            onChanged: (value) {
                              setState(() {
                                editing = "";
                                selected.contains(item.id)
                                    ? selected.remove(item.id)
                                    : selected.add(item.id ?? item.tmpId ?? "");
                              });
                              widget.onSelected?.call(selected);
                            },
                          )
                        : null,
                    title: item.tmpId == null
                        ? Text(item.name ?? "")
                        : Text("(Not saved) ${item.name}"),
                    trailing: item.tmpId == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Last modified:"),
                              Text(formatTimestamp(
                                  item.updatedAt?.toString() ?? ""))
                            ],
                          )
                        : const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator()))),
        ]));
  }
}
