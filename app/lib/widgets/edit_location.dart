import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/widgets/storage_selector.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditLocation extends ConsumerStatefulWidget {
  final Location? location;
  final Widget title;
  final void Function(Location?)? onSave;
  final String? itemID;

  const EditLocation(
      {super.key,
      this.location,
      required this.title,
      this.onSave,
      this.itemID});

  @override
  ConsumerState createState() => EditLocationState();
}

class EditLocationState extends ConsumerState<EditLocation> {
  String? storageID;

  @override
  void initState() {
    super.initState();
    storageID = widget.location?.storageId;
  }

  void save() {
    if (storageID == null) {
      return;
    }
    widget.onSave?.call(Location(storageId: storageID!));
  }

  @override
  Widget build(context) {
    return AlertDialog(
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel)),
          TextButton(
            onPressed: () {
              save();
            },
            child: Text(AppLocalizations.of(context)!.save,
                textAlign: TextAlign.end),
          )
        ],
        title: widget.title,
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          StorageSelector(
              expandedInsets: EdgeInsets.zero,
              onSelected: (s) {
                setState(() {
                  storageID = s?.id;
                });
              }),
        ]));
  }
}
