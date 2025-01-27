import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:librairian/models/item.dart';
import 'package:librairian/providers/attachment.dart';
import 'package:librairian/providers/item.dart';
import 'package:librairian/widgets/attachment_display.dart';
import 'package:librairian/widgets/attachments_picker.dart';
import 'package:librairian/widgets/default_error.dart';
import 'package:librairian/widgets/edit_location.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  bool loading = false;

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(widget);
    if (widget.itemID != oldWidget.itemID) {
      descriptionController.text = "";
      nameController.text = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    var itemProv = ref.watch(itemControllerProvider(widget.itemID));
    if (itemProv is AsyncError) {
      return Center(
          child: TextButton(
              child: const DefaultError(),
              onPressed: () {
                if (MediaQuery.of(context).size.width < 840) {
                  Navigator.of(context).pop();
                } else {
                  widget.onCancel?.call();
                }
              }));
    }
    if (itemProv is AsyncLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (itemProv.value == null) {
      return const Center(child: DefaultError());
    }
    item = itemProv.value!;
    descriptionController.text = item.description;
    nameController.text = item.name;
    var oldDesc = item.description;
    var oldName = item.name;
    return RefreshIndicator(
        onRefresh: () => ref.read(itemControllerProvider(widget.itemID).future),
        child: Column(children: [
          Expanded(
              child: ListView(children: [
            FocusTraversalGroup(
                child: Form(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      ListTile(
                          title: TextFormField(
                              maxLines: 1,
                              focusNode: nameFocusNode,
                              controller: nameController,
                              onTapOutside: (_) async {
                                      if (nameController.text == oldName) return;
                                      setState(() {
                                        loading = true;
                                      });
                                      await ref
                                          .read(itemControllerProvider(widget.itemID)
                                              .notifier)
                                          .patch(Item(name: nameController.text));
                                      editName = false;
                                      widget.onEdit?.call(item);
                                      setState(() {
                                        loading = false;
                                      });
                              },
                              onFieldSubmitted: (value) async {
                                if (nameController.text == oldName) return;
                                setState(() {
                                  loading = true;
                                });
                                await ref
                                    .read(itemControllerProvider(widget.itemID)
                                        .notifier)
                                    .patch(Item(name: value));
                                editName = false;
                                widget.onEdit?.call(item);
                                setState(() {
                                  loading = false;
                                });
                              }),
                        ),
                  Divider(
                    color: Theme.of(context).colorScheme.surfaceDim,
                    height: 0,
                  ),
                  ListTile(
                      title: Text(AppLocalizations.of(context)!.locations,
                          style: Theme.of(context).textTheme.titleMedium),
                      trailing: IconButton(
                          icon: const Icon(
                            Icons.add,
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => EditLocation(
                                    title:
                                        Text(AppLocalizations.of(context)!.add),
                                    onSave: (sl) async {
                                      setState(() {
                                        loading = true;
                                      });
                                      if (sl != null) {
                                        sl.itemId = item.id;
                                        var newItem = await ref
                                            .read(itemControllerProvider(
                                                    widget.itemID)
                                                .notifier)
                                            .addLocation(sl);
                                        widget.onEdit?.call(newItem ?? item);
                                        setState(() {
                                          loading = false;
                                        });
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
                                title: Text(
                                    item.locations?[i].storage?.alias ?? ""),
                                trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        loading = true;
                                      });
                                      await ref
                                          .read(itemControllerProvider(
                                                  widget.itemID)
                                              .notifier)
                                          .deleteLocation(
                                              item.locations![i].id);
                                      widget.onEdit?.call(item);
                                      setState(() {
                                        loading = false;
                                      });
                                    }),
                              ))
                          : const SizedBox(),
                  Divider(
                    color: Theme.of(context).colorScheme.surfaceDim,
                    height: 0,
                  ),
                  ListTile(
                      title: TextFormField(
                          focusNode: descriptionFocusNode,
                          controller: descriptionController,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          maxLength: 1000,
                          onTapOutside: (_) async {
                            if (descriptionController.text == oldDesc) return;
                            setState(() {
                              loading = true;
                            });
                            var newItem = await ref
                                .read(itemControllerProvider(widget.itemID)
                                    .notifier)
                                .patch(Item(description: descriptionController.text));
                            if (!context.mounted) return;
                            if (newItem == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .error)));
                            }
                            widget.onEdit?.call(item);
                            setState(() {
                              loading = false;
                            });
                          },
                          onFieldSubmitted: (value) async {
                            if (descriptionController.text == oldDesc) return;
                            setState(() {
                              loading = true;
                            });
                            var newItem = await ref
                                .read(itemControllerProvider(widget.itemID)
                                    .notifier)
                                .patch(Item(description: value));
                            if (!context.mounted) return;
                            if (newItem == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .error)));
                            }
                            widget.onEdit?.call(item);
                            setState(() {
                              loading = false;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: "Describe the item and it's content",
                          ))),
                  const SizedBox(height: 10),
                  AttachmentDisplay(
                    itemId: item.id,
                  ),
                  const SizedBox(height: 10),
                  ListTile(trailing:
                      AttachmentsPicker(onAdd: (List<XFile> files) async {
                    setState(() {
                      loading = true;
                    });
                    for (var file in files) {
                      var bytes = await file.readAsBytes();
                      ref
                          .read(itemAttachmentsControllerProvider(item.id)
                              .notifier)
                          .postAttachment(item.id, file.path, bytes);
                    }
                    setState(() {
                      loading = false;
                    });
                  }))
                ])))
          ])),
          const SizedBox(height: 10),
          ListTile(
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            widget.onCancel != null
                ? TextButton(
                    child: Text(AppLocalizations.of(context)!.cancel),
                    onPressed: () {
                      widget.onCancel?.call();
                    })
                : Container(),
            const SizedBox(width: 5),
            if (loading)
              const SizedBox(
                  width: 24, height: 24, child: CircularProgressIndicator()),
          ])),
          const SizedBox(height: 10),
        ]));
  }
}
