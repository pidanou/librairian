import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/models/item.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/widgets/file_picker.dart';

class ItemsList extends ConsumerStatefulWidget {
  const ItemsList(
      {required this.items,
      required this.storage,
      this.onSelect,
      this.onDelete,
      super.key});

  final Storage storage;
  final Function(Item)? onSelect;
  final Function(List<String>)? onDelete;
  final List<Item> items;

  @override
  ItemsListState createState() => ItemsListState();
}

class ItemsListState extends ConsumerState<ItemsList> {
  List<String> selected = [];
  String? editing;
  bool selectAll = false;
  int page = 1;
  int limit = 10;
  late Storage storage;
  late List<Item> items;

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
    items.addAll(files);
  }

  void deleteSelected() {
    widget.onDelete?.call(selected);
    setState(() {
      editing = null;
      selectAll = false;
      selected.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    storage = widget.storage;
    items = widget.items;
  }

  @override
  void didUpdateWidget(ItemsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.storage.id != oldWidget.storage.id) {
      storage = widget.storage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        const SizedBox(width: 16),
        Checkbox(
          onChanged: (value) {
            setState(() {
              selectAll = !selectAll;
              if (selectAll == true) {
                for (var item in items) {
                  selected.add(item.id!);
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
        storage.type == "Physical Storage"
            ? IconButton(
                tooltip: 'Add item',
                icon: const Icon(Icons.add_circle),
                onPressed: () {
                  setState(() {
                    final newItem = Item.newPhysicalItem();
                    newItem.storageLocations = [
                      StorageLocation(storage: widget.storage)
                    ];
                    widget.onSelect?.call(newItem);
                  });
                })
            : FilePicker(onSelect: (List<XFile>? files) {
                _addItemsFromFiles(files);
              }),
      ]),
      Divider(
        color: Theme.of(context).colorScheme.surfaceDim,
        height: 0,
      ),
      Expanded(
          child: ListView(children: [
        for (Item item in items)
          Material(
              type: MaterialType.transparency,
              child: ListTile(
                onTap: () {
                  widget.onSelect?.call(item);
                  setState(() {
                    editing = item.id;
                    selected = [];
                    selectAll = false;
                  });
                },
                selected: selected.contains(item.id) || editing == item.id,
                selectedColor: Theme.of(context).colorScheme.onSurface,
                selectedTileColor: Theme.of(context).colorScheme.surfaceDim,
                leading: Checkbox(
                  value: selected.contains(item.id) || selectAll,
                  onChanged: (value) {
                    setState(() {
                      editing = null;
                      selected.contains(item.id)
                          ? selected.remove(item.id)
                          : selected.add(item.id!);
                    });
                  },
                ),
                title: Text(item.name ?? ""),
                subtitle: Text(
                    item.storageLocations?.isNotEmpty ?? false
                        ? item.storageLocations![0].location ?? ""
                        : '',
                    style: const TextStyle(fontSize: 11)),
                trailing: item.isDigital ?? true
                    ? const Tooltip(
                        message: 'Digital item', child: Icon(Icons.upload_file))
                    : const Tooltip(
                        message: 'Physical item', child: Icon(Icons.category)),
              )),
      ]))
    ]);
  }
}
