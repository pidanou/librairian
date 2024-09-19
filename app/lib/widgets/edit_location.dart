import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/widgets/storage_selector.dart';

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
  Storage? storage;
  String? storageID;
  TextEditingController controller = TextEditingController();
  late FocusNode focus = FocusNode(
    onKeyEvent: (FocusNode node, KeyEvent evt) {
      if (evt.logicalKey.keyLabel == 'Enter') {
        save();
        return KeyEventResult.handled;
      } else {
        return KeyEventResult.ignored;
      }
    },
  );

  @override
  void initState() {
    super.initState();
    storage = widget.location?.storage;
    controller.text = widget.location?.location ?? "";
    storageID = widget.location?.storageId;
  }

  void save() {
    if (storage == null || storageID == null || controller.text == "") {
      return;
    }
    widget.onSave?.call(Location(
        storage: storage, location: controller.text, storageId: storageID));
  }

  @override
  Widget build(context) {
    return AlertDialog(
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              save();
            },
            child: const Text("Save", textAlign: TextAlign.end),
          )
        ],
        title: widget.title,
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          StorageSelector(
              initialSelection: storage,
              expandedInsets: EdgeInsets.zero,
              onSelected: (s) {
                setState(() {
                  storage = s;
                  storageID = s?.id;
                });
              }),
          const SizedBox(height: 10),
          SizedBox(
              width: 500,
              child: Row(children: [
                Expanded(
                    child: TextFormField(
                  textInputAction: TextInputAction.none,
                  decoration: const InputDecoration(
                    hintText: "Location",
                  ),
                  focusNode: focus,
                  onFieldSubmitted: (s) {
                    save();
                  },
                  controller: controller,
                  maxLines: null,
                )),
              ]))
        ]));
  }
}
