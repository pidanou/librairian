import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/widgets/file_picker.dart';
import 'package:librairian/widgets/storage_selector.dart';

class EditStorageLocation extends ConsumerStatefulWidget {
  final StorageLocation? storageLocation;
  final Widget title;
  final void Function(StorageLocation?)? onSave;
  final String? itemID;

  const EditStorageLocation(
      {super.key,
      this.storageLocation,
      required this.title,
      this.onSave,
      this.itemID});

  @override
  ConsumerState createState() => EditStorageLocationState();
}

class EditStorageLocationState extends ConsumerState<EditStorageLocation> {
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
    storage = widget.storageLocation?.storage;
    controller.text = widget.storageLocation?.location ?? "";
    storageID = widget.storageLocation?.storageId;
  }

  void save() {
    if (storage == null || storageID == null || controller.text == "") {
      return;
    }
    widget.onSave?.call(StorageLocation(
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
                    // suffixIcon: (storage != null &&
                    //         (storage?.type == "Device" ||
                    //             storage?.type == "Local"))
                    //     ? FilePicker(
                    //         allowMultiple: false,
                    //         onSelect: (List<XFile>? files) {
                    //           setState(() {
                    //             controller.text = files?[0].path ?? '';
                    //           });
                    //           focus.requestFocus();
                    //         })
                    //     : const SizedBox(),
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
