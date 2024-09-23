import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:librairian/providers/storage.dart' as sp;
import 'package:librairian/models/storage.dart';
import 'package:librairian/widgets/edit_storage.dart';

class ManageStorages extends ConsumerStatefulWidget {
  const ManageStorages({required this.selectAll, this.editing, super.key});
  final bool selectAll;
  final Storage? editing;

  @override
  ManageStoragesState createState() => ManageStoragesState();
}

class ManageStoragesState extends ConsumerState<ManageStorages> {
  Storage? editing;
  List<String> selected = [];
  bool selectAll = false;

  @override
  void initState() {
    editing = widget.editing;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var storages = ref.watch(sp.storagesProvider);
    if (storages is AsyncError) {
      print("error");
      return const Column(children: [Center(child: Text('Error'))]);
    }
    if (storages is AsyncData) {
      return Row(children: [
        Expanded(
            flex: 1,
            child: Column(children: [
              Expanded(
                  child: RefreshIndicator(
                      onRefresh: () => ref.refresh(sp.storagesProvider.future),
                      child: ListView(children: [
                        for (var storage in storages.value ?? [])
                          Material(
                              type: MaterialType.transparency,
                              child: ListTile(
                                selected: storage.id == editing?.id,
                                selectedColor:
                                    Theme.of(context).colorScheme.onSurface,
                                selectedTileColor:
                                    Theme.of(context).colorScheme.surfaceDim,
                                onTap: () {
                                  if (MediaQuery.of(context).size.width > 840) {
                                    setState(() {
                                      editing = storage;
                                    });
                                  } else {
                                    GoRouter.of(context).go(
                                        '/storage/${storage.id}',
                                        extra: storage);
                                  }
                                },
                                title: Text(storage.alias),
                              ))
                      ])))
            ])),
        if (MediaQuery.of(context).size.width > 840) ...[
          VerticalDivider(
            color: Theme.of(context).colorScheme.surfaceDim,
            width: 1,
          ),
          editing != null
              ? Expanded(
                  flex: 2,
                  child: EditStorage(
                      storage: editing!,
                      onDelete: () {
                        setState(() {
                          editing = null;
                        });
                      }))
              : const Expanded(
                  flex: 2,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text("No storage selected")]))
        ]
      ]);
    }
    return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Center(child: CircularProgressIndicator())]);
  }
}
