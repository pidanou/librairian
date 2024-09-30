import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/providers/storage.dart';
import 'package:librairian/widgets/alert_dialog_delete_storage.dart';
import 'package:librairian/widgets/default_error.dart';
import 'package:librairian/widgets/edit_storage.dart';

class StorageDetailPage extends ConsumerStatefulWidget {
  const StorageDetailPage({required this.storageID, super.key});

  final String storageID;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      StorageDetailPageState();
}

class StorageDetailPageState extends ConsumerState<StorageDetailPage> {
  bool editingName = false;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var storage = ref.watch(storageByIDProvider(widget.storageID));
    if (storage is AsyncLoading) {
      return Scaffold(
          appBar: AppBar(
              scrolledUnderElevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surfaceDim,
              centerTitle: true),
          body: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceBright,
                borderRadius: MediaQuery.of(context).size.width < 840
                    ? const BorderRadius.all(Radius.circular(0))
                    : const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0))),
            child: const Center(child: CircularProgressIndicator()),
          ));
    }
    if (storage is AsyncError) {
      return Scaffold(
          appBar: AppBar(
              scrolledUnderElevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surfaceDim,
              centerTitle: true),
          body: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceBright,
                borderRadius: MediaQuery.of(context).size.width < 840
                    ? const BorderRadius.all(Radius.circular(0))
                    : const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0))),
            child: const Center(child: DefaultError()),
          ));
    }
    if (storage.value == null) {
      return Scaffold(
          appBar: AppBar(
              scrolledUnderElevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surfaceDim,
              centerTitle: true),
          body: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceBright,
                borderRadius: MediaQuery.of(context).size.width < 840
                    ? const BorderRadius.all(Radius.circular(0))
                    : const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0))),
            child: const Center(child: Text("Item not found")),
          ));
    }
    return Scaffold(
        appBar: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surfaceDim,
            actions: editingName
                ? [
                    IconButton(
                        icon: const Icon(Icons.cancel,  ),
                        onPressed: () {
                          setState(() {
                            editingName = false;
                          });
                        }),
                  ]
                : [
                    IconButton(
                        icon: const Icon(Icons.edit,  ),
                        onPressed: () {
                          setState(() {
                            editingName = true;
                          });
                        }),
                    IconButton(
                        icon: const Icon(Icons.delete,  ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialogDeleteStorage(
                                    storageID: storage.value?.id ?? "");
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
                                  .edit(storage.value!);
                              setState(() {
                                storage.value?.alias = controller.text;
                                editingName = false;
                              });
                            })),
                    controller: controller,
                    onFieldSubmitted: (value) {
                      ref.read(storagesProvider.notifier).edit(storage.value!);
                      setState(() {
                        storage.value!.alias = value;
                        editingName = false;
                      });
                    })
                : Text(storage.value?.alias ?? 'No name'),
            centerTitle: true),
        body: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceBright,
              borderRadius: MediaQuery.of(context).size.width < 840
                  ? const BorderRadius.all(Radius.circular(0))
                  : const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0))),
          child: storage is AsyncData && storage.value != null
              ? EditStorage(storage: storage.value!)
              : const Center(child: CircularProgressIndicator()),
        ));
  }
}
