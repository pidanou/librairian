import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/models/item.dart';
import 'package:librairian/widgets/edit_storage_location.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class ItemEditForm extends ConsumerStatefulWidget {
  const ItemEditForm({super.key, required this.item, this.onEdit, this.onSave});

  final Item item;
  final void Function(Item)? onEdit;
  final void Function()? onSave;

  @override
  ConsumerState<ItemEditForm> createState() => ItemEditFormState();
}

class ItemEditFormState extends ConsumerState<ItemEditForm> {
  TextEditingController descriptionController = TextEditingController();
  FocusNode nameFocusNode = FocusNode();

  FocusNode descriptionFocusNode = FocusNode();

  bool editName = false;

  @override
  build(BuildContext context) {
    Item item = widget.item;
    descriptionController.text = widget.item.description?.data ?? '';
    return ListView(children: [
      FocusTraversalGroup(
          child: Form(
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        editName
                            ? Row(children: [
                                Expanded(
                                    child: TextFormField(
                                        maxLines: 1,
                                        focusNode: nameFocusNode,
                                        initialValue: item.name,
                                        decoration: InputDecoration(
                                            suffixIcon: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 5),
                                                child: IconButton(
                                                  icon: const Icon(Icons.cancel,
                                                      size: 20),
                                                  onPressed: () {
                                                    setState(() {
                                                      editName = false;
                                                    });
                                                  },
                                                ))),
                                        onFieldSubmitted: (value) {
                                          setState(() {
                                            item.name = value;
                                            editName = false;
                                          });
                                          widget.onEdit?.call(item);
                                        }))
                              ])
                            : Row(
                                children: [
                                  Text(item.name ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const SizedBox(width: 10),
                                  IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          editName = true;
                                          nameFocusNode.requestFocus();
                                        });
                                      })
                                ],
                              ),
                        const SizedBox(height: 10),
                        Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runAlignment: WrapAlignment.start,
                            direction: Axis.horizontal,
                            spacing: 10,
                            runSpacing: 5,
                            children: [
                              if (item.storageLocations != null &&
                                  item.storageLocations!.isNotEmpty)
                                for (var i = 0;
                                    i < item.storageLocations!.length;
                                    i++)
                                  item.storageLocations![i].storage != null
                                      ? InputChip(
                                          avatar: const Icon(Icons.location_on),
                                          label: Text(item.storageLocations?[i]
                                                  .storage?.alias ??
                                              ""),
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    EditStorageLocation(
                                                      storageLocation: item
                                                          .storageLocations![i],
                                                      title: const Text(
                                                          "Edit location"),
                                                      onSave: (sl) {
                                                        if (sl != null) {
                                                          setState(() {
                                                            item.storageLocations?[
                                                                i] = sl;
                                                          });
                                                          widget.onEdit
                                                              ?.call(item);
                                                        }
                                                        Navigator.of(context)
                                                            .pop();
                                                        return;
                                                      },
                                                    ));
                                          },
                                          onDeleted: () {
                                            setState(() {
                                              item.storageLocations!
                                                  .removeAt(i);
                                            });
                                            widget.onEdit?.call(item);
                                          })
                                      : const SizedBox(),
                              const SizedBox(width: 10),
                              IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) =>
                                            EditStorageLocation(
                                                title:
                                                    const Text("Add location"),
                                                onSave: (sl) {
                                                  if (sl != null) {
                                                    setState(() {
                                                      if (item.storageLocations ==
                                                          null) {
                                                        item.storageLocations =
                                                            [sl];
                                                      } else {
                                                        item.storageLocations!
                                                            .add(sl);
                                                      }
                                                    });
                                                    widget.onEdit?.call(item);
                                                  }
                                                  Navigator.of(context).pop();
                                                }));
                                  }),
                            ]),
                        const SizedBox(height: 10),
                        TextFormField(
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            maxLength: 1000,
                            maxLines: null,
                            onChanged: (value) {
                              if (item.description == null) {
                                item.description = Description(
                                    data: value,
                                    userId: Supabase
                                        .instance.client.auth.currentUser!.id);
                                widget.onEdit?.call(item);
                                return;
                              }
                              item.description!.data = value;
                            },
                            controller: descriptionController,
                            decoration: const InputDecoration(
                              hintText: "Describe the item and it's content",
                              labelText: 'Description',
                            )),
                        const SizedBox(height: 30),
                        Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                                label: const Text('Save'),
                                icon: const Icon(Icons.backup),
                                onPressed: () {
                                  widget.onSave?.call();
                                }))
                      ]))))
    ]);
  }
}
