import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/models/item.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/providers/new_items.dart';
import 'package:librairian/providers/storage.dart';
import 'package:librairian/widgets/item_edit_form.dart';
import 'package:librairian/widgets/file_picker.dart';

class AddPage extends ConsumerStatefulWidget {
  const AddPage({super.key});

  @override
  ConsumerState<AddPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<AddPage> {
  List<int> selected = [];
  bool selectAll = false;
  int? editing;

  int? saving;
  bool savingAll = false;

  void _addItemsFromFiles(List<XFile>? listItems) async {
    List<Item> files = [];
    for (var pfile in listItems ?? []) {
      var file = await Item.fromXFile(pfile);
      final defaultStorage = ref.read(defaultStorageProvider);
      if (defaultStorage != null) {
        file.storageLocations = [
          StorageLocation(
              storage: defaultStorage,
              location: pfile.path,
              storageId: defaultStorage.id)
        ];
      }
      files.add(file);
    }
    ref.read(newItemsProvider.notifier).add(files);
  }

  void deleteSelected() {
    if (selectAll) {
      ref.read(newItemsProvider.notifier).set([]);
      setState(() {
        editing = null;
        selectAll = false;
        selected.clear();
      });
      return;
    }
    selected.sort((a, b) => b.compareTo(a));
    List<Item> files = ref.watch(newItemsProvider);
    for (var index in selected) {
      files.removeAt(index);
    }
    ref.read(newItemsProvider.notifier).set(files);
    setState(() {
      selected.clear();
    });
  }

  void save() {
    setState(() {
      saving = editing;
    });
    ref.read(newItemsProvider.notifier).saveItem(editing!).then((success) {
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Item could not be saved")));
        setState(() {
          saving = null;
        });
        return;
      }
      setState(() {
        editing = null;
        saving = null;
      });
    }).catchError((e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item could not be saved")));
      setState(() {
        saving = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Item> uploadedItems = ref.watch(newItemsProvider);
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceBright,
            borderRadius: MediaQuery.of(context).size.width < 600
                ? const BorderRadius.all(Radius.circular(0))
                : const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding:
                  const EdgeInsets.only(left: 16, top: 5, bottom: 5, right: 16),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Checkbox(
                        onChanged: (value) {
                          setState(() {
                            selectAll = value!;
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
                      FilePicker(onSelect: (List<XFile>? files) {
                        _addItemsFromFiles(files);
                      }),
                      IconButton(
                          tooltip: 'Add item',
                          icon: const Icon(Icons.category),
                          onPressed: () {
                            setState(() {
                              final newItem = Item.newPhysicalItem();
                              newItem.storageLocations = [
                                StorageLocation(
                                    storage: ref.read(defaultStorageProvider))
                              ];
                              ref
                                  .read(newItemsProvider.notifier)
                                  .add([newItem]);
                              editing = uploadedItems.length;
                            });
                          })
                    ]),
                    FilledButton.icon(
                        icon: const Icon(Icons.book),
                        label: const Text('Save all'),
                        onPressed: () {
                          setState(() {
                            savingAll = true;
                          });
                          ref
                              .read(newItemsProvider.notifier)
                              .saveAll()
                              .then((value) {
                            if (value.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Some items could not be saved")));
                            }
                            setState(() {
                              editing = null;
                              savingAll = false;
                            });
                          });
                        }),
                  ])),
          Divider(
            color: Theme.of(context).colorScheme.surfaceDim,
            height: 0,
          ),
          Expanded(
              child: Row(children: [
            Expanded(
                child: ListView(shrinkWrap: uploadedItems.isEmpty, children: [
              if (uploadedItems.isEmpty)
                const Center(child: Text("No items added")),
              if (uploadedItems.isNotEmpty)
                for (var i = 0; i < uploadedItems.length; i++)
                  Material(
                      type: MaterialType.transparency,
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            editing = i;
                            selected = [];
                            selectAll = false;
                          });
                        },
                        selected:
                            selected.contains(i) || selectAll || editing == i,
                        selectedColor: Theme.of(context).colorScheme.onSurface,
                        selectedTileColor:
                            Theme.of(context).colorScheme.surfaceDim,
                        leading: Checkbox(
                          value: selected.contains(i) || selectAll,
                          onChanged: (value) {
                            setState(() {
                              editing = null;
                              selected.contains(i)
                                  ? selected.remove(i)
                                  : selected.add(i);
                            });
                          },
                        ),
                        title: Text(uploadedItems[i].name ?? ""),
                        subtitle: Text(
                            uploadedItems[i].storageLocations?.isNotEmpty ??
                                    false
                                ? uploadedItems[i]
                                        .storageLocations![0]
                                        .location ??
                                    ""
                                : '',
                            style: const TextStyle(fontSize: 11)),
                        trailing: savingAll || saving == i
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .onPrimary))
                            : uploadedItems[i].isDigital ?? true
                                ? const Tooltip(
                                    message: 'Digital item',
                                    child: Icon(Icons.upload_file))
                                : const Tooltip(
                                    message: 'Physical item',
                                    child: Icon(Icons.category)),
                      ))
            ])),
            if (MediaQuery.of(context).size.width > 840)
              VerticalDivider(
                color: Theme.of(context).colorScheme.surfaceDim,
                width: 1,
              ),
            if (MediaQuery.of(context).size.width > 840)
              Expanded(
                  child: Container(
                      color: Theme.of(context).colorScheme.surfaceBright,
                      child: editing != null
                          ? ItemEditForm(
                              item: uploadedItems[editing!],
                              onSave: (_) {
                                save();
                              },
                              onEdit: (file) {
                                ref
                                    .read(newItemsProvider.notifier)
                                    .editAt(editing!, file);
                              })
                          : const Center(child: Text("No item selected")))),
          ])),
        ]));
  }
}
