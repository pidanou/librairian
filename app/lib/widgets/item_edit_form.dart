import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:librairian/models/item.dart';
import 'package:librairian/providers/attachment.dart';
import 'package:librairian/providers/item.dart';
import 'package:librairian/widgets/attachment_display.dart';
import 'package:librairian/widgets/attachments_picker.dart';
import 'package:librairian/widgets/edit_location.dart';

class ItemEditForm extends ConsumerStatefulWidget {
  const ItemEditForm({
    super.key,
    required this.itemID,
    this.onEdit,
    this.onCancel,
  });

  final String itemID;
  final void Function(Item)? onEdit;
  final VoidCallback? onCancel;

  @override
  ConsumerState<ItemEditForm> createState() => ItemEditFormState();
}

class ItemEditFormState extends ConsumerState<ItemEditForm> {
  FocusNode nameFocusNode = FocusNode();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  FocusNode descriptionFocusNode = FocusNode();
  late Item item;

  bool editName = false;

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(widget);
    if (widget.itemID != oldWidget.itemID) {
      descriptionController.text = item.description;
      nameController.text = item.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    var itemProv = ref.watch(itemControllerProvider(widget.itemID));
    if (itemProv is AsyncError) {
      return const Center(child: Text("Error"));
    }
    if (itemProv is AsyncLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (itemProv.value == null) {
      return const Center(child: Text("Error"));
    }
    item = itemProv.value!;
    descriptionController.text = item.description;
    return Column(children: [
      Expanded(
          child: ListView(children: [
        FocusTraversalGroup(
            child: Form(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              editName
                  ? ListTile(
                      title: TextFormField(
                          autofocus: true,
                          maxLines: 1,
                          focusNode: nameFocusNode,
                          controller: nameController,
                          onChanged: (value) {
                            setState(() {
                              item.name = value;
                            });
                          },
                          onFieldSubmitted: (value) async {
                            await ref
                                .read(itemControllerProvider(widget.itemID)
                                    .notifier)
                                .patch(Item(name: value));
                            editName = false;
                            widget.onEdit?.call(item);
                          }),
                      trailing: IconButton(
                          icon: const Icon(Icons.cancel, size: 20),
                          onPressed: () {
                            setState(() {
                              editName = false;
                            });
                            setState(() {});
                          }),
                    )
                  : ListTile(
                      title: Text(item.name,
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
                                onSave: (sl) async {
                                  if (sl != null) {
                                    item.locations = [
                                      ...item.locations ?? [],
                                      sl
                                    ];
                                    await ref
                                        .read(itemControllerProvider(
                                                widget.itemID)
                                            .notifier)
                                        .patch(Item(locations: item.locations));
                                    widget.onEdit?.call(item);
                                  }
                                  if (!context.mounted) return;
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
                                onPressed: () async {
                                  item.locations!.removeAt(i);
                                  await ref
                                      .read(
                                          itemControllerProvider(widget.itemID)
                                              .notifier)
                                      .patch(Item(locations: item.locations));
                                  widget.onEdit?.call(item);
                                }),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => EditLocation(
                                      location: item.locations![i],
                                      title: const Text("Edit location"),
                                      onSave: (sl) async {
                                        if (sl != null) {
                                          await ref
                                              .read(itemControllerProvider(
                                                      widget.itemID)
                                                  .notifier)
                                              .patch(Item(
                                                  locations: item.locations));
                                          widget.onEdit?.call(item);
                                        }
                                        if (!context.mounted) return;
                                        Navigator.of(context).pop();
                                      }));
                            },
                          ))
                      : const SizedBox(),
              Divider(
                color: Theme.of(context).colorScheme.surfaceDim,
                height: 0,
              ),
              ListTile(
                  title: TextFormField(
                      controller: descriptionController,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      maxLength: 1000,
                      onFieldSubmitted: (value) async {
                        var newItem = await ref
                            .read(
                                itemControllerProvider(widget.itemID).notifier)
                            .patch(Item(description: value));
                        if (newItem == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Error updating item")));
                        }
                        widget.onEdit?.call(item);
                      },
                      decoration: const InputDecoration(
                        hintText: "Describe the item and it's content",
                      ))),
              const SizedBox(height: 10),
              AttachmentDisplay(
                itemId: item.id,
              ),
              const SizedBox(height: 10),
              ListTile(
                  trailing: AttachmentsPicker(onAdd: (List<XFile> files) async {
                for (var file in files) {
                  var bytes = await file.readAsBytes();
                  ref
                      .read(itemAttachmentsControllerProvider(item.id).notifier)
                      .postAttachment(item.id, file.path, bytes);
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
      ])),
      const SizedBox(height: 10),
    ]);
  }
}
