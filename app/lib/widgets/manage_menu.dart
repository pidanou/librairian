import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/providers/storage.dart';

class ManageMenu extends ConsumerStatefulWidget {
  final void Function(String)? onTap;
  final String selectedMenu;

  const ManageMenu({super.key, this.onTap, this.selectedMenu = "storages"});

  @override
  ConsumerState<ManageMenu> createState() => ManageMenuState();
}

class ManageMenuState extends ConsumerState<ManageMenu> {
  late String selectedMenu;
  @override
  void initState() {
    super.initState();
    selectedMenu = widget.selectedMenu;
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SegmentedButton(
          segments: const [
            ButtonSegment(
              value: "storages",
              label: Text("Storages"),
              icon: Icon(Icons.inventory_2),
            ),
            ButtonSegment(
              value: "items",
              label: Text("Items"),
              icon: Icon(Icons.category),
            )
          ],
          selected: <String>{
            selectedMenu
          },
          onSelectionChanged: (value) {
            setState(() {
              selectedMenu = value.first;
            });
            widget.onTap?.call(value.first);
          }),
      const SizedBox(width: 20),
      IconButton(
          tooltip: "Refresh data",
          icon: const Icon(Icons.refresh),
          onPressed: () {
            ref.invalidate(storageProvider);
          })
    ]);
  }
}
