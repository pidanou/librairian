import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:librairian/models/item.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/providers/attachment.dart';
import 'package:librairian/providers/item.dart';
import 'package:librairian/providers/storage.dart';
import 'package:librairian/widgets/attachment_display.dart';
import 'package:librairian/widgets/attachments_picker.dart';
import 'package:librairian/widgets/edit_location.dart';

class ItemEditForm extends ConsumerStatefulWidget {
  const ItemEditForm(
      {super.key,
      required this.item,
      this.onEdit,
      this.onSave,
      this.onCancel,
      this.isNewItem});

  final bool? isNewItem;
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
    editName = widget.isNewItem ?? false;
  }

  @override
  build(BuildContext context) {
    var itemProv = ref.watch(itemControllerProvider(widget.item.id));
    descriptionController.text = widget.item.description ?? '';
    if (itemProv is AsyncError) {
      return const Center(child: Text("Error"));
    }
    if (itemProv is AsyncLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    var item = itemProv.value ??
        Item(
            name: "New item",
            locations: [Location(storage: ref.read(defaultStorageProvider))]);
    return Column(children: [
      Expanded(
          child: ListView(children: [
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
                                autofocus: true,
                                maxLines: 1,
                                focusNode: nameFocusNode,
                                controller: nameController,
                                decoration: InputDecoration(
                                    suffixIcon: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: IconButton(
                                          icon: const Icon(Icons.backspace,
                                              size: 20),
                                          onPressed: () {
                                            setState(() {
                                              nameController.clear();
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
                            icon: const Icon(Icons.cancel, size: 20),
                            onPressed: () {
                              setState(() {
                                editName = false;
                              });
                              setState(() {});
                            }),
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
              Divider(
                color: Theme.of(context).colorScheme.surfaceDim,
                height: 0,
              ),
              const SizedBox(height: 10),
              ListTile(
                  title: const Text(
                    "Locations",
                  ),
                  trailing: IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => EditLocation(
                                title: const Text("Add location"),
                                onSave: (sl) {
                                  if (sl != null) {
                                    setState(() {
                                      if (item.locations == null) {
                                        item.locations = [sl];
                                      } else {
                                        item.locations!.add(sl);
                                      }
                                    });
                                    widget.onEdit?.call(item);
                                  }
                                  Navigator.of(context).pop();
                                }));
                      })),
              if (item.locations != null && item.locations!.isNotEmpty)
                for (var i = 0; i < item.locations!.length; i++)
                  item.locations![i].storage != null
                      ? Material(
                          type: MaterialType.transparency,
                          child: ListTile(
                            leading: const Icon(Icons.location_on),
                            title:
                                Text(item.locations?[i].storage?.alias ?? ""),
                            subtitle: Text(item.locations?[i].location ?? "",
                                style: const TextStyle(fontSize: 10)),
                            trailing: IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () {
                                  setState(() {
                                    item.locations!.removeAt(i);
                                  });
                                  widget.onEdit?.call(item);
                                }),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => EditLocation(
                                      location: item.locations![i],
                                      title: const Text("Edit location"),
                                      onSave: (sl) {
                                        if (sl != null) {
                                          setState(() {
                                            item.locations?[i] = sl;
                                          });
                                          widget.onEdit?.call(item);
                                        }
                                        Navigator.of(context).pop();
                                        return;
                                      }));
                            },
                          ))
                      : const SizedBox(),
              const SizedBox(height: 10),
              ListTile(
                  title: TextFormField(
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      maxLength: 1000,
                      maxLines: null,
                      onChanged: (value) {
                        item.description = value;
                      },
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        hintText: "Describe the item and it's content",
                        labelText: 'Description',
                      ))),
              const SizedBox(height: 10),
              AttachmentDisplay(
                itemId: item.id ?? "",
              ),
              const SizedBox(height: 10),
              ListTile(
                  trailing: AttachmentsPicker(onAdd: (List<XFile> files) async {
                for (var file in files) {
                  var bytes = await file.readAsBytes();

                  ref
                      .read(itemAttachmentsControllerProvider(item.id).notifier)
                      .postAttachment(item.id!, file.path, bytes);
                }
              }))
            ])))
      ])),
      const SizedBox(height: 10),
      ListTile(
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        widget.onCancel != null
            ? TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  widget.onCancel?.call();
                })
            : Container(),
        const SizedBox(width: 5),
        FilledButton.icon(
            label: const Text('Save'),
            icon: const Icon(Icons.backup),
            onPressed: () {
              widget.onSave?.call(item);
            })
      ])),
      const SizedBox(height: 10),
    ]);
  }
}
