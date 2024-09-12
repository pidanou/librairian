import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/providers/storage.dart';
import 'package:librairian/widgets/alert_dialog_delete_storage.dart';
import 'package:librairian/widgets/edit_storage.dart';

class StorageDetailPage extends ConsumerStatefulWidget {
  const StorageDetailPage(
      {required this.storageID, required this.storage, super.key});

  final String storageID;
  final Storage storage;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      StorageDetailPageState();
}

class StorageDetailPageState extends ConsumerState<StorageDetailPage> {
  bool editingName = false;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    controller.text = widget.storage.alias ?? 'No name';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surfaceDim,
            actions: editingName
                ? [
                    IconButton(
                        icon: const Icon(Icons.cancel, size: 20),
                        onPressed: () {
                          setState(() {
                            editingName = false;
                          });
                        }),
                  ]
                : [
                    IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () {
                          setState(() {
                            editingName = true;
                          });
                        }),
                    IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialogDeleteStorage(
                                    storageID: widget.storage.id ?? "");
                              });
                        })
                  ],
            title: editingName
                ? TextFormField(
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                            icon: const Icon(Icons.save),
                            onPressed: () {
                              ref
                                  .read(storagesProvider.notifier)
                                  .edit(widget.storage);
                              setState(() {
                                widget.storage.alias = controller.text;
                                editingName = false;
                              });
                            })),
                    controller: controller,
                    onFieldSubmitted: (value) {
                      ref.read(storagesProvider.notifier).edit(widget.storage);
                      setState(() {
                        widget.storage.alias = value;
                        editingName = false;
                      });
                    })
                : Text(widget.storage.alias ?? 'No name'),
            centerTitle: true),
        body: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceBright,
                borderRadius: MediaQuery.of(context).size.width < 840
                    ? const BorderRadius.all(Radius.circular(0))
                    : const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0))),
            child: EditStorage(
              storage: widget.storage,
            )));
  }
}
