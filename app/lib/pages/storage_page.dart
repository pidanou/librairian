import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/providers/storage.dart';
import 'package:librairian/widgets/dialog_add_storage.dart';
import 'package:librairian/widgets/custom_appbar.dart';
import 'package:librairian/widgets/manage_storages.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StoragePage extends ConsumerStatefulWidget {
  const StoragePage({super.key, this.storageID});
  final String? storageID;
  @override
  StoragePageState createState() => StoragePageState();
}

class StoragePageState extends ConsumerState<StoragePage> {
  bool selectAll = false;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 840) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceBright,
        appBar: CustomAppBar(
          title: Text(AppLocalizations.of(context)!.myStorages),
          actions: [
            IconButton(
                tooltip: AppLocalizations.of(context)!.add,
                icon: const Icon(Icons.add_circle),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const DialogAddStorage();
                      });
                }),
          ],
        ),
        body: content(context),
      );
    }
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceBright,
            borderRadius: MediaQuery.of(context).size.width < 840
                ? const BorderRadius.all(Radius.circular(0))
                : const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0))),
        child: content(context));
  }

  Widget content(BuildContext context) {
    return Column(children: [
      if (MediaQuery.of(context).size.width > 840) ...[
        ListTile(
          title: Row(children: [
            IconButton(
                tooltip: AppLocalizations.of(context)!.add,
                icon: const Icon(
                  Icons.add_circle,
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const DialogAddStorage();
                      });
                }),
            if (MediaQuery.of(context).size.width > 840)
              IconButton(
                  tooltip: AppLocalizations.of(context)!.refresh,
                  icon: const Icon(
                    Icons.refresh,
                  ),
                  onPressed: () {
                    ref.invalidate(storagesProvider);
                  })
          ]),
        ),
        Divider(
          color: Theme.of(context).colorScheme.surfaceDim,
          height: 0,
        )
      ],
      Expanded(
          child: ManageStorages(
        selectAll: selectAll,
      )),
    ]);
  }
}
