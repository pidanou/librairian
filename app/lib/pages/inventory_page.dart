import 'package:flutter/material.dart';
import 'package:librairian/widgets/manage_menu.dart';
import 'package:librairian/widgets/manage_storages.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key, this.selectedMenu = "storages"});
  final String selectedMenu;
  @override
  ManagePageState createState() => ManagePageState();
}

class ManagePageState extends State<InventoryPage> {
  late String selectedMenu;

  @override
  void initState() {
    super.initState();
    selectedMenu = widget.selectedMenu;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceBright,
            borderRadius: MediaQuery.of(context).size.width < 600
                ? const BorderRadius.all(Radius.circular(0))
                : const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0))),
        child: Column(children: [
          Padding(
              padding:
                  const EdgeInsets.only(left: 16, top: 5, bottom: 5, right: 16),
              child: ManageMenu(
                  selectedMenu: selectedMenu,
                  onTap: (value) {
                    setState(() {
                      selectedMenu = value;
                    });
                  })),
          Divider(
            color: Theme.of(context).colorScheme.surfaceDim,
            height: 0,
          ),
          Expanded(
              child: Row(
            children: [
              if (selectedMenu == "storages")
                const Expanded(child: ManageStorages()),
              if (MediaQuery.of(context).size.width > 840) ...[
                VerticalDivider(
                  color: Theme.of(context).colorScheme.surfaceDim,
                  width: 1,
                ),
                if (selectedMenu == "storages")
                  const Expanded(child: ManageStorages())
              ]
            ],
          ))
        ]));
  }
}
