import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/models/file.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/providers/device.dart';
import 'package:librairian/providers/new_files.dart';
import 'package:librairian/widgets/file_edit_form.dart';
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

  void _addFiles(List<XFile>? listFiles) async {
    List<File> files = [];
    for (var pfile in listFiles ?? []) {
      var file = await File.fromXFile(pfile);
      final currentDevice = ref.read(currentDeviceProvider);
      file.storageLocations = [
        StorageLocation(
            storage: currentDevice,
            location: pfile.path,
            storageId: currentDevice?.id)
      ];
      files.add(file);
    }
    ref.read(newFilesProvider.notifier).add(files);
  }

  void deleteSelected() {
    if (selectAll) {
      ref.read(newFilesProvider.notifier).set([]);
      setState(() {
        selectAll = false;
      });
      return;
    }
    selected.sort((a, b) => b.compareTo(a));
    List<File> files = ref.watch(newFilesProvider);
    for (var index in selected) {
      files.removeAt(index);
    }
    ref.read(newFilesProvider.notifier).set(files);
    setState(() {
      selected.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<File> uploadedFiles = ref.watch(newFilesProvider);
    if (uploadedFiles.isEmpty) {
      return Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceBright,
              borderRadius: MediaQuery.of(context).size.width < 600
                  ? const BorderRadius.all(Radius.circular(0))
                  : const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0))),
          child: Center(
              child: FilePicker(
                  extendedFab: true,
                  onSelect: (files) {
                    _addFiles(files);
                  })));
    }
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
                        _addFiles(files);
                      }),
                    ]),
                    FilledButton.icon(
                        icon: const Icon(Icons.book),
                        label: const Text('Save all'),
                        onPressed: () {
                          setState(() {
                            savingAll = true;
                          });
                          ref
                              .read(newFilesProvider.notifier)
                              .saveAll()
                              .then((value) {
                            if (value.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Some files could not be saved")));
                            }
                            setState(() {
                              savingAll = false;
                            });
                          });
                        })
                  ])),
          Divider(
            color: Theme.of(context).colorScheme.surfaceDim,
            height: 0,
          ),
          Expanded(
              child: Row(children: [
            Expanded(
                child: ListView(children: [
              for (var i = 0; i < uploadedFiles.length; i++)
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
                      title: Text(uploadedFiles[i].name ?? ""),
                      subtitle: Text(
                          uploadedFiles[i].storageLocations!.isNotEmpty
                              ? uploadedFiles[i].storageLocations![0].location!
                              : '',
                          style: const TextStyle(fontSize: 11)),
                      trailing: savingAll || saving == i
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.onPrimary))
                          : const SizedBox(),
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
                          ? FileEditForm(
                              file: uploadedFiles[editing!],
                              onSave: () {
                                setState(() {
                                  saving = editing;
                                });
                                ref
                                    .read(newFilesProvider.notifier)
                                    .saveFile(editing!)
                                    .then((success) {
                                  if (!success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "File could not be saved")));
                                  }
                                  setState(() {
                                    saving = null;
                                  });
                                });
                              },
                              onEdit: (file) {
                                ref
                                    .read(newFilesProvider.notifier)
                                    .editAt(editing!, file);
                              })
                          : const Center(child: Text("No file selected")))),
          ])),
        ]));
  }
}
