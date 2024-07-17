import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/models/file.dart';
import 'package:librairian/widgets/edit_storage_location.dart';
import 'package:librairian/widgets/textfield_tags.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class FileEditForm extends ConsumerStatefulWidget {
  const FileEditForm({super.key, required this.file, this.onEdit, this.onSave});

  final File file;
  final void Function(File)? onEdit;
  final void Function()? onSave;

  @override
  ConsumerState<FileEditForm> createState() => FileEditFormState();
}

class FileEditFormState extends ConsumerState<FileEditForm> {
  TextEditingController descriptionController = TextEditingController();

  FocusNode descriptionFocusNode = FocusNode();

  @override
  build(BuildContext context) {
    File file = widget.file;
    descriptionController.text = widget.file.description?.data ?? '';
    return ListView(children: [
      FocusTraversalGroup(
          child: Form(
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                            spacing: 10,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(file.name ?? '',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              if (file.size != null && file.size! <= 1000000)
                                Text(
                                    '${(file.size! / 1000).toStringAsFixed(2)} KB'),
                              if (file.size != null && file.size! > 1000000)
                                Text(
                                    '${(file.size! / 1000000).toStringAsFixed(2)} MB'),
                              if (file.size != null && file.size! > 1000000000)
                                Text(
                                    '${(file.size! / 1000000000).toStringAsFixed(2)} GB'),
                            ]),
                        const SizedBox(height: 10),
                        Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runAlignment: WrapAlignment.start,
                            direction: Axis.horizontal,
                            spacing: 10,
                            runSpacing: 5,
                            children: [
                              if (file.storageLocations != null &&
                                  file.storageLocations!.isNotEmpty)
                                for (var i = 0;
                                    i < file.storageLocations!.length;
                                    i++)
                                  InputChip(
                                      avatar: const Icon(Icons.location_on),
                                      label: Text(file.storageLocations?[i]
                                              .storage?.alias ??
                                          ""),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              EditStorageLocation(
                                                  title: const Text(
                                                      "Edit location"),
                                                  onSave: (sl) {
                                                    if (sl != null) {
                                                      setState(() {
                                                        file.storageLocations![
                                                            i] = sl;
                                                      });
                                                      widget.onEdit?.call(file);
                                                    }
                                                    Navigator.of(context).pop();
                                                  },
                                                  storageLocation: file
                                                      .storageLocations![i]),
                                        );
                                      },
                                      onDeleted: () {
                                        setState(() {
                                          file.storageLocations!.removeAt(i);
                                        });
                                        widget.onEdit?.call(file);
                                      }),
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
                                                      file.storageLocations!
                                                          .add(sl);
                                                    });
                                                    widget.onEdit?.call(file);
                                                  }
                                                  Navigator.of(context).pop();
                                                }));
                                  }),
                            ]),
                        const SizedBox(height: 10),
                        TextFormField(
                            maxLines: null,
                            onChanged: (value) {
                              if (file.description == null) {
                                file.description = Description(
                                    data: value,
                                    userId: Supabase
                                        .instance.client.auth.currentUser!.id);
                                widget.onEdit?.call(file);
                                return;
                              }
                              file.description!.data = value;
                            },
                            controller: descriptionController,
                            decoration: const InputDecoration(
                              hintText: "Describe the file and it's content",
                              labelText: 'Description',
                            )),
                        const SizedBox(height: 10),
                        TextFieldTags(
                            tags: file.tags ?? [],
                            onTagsChanged: (List<String> input) {
                              setState(() {
                                file.tags = input;
                              });
                              widget.onEdit?.call(file);
                            }),
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
