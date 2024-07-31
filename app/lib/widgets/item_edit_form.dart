import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/models/item.dart';
import 'package:librairian/widgets/edit_storage_location.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class ItemEditForm extends ConsumerStatefulWidget {
  const ItemEditForm(
      {super.key, required this.item, this.onEdit, this.onSave, this.onCancel});

  final Item item;
  final void Function(Item)? onEdit;
  final void Function(Item)? onSave;
  final VoidCallback? onCancel;

  @override
  ConsumerState<ItemEditForm> createState() => ItemEditFormState();
}

class ItemEditFormState extends ConsumerState<ItemEditForm> {
  TextEditingController descriptionController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  FocusNode nameFocusNode = FocusNode();

  FocusNode descriptionFocusNode = FocusNode();

  bool editName = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.item.name ?? "";
  }

  @override
  void didUpdateWidget(ItemEditForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.id != oldWidget.item.id) {
      nameController.text = widget.item.name ?? "";
    }
  }

  @override
  build(BuildContext context) {
    Item item = widget.item;
    descriptionController.text = widget.item.description?.data ?? '';
    return ListView(children: [
      FocusTraversalGroup(
          child: Form(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            editName
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(children: [
                      Expanded(
                          child: TextFormField(
                              maxLines: 1,
                              focusNode: nameFocusNode,
                              controller: nameController,
                              decoration: InputDecoration(
                                  suffixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: IconButton(
                                        icon:
                                            const Icon(Icons.cancel, size: 20),
                                        onPressed: () {
                                          setState(() {
                                            editName = false;
                                          });
                                        },
                                      ))),
                              onChanged: (value) {
                                setState(() {
                                  item.name = value;
                                });
                              },
                              onFieldSubmitted: (value) {
                                setState(() {
                                  item.name = value;
                                  editName = false;
                                });
                                widget.onEdit?.call(item);
                              })),
                      IconButton(
                          icon: const Icon(Icons.check_circle, size: 20),
                          onPressed: () {
                            setState(() {
                              item.name = nameController.text;
                              editName = false;
                            });
                          })
                    ]))
                : ListTile(
                    title: Text(item.name ?? '',
                        style: Theme.of(context).textTheme.titleMedium),
                    trailing: IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () {
                          setState(() {
                            editName = true;
                            nameFocusNode.requestFocus();
                          });
                        })),
            const SizedBox(height: 10),
            ListTile(
              title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runAlignment: WrapAlignment.start,
                  direction: Axis.horizontal,
                  spacing: 10,
                  runSpacing: 5,
                  children: [
                    if (item.storageLocations != null &&
                        item.storageLocations!.isNotEmpty)
                      for (var i = 0; i < item.storageLocations!.length; i++)
                        item.storageLocations![i].storage != null
                            ? InputChip(
                                avatar: const Icon(Icons.location_on),
                                label: Text(
                                    item.storageLocations?[i].storage?.alias ??
                                        ""),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => EditStorageLocation(
                                            storageLocation:
                                                item.storageLocations![i],
                                            title: const Text("Edit location"),
                                            onSave: (sl) {
                                              if (sl != null) {
                                                setState(() {
                                                  item.storageLocations?[i] =
                                                      sl;
                                                });
                                                widget.onEdit?.call(item);
                                              }
                                              Navigator.of(context).pop();
                                              return;
                                            },
                                          ));
                                },
                                onDeleted: () {
                                  setState(() {
                                    item.storageLocations!.removeAt(i);
                                  });
                                  widget.onEdit?.call(item);
                                })
                            : const SizedBox()
                  ]),
              trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => EditStorageLocation(
                            title: const Text("Add location"),
                            onSave: (sl) {
                              if (sl != null) {
                                setState(() {
                                  if (item.storageLocations == null) {
                                    item.storageLocations = [sl];
                                  } else {
                                    item.storageLocations!.add(sl);
                                  }
                                });
                                widget.onEdit?.call(item);
                              }
                              Navigator.of(context).pop();
                            }));
                  }),
            ),
            const SizedBox(height: 10),
            ListTile(
                title: TextFormField(
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    maxLength: 1000,
                    maxLines: null,
                    onChanged: (value) {
                      if (item.description == null) {
                        item.description = Description(
                            data: value,
                            userId:
                                Supabase.instance.client.auth.currentUser!.id);
                        widget.onEdit?.call(item);
                        return;
                      }
                      item.description!.data = value;
                    },
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      hintText: "Describe the item and it's content",
                      labelText: 'Description',
                    ))),
            const SizedBox(height: 30),
            ListTile(
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    widget.onCancel?.call();
                  }),
              const SizedBox(width: 5),
              FilledButton.icon(
                  label: const Text('Save'),
                  icon: const Icon(Icons.backup),
                  onPressed: () {
                    widget.onSave?.call(item);
                  })
            ]))
          ])))
    ]);
  }
}
